---
phase: 11-claim-graph-foundation
reviewed: 2026-04-20T00:00:00Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - .claude/agents/research-integrity.md
  - .claude/commands/research/audit-claims/SKILL.md
  - .claude/commands/research/init/SKILL.md
findings:
  critical: 0
  warning: 1
  info: 3
  total: 4
status: issues_found
---

# Phase 11: Code Review Report

**Reviewed:** 2026-04-20
**Depth:** standard
**Files Reviewed:** 3
**Status:** issues_found

## Summary

Three files reviewed: the `research-integrity` agent definition and the `audit-claims` and `init` SKILL.md files. These files represent the claim-graph foundation layer — the init scaffold, the audit pass that writes claim nodes, and the integrity agent that checks graph-audit consistency.

No critical issues found. One warning-level ambiguity was found in the final-phase branch of audit-claims around a destructive/non-destructive option that could leave STATE.md malformed. Three info-level drift issues were found, all stemming from the same root cause: `init` now scaffolds `claim-graph.json` at project creation time, which makes two "file does not exist" guards in `audit-claims` and `research-integrity` dead code. These guards are harmless in practice but represent spec drift that could mislead future maintainers.

---

## Warnings

### WR-01: Final-phase STATE.md closeout has ambiguous "remove it or replace it with" instruction

**File:** `.claude/commands/research/audit-claims/SKILL.md:163`

**Issue:** The final-phase branch in the PASS closeout reads: "Do NOT generate a new Current Phase Cycle block — remove it or replace it with `*(No active phase — all phases complete.)*`". The phrase "remove it or replace it with" presents two structurally different operations as equivalent alternatives. Removing the `Current Phase Cycle` block leaves STATE.md without that section entirely; replacing it inserts the parenthetical placeholder. Downstream resume behavior (read STATE.md, find `Current Phase Cycle`) depends on the placeholder being present — a session that resumes on a completed project must be able to read `Current Phase Cycle` and understand the project is done. If the agent selects "remove it," the section header disappears and resume logic that scans for `Current Phase Cycle` may fail silently or branch incorrectly.

The intent is clearly "replace with the placeholder text," but "remove it" as an explicitly-named option invites the wrong choice.

**Fix:**
```markdown
- Do NOT generate a new Current Phase Cycle block — replace it with:
  `*(No active phase — all phases complete.)*`
```

Remove "remove it or" entirely. The replacement text is the safe, unambiguous instruction.

---

## Info

### IN-01: Check 9 in research-integrity.md has a now-dead "file does not exist" guard

**File:** `.claude/agents/research-integrity.md:65`

**Issue:** Check 9 reads: "If the file does not exist, skip this check without comment (the graph is scaffolded at init but populated only after the first audit-claims run)." The parenthetical is now factually incorrect — `init` scaffolds `claim-graph.json` with `{"claims": []}` (init SKILL.md line 686), so the file will always exist after project initialization. The guard fires only if `research/reference/claim-graph.json` was manually deleted, which is an unusual scenario not otherwise addressed in the spec. The parenthetical comment misleads anyone reading the agent's intent.

**Fix:** Update the parenthetical to reflect current behavior:
```markdown
If the file does not exist, skip this check without comment (the file is
created by /research:init — its absence indicates an incomplete scaffold or
manual deletion, not a pre-audit project state).
```

---

### IN-02: audit-claims "create if not exists" branch for claim-graph.json is dead code

**File:** `.claude/commands/research/audit-claims/SKILL.md:92`

**Issue:** Step 8b reads: "Read `research/reference/claim-graph.json`. If the file does not exist, create it with `{"claims": []}`. " Since `init` now always creates this file (init SKILL.md line 686-687), the "if the file does not exist, create it" branch is unreachable in normal project flow. The guard is harmless, but it implies audit-claims is responsible for bootstrapping the file, which conflicts with the init skill's responsibility for scaffolding.

**Fix:** Update to reflect that init owns the file's creation:
```markdown
Read `research/reference/claim-graph.json`. The file is created by
/research:init — if it is missing, that indicates an incomplete scaffold;
log a warning and skip the graph write rather than creating the file here.
```

Alternatively, keep the fallback create as defensive infrastructure but remove the implication that this is a normal code path.

---

### IN-03: canonical-figures.json corruption recovery instruction is underspecified

**File:** `.claude/commands/research/audit-claims/SKILL.md:30`

**Issue:** Step 6a instructs: "stop the audit and tell the user: `research/reference/canonical-figures.json` exists but cannot be parsed as JSON. This is a registry corruption — restore from git or fix the file manually before re-running the audit." The hard-stop is correct since `canonical-figures.json` is an evidence gate. However, "restore from git or fix the file manually" gives no guidance on what valid JSON structure looks like for this file, and users who aren't git-fluent have no recovery path. A user who receives this error cannot fix the file without knowing its schema.

**Fix:** Append the expected schema to the error message:
```
"research/reference/canonical-figures.json" exists but cannot be parsed as JSON.
This is a registry corruption — restore from git or recreate it manually. The file
must be valid JSON with a top-level object containing a "figures" array (or whatever
the canonical schema is). Do not proceed until the file parses correctly.
```

Alternatively, add a reference to where the schema template lives (`.claude/reference/templates/canonical-figures.json`) so the user can use it as a recovery baseline.

---

_Reviewed: 2026-04-20_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
