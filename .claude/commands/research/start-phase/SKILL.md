---
name: start-phase
description: Show what's needed to begin the next research phase — questions, prior findings, and context
allowed-tools: Read, Grep, Glob
disable-model-invocation: true
---

# /research:start-phase

Prepare to begin the next research phase by gathering all relevant context.

## Current State

!`cat research/STATE.md 2>/dev/null || echo "No STATE.md found — run /research:init first."`

## Process

1. **Read `research/STATE.md`** to determine the current active phase.
2. **Read `research/research-plan.md`** to get the details for the next phase — its name, what needs to be validated/explored/analyzed, and the specific questions.
3. **Read `research/gaps.md`** to check if any gaps from previous phases are relevant to this phase.
4. **Read `research/cross-reference.md`** to identify any patterns from earlier phases that inform this one.
5. **Check for skipped or folded phases** in STATE.md. If any exist, report them to the user with context.

## Output

Present a briefing for the phase:

### Phase [N]: [Name]

**Questions to answer:**
- [List each question from the research plan for this phase]

**Relevant prior findings:**
- [Any findings from completed phases that connect to this phase's questions]
- [Any cross-reference patterns that are relevant]

**Gaps carried forward:**
- [Any unresolved gaps from previous phases that overlap with this phase]

**Skipped/Folded phases:** [List any, or "None"]

**Ready to begin:** Start collecting sources with `/research:process-source` for Phase [N] questions only.

## Guardrails

1. Do not present a phase briefing if the previous phase's cycle is incomplete. Check STATE.md first — all five steps must be checked.
2. If STATE.md records skipped or folded phases, surface them explicitly before presenting the next phase's briefing.
3. Do not pre-collect sources or begin research as part of the briefing. This skill prepares context; source collection is a separate step.
4. Carry forward only documented gaps and cross-reference patterns — do not carry forward interpretations or conclusions from conversation history.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Starting a phase before the previous one is complete | Read STATE.md's cycle checklist. If any step is unchecked, tell the user what remains before presenting the next phase. |
| Presenting stale prior findings from conversation memory instead of files | Read cross-reference.md and gaps.md fresh. Do not rely on what was discussed earlier in the session. |
| Overwhelming the briefing with prior-phase detail that obscures the current phase's questions | Keep prior findings to bullet points directly relevant to the new phase's questions. The full prior output is in research/outputs/ if needed. |
| Missing carried-forward gaps that affect the new phase | Always check gaps.md for unresolved items from prior phases. An unresolved gap about market size from Phase 2 matters if Phase 5 asks about revenue projections. |

This skill is read-only — it does NOT write any files.
