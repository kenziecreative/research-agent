---
phase: 07-cross-reference-rigor
plan: "02"
subsystem: research-skills
tags: [cross-reference, contradiction-detection, synthesis-gate, research-workflow]

# Dependency graph
requires:
  - phase: 07-cross-reference-rigor/07-01
    provides: Contradiction classification format (core/peripheral, unresolved/resolved) in cross-reference.md
provides:
  - Contradiction resolution gate in summarize-section blocking synthesis until core contradictions are resolved
  - User-facing messaging with specific contradiction details and suggested resolutions
  - Resolved contradiction inclusion in draft output with full reasoning
  - Guardrail 7 preventing mid-draft synthesis past newly noticed contradictions
affects:
  - 02-source-independence
  - 03-confidence-scoring
  - 04-assumption-tagging

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Gate pattern: pre-check reads upstream artifact status field to block downstream action until resolved"
    - "Contradiction surfacing: resolved contradictions presented in draft with both sides + resolution reasoning, not silently discarded"

key-files:
  created: []
  modified:
    - .claude/commands/research/summarize-section/SKILL.md

key-decisions:
  - "Gate triggers on core+unresolved only — peripheral contradictions are noted in draft as open questions but never block synthesis"
  - "Resolved contradictions must appear in draft with reasoning, not just the winning side, so readers see the disagreement existed"
  - "Guardrail 7 added as a mid-draft catch: if a contradiction not in cross-reference.md is noticed during synthesis, stop and flag rather than smooth"

patterns-established:
  - "Pre-check 3 pattern: read Contradictions section, count core+unresolved items, block with named items if any exist"
  - "Failure mode row pattern: explicit prevention instruction paired with each failure mode"

requirements-completed: [XREF-01]

# Metrics
duration: 1min
completed: 2026-04-03
---

# Phase 1 Plan 02: Contradiction Resolution Gate Summary

**Synthesis gate in summarize-section that reads cross-reference.md Contradictions section and blocks with named contradictions when any core item remains unresolved**

## Performance

- **Duration:** ~1 min
- **Started:** 2026-04-03T22:18:15Z
- **Completed:** 2026-04-03T22:19:11Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Added pre-check 3 to summarize-section blocking synthesis when cross-reference.md contains core+unresolved contradictions
- User messaging names the specific contradictions, both source claims, and the suggested resolution from cross-ref
- Updated process step 5 so resolved contradictions appear in drafts with reasoning (not just the winning side)
- Added guardrail 7 as a mid-synthesis catch for contradictions missed by the pre-check
- Added failure mode row for synthesizing past unresolved contradictions into false consensus

## Task Commits

Each task was committed atomically:

1. **Task 1: Add contradiction resolution gate to summarize-section** - `e8006fd` (feat)

**Plan metadata:** TBD (docs: complete plan)

## Files Created/Modified

- `.claude/commands/research/summarize-section/SKILL.md` - Added pre-check 3 (contradiction gate), updated process step 5, added guardrail 7, added failure mode row

## Decisions Made

- Gate triggers on "core" + "unresolved" only. Peripheral contradictions are non-blocking but must appear as open questions in the draft. This avoids over-blocking while still forcing explicit decisions on contradictions that directly affect phase conclusions.
- Resolved contradictions must be surfaced in the draft with the full disagreement and reasoning, not silently replaced by the winning side. This preserves epistemic honesty for readers.

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- XREF-01 is fully satisfied: cross-ref skill writes contradiction status (07-01), summarize-section gates on it (07-02)
- Phase 07-cross-reference-rigor plans are complete
- Ready to advance to Phase 08 (Pipeline Quality Gates) or next phase per ROADMAP

---
*Phase: 07-cross-reference-rigor*
*Completed: 2026-04-03*

## Self-Check: PASSED

- FOUND: .claude/commands/research/summarize-section/SKILL.md
- FOUND: .planning/phases/07-cross-reference-rigor/07-02-SUMMARY.md
- FOUND: commit e8006fd (feat: contradiction gate)
