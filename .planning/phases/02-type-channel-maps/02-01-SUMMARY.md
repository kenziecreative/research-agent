---
phase: 02-type-channel-maps
plan: 01
subsystem: discovery
tags: [type-channel-maps, company-for-profit, company-non-profit, competitive-analysis, channel-routing, discovery]

# Dependency graph
requires:
  - phase: 01-channel-playbooks
    provides: "6 channel playbooks defining channel names, query templates, and credibility tiers that these maps reference"
provides:
  - "company-for-profit.md — phase-grouped channel routing for for-profit company research"
  - "company-non-profit.md — phase-grouped channel routing for non-profit company research"
  - "competitive-analysis.md — phase-grouped channel routing for competitive analysis research"
affects:
  - "03-discover-skill — reads these maps at runtime to determine channel routing per research type and phase"
  - "02-02-type-channel-maps — sibling plans following same structure"

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Phase-grouped discovery sections: group type template phases by channel needs, not by phase number"
    - "Primary/secondary tier notation: primary always executes, secondary executes if primary returns fewer than 5-8 sources"
    - "YAML active-channels frontmatter: enables quick channel lookup without full doc parse"
    - "Domain-specific sources section: type-scoped hooks filling in domain-specific playbook's type-hook template pattern"
    - "Synthesis/risks phases omitted: phases using existing sources get no discovery groups; discover skill reports 'no channels mapped'"

key-files:
  created:
    - .claude/reference/discovery/type-channel-maps/company-for-profit.md
    - .claude/reference/discovery/type-channel-maps/company-non-profit.md
    - .claude/reference/discovery/type-channel-maps/competitive-analysis.md
  modified: []

key-decisions:
  - "For-profit financial phases: regulatory (SEC filings) + domain-specific (Crunchbase/PitchBook) as co-primary — both are highest-credibility sources for distinct data (public company vs. private funding)"
  - "Non-profit financial phases: regulatory channel is the primary (990/ProPublica) — domain-specific secondary only for aggregators"
  - "Competitive analysis uses 8 granular groups vs. 7 for company types — higher channel variation across phases warrants finer grouping (per CONTEXT.md discretion note)"
  - "Academic channel included for non-profit (impact/effectiveness phases) and competitive analysis (tech/trends) but not for-profit — traces to credibility hierarchy differences"

patterns-established:
  - "Type-channel map structure: YAML frontmatter → discovery groups → domain-specific sources section"
  - "Group granularity scales with channel variation: more variation = more groups (competitive analysis has 8 groups, company types have 7-8)"
  - "Channel names are exact: web-search, academic, regulatory, financial, social-signals, domain-specific"

requirements-completed: [DISC-02]

# Metrics
duration: 20min
completed: 2026-03-29
---

# Phase 2 Plan 01: Company/Competitive Type-Channel Maps Summary

**Phase-grouped channel routing for 3 company/competitive research types, derived from credibility hierarchies: SEC filings for for-profit, 990/ProPublica for non-profit, and analyst reports + user reviews for competitive analysis**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-03-29T17:41:36Z
- **Completed:** 2026-03-29T17:55:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Created company-for-profit map with 7 discovery groups; regulatory + domain-specific co-primary for financial phases per credibility hierarchy (SEC + Crunchbase/PitchBook cover distinct data)
- Created company-non-profit map with 8 discovery groups prominently featuring regulatory channel (ProPublica/990) as primary for financial and funding phases; academic channel added for impact/effectiveness phases
- Created competitive-analysis map with 8 granular groups to reflect high channel variation; social-signals (G2/Capterra) primary for features/pricing reality, financial + domain-specific primary for traction/funding, patent search hook for tech/IP

## Task Commits

Each task was committed atomically:

1. **Task 1: Create company-for-profit type-channel map** - `d9f5fa2` (feat)
2. **Task 2: Create company-non-profit and competitive-analysis type-channel maps** - `2a5cff4` (feat)

**Plan metadata:** _(docs commit follows)_

## Files Created/Modified

- `.claude/reference/discovery/type-channel-maps/company-for-profit.md` — 7 discovery groups; web-search/regulatory/financial/social-signals/domain-specific; patent search + industry databases hooks
- `.claude/reference/discovery/type-channel-maps/company-non-profit.md` — 8 discovery groups; regulatory channel primary for 990-based financials and funding; academic added for impact evidence; GuideStar/Charity Navigator/GiveWell domain-specific sources
- `.claude/reference/discovery/type-channel-maps/competitive-analysis.md` — 8 granular groups; financial + domain-specific for traction; social-signals for features/pricing reality; patent search + industry databases + market report sources

## Decisions Made

- **For-profit financials: regulatory + domain-specific co-primary** — SEC filings (regulatory) cover public company financials; Crunchbase/PitchBook (domain-specific) cover private funding rounds. These are the highest-credibility sources for distinct but complementary data, warranting co-primary status.
- **Non-profit financials: regulatory is sole primary** — 990 filings via ProPublica are definitively the top source; charity aggregators (domain-specific) are secondary since they pull from the same 990 data.
- **Competitive analysis gets 8 groups (not 7)** — Phase variation in channel needs is meaningfully higher for competitive analysis (market definition, competitor ID, features, positioning, pricing, tech, traction, trends each have distinct channel priorities). Collapsing them would lose precision.
- **Academic channel in non-profit and competitive but not for-profit** — Credibility hierarchy differences: non-profit impact measurement explicitly references academic evaluations; competitive analysis has technology/architecture and trends phases where academic research adds depth; for-profit credibility hierarchy doesn't list academic sources.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. Directory `.claude/reference/discovery/type-channel-maps/` was created automatically by the Write tool.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 3 of 9 type-channel maps complete; plans 02-02 and 02-03 complete the remaining 6 maps
- Once all 9 maps exist, Phase 3 (discover skill) can reference them for runtime channel routing
- Map structure and patterns are established; sibling plans 02-02 and 02-03 follow the same template

---
*Phase: 02-type-channel-maps*
*Completed: 2026-03-29*
