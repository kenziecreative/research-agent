---
phase: 16-cli-polish
reviewed: 2026-04-20T00:00:00Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - .claude/commands/research/check-gaps/SKILL.md
  - .claude/commands/research/cross-ref/SKILL.md
  - .claude/commands/research/discover/SKILL.md
  - .claude/commands/research/init/SKILL.md
  - .claude/commands/research/process-source/SKILL.md
  - .claude/reference/prompt-templates.md
findings:
  critical: 1
  warning: 2
  info: 2
  total: 5
status: issues_found
---

# Phase 16: Code Review Report

**Reviewed:** 2026-04-20
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

Reviewed six SKILL.md and reference files governing the research agent's CLI workflow. The files are well-structured with thorough guardrails and failure mode tables. One critical issue was found in `init/SKILL.md`: a conflict between the frontmatter `disable-model-invocation: true` flag and the explicit instruction to launch a subagent in Step 4. Two warnings were found: an Exa degradation instruction that silently skips a log write that should be recorded, and a direct self-contradiction in `prompt-templates.md` about which skills should use the transition prompt template.

---

## Critical Issues

### CR-01: `disable-model-invocation: true` conflicts with subagent launch in Step 4

**File:** `.claude/commands/research/init/SKILL.md:4` and `:165`

**Issue:** The SKILL.md frontmatter declares `disable-model-invocation: true` on line 4. Step 4 (line 165) instructs the executing agent to "Launch an agent (use `subagent_type: 'general-purpose'`, model: `opus`) to generate the research plan." These two directives are incompatible. If `disable-model-invocation` is enforced by the runner, the subagent launch will fail silently or throw an error at exactly the most expensive step of init — after the user has answered three questions and the project directories have been created, but before the research plan is written. The user receives no feedback and the project is left in a partially-initialized state (directories exist, no research plan).

**Fix:** Resolve the conflict in one of two ways:

Option A — if the flag is intended to prevent the *init skill itself* from being invoked by another model (i.e., it guards against recursive init calls), rename it to something more precise such as `disable-recursive-invocation: true` and document the semantics in the frontmatter comment.

Option B — if the flag was added to prevent model invocations generally (wrong intent for this skill), remove it from the frontmatter:

```yaml
---
name: init
description: Scaffold a structured research project with state management, evidence standards, and agent-driven workflows
# remove: disable-model-invocation: true
---
```

---

## Warnings

### WR-01: Exa degradation instruction says "skip silently" but retrieval log requires recording all failures

**File:** `.claude/commands/research/discover/SKILL.md:385` and `:121-126`

**Issue:** The Exa degradation rule on line 385 states: "If `EXA_API_KEY` is absent, or Exa returns error/timeout, skip silently." However, Step 2i (lines 121–126) requires an accumulation of retrieval log entries "even when status is 'error' or 'skipped'" — the table explicitly lists `status` values of `"error"` and `"skipped"` and the instruction at line 125 states "Failed channels: Accumulate an entry even when status is 'error' or 'skipped'." These two directives conflict. "Skip silently" implies no log entry; the Step 2i contract requires one. On an Exa failure the log entry will either be missing (if "skip silently" wins) or present (if Step 2i wins), depending on which instruction the agent follows. The inconsistency also means the `deduped_count` and `results_count` fields on the missing entry can never be set to 0 as specified.

**Fix:** Change the Exa degradation text to align with the Step 2i contract:

```
Exa degradation: If EXA_API_KEY is absent, or Exa returns error/timeout, log the
failure as a retrieval log entry with status: "skipped" (key absent) or "error"
(timeout/API error), results_count: 0, urls: [], degraded_to: null. Do NOT suppress
the log entry — print: "Exa: unavailable — web search results from Tavily only".
Exa failure does not trigger Tavily fallbacks — they are independent parallel tools.
```

---

### WR-02: `prompt-templates.md` contradicts itself about which skills use the transition prompt

**File:** `.claude/reference/prompt-templates.md:44-47` and `:141-143`

**Issue:** The "When NOT to use it" section (lines 44–47) explicitly lists `/research:cross-ref` and `/research:check-gaps` as skills that should NOT use the transition prompt template: "Read-only status skills — `/research:progress`, `/research:check-gaps`, `/research:cross-ref` ... These skills inform a decision the user is about to make; they don't transition to the next one."

The "Skills That Use This Template" section (lines 141–143) then lists both `/research:cross-ref` and `/research:check-gaps` as skills that DO use the template: `- /research:cross-ref — after cross-reference report (context-sensitive)` and `- /research:check-gaps — after gap analysis (context-sensitive)`.

Both `cross-ref/SKILL.md` and `check-gaps/SKILL.md` contain explicit transition prompt blocks at their ends, consistent with the "Skills That Use" list. The "When NOT to use it" section appears to be stale guidance that was not updated when context-sensitive transition prompts were added to those skills.

**Fix:** Update the "When NOT to use it" section to remove `cross-ref` and `check-gaps` from the read-only list, or add a qualifier that explains the context-sensitive exception:

```markdown
- **Read-only status skills with no unambiguous next step** — `/research:progress`
  (unconditionally read-only). Note: `/research:check-gaps` and `/research:cross-ref`
  use the template in context-sensitive mode — they include a transition prompt only
  when the recommended next action is unambiguous (e.g., all contradictions require
  resolution, or all coverage is adequate). See those skills' Output sections for the
  specific conditions that trigger the block.
```

---

## Info

### IN-01: Pre-check step numbering in `discover/SKILL.md` uses non-sequential labels

**File:** `.claude/commands/research/discover/SKILL.md:15-25`

**Issue:** The Pre-check section labels steps as `1`, `1a`, `2`, `3`, `4a`, `4b`, `5`, `6`, `7`. The jump from `1a` back to `2` (skipping `1b`) and the parallel `4a`/`4b` pattern is consistent with the content but unusual enough that it may cause agents to misread the step ordering, particularly between `1` and `1a` where `1a` is described as a sub-check that feeds back into whether `1` passes.

**Fix:** No functional change required. Consider renaming `1a` to `1b` for consistency with the `4a`/`4b` pair, or restructure as a nested list under step 1 to signal it is a sub-step:

```markdown
1. **Read `research/STATE.md`** — extract the current active phase name.
   - If STATE.md does not exist: error...
   - If STATE.md exists but Active phase is missing: error...
   - If Active phase is a completion sentinel: error...

   **1a. Stale-active-phase check (self-healing).** ...
```

---

### IN-02: `init/SKILL.md` Step 7 hardcodes "ten research skills" but the list has grown

**File:** `.claude/commands/research/init/SKILL.md:751`

**Issue:** Step 7 instructs: "Include the ten research skills available: `/research:init`, `/research:discover`, ..." and lists exactly 10 skills. The CLAUDE.md section 4 skills table (line 421) lists 10 rows — currently consistent. However, the count is hardcoded as the English word "ten" rather than derived from the list, so if a skill is added or removed the text will be wrong without an obvious indicator that it needs updating.

**Fix:** Remove the hardcoded count and let the list be self-documenting:

```markdown
- The research skills available (list each with its `/research:*` qualified name):
  `/research:init`, `/research:discover`, `/research:process-source`, ...
```

---

_Reviewed: 2026-04-20_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
