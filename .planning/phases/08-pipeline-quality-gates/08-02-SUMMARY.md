---
phase: 08-pipeline-quality-gates
plan: "02"
subsystem: audit
tags: [audit-claims, confidence-tier, evidence-strength, source-quality]

# Dependency graph
requires:
  - phase: 08-01
    provides: staleness thresholds in process-source type templates, stale-source age caveats in summarize-section
provides:
  - Per-section confidence tier (High/Moderate/Low/Insufficient) in audit-claims scorecard and report
  - Four-input confidence scoring: source count, credibility tiers, evidence directness, staleness
  - Advisory tier: does not block promotion, visible alongside pass/fail
affects:
  - audit-claims users — scorecard now includes section-level confidence tiers
  - downstream phases that rely on audit reports — reports now contain confidence tier tables

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Weakest-link overall confidence: overall tier = lowest section tier"
    - "Advisory scoring: confidence tier is informational, pass/fail is compliance; they are orthogonal"
    - "Four-input tier computation: source count sets baseline, credibility/directness upgrade, staleness/weakness downgrade"

key-files:
  created: []
  modified:
    - .claude/commands/research/audit-claims/SKILL.md

key-decisions:
  - "Confidence tier is advisory and does not affect pass/fail — a Low-confidence section that passes the audit is promoted with its tier visible"
  - "Single-source sections cannot be High confidence regardless of source authority — triangulation requires multiple independent sources"
  - "Weakest-link determines overall confidence: the lowest section tier sets the document-level tier"
  - "Echo-level sources (shared origin cluster) count as one independent source for confidence scoring purposes"

patterns-established:
  - "Confidence tier computation: start at source-count baseline (Claim=Low, Emerging=Moderate, Pattern=High), upgrade for strong credibility/direct evidence, downgrade for weak credibility/indirect evidence/staleness dominance"
  - "Audit report includes confidence tier table alongside scorecard and findings"

requirements-completed: [PIPE-02]

# Metrics
duration: 2min
completed: 2026-04-04
---

# Phase 08 Plan 02: Pipeline Quality Gates — Confidence Tiers Summary

**Confidence tier scoring (High/Moderate/Low/Insufficient) added to audit-claims, derived from source count, credibility, evidence directness, and staleness — displayed per section as advisory evidence-strength signal that does not affect pass/fail**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-04-04T00:49:36Z
- **Completed:** 2026-04-04T00:50:58Z
- **Tasks:** 1 of 1
- **Files modified:** 1

## Accomplishments

- Added step 8a to audit-claims process: per-section confidence tier computation with four explicitly-named inputs (source count, credibility tiers, evidence directness, staleness)
- Added confidence tier table format to scorecard output in step 8: section name, tier, one-sentence rationale, overall weakest-link tier
- Updated step 9 audit report to include the confidence tier table alongside scorecard and findings
- Added advisory note to Pass/Fail Criteria: tier is orthogonal to pass/fail — a Low-confidence section that passes is promoted with its tier visible
- Added failure mode row to prevent conflating confidence with audit compliance
- Added guardrail to Non-Negotiable Rules: no confidence tier inflation, single-source cannot be High

## Task Commits

Each task was committed atomically:

1. **Task 1: Add confidence tier scoring to audit-claims** - `18f297a` (feat)

**Plan metadata:** (pending final commit)

## Files Created/Modified

- `.claude/commands/research/audit-claims/SKILL.md` — Added step 8a (confidence tier computation), scorecard format extension, audit report update, advisory pass/fail note, new failure mode, and no-inflation guardrail

## Decisions Made

- Confidence tier is advisory only: it indicates evidence strength (how well-supported), not audit compliance (how truthfully represented). The two are orthogonal. A Low-confidence section that passes is promoted; a High-confidence section that fails is blocked.
- Single-source = Low confidence regardless of source authority. Triangulation requires multiple independent sources; the label "High" requires Pattern-level (4+) independent source coverage.
- Weakest-link rule: the overall confidence tier for the document equals the lowest section tier. This is conservative and surfaces the weakest area clearly.
- Echo-level sources (dependent/derived, sharing a common origin) count as one independent source for confidence scoring, consistent with the cross-reference skill's shared-origin cluster logic from Phase 07.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- audit-claims now surfaces evidence strength per section as a named tier (High/Moderate/Low/Insufficient)
- The tier computation draws on the staleness thresholds introduced in Plan 08-01 (type templates via process-source)
- Phase 08 is now complete: Plans 01 (staleness gates) and 02 (confidence tiers) both delivered
- Downstream phases that use audit reports will see confidence tier tables in their reports automatically

---
*Phase: 08-pipeline-quality-gates*
*Completed: 2026-04-04*

## Self-Check: PASSED

- FOUND: .claude/commands/research/audit-claims/SKILL.md
- FOUND: .planning/phases/08-pipeline-quality-gates/08-02-SUMMARY.md
- FOUND: commit 18f297a
