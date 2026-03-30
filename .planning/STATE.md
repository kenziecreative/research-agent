---
gsd_state_version: 1.0
milestone: v1.1
milestone_name: Structured Source Discovery
status: planning
stopped_at: Completed 06-01-PLAN.md
last_updated: "2026-03-30T03:53:20.988Z"
last_activity: 2026-03-28 — Roadmap created for v1.1 milestone
progress:
  total_phases: 6
  completed_phases: 6
  total_plans: 10
  completed_plans: 10
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-29)

**Core value:** Every claim in the research output must trace to a specific, credibility-assessed source. If it can't be traced, it doesn't ship.
**Current focus:** Phase 1 — Channel Playbooks

## Current Position

Phase: 1 of 5 (Channel Playbooks)
Plan: 0 of TBD in current phase
Status: Ready to plan
Last activity: 2026-03-28 — Roadmap created for v1.1 milestone

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**
- Total plans completed: 0
- Average duration: —
- Total execution time: 0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**
- Last 5 plans: —
- Trend: —

*Updated after each plan completion*
| Phase 01-channel-playbooks P01 | 2 | 2 tasks | 3 files |
| Phase 01-channel-playbooks P02 | 4 | 3 tasks | 3 files |
| Phase 02-type-channel-maps P01 | 20 | 2 tasks | 3 files |
| Phase 02-type-channel-maps P02 | 3 | 2 tasks | 3 files |
| Phase 02-type-channel-maps P03 | 3 | 2 tasks | 3 files |
| Phase 03-discover-skill P01 | 4 | 2 tasks | 1 files |
| Phase 04-init-modifications P02 | 1 | 2 tasks | 2 files |
| Phase 04-init-modifications P01 | 3 | 1 tasks | 1 files |
| Phase 05-tools-guide-update P01 | 1 | 2 tasks | 1 files |
| Phase 06-discover-skill-consistency-fixes PP01 | 2 | 2 tasks | 2 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- v1.1 planning: Reference files (playbooks, type-channel maps) must live in `.claude/reference/discovery/`, NOT `.claude/commands/research/` — phantom command constraint
- v1.1 planning: Discover skill is a thin orchestrator; all channel intelligence lives in playbooks, not the skill itself
- v1.1 planning: Discovery candidate output goes to `research/discovery/` only; never auto-feeds into process-source pipeline
- [Phase 01-channel-playbooks]: Source status taxonomy canonical definition lives in web-search.md Section 5; other playbooks reference it to prevent drift
- [Phase 01-channel-playbooks]: Wildcard include_domains (community.*.com, investor.*.com) flagged as unconfirmed in Tavily — notes added in playbooks to fall back to explicit domain lists
- [Phase 01-channel-playbooks]: Financial channel scoped to Tavily-based discovery only; direct EDGAR/ProPublica API access deferred to regulatory channel (Plan 02)
- [Phase 01-02]: Academic channel uses OpenAlex API (free, no auth) as primary with 10 req/s polite pool via mailto parameter
- [Phase 01-02]: Regulatory channel requires User-Agent header for SEC EDGAR per SEC policy — embedded in curl templates
- [Phase 01-02]: Domain-specific channel uses type-hook template pattern — Phase 2 type-channel maps select applicable hooks per research type
- [Phase 02-type-channel-maps]: For-profit financial phases: regulatory (SEC filings) + domain-specific (Crunchbase/PitchBook) co-primary — cover distinct public vs. private funding data
- [Phase 02-type-channel-maps]: Non-profit financial phases: regulatory channel sole primary for 990/ProPublica — charity aggregators are secondary since they pull from same 990 data
- [Phase 02-type-channel-maps]: Academic channel included for non-profit (impact phases) and competitive analysis (tech/trends) but not for-profit — traces to credibility hierarchy differences
- [Phase 02-type-channel-maps]: market-industry uses 8 phase groups due to high channel variation — different channels needed for sizing vs. technology vs. regulatory vs. investment phases
- [Phase 02-type-channel-maps]: prd-validation excludes regulatory channel — government filings and standards bodies are not primary sources for PRD assumption validation
- [Phase 02-type-channel-maps]: presentation-research excludes domain-specific and financial channels — patent search and VC databases are irrelevant to presentation evidence gathering
- [Phase 02-type-channel-maps]: Exploratory-thesis routes to academic as primary in 4 of 5 groups — matches credibility hierarchy where peer-reviewed research is highest
- [Phase 02-type-channel-maps]: Curriculum-research practitioner reality group uses social-signals as primary — practitioner community knowledge is high credibility for ground truth, academic lags
- [Phase 02-type-channel-maps]: Person-research financial/legal group uses regulatory + financial as primary — SEC filings, court records, corporate registrations are highest credibility per hierarchy
- [Phase 03-discover-skill]: Skill reads channel playbooks at execution time — thin orchestrator pattern keeps channel intelligence in playbooks
- [Phase 03-discover-skill]: Re-run behavior: append with timestamp separator + deduplicate by URL — never overwrite prior discovery work
- [Phase 03-discover-skill]: Status PROCESSED reserved for process-source — discover assigns only DISCOVERED or ACCESSIBLE
- [Phase 04-init-modifications]: Strategy.md express lane: discover reads pre-matched phase-to-channel mappings from strategy.md when available, skipping keyword guessing entirely
- [Phase 04-init-modifications]: Start-phase recommends discover first: natural workflow entry point surfaces /research:discover before /research:process-source
- [Phase 04-init-modifications]: Plan-generator subagent receives type-channel map content and produces discovery/strategy.md alongside research-plan.md in the same pass
- [Phase 04-init-modifications]: Discover is a substep of Collect (soft rule, not mandatory) — keeps the 5-step cycle intact while advertising the discover skill
- [Phase 05-tools-guide-update]: Tools guide expanded in place — existing Tavily content retained with search-vs-extract rule and channel-tool mapping table added
- [Phase 05-tools-guide-update]: Common Mistakes section covers 5 anti-patterns: extract-before-search, WebSearch-when-Tavily-available, crawl-without-map, manual-search-for-systematic-discovery, extracting-snippet-URLs
- [Phase 06-01]: EDGAR User-Agent updated to match regulatory.md (ResearchAgent (contact@example.com)) — playbook is source of truth
- [Phase 06-01]: Academic fallback chain: Semantic Scholar step removed entirely, now tavily_search then WebSearch per academic.md section 6
- [Phase 06-01]: Init CLAUDE.md template: research-type field added as item 0 — machine-readable for discover pre-check

### Pending Todos

None yet.

### Blockers/Concerns

- Phase 3 (Discover Skill): MCP tool availability detection pattern is MEDIUM confidence — verify against current Claude Code docs before finalizing skill
- Phase 3 (Discover Skill): OpenAlex, Semantic Scholar, PubMed rate limits should be re-verified before specifying per-session query budgets
- Phase 1 (Channel Playbooks): Tavily `include_domains` wildcard behavior (e.g., `*.gov`) is unconfirmed — test in implementation, fall back to explicit domain lists if needed

## Session Continuity

Last session: 2026-03-30T03:50:21.408Z
Stopped at: Completed 06-01-PLAN.md
Resume file: None
