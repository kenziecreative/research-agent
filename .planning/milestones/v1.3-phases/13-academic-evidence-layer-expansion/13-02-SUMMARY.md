---
phase: 13-academic-evidence-layer-expansion
plan: "02"
subsystem: gap-analysis
tags: [gap-analysis, classification, coverage-status, evidence-quality]
requires: []
provides: [four-tier-classification, evidence-against-status]
affects: [check-gaps-skill, coverage-assessment-guide]
tech-stack:
  added: []
  patterns: [self-analog extension, advisory-not-gate]
key-files:
  created: []
  modified:
    - .claude/reference/coverage-assessment-guide.md
    - .claude/commands/research/check-gaps/SKILL.md
decisions:
  - "Add Contradicts as fourth classification tier between Adjacent and None, following existing bold-name + definition + counting-rule format"
  - "Evidence Against status defined as 0 Direct + 1+ Contradicts — distinct from Not Started (no sources at all)"
  - "Advisory-not-gate: Evidence Against is informational, mirrors Addressed but unbalanced framing"
  - "Guardrail 10 and Common Failure Modes row provide redundant protection against Contradicts/Adjacent conflation"
metrics:
  duration: "<10 minutes"
  completed: 2026-04-20
  tasks_completed: 2
  files_modified: 2
requirements: [TRACE-05]
---

# Phase 13 Plan 02: Contradicts Classification and Evidence Against Status Summary

Four-tier classification (Direct/Adjacent/Contradicts/None) and Evidence Against coverage status extending both the reference guide and check-gaps skill to distinguish absence of evidence from active counter-evidence.

## What Was Built

Two documentation files updated to add:

1. **coverage-assessment-guide.md** — Extended Match Classification section with Contradicts as the fourth tier (between Adjacent and None), plus a second critical rule distinguishing Contradicts from Adjacent. Added Evidence Against as a fifth Coverage Status. Updated workflow step 1 to include Contradicts and added step 2 for Contradicts verification guidance (7 steps total, was 6).

2. **check-gaps/SKILL.md** — Six targeted edits: step 4 guide reference updated, step 6 classification loop extended (6a, new 6c, new 6g), dashboard adds 2 counters, per-question Coverage bracket and Contradicts sources section added, highest-priority gaps list extended with Evidence Against in status bracket and criticality item 2, Note distinguishing discovery targets from synthesis challenges, Guardrail 10, and Common Failure Modes row.

## Commits

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Extend coverage-assessment-guide.md | cf1e682 | .claude/reference/coverage-assessment-guide.md |
| 2 | Extend check-gaps/SKILL.md | 7c23ca7 | .claude/commands/research/check-gaps/SKILL.md |

## Verification Results

| Check | Result |
|-------|--------|
| coverage-assessment-guide.md "Contradicts" count >= 5 | 5 |
| check-gaps/SKILL.md "Contradicts" count >= 5 | 9 |
| check-gaps/SKILL.md "Evidence Against" count >= 4 | 7 |
| "one of four tiers" in coverage-assessment-guide.md | PASS |
| "Evidence Against" in coverage-assessment-guide.md | PASS |
| Direct/Adjacent/None still present | PASS |

## Deviations from Plan

None - plan executed exactly as written. The PATTERNS.md referenced "Guardrail 9" while the PLAN.md specified "Guardrail 10" — because the current SKILL.md already had 9 guardrails, adding as Guardrail 10 is the correct action per the plan instructions.

## Threat Model Coverage

| Threat | Mitigation Applied |
|--------|-------------------|
| T-13-05: Contradicts classification accuracy (Tampering) | Guardrail 10 + critical rule in coverage-assessment-guide.md + Common Failure Modes row |
| T-13-06: Evidence Against hiding gaps (Repudiation) | Evidence Against surfaces in dashboard counter + priority list item 2 |
| T-13-07: Information Disclosure | Accepted — no new sensitive data flows |

## Known Stubs

None. Both files are documentation/instructions; no data placeholders exist.

## Threat Flags

None — no new network endpoints, auth paths, file access patterns, or schema changes introduced.

## Self-Check: PASSED

- `.claude/reference/coverage-assessment-guide.md` — modified, committed cf1e682
- `.claude/commands/research/check-gaps/SKILL.md` — modified, committed 7c23ca7
- Commits cf1e682 and 7c23ca7 confirmed in git log
