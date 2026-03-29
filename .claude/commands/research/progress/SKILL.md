---
name: progress
description: Show research project dashboard — phase status, source counts, and next action
allowed-tools: Read, Grep, Glob
disable-model-invocation: true
---

# /research:progress

Show the current state of the research project as a dashboard.

## Current State

!`cat research/STATE.md 2>/dev/null || echo "No STATE.md found — run /research:init first."`

## Process

1. **Read `research/STATE.md`** for current position, active phase, and completed phases.
2. **Count files:**
   - `research/notes/` — total source notes
   - `research/drafts/` — drafts pending audit
   - `research/outputs/` — audited outputs
   - `research/audits/` — audit reports
3. **Read `research/research-plan.md`** to get the full phase list.
4. **Read `research/cross-reference.md`** and count the number of identified patterns.
5. **Read `research/gaps.md`** to identify any blocking gaps.

## Output

### Research Progress

| Phase | Status | Sources | Draft | Audit | Output |
|-------|--------|---------|-------|-------|--------|
| 1. [Name] | Complete/Active/Pending | [N] | [Yes/No] | [Pass/Fail/—] | [Yes/No] |
| 2. [Name] | ... | ... | ... | ... | ... |
| ... | | | | | |

**Source notes:** [N] total
**Cross-reference patterns:** [N] identified
**Blocking issues:** [Any gaps or issues preventing progress, or "None"]

**Next action:** [What to do next based on current cycle step]

## Guardrails

1. Report exactly what STATE.md and the files say. Do not editorialize on progress quality.
2. If STATE.md and the actual file counts disagree (e.g., STATE.md says 5 sources but there are 7 files in notes/), report the discrepancy.
3. Do not recommend skipping phases or batching work to "speed things up."
4. Show blocking issues prominently — a stale cross-reference or undone gap check is a blocker, not a footnote.

This skill is read-only — it does NOT write any files.
