---
phase: 08-pipeline-quality-gates
plan: "03"
subsystem: research-pipeline
tags: [assumptions, counter-evidence, quality-gates, synthesis, skill-md]

# Dependency graph
requires:
  - phase: 08-pipeline-quality-gates-01
    provides: Pre-checks 1-4 and guardrails 1-8 in summarize-section (staleness advisory already in place)
provides:
  - Counter-evidence gate in summarize-section (pre-check 5) blocks PRD Validation and Exploratory Thesis until credible opposing evidence exists
  - Assumption logging step (8a) in summarize-section writes thin-evidence judgments to research/assumptions.md
  - Assumption surfacing in start-phase surfaces relevant open assumptions in every phase briefing
  - research/assumptions.md format with Open/Validated/Challenged lifecycle
affects: [summarize-section, start-phase, research-integrity, audit-claims]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Assumption lifecycle: Open -> Validated or Challenged as new phases produce evidence"
    - "Counter-evidence gate: credible source with CHALLENGED/CONTRADICTED tag required before PRD Validation or Exploratory Thesis synthesis"
    - "Assumptions file: research/assumptions.md created on first write, appended on subsequent phases"

key-files:
  created: []
  modified:
    - .claude/commands/research/summarize-section/SKILL.md
    - .claude/commands/research/start-phase/SKILL.md

key-decisions:
  - "Counter-evidence gate applies to every phase in PRD Validation and Exploratory Thesis types, not just the final synthesis phase"
  - "Blog/opinion tier sources do not satisfy the counter-evidence gate — credibility tier must be above that level"
  - "Assumption logging is a synthesis step (8a), not a post-synthesis audit — identified while writing so context is fresh"
  - "start-phase is read-only and surfaces assumptions only from prior phases, not the current one"

patterns-established:
  - "Pre-check gate pattern: check type from research-plan.md, scan notes for qualifying tags, block with actionable guidance if gate fails"
  - "Assumption entry pattern: status + phase + section + basis + what-would-validate + what-would-challenge + date"
  - "Assumption status update: when new synthesis validates or challenges an existing Open assumption, update it inline with evidence note"

requirements-completed: [PIPE-03, PIPE-04]

# Metrics
duration: 10min
completed: 2026-04-04
---

# Phase 08 Plan 03: Assumption Tracking and Counter-Evidence Gate Summary

**Counter-evidence gate blocks confirmation-bias research in PRD Validation and Exploratory Thesis types; assumption logging with three-state lifecycle (Open/Validated/Challenged) persists thin-evidence judgments across phases**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-04-04T00:41:00Z
- **Completed:** 2026-04-04T00:51:19Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added pre-check 5 (counter-evidence gate) to summarize-section: PRD Validation and Exploratory Thesis types are blocked until at least one credible source carries a CHALLENGED or CONTRADICTED finding — gate includes actionable discovery guidance when blocked
- Added process step 8a to summarize-section: assumptions identified during synthesis (single-source, inferred, extrapolated, stale-sourced) are logged to research/assumptions.md with full structured metadata and a three-state lifecycle
- Added assumption surfacing to start-phase: step 5a reads research/assumptions.md and the output template now includes an "Open assumptions to revisit" section so users know which prior thin-evidence judgments the new phase could validate or challenge

## Task Commits

1. **Task 1: Counter-evidence gate and assumption logging in summarize-section** - `36b64c1` (feat)
2. **Task 2: Assumption surfacing in start-phase** - `dc52dab` (feat)

## Files Created/Modified

- `.claude/commands/research/summarize-section/SKILL.md` - Added pre-check 5 (counter-evidence gate), process step 8a (assumption logging), guardrails 9-10, two new failure mode rows
- `.claude/commands/research/start-phase/SKILL.md` - Added process step 5a (read assumptions.md), "Open assumptions to revisit" output section, guardrail 5, new failure mode row

## Decisions Made

- Counter-evidence gate applies to every phase in PRD Validation and Exploratory Thesis types, not just the final synthesis — reasoning: confirmation bias accumulates incrementally; each phase should challenge the thesis, not just the final one
- Blog/opinion tier sources do not satisfy the counter-evidence gate — credibility tier must be official docs, analyst reports, peer-reviewed, industry data, or developer community; low-tier "counter-evidence theater" gets its own failure mode row
- Assumption logging is step 8a (during drafting), not a post-draft audit — reasoning: source context is fresh during drafting; assumptions spotted post-draft may be harder to trace back to the right source
- start-phase surfaces only assumptions from prior phases, not the current one — current-phase assumptions are written by summarize-section at synthesis time, not visible at phase start

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- summarize-section now has pre-checks 1-5 and guardrails 1-10 with a full failure modes table
- start-phase now presents the "Open assumptions to revisit" section whenever research/assumptions.md has relevant Open entries
- research/assumptions.md format is defined and will be created on first synthesis pass in any research project
- Pipeline quality gates phase (08) is complete pending plan 04 (if any); assumption and counter-evidence infrastructure is ready for use in live research sessions

---
*Phase: 08-pipeline-quality-gates*
*Completed: 2026-04-04*
