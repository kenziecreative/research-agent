---
phase: 09-gap-analysis-depth
plan: "01"
subsystem: research-skills
tags: [check-gaps, coverage-assessment, source-independence, origin-chain, gap-analysis]

# Dependency graph
requires:
  - phase: 07-cross-reference-rigor
    provides: origin_chain field in source notes for shared-origin collapse
  - phase: 08-pipeline-quality-gates
    provides: advisory-not-blocking pattern and single-source confidence rules

provides:
  - Direct/Adjacent/None three-tier match classification system in coverage-assessment-guide.md
  - Source independence rules referencing origin_chain in coverage-assessment-guide.md
  - Enhanced check-gaps skill with independence map, lopsided flagging, dashboard output
  - Full regeneration pattern for gaps.md

affects: [check-gaps, coverage-assessment-guide, phase-insight, summarize-section, start-phase]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Three-tier match classification: Direct counts for coverage, Adjacent is a research lead, None is excluded"
    - "Independence map: group source notes by origin_chain before counting coverage"
    - "Lopsided flag: exactly 1 independent Direct source triggers warning (not 0, not 2+)"
    - "Full regeneration: gaps.md rebuilt from scratch each run, never appended"
    - "Dashboard-at-top: quick summary header before per-question detail in gaps.md"

key-files:
  created: []
  modified:
    - .claude/reference/coverage-assessment-guide.md
    - .claude/commands/research/check-gaps/SKILL.md

key-decisions:
  - "Adjacent matches do not count toward coverage status — a question with 3 Adjacent and 0 Direct sources is Not Started"
  - "Coverage status calculated from independent Direct source count only using origin_chain"
  - "Lopsided flag triggers at exactly 1 independent Direct source — not 0 (Not Started) and not 2+ (adequate)"
  - "coverage-assessment-guide.md is the single source of truth for Direct/Adjacent/None classification"
  - "Full regeneration pattern for gaps.md — never append, always rebuild"

patterns-established:
  - "Match classification before coverage assignment: classify all sources as Direct/Adjacent/None first, then count independent Directs, then assign status"
  - "Independence map built once per run from origin_chain, reused for all questions"
  - "Adjacent sources listed with explanation in per-question detail but excluded from coverage counts"
  - "Non-independent sources collapsed to footnote: main count shows independent Directs, footnote notes which sources share origin"

requirements-completed: [GAP-01, GAP-02]

# Metrics
duration: 2min
completed: 2026-04-04
---

# Phase 9 Plan 01: Gap Analysis Depth Summary

**check-gaps enhanced with Direct/Adjacent/None three-tier classification, independence counting via origin_chain, lopsided coverage flagging, and dashboard-at-top output format in gaps.md**

## Performance

- **Duration:** 2 min
- **Started:** 2026-04-04T02:36:07Z
- **Completed:** 2026-04-04T02:37:57Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Updated coverage-assessment-guide.md as the single source of truth for Direct/Adjacent/None classification and source independence rules (referencing origin_chain from Phase 7)
- Rewrote check-gaps SKILL.md process to build an independence map, classify each source-question match as Direct/Adjacent/None, and assign coverage status from independent Direct count only
- Added dashboard-at-top format to gaps.md output (total questions, direct coverage count, lopsided flags, adjacent-only matches)
- Added 4 new guardrails (6-9) and 3 new failure modes to check-gaps preventing Adjacent inflation, non-independent double-counting, and missed lopsided flags

## Task Commits

Each task was committed atomically:

1. **Task 1: Update coverage-assessment-guide with Direct/Adjacent/None classification** - `09fd8cc` (feat)
2. **Task 2: Enhance check-gaps skill with independence counting, three-tier matching, and dashboard** - `5312480` (feat)

**Plan metadata:** (docs commit to follow)

## Files Created/Modified

- `.claude/reference/coverage-assessment-guide.md` — Added Match Classification section (Direct/Adjacent/None), Source Independence section (origin_chain), updated coverage status definitions to use independent Direct counts, updated workflow steps
- `.claude/commands/research/check-gaps/SKILL.md` — Rewrote process steps 1-8 with independence map, three-tier classification, lopsided flagging, dashboard output; added guardrails 6-9 and 3 new failure mode rows

## Decisions Made

- Adjacent matches are research leads, not coverage — a question with only Adjacent sources is Not Started (consistent with Phase 9 context decision)
- Independence determined solely by origin_chain: two sources agreeing independently are still two independent sources; only explicit shared-origin sources collapse
- Lopsided flag at exactly 1 independent Direct source (consistent with Phase 8 single-source rule that can't be High confidence)
- coverage-assessment-guide.md designated as single source of truth — check-gaps references it for all classification criteria
- Full regeneration pattern (consistent with Phase 7 cross-ref skill)

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- coverage-assessment-guide.md and check-gaps SKILL.md fully enhanced for Phase 9 requirements
- GAP-01 (independent source counting + lopsided flagging) and GAP-02 (close-enough match detection) both satisfied
- Phase 9 plan 02 (if any) can reference the independence map pattern and three-tier classification from this plan

---
*Phase: 09-gap-analysis-depth*
*Completed: 2026-04-04*
