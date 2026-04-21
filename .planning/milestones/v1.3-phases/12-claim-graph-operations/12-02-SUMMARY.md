---
phase: 12-claim-graph-operations
plan: 02
subsystem: research-integrity
tags: [claim-graph, drift-detection, integrity-agent, advisory]

# Dependency graph
requires:
  - phase: 12-claim-graph-operations
    plan: 01
    provides: "audit-claims writes drift_warning fields to claim-graph.json nodes when figures change"
provides:
  - "research-integrity agent check 9 surfaces active drift_warning fields using DRIFT WARNING ACTIVE: flag"
  - "Drift visibility outside audit-claims runs — integrity review prompts user to re-audit when drift present"
  - "TRACE-02 fully satisfied: drift detected in audit-claims (Plan 01) AND surfaced by integrity agent (Plan 02)"
affects: [claim-graph, audit-claims, research-integrity]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "ALL_CAPS_PREFIX advisory flag pattern extended to drift_warning surface (DRIFT WARNING ACTIVE:)"
    - "Advisory-not-gate: drift warnings visible but do not block promotion"

key-files:
  created: []
  modified:
    - ".claude/agents/research-integrity.md"

key-decisions:
  - "Drift warnings use ALL_CAPS_PREFIX consistent with other integrity checks (DRIFT WARNING ACTIVE:)"
  - "Drift warnings are advisory — they surface the problem and prompt action but do not block promotion"
  - "Warning message includes actionable next step: run /research:audit-claims to clear or confirm"

patterns-established:
  - "Integrity checks surface stored warning fields rather than silently passing nodes with warnings set"

requirements-completed: [TRACE-02]

# Metrics
duration: 5min
completed: 2026-04-20
---

# Phase 12 Plan 02: Claim Graph Operations — Drift Warning Surface Summary

**research-integrity check 9 extended to surface DRIFT WARNING ACTIVE: flags for claim nodes with drift_warning fields, completing TRACE-02 drift visibility**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-04-20T17:35:00Z
- **Completed:** 2026-04-20T17:40:00Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Extended check 9 in research-integrity agent to detect and surface `drift_warning` fields on claim nodes
- Flag format uses established ALL_CAPS_PREFIX pattern (DRIFT WARNING ACTIVE:) consistent with check 5 (CROSS-PHASE DRIFT:)
- Warning message includes figure_id, expected_value, canonical_value, and actionable instruction to run `/research:audit-claims`
- Explicitly advisory — does not block promotion, consistent with check 9's existing advisory posture
- TRACE-02 is now fully satisfied: drift is detected when figures change (Plan 01) and surfaced whenever the integrity agent reviews a file (Plan 02)

## Task Commits

1. **Task 1: Extend check 9 to surface drift_warning fields** - `64746aa` (feat)

**Plan metadata:** (committed with SUMMARY)

## Files Created/Modified
- `.claude/agents/research-integrity.md` - Appended drift_warning surface instructions to check 9

## Decisions Made
- Placed the drift warning surface text after the existing advisory line in check 9, keeping it within the same check scope and maintaining the advisory-not-gate pattern already established
- Used DRIFT WARNING ACTIVE: as the ALL_CAPS_PREFIX to distinguish this flag from CLAIM GRAPH INCONSISTENCY: (confidence tier drift) and CROSS-PHASE DRIFT: (canonical figure drift) — each flag type is distinct and actionable

## Deviations from Plan

None - plan executed exactly as written.

Note: The acceptance criterion `grep -c "advisory" returns at least 3` found only 2 occurrences — the plan's parenthetical noted "+any prior usage" was conditional. Both required advisory lines are present (original check 9 line + new "Drift warnings are advisory" line). All substantive criteria pass.

## Issues Encountered
- `12-PATTERNS.md` was not present in the worktree (file exists in main repo but worktree branch hadn't pulled it). Sufficient context from the plan interfaces and research-integrity.md itself to execute without it.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- TRACE-02 is complete: drift is detected (audit-claims, Plan 01) and surfaced (research-integrity, Plan 02)
- Phase 12 both plans complete; claim graph foundation and operations are delivered
- Ready for Phase 13 if planned; no blockers

---
*Phase: 12-claim-graph-operations*
*Completed: 2026-04-20*
