# Requirements: Research Agent v1.1 — Structured Source Discovery

**Defined:** 2026-03-29
**Core Value:** Every claim in the research output must trace to a specific, credibility-assessed source.

## v1.1 Requirements

Requirements for structured multi-channel source discovery. Each maps to roadmap phases.

### Discovery Infrastructure

- [x] **DISC-01**: Channel playbooks exist for 6 channel types (web-search, academic, regulatory, financial, social-signals, domain-specific) with query construction patterns, credibility tiers, tool mappings, and graceful degradation instructions
- [x] **DISC-02**: Type-channel maps exist for all 9 research types, mapping each type's phases to prioritized primary and secondary discovery channels derived from existing credibility hierarchies
- [x] **DISC-03**: Discovery candidate output is written to `research/discovery/<phase>-candidates.md`, separate from `research/notes/` where processed sources live
- [x] **DISC-04**: Discovery strategy is generated at project init time by the plan-generator subagent, mapping each phase to its highest-value channels based on research type

### Discovery Skill

- [x] **DSKL-01**: User can run `/research:discover` to execute type-aware source discovery for the current phase
- [x] **DSKL-02**: The discover skill reads the type-channel map for the project's research type and executes available channels in priority order
- [x] **DSKL-03**: The discover skill constructs channel-specific queries (different syntax for EDGAR vs. OpenAlex vs. Tavily) based on the current phase's research questions
- [x] **DSKL-04**: The discover skill degrades gracefully when channels are unavailable, skipping them with explicit status reporting (found N / rate limited / error / skipped / not configured)
- [x] **DSKL-05**: The discover skill outputs a candidate list for user review before any sources are processed — discovery never auto-feeds into process-source
- [x] **DSKL-06**: Each source in the candidate list includes a status (DISCOVERED / ACCESSIBLE / PROCESSED) so the user knows what can be immediately processed vs. what is paywalled or inaccessible
- [x] **DSKL-07**: Channel results are capped at 5-8 sources per channel per query to prevent noise from overwhelming the researcher

### Channel Integrations

- [x] **CHAN-01**: Tavily searches use `include_domains`, `exclude_domains`, and `topic` parameters to scope discovery to relevant source types per channel playbook
- [x] **CHAN-02**: OpenAlex HTTP API integration surfaces academic papers with title, authors, citation count, open-access status, and DOI for research types that benefit from peer-reviewed evidence
- [x] **CHAN-03**: SEC EDGAR EFTS HTTP API integration surfaces regulatory filings (10-K, 10-Q, 8-K, S-1, DEF 14A) for company, person, and PRD validation research types
- [x] **CHAN-04**: ProPublica Nonprofit Explorer API integration surfaces 990 filing data and PDF links for non-profit research type
- [x] **CHAN-05**: Google Patents URL construction generates search URLs that can be extracted via Tavily for company, person, and PRD validation research types

### Init & Workflow Updates

- [x] **INIT-01**: Project scaffold includes `research/discovery/` directory
- [x] **INIT-02**: CLAUDE.md template includes `/research:discover` in the skills table and phase cycle workflow
- [ ] **INIT-03**: Tools guide is updated with discovery-specific patterns (when to use search vs. extract, channel-specific tool recommendations)

## v1.2 Requirements

Deferred to future milestone. Tracked but not in current roadmap.

### Additional Channels

- **CHAN-06**: YouTube Data API integration for video/transcript discovery (curriculum, person research)
- **CHAN-07**: Semantic Scholar full integration (redundant with OpenAlex for most types; add as enhancement)
- **CHAN-08**: Podcast RSS discovery (requires transcription infrastructure)

### Discovery Enhancements

- **DSKL-08**: Cross-channel deduplication (URLs don't deduplicate DOIs; complex to implement correctly)
- **DSKL-09**: Re-discovery mid-phase deduplication against already-processed sources in registry

## Out of Scope

| Feature | Reason |
|---------|--------|
| Google Scholar integration | No API, blocks crawlers — OpenAlex/Semantic Scholar cover the same material |
| Google Trends integration | Unofficial API, fragile, rate-limited — document as manual URL step instead |
| Google News integration | No API — Tavily `topic: "news"` covers this use case |
| Auto-processing discovered sources | Human gate is a design choice — user must select which candidates to process |
| MCP servers for academic/government sources | Direct HTTP is simpler and more reliable than community-maintained servers |
| Paid API integrations requiring billing setup | All channels must be free or use APIs the user already has configured |
| PACER court records | Requires account, complex auth, niche use case |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DISC-01 | Phase 1 | Complete |
| DISC-02 | Phase 2 | Complete |
| DISC-03 | Phase 3 | Complete |
| DISC-04 | Phase 4 | Complete |
| DSKL-01 | Phase 3 | Complete |
| DSKL-02 | Phase 3 | Complete |
| DSKL-03 | Phase 3 | Complete |
| DSKL-04 | Phase 3 | Complete |
| DSKL-05 | Phase 3 | Complete |
| DSKL-06 | Phase 3 | Complete |
| DSKL-07 | Phase 3 | Complete |
| CHAN-01 | Phase 3 | Complete |
| CHAN-02 | Phase 3 | Complete |
| CHAN-03 | Phase 3 | Complete |
| CHAN-04 | Phase 3 | Complete |
| CHAN-05 | Phase 3 | Complete |
| INIT-01 | Phase 4 | Complete |
| INIT-02 | Phase 4 | Complete |
| INIT-03 | Phase 5 | Pending |

**Coverage:**
- v1.1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0

---
*Requirements defined: 2026-03-29*
*Last updated: 2026-03-28 after roadmap creation*
