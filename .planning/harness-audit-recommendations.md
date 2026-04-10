# Research Agent: Harness Audit Recommendations

## Background

These recommendations come from evaluating the research-agent codebase against the 12 infrastructure primitives identified in Nate Jones's analysis of the Claude Code source leak ("Your Agent Is 80% Plumbing"). The full codebase was read — all 10 skills, the research-integrity agent, all reference files, hooks, settings, templates, and the state management system.

The research agent is already strong on several primitives that most agent systems miss entirely: workflow state with explicit phase cycles, a formal verification harness (research-integrity agent + audit-claims gate), enforced permission boundaries via PreToolUse hooks, and session persistence through STATE.md. These aren't surface-level implementations — the canonical figures registry alone is more sophisticated than what most production systems have for cross-document consistency.

The gaps below are the places where the existing infrastructure could be extended with relatively low effort to close the remaining primitive coverage.

---

## Recommendation 1: Permission Audit Trail

**Primitive:** Permission audit trail (Nate's Week One tier)

**What's missing:** The PreToolUse hooks on Write and Edit enforce hard gates — they block writes to `research/outputs/` without a passing audit. But they don't log their decisions anywhere persistent. When a write is blocked, the user sees an error in the conversation, but there's no durable record. When a write is allowed, there's no record of what was checked and why it passed.

**Why it matters:** Without a trail, you can't answer "what was this agent allowed to do during this session?" after the fact. If a user hits a blocked write and clears context, the next session has no way to know it happened. It also means there's no way to audit whether the hooks are actually firing — silent hook failures would be invisible.

**Recommendation:** Add a shared `append_audit_entry` function (similar to the pattern in trailhead's hook-utils.sh) and call it from both PreToolUse hooks. Log to `research/audits/gate-log.md` (or `.planning/security/audit-log.md` if you prefer the trailhead convention). Each entry should capture: timestamp, action (write-to-outputs, edit-outputs), result (ALLOWED or BLOCKED), and detail (which file, which audit report was checked).

Log both outcomes — allowed and blocked. The allowed entries are just as important for establishing that the gate was checked.

**Scope:** Small. One shared function, two hook modifications, ~20 lines total.

---

## Recommendation 2: Token/Session Budget Awareness

**Primitive:** Token budget tracking with pre-turn checks (Nate's Day One tier)

**What's missing:** There's no budget awareness anywhere in the system. A research session that processes 15 sources with `tavily_extract`, runs cross-ref twice, and writes two drafts can consume significant context and API budget without any visibility. There's no "approaching limit" warning and no "wrap up" behavior.

**Why it matters:** Research sessions are inherently long and tool-heavy. The process-source skill alone involves fetch + verify + assess + structure + register + update STATE.md per source. Multiply by 10-15 sources per phase and you're deep into budget territory. The user has no signal that they should checkpoint and start a fresh session until they hit a wall.

**Recommendation:** Add a `## Session Budget` section to STATE.md that tracks: sources processed this session, tool calls this session (approximate — increment in process-source and discover), and a configurable soft limit. Add a pre-check to process-source that warns when approaching the limit: "You've processed N sources this session. Consider running /research:cross-ref and clearing context before continuing." This doesn't need to be precise — a rough counter that encourages session hygiene is enough.

**Scope:** Medium. STATE.md template change, process-source pre-check addition, ~30 lines across two files.

---

## Recommendation 3: System Health Check in /research:progress

**Primitive:** The doctor pattern (Nate's Week One tier)

**What's missing:** `/research:progress` is a project dashboard — it shows phase status, source counts, and blocking issues. But it doesn't validate that the system infrastructure itself is healthy. If a hook registration is missing from settings.json, if canonical-figures.json has invalid JSON, if a reference file was accidentally deleted, or if STATE.md structure is malformed, progress won't catch it. You'd only discover the problem when a skill fails mid-execution.

**Why it matters:** Research sessions can be long and expensive. Discovering that your audit gate hook was silently deregistered after you've processed 8 sources and written a draft means the draft may have been written to outputs/ without passing audit. Catching infrastructure problems at the start of a session is much cheaper than catching them after work is done.

**Recommendation:** Add a `## System Health` section to the progress skill output that validates:
- settings.json exists and contains expected PreToolUse hook registrations
- canonical-figures.json exists and parses as valid JSON
- STATE.md exists and contains expected section headers (Current Position, Current Phase Cycle, Sources Processed)
- Reference files present: source-standards.md, writing-standards.md, tools-guide.md
- Discovery strategy.md exists (if past init)
- research/sources/registry.md exists

Report as a simple pass/warning list at the top of the progress output. If any infrastructure check fails, surface it before the project status — broken infrastructure is more urgent than phase progress.

**Scope:** Medium. Additions to progress/SKILL.md, ~40 lines of new checks.

---

## Recommendation 4: Idempotency Guard for process-source

**Primitive:** Workflow state and idempotency (Nate's Day One tier)

**What's missing:** If process-source crashes or context clears between writing the note file and updating the registry/STATE.md, the source is partially processed. The next session might re-process the same URL, creating a duplicate note, or skip it thinking it's done when STATE.md wasn't updated. There's no dedupe check at the start of process-source.

**Why it matters:** Re-processing a source wastes a tavily_extract call and creates confusing duplicate notes. Worse, if the first note was partially written (truncated due to context loss), the registry might point to a broken file. The canonical figures registry could end up with duplicate entries for the same source if the crash happened after note creation but before registry update.

**Recommendation:** Add an early check to process-source: before fetching, scan `research/sources/registry.md` and `research/notes/` for the URL or a slug derived from it. If found in registry but note file is missing or truncated, warn: "This source appears partially processed. Note file may be incomplete." If found in both registry and notes with a complete note, warn: "This source was already processed — see research/notes/{file}. Process again to update, or skip."

This doesn't need to be a hard block — just awareness. The user decides whether to re-process or skip.

**Scope:** Small. One pre-check addition to process-source/SKILL.md, ~15 lines.

---

## Recommendation 5: Structured Event Log

**Primitive:** System event logging (Nate's Day One tier)

**What's missing:** The research agent has excellent domain-specific logging — audit reports, discovery candidates, source registry, cross-reference patterns. But there's no unified system event log that captures operational events: which skills were invoked, when hooks fired, when STATE.md was updated, when degradation occurred (Tavily → WebSearch fallback). The conversation transcript is the only record of these events, and it's lost on context clear.

**Why it matters:** When debugging "why did this phase take so long" or "why are my sources all from WebSearch," the answer is in operational events that currently only exist in ephemeral conversation context. A persistent event log would let the user (or a future session) understand what happened during a research session without re-reading the entire conversation.

**Recommendation:** Add a `research/session-events.md` file with a simple append-only table: timestamp, event type (skill-invoked, gate-checked, degradation, state-updated, phase-transition), and detail. Have each skill append a one-line entry when it starts and completes. Have hooks append when they fire. Cap at 200 rows, trim oldest when exceeded.

This is lower priority than recommendations 1-4 because the domain-specific logs (audits, registry, discovery) already capture most of what matters. But it would close the "what happened between sessions" gap.

**Scope:** Medium. Shared append function, additions to each skill and hook, ~50 lines spread across files.

---

## Priority Order

1. **Permission audit trail** — Easiest win, closes a real blind spot in the gate system
2. **Idempotency guard** — Small change, prevents a concrete failure mode
3. **System health in progress** — Medium effort, catches infrastructure rot early
4. **Session budget awareness** — Medium effort, prevents expensive session failures
5. **Structured event log** — Lower priority, nice-to-have for operational visibility

Items 1 and 2 could ship together as a single commit. Item 3 is independent. Items 4 and 5 are independent of everything else.
