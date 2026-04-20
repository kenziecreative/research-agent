# Phase 14: Web Channel Diversity - Context

**Gathered:** 2026-04-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Web search discovery gains Exa neural search as a parallel tier alongside Tavily, with deduplication to collapse overlapping results into single candidate entries. This phase extends the existing web-search channel playbook and discover skill's dedup logic — it does not add new channels, new skills, or new data structures.

</domain>

<decisions>
## Implementation Decisions

### Exa Integration Point
- **D-01:** Exa is integrated by extending the existing `web-search.md` channel playbook — not as a separate channel. This follows the Phase 13 precedent where Crossref was added inside academic.md because it serves the same domain (general web URLs). The discover skill's channel routing and type-channel maps remain unchanged.
- **D-02:** Query execution order within the web-search channel: Tavily first (existing), then Exa second. Exa results are deduplicated against Tavily results by URL match before adding to candidates. This mirrors the OpenAlex-first/Crossref-second pattern in academic.md.
- **D-03:** The 8-result cap applies per tool within the channel. Tavily returns up to 8, Exa returns up to 8, dedup collapses overlaps. Maximum combined output before dedup: 16 candidates from web search.

### Exa API Configuration
- **D-04:** Use Exa's `auto` search mode (the API default). Auto mode routes queries to neural or keyword search via Exa's internal categorization — neural for broad/conceptual queries (the primary value add per DISC-03), keyword for specific/exact-match queries. This is durable across the variety of query types a research agent generates.
- **D-05:** Exa authenticates via `EXA_API_KEY` environment variable. Free tier is sufficient for research use (1,000 searches/month).
- **D-06:** Query templates in the playbook follow the existing Tavily template structure (Template A/B/C pattern) adapted for Exa's API parameters.

### Deduplication Strategy
- **D-07:** Exact URL match — the same contract as discover's existing Step 4 (re-run dedup). When Exa and Tavily return the same URL, collapse to a single candidate entry. No URL normalization, no title similarity matching.
- **D-08:** The dedup logic lives inside web-search.md (Section 8, mirroring academic.md's Section 8 dedup rules). The discover skill's Step 4 handles cross-run dedup; within-channel cross-tool dedup is the playbook's responsibility.

### Source Attribution
- **D-09:** Inline tag per candidate line showing which engine(s) found it: `[Tavily]`, `[Exa]`, or `[Tavily+Exa]`. This extends the existing tag pattern (`[ACCESSIBLE]`, `[Firecrawl fallback]`, `[WebSearch fallback]`). Tag appears after the status tag: `[ACCESSIBLE] [Exa] Title — URL`.
- **D-10:** Combined status line at the Web Search section header showing per-tool counts: `Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3})`. This mirrors academic.md's Section 8 status line pattern.
- **D-11:** SC#3 ("source of each candidate is visible") is satisfied by the inline tag (D-09). The status line (D-10) provides aggregate visibility.

### Graceful Degradation
- **D-12:** If Exa is unavailable (API key absent, timeout > 15 seconds, HTTP error), skip silently with a channel status note: `Exa: unavailable — web search results from Tavily only`. Discovery continues with Tavily results. This follows the Unpaywall degradation pattern from Phase 13.
- **D-13:** Exa has its own degradation path separate from Tavily's. Tavily's existing 3-tier degradation (tvly -> Firecrawl -> WebSearch) is unchanged. Exa failure does not trigger Tavily fallbacks or vice versa — they are independent parallel tools within the same channel.

### Claude's Discretion
- Exa query template parameter details (num_results, date filters, content type filters)
- Whether the Exa response `autopromptString` field should be logged for transparency
- Exact positioning of the Exa query templates in web-search.md (after or interleaved with Tavily templates)
- Whether to add Exa-specific credibility tier notes or treat all Exa results under the existing web-search tier system

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Discovery Infrastructure
- `.claude/reference/discovery/channel-playbooks/web-search.md` — The playbook being extended; contains Tavily query templates, credibility tiers, source status taxonomy, and 3-tier degradation chain. Exa integration adds parallel query templates, dedup rules, and its own degradation path.
- `.claude/commands/research/discover/SKILL.md` — The orchestrator skill; defines per-channel execution flow, Step 4 URL dedup, Step 5 status determination, and candidate file format. Web Search section needs update for dual-tool status line.
- `.claude/reference/discovery/channel-playbooks/academic.md` — Reference pattern for multi-API integration within one playbook (OpenAlex + Crossref + Unpaywall, Section 8 dedup/priority rules, combined status line)

### Requirements
- `.planning/REQUIREMENTS.md` DISC-03 — Exa as parallel web-search tier requirement
- `.planning/REQUIREMENTS.md` DISC-04 — Dedup Exa against Tavily requirement

### Prior Phase Context
- `.planning/phases/13-academic-evidence-layer-expansion/13-CONTEXT.md` — Phase 13 decisions on multi-API playbook extension pattern, inline enrichment during same pass, graceful degradation per-API

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `web-search.md` playbook structure — Sections 1-7 (overview, tool config, query templates, credibility tiers, source status, degradation, rate limits) provide the scaffold; Exa additions follow the same section structure
- `academic.md` Section 8 (dedup and priority rules) — Direct pattern to replicate for web-search.md cross-tool dedup
- Discover SKILL.md Channel Execution: Search-Based Channels — Web Search subsection already documents Tavily execution params; Exa execution params added alongside
- Existing tag patterns in candidate file format (`[ACCESSIBLE]`, `[Firecrawl fallback]`) — Exa source tags follow same idiom

### Established Patterns
- Multi-API within one playbook: academic.md has three APIs (OpenAlex, Crossref, Unpaywall) in one channel playbook with ordered execution and dedup
- Per-API graceful degradation: each API has its own degradation path; failure of one doesn't affect others
- 8-result cap per tool: applied per-API, not per-channel aggregate
- Combined status line: single-line summary with per-API counts and degradation notes

### Integration Points
- `web-search.md` — Primary integration; add Exa tool configuration, query templates, degradation chain, rate limits, and Section 8 dedup rules
- `discover/SKILL.md` — Update Web Search channel execution subsection to document Exa parallel execution and combined status line
- Type-channel maps (all 11 maps) — No changes needed; Exa is within web-search channel, not a new channel

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 14-web-channel-diversity*
*Context gathered: 2026-04-20*
