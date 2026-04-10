---
phase: 03-discover-skill
plan: "01"
subsystem: research-skills
tags: [tavily, websearch, openalex, edgar, propublica, discovery, slash-command]

# Dependency graph
requires:
  - phase: 01-channel-playbooks
    provides: "Channel playbooks with query templates, degradation chains, and rate limits"
  - phase: 02-type-channel-maps
    provides: "Type-channel maps with active-channels frontmatter and phase-grouped channel priorities"
provides:
  - ".claude/commands/research/discover/SKILL.md — complete discover slash command skill"
  - "Type-aware multi-channel orchestration reading STATE.md + type-channel maps + channel playbooks"
  - "Candidate output format at research/discovery/{phase}-candidates.md with summary table and per-source status"
  - "Degradation handling: Tavily unavailable → WebSearch fallback, HTTP API failure → Tavily fallback → WebSearch"
affects:
  - "04-process-source (discover feeds candidates; process-source handles actual extraction)"
  - "research/discovery/ directory (new output location created by this skill)"

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Thin orchestrator pattern: skill reads playbooks at execution time rather than embedding channel intelligence"
    - "Append + deduplicate on re-run: preserves prior discovery work, deduplicates by URL"
    - "Per-channel status reporting: build-log style real-time feedback during execution"
    - "Status taxonomy: DISCOVERED / ACCESSIBLE / PROCESSED with clear assignment rules"

key-files:
  created:
    - ".claude/commands/research/discover/SKILL.md"
  modified: []

key-decisions:
  - "Skill reads channel playbooks at execution time — playbooks are the source of channel intelligence, not the skill"
  - "Re-run behavior: append with timestamp separator + deduplicate by URL — never overwrite prior discovery"
  - "Status PROCESSED reserved for process-source — discover assigns only DISCOVERED or ACCESSIBLE"
  - "No pre-flight Tavily detection — the attempt is the check; handle failure inline"
  - "Optional --channel filter for targeted re-runs documented in skill introduction"

patterns-established:
  - "Skill structure: frontmatter → title → Pre-check → Process → Channel Execution sections → Guardrails → Common Failure Modes → Output"
  - "Per-channel status line pattern: '{Channel Name}: querying...' then '{Channel Name}: found {N}'"
  - "Fallback labeling: all degraded results tagged inline with actual method used"

requirements-completed:
  - DSKL-01
  - DSKL-02
  - DSKL-03
  - DSKL-04
  - DSKL-05
  - DSKL-06
  - DSKL-07
  - DISC-03
  - CHAN-01
  - CHAN-02
  - CHAN-03
  - CHAN-04
  - CHAN-05

# Metrics
duration: 4min
completed: "2026-03-29"
---

# Phase 3 Plan 01: Discover Skill Summary

**Type-aware /research:discover slash command that reads STATE.md + type-channel maps + channel playbooks to execute 6-channel source discovery and write reviewable candidates to research/discovery/{phase}-candidates.md**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-29T22:20:14Z
- **Completed:** 2026-03-29T22:24:14Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- Created `.claude/commands/research/discover/SKILL.md` (340 lines) following the established process-source skill pattern
- All 13 Phase 3 requirements (DSKL-01 through DSKL-07, DISC-03, CHAN-01 through CHAN-05) addressed explicitly in the skill
- Complete orchestration covering all 6 channels: web-search, financial, social-signals, domain-specific (with type hooks), academic (OpenAlex API), regulatory (EDGAR EFTS + ProPublica)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create discover skill with core orchestration and all 6 channels** - `b678d82` (feat)
2. **Task 2: Validate skill against all Phase 3 requirements** - no commit needed (Task 1 already covered all requirements; Task 2 was read-only validation with no file changes)

**Plan metadata:** (docs commit follows)

## Files Created/Modified

- `.claude/commands/research/discover/SKILL.md` - Complete discover slash command skill with pre-checks, orchestration, 6-channel execution, candidate output format, degradation handling, guardrails, failure modes

## Decisions Made

- Skill reads channel playbooks at execution time rather than embedding channel logic — preserves the thin orchestrator design from CONTEXT.md
- Re-run behavior appends with timestamp separator and deduplicates by URL — consistent with CONTEXT.md decision to preserve prior discovery work
- Status PROCESSED is reserved for process-source and explicitly excluded from discover's assignment logic — prevents status taxonomy drift
- Optional `--channel {name}` argument documented per CONTEXT.md "Claude's Discretion" item — enables targeted re-runs without rewriting full discovery

## Deviations from Plan

None - plan executed exactly as written. Task 2 validation confirmed all 13 requirements were already met by Task 1 output with no additions required.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. API credentials (Tavily, EDGAR, OpenAlex) are handled inline during skill execution per playbook instructions.

## Next Phase Readiness

- Phase 3 is complete: the discover skill is the sole deliverable of Phase 3
- The skill reads reference files from Phases 1 and 2 at execution time — no modifications to those files needed
- Ready for any final integration testing or additional skill development

---
*Phase: 03-discover-skill*
*Completed: 2026-03-29*
