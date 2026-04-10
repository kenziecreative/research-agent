---
phase: 09-gap-analysis-depth
plan: "02"
subsystem: research-skills
tags: [phase-insight, summarize-section, start-phase, gap-analysis, coverage, lopsided, adjacency]

# Dependency graph
requires:
  - phase: 09-gap-analysis-depth
    plan: "01"
    provides: Enhanced gaps.md format with independent source counts, lopsided flags, adjacent-only matches, and Coverage Dashboard

provides:
  - phase-insight output table with Independent and Adjacent columns plus Adjacent-only matches subsection
  - summarize-section Pre-check 6 — lopsided coverage advisory (warn-not-block)
  - start-phase step 5b + Coverage snapshot display from gaps.md before source collection begins

affects: [phase-insight, summarize-section, start-phase, check-gaps]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Advisory-not-blocking pre-check: display warning, then proceed (consistent with Phase 8 staleness advisory)"
    - "Coverage snapshot at briefing time: surface lopsided and adjacent-only flags before user decides what to collect"
    - "Independence-aware strength labels: Thin = 1 independent Direct, Unsupported = 0 Direct, Adjacent excluded"

key-files:
  created: []
  modified:
    - .claude/commands/research/phase-insight/SKILL.md
    - .claude/commands/research/summarize-section/SKILL.md
    - .claude/commands/research/start-phase/SKILL.md

key-decisions:
  - "Adjacent sources excluded from strength labels in phase-insight — Thin and Unsupported reference independent Direct counts only"
  - "Lopsided advisory in summarize-section is a warning, not a gate — consistent with Phase 8 staleness advisory pattern"
  - "Coverage snapshot always displayed in start-phase if gaps.md exists — lopsided and adjacent-only flags are invisible without it"

patterns-established:
  - "Downstream integration of gaps.md data: all three user-facing skills now surface independence counts and adjacent match flags"
  - "Pre-check 6 follows the advisory pattern from Phase 8: warn but do not block, silent pass when no issues"

requirements-completed: [GAP-01, GAP-02]

# Metrics
duration: 3min
completed: 2026-04-04
---

# Phase 9 Plan 02: Gap Analysis Depth Summary

**phase-insight, summarize-section, and start-phase wired to surface gaps.md independence counts, lopsided flags, and adjacent-only matches in output**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-04T02:40:20Z
- **Completed:** 2026-04-04T02:42:40Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Updated phase-insight output table to include Independent and Adjacent columns, added Adjacent-only matches subsection, updated guardrail 2 so Thin and Unsupported reference independent Direct counts, added failure mode row for adjacent-source inflation
- Added Pre-check 6 (lopsided coverage advisory) to summarize-section following the Phase 8 advisory-not-blocking pattern, with failure mode row for synthesizing lopsided questions with confident language
- Added step 5b and Coverage snapshot output section to start-phase so users see lopsided flags and adjacent-only matches before deciding what sources to collect; added guardrail 6 and failure mode row

## Task Commits

Each task was committed atomically:

1. **Task 1: Enhance phase-insight with independence and adjacency data from gaps.md** - `9863466` (feat)
2. **Task 2: Add lopsided coverage advisory to summarize-section and coverage snapshot to start-phase** - `817f5c9` (feat)

**Plan metadata:** `ba6e075` (docs)

## Files Created/Modified

- `.claude/commands/research/phase-insight/SKILL.md` — Expanded step 4, added Independent/Adjacent columns to output table, added Adjacent-only matches subsection, updated guardrail 2 for independence-aware labels, added failure mode row
- `.claude/commands/research/summarize-section/SKILL.md` — Added Pre-check 6 (lopsided coverage advisory, warn-not-block), updated pre-check closing note, added failure mode row
- `.claude/commands/research/start-phase/SKILL.md` — Added step 5b (read gaps.md), added Coverage snapshot to Output section, added guardrail 6, added failure mode row

## Decisions Made

- Advisory-not-blocking for lopsided pre-check: consistent with Phase 8's staleness advisory — user agency preserved while surfacing risk
- Coverage snapshot is mandatory when gaps.md exists (guardrail 6): lopsided flags and adjacent-only matches are not surfaced by source counts alone, so they would be invisible without explicitly reading gaps.md

## Deviations from Plan

None — plan executed exactly as written.

The verify command for Task 2 initially failed because the pattern `pre-check 6` didn't match `pre-checks 4 and 6` (plural). Fixed by adding `Pre-check 6 —` inline to the section label so both the plain text and verify pattern align.

## Issues Encountered

Minor: The automated verify pattern `grep -q "pre-check 6\|Pre-check 6"` required the exact phrase. The initial implementation used "pre-checks 4 and 6" (plural) which didn't match. Added "Pre-check 6 —" to the item label text, which both satisfies the verify and improves readability.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- All three downstream skills now integrated with the enhanced gaps.md format from Plan 01
- GAP-01 (independent source counting + lopsided flagging) and GAP-02 (close-enough match detection) both satisfied across the full skill pipeline
- Phase 9 complete — gap analysis depth enhancements fully wired from check-gaps through phase-insight, summarize-section, and start-phase

---
*Phase: 09-gap-analysis-depth*
*Completed: 2026-04-04*
