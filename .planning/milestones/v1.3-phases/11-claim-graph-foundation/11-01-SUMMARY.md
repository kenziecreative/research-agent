---
phase: 11-claim-graph-foundation
plan: "01"
subsystem: audit-claims
tags: [claim-graph, audit, traceability, TRACE-01]
dependency_graph:
  requires: []
  provides: [claim-graph-write-path]
  affects: [audit-claims/SKILL.md]
tech_stack:
  added: []
  patterns: [read-then-write-verify, non-blocking-error-handling, deduplication-by-equality]
key_files:
  created: []
  modified:
    - .claude/commands/research/audit-claims/SKILL.md
decisions:
  - "Step 8b executes after confidence tier computation (8a) and before audit report write (9) — all claim data already in working memory at that point, no extra reads needed"
  - "Graph write failure is non-blocking: logs WARNING in audit report, skips graph write, audit continues. The audit gate protects research quality; the graph is downstream infrastructure."
  - "Deduplication is by phase + section + text equality — overwrites on re-audit, never duplicates"
  - "Verify-after-write pattern mirrors step 9 (audit report) — re-reads file, confirms valid JSON with claims array"
metrics:
  duration: "~5 minutes"
  completed_date: "2026-04-20"
  tasks_completed: 1
  tasks_total: 1
  files_modified: 1
requirements_satisfied: [TRACE-01]
---

# Phase 11 Plan 01: Claim Graph Write Path Summary

**One-liner:** Step 8b added to audit-claims SKILL.md — writes claim nodes with full D-05 schema to claim-graph.json after confidence tier computation, with deduplication and non-blocking error handling.

## What Was Done

Inserted step 8b into `.claude/commands/research/audit-claims/SKILL.md` between step 8a (confidence tier computation, line 77) and step 9 (audit report write, line 100).

Step 8b instructs the audit-claims agent to:
1. Construct a claim node for every factual claim traced in step 5, using data already in agent working memory (confidence tier from 8a, source files from step 5, figure IDs from step 6a)
2. Read `research/reference/claim-graph.json` — create with `{"claims": []}` if absent, warn and skip if parse fails
3. Deduplicate by `phase` + `section` + `text` equality — overwrite on re-audit, append new claims
4. Write updated JSON back, then re-read to verify write succeeded
5. Log a WARNING and continue (never fail the audit) on any graph write issue

Also added a Common Failure Modes table entry for "Graph write blocking audit promotion" — clarifying that the graph is supplementary infrastructure, not an evidence gate.

## Commits

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Insert step 8b into audit-claims SKILL.md | 18d7831 | .claude/commands/research/audit-claims/SKILL.md |

## Acceptance Criteria Verification

- [x] SKILL.md contains `8b. **Write claim graph nodes to research/reference/claim-graph.json.**`
- [x] Step 8b appears AFTER "Add to the scorecard output (step 8) after severity distribution." (line 77)
- [x] Step 8b appears BEFORE "9. **Write audit report" (line 100)
- [x] All 9 field definitions present: `id`, `text`, `phase`, `section`, `confidence_tier`, `source_files`, `figure_ids`, `evidence_directness`, `source_count`
- [x] Deduplication rule: "matched by `phase` + `section` + `text` equality"
- [x] Error handling: "do not fail the audit"
- [x] ID generation example: `c001-market-size-exceeds-four`
- [x] Verify-after-write: "Re-read the file and confirm it parses as valid JSON"
- [x] Common Failure Modes entry: "Graph write blocking audit promotion"

## Deviations from Plan

None — plan executed exactly as written. The verbatim step 8b text from the plan was inserted precisely at the specified location with no modifications.

## Threat Surface Scan

No new network endpoints, auth paths, or trust boundaries introduced. Step 8b writes to `research/reference/claim-graph.json` — a project-local file within the existing agent working directory. T-11-02 (parse failure causing audit block) is mitigated by the non-blocking error handling in the step text. No new threat flags.

## Known Stubs

None. Step 8b is complete instruction text — no placeholder content, no TODO markers. The claim-graph.json file itself does not yet exist as a template (it is created at runtime by audit-claims or at project init by 11-02), but that is expected and covered by the "If the file does not exist, create it" instruction in step 8b.

## Self-Check: PASSED

- `.claude/commands/research/audit-claims/SKILL.md` — FOUND and modified
- Commit `18d7831` — FOUND in git log
- Step ordering verified: 8a end (line 77) -> 8b (line 79) -> step 9 (line 100)
- All 9 schema fields verified present
- Failure mode entry verified at line 236
