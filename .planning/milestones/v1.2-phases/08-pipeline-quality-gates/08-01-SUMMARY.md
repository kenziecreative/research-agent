---
phase: 08-pipeline-quality-gates
plan: "01"
subsystem: pipeline
tags: [staleness, quality-gates, synthesis, source-assessment, research-types]

# Dependency graph
requires: []
provides:
  - Staleness Threshold field in all 11 research type templates
  - Pre-check 4 (source staleness advisory) in summarize-section
  - Guardrail 8 (explicit age caveats for stale sources) in summarize-section
  - Staleness failure mode in summarize-section Common Failure Modes table
affects:
  - summarize-section (reads type template thresholds at synthesis time)
  - all research type templates
  - any downstream synthesis quality gates

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Type-aware staleness thresholds: each research domain sets its own decay rate in the type template"
    - "Advisory pre-check pattern: warn but do not block, include stale evidence with age caveats"

key-files:
  created: []
  modified:
    - .claude/reference/templates/types/market-industry.md
    - .claude/reference/templates/types/competitive-analysis.md
    - .claude/reference/templates/types/prd-validation.md
    - .claude/reference/templates/types/exploratory-thesis.md
    - .claude/reference/templates/types/company-for-profit.md
    - .claude/reference/templates/types/company-non-profit.md
    - .claude/reference/templates/types/customer-safari.md
    - .claude/reference/templates/types/curriculum-research.md
    - .claude/reference/templates/types/opportunity-discovery.md
    - .claude/reference/templates/types/person-research.md
    - .claude/reference/templates/types/presentation-research.md
    - .claude/commands/research/summarize-section/SKILL.md

key-decisions:
  - "Stale sources warn but do not block synthesis — advisory pattern preserves user agency while surfacing age risk"
  - "Data year checked, not publication year — a 2025 article citing 2021 data uses 2021 as the staleness reference"
  - "Thresholds range from 1 year (competitive-analysis) to 5 years (curriculum-research) — differentiated by domain decay rate"
  - "No sources exceed threshold → advisory skipped silently (no noise when all sources are current)"

patterns-established:
  - "Advisory pre-check pattern: pre-check N warns user of risk, displays structured list, synthesis proceeds without blocking"
  - "Type-template-as-configuration: summarize-section reads thresholds from type templates rather than hardcoding values — single source of truth"

requirements-completed: [PIPE-01]

# Metrics
duration: 2min
completed: 2026-04-03
---

# Phase 8 Plan 1: Pipeline Quality Gates — Source Staleness Thresholds Summary

**Type-aware staleness thresholds added to all 11 research type templates (1–5 year ranges by domain decay rate) with a staleness advisory pre-check in summarize-section that surfaces stale source warnings before synthesis**

## Performance

- **Duration:** 2 min
- **Started:** 2026-04-04T00:45:25Z
- **Completed:** 2026-04-04T00:47:35Z
- **Tasks:** 2
- **Files modified:** 12

## Accomplishments

- Added a `**Staleness Threshold:** N years — [rationale]` field immediately after the Finding Tags section in all 11 research type templates, with thresholds calibrated to domain data decay rates (1 year for competitive-analysis through 5 years for curriculum-research)
- Added pre-check 4 to summarize-section: reads the type template's threshold dynamically, compares source data years (not publication years) against the threshold, displays a structured advisory listing each stale source with its data year and years over threshold
- Added guardrail 8 (explicit age caveats) and a new Common Failure Mode row ("Treating stale sources as equally current") to summarize-section

## Task Commits

1. **Task 1: Add staleness threshold field to all 11 research type templates** - `0d60f8d` (feat)
2. **Task 2: Add staleness warning pre-check to summarize-section** - `6a9f70e` (feat)

## Files Created/Modified

- `.claude/reference/templates/types/market-industry.md` - Staleness Threshold: 2 years
- `.claude/reference/templates/types/competitive-analysis.md` - Staleness Threshold: 1 year
- `.claude/reference/templates/types/prd-validation.md` - Staleness Threshold: 2 years
- `.claude/reference/templates/types/exploratory-thesis.md` - Staleness Threshold: 3 years
- `.claude/reference/templates/types/company-for-profit.md` - Staleness Threshold: 2 years
- `.claude/reference/templates/types/company-non-profit.md` - Staleness Threshold: 3 years
- `.claude/reference/templates/types/customer-safari.md` - Staleness Threshold: 2 years
- `.claude/reference/templates/types/curriculum-research.md` - Staleness Threshold: 5 years
- `.claude/reference/templates/types/opportunity-discovery.md` - Staleness Threshold: 2 years
- `.claude/reference/templates/types/person-research.md` - Staleness Threshold: 3 years
- `.claude/reference/templates/types/presentation-research.md` - Staleness Threshold: 2 years
- `.claude/commands/research/summarize-section/SKILL.md` - Pre-check 4, guardrail 8, failure mode added

## Decisions Made

- **Advisory pattern, not a gate:** Stale sources warn but do not block synthesis. Stale evidence is still evidence — the user needs to see it with context, not have it hidden. This preserves user agency while ensuring age risk is visible.
- **Data year over publication year:** A 2025 article discussing 2021 survey data uses 2021 as the staleness reference. This is already consistent with how source notes structure data year vs. publication year fields.
- **Threshold range 1–5 years:** Competitive analysis set at 1 year (fastest-moving domain); curriculum research set at 5 years (pedagogy is durable). All other types cluster at 2–3 years reflecting typical domain decay rates.
- **Silent pass when no stale sources:** Advisory only appears when threshold is exceeded. Clean runs produce no noise.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All 11 type templates now carry a machine-readable staleness threshold field
- summarize-section will surface age warnings before any synthesis run where source notes are older than the type's threshold
- PIPE-02 (confidence scoring) can reference the staleness field in process-source notes as one input to confidence scoring — the threshold values established here serve as reference calibration points

---
*Phase: 08-pipeline-quality-gates*
*Completed: 2026-04-03*
