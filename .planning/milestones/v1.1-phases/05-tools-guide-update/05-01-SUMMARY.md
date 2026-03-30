---
phase: 05-tools-guide-update
plan: "01"
subsystem: documentation
tags: [tavily, discovery, tools-guide, channel-playbooks, websearch]

# Dependency graph
requires:
  - phase: 04-init-modifications
    provides: discover skill and strategy.md integration context
  - phase: 01-channel-playbooks
    provides: channel playbooks the tools guide points to
provides:
  - Discovery-aware tools reference guide covering all 6 channels and search-vs-extract workflow rule
affects: [agents using tools-guide.md, CLAUDE.md assembler, any agent reading reference/tools-guide.md]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Tools guide as concise pointer document — no query syntax duplication, points to playbooks for full details"
    - "Channel-tool mapping table as single lookup for 'which tool for which channel'"

key-files:
  created: []
  modified:
    - .claude/reference/tools-guide.md

key-decisions:
  - "Tools guide expanded in place — existing Tavily content retained and lightly edited for coherence with new sections"
  - "Search-vs-extract rule prominently stated as 'Search first, extract after' with hard constraint on extracting uneval'd URLs"
  - "Channel-tool mapping as single 6-row table with Primary/Fallback/Key Param columns, pointing to playbooks for full templates"
  - "WebSearch added to main tool reference table as degraded fallback; Bash curl listed for academic/regulatory direct API access"
  - "Common Mistakes section covers 5 anti-patterns: extract-before-search, WebSearch-when-Tavily-available, crawl-without-map, manual-search-for-systematic-discovery, extracting-snippet-URLs"

patterns-established:
  - "Quick-reference pattern: guide uses tables and bullets, no prose paragraphs, no full query syntax — just enough to orient"

requirements-completed: [INIT-03]

# Metrics
duration: 1min
completed: 2026-03-30
---

# Phase 5 Plan 01: Tools Guide Update Summary

**Discovery-aware tools guide with search-vs-extract workflow rule, 6-channel mapping table, and 5 common mistakes — replacing the 21-line Tavily-only guide**

## Performance

- **Duration:** ~1 min
- **Started:** 2026-03-30T03:16:36Z
- **Completed:** 2026-03-30T03:17:33Z
- **Tasks:** 2 (Task 1: expand guide, Task 2: verify content)
- **Files modified:** 1

## Accomplishments

- Rewrote `.claude/reference/tools-guide.md` from 21 lines to 62 lines, covering the full discovery-to-processing tool landscape
- Established the "Search first, extract after" rule as the central workflow principle
- Added channel-tool mapping table for all 6 discovery channels (web-search, academic, regulatory, financial, social-signals, domain-specific)
- Documented WebSearch and Bash curl as non-Tavily tools with usage-pattern guidance
- Added 5-item Common Mistakes section with concrete anti-patterns
- All Task 2 verification checks passed without requiring any corrections

## Task Commits

Each task was committed atomically:

1. **Task 1: Expand tools guide with discovery sections** - `b49a8d2` (feat)
2. **Task 2: Verify guide content and cross-references** - verification only, no file changes

## Files Created/Modified

- `.claude/reference/tools-guide.md` — Expanded from 21 to 62 lines; updated title, added Search vs. Extract Workflow, Channel-Tool Mapping table, WebSearch/Bash curl rows, Common Mistakes section

## Decisions Made

- Guide expanded in place per CONTEXT.md — existing Tavily content retained, not restructured
- Bash curl kept in both main tool reference table (per plan task wording) and channel mapping table for maximum discoverability
- URL construction documented as a brief inline note rather than a full table row (it's a technique, not a tool)
- Common Mistakes landed at 5 items covering all themes from CONTEXT.md decisions

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- Phase 5 is the final phase of the v1.1 milestone
- All 5 phases complete: channel playbooks, type-channel maps, discover skill, init modifications, tools guide update
- The v1.1 Structured Source Discovery milestone is complete

---
*Phase: 05-tools-guide-update*
*Completed: 2026-03-30*
