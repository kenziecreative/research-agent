# Requirements: Research Agent v1.1 — Structured Source Discovery

**Defined:** 2026-03-29
**Core Value:** Every claim in the research output must trace to a specific, credibility-assessed source.

## v1.1 Requirements

Requirements for structured multi-channel source discovery. Each maps to roadmap phases.

### Discovery Infrastructure

- [x] **DISC-01**: Channel playbooks exist for 6 channel types (web-search, academic, regulatory, financial, social-signals, domain-specific) with query construction patterns, credibility tiers, tool mappings, and graceful degradation instructions
- [ ] **DISC-02**: Type-channel maps exist for all 9 research types, mapping each type's phases to prioritized primary and secondary discovery channels derived from existing credibility hierarchies
- [ ] **DISC-03**: Discovery candidate output is written to `research/discovery/<phase>-candidates.md`, separate from `research/notes/` where processed sources live
- [ ] **DISC-04**: Discovery strategy is generated at project init time by the plan-generator subagent, mapping each phase to its highest-value channels based on research type

### Discovery Skill

- [ ] **DSKL-01**: User can run `/research:discover` to execute type-aware source discovery for the current phase
- [ ] **DSKL-02**: The discover skill reads the type-channel map for the project's research type and executes available channels in priority order
- [ ] **DSKL-03**: The discover skill constructs channel-specific queries (different syntax for EDGAR vs. OpenAlex vs. Tavily) based on the current phase's research questions
- [ ] **DSKL-04**: The discover skill degrades gracefully when channels are unavailable, skipping them with explicit status reporting (found N / rate limited / error / skipped / not configured)
- [ ] **DSKL-05**: The discover skill outputs a candidate list for user review before any sources are processed — discovery never auto-feeds into process-source
- [ ] **DSKL-06**: Each source in the candidate list includes a status (DISCOVERED / ACCESSIBLE / PROCESSED) so the user knows what can be immediately processed vs. what is paywalled or inaccessible
- [ ] **DSKL-07**: Channel results are capped at 5-8 sources per channel per query to prevent noise from overwhelming the researcher

### Channel Integrations

- [ ] **CHAN-01**: Tavily searches use `include_domains`, `exclude_domains`, and `topic` parameters to scope discovery to relevant source types per channel playbook
- [ ] **CHAN-02**: OpenAlex HTTP API integration surfaces academic papers with title, authors, citation count, open-access status, and DOI for research types that benefit from peer-reviewed evidence
- [ ] **CHAN-03**: SEC EDGAR EFTS HTTP API integration surfaces regulatory filings (10-K, 10-Q, 8-K, S-1, DEF 14A) for company, person, and PRD validation research types
- [ ] **CHAN-04**: ProPublica Nonprofit Explorer API integration surfaces 990 filing data and PDF links for non-profit research type
- [ ] **CHAN-05**: Google Patents URL construction generates search URLs that can be extracted via Tavily for company, person, and PRD validation research types

### Init & Workflow Updates

- [ ] **INIT-01**: Project scaffold includes `research/discovery/` directory
- [ ] **INIT-02**: CLAUDE.md template includes `/research:discover` in the skills table and phase cycle workflow
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
| DISC-02 | Phase 2 | Pending |
| DISC-03 | Phase 3 | Pending |
| DISC-04 | Phase 4 | Pending |
| DSKL-01 | Phase 3 | Pending |
| DSKL-02 | Phase 3 | Pending |
| DSKL-03 | Phase 3 | Pending |
| DSKL-04 | Phase 3 | Pending |
| DSKL-05 | Phase 3 | Pending |
| DSKL-06 | Phase 3 | Pending |
| DSKL-07 | Phase 3 | Pending |
| CHAN-01 | Phase 3 | Pending |
| CHAN-02 | Phase 3 | Pending |
| CHAN-03 | Phase 3 | Pending |
| CHAN-04 | Phase 3 | Pending |
| CHAN-05 | Phase 3 | Pending |
| INIT-01 | Phase 4 | Pending |
| INIT-02 | Phase 4 | Pending |
| INIT-03 | Phase 5 | Pending |

**Coverage:**
- v1.1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0

---
*Requirements defined: 2026-03-29*
*Last updated: 2026-03-28 after roadmap creation*
