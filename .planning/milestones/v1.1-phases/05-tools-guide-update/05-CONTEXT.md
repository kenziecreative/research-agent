# Phase 5: Tools Guide Update - Context

**Gathered:** 2026-03-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Update `.claude/reference/tools-guide.md` with discovery-specific patterns and channel-specific tool recommendations. The guide currently covers only Tavily basics (21 lines). This phase expands it to cover the full discovery-to-processing tool landscape so users and agents know when to use search vs. extract and which tools to reach for per channel.

</domain>

<decisions>
## Implementation Decisions

### Guide scope & structure
- Expand in place — add new discovery sections below the existing Tavily content, don't restructure
- Broadened title: "Tools Guide — Research Discovery & Processing" (replaces "Tools Guide — Tavily MCP")
- Light edits to existing content for coherence with new sections, but no structural overhaul
- Quick-reference with pointers to playbooks — concise tables and bullets, not full syntax. Avoids duplicating playbook content

### Search vs. Extract workflow rule
- Clear workflow rule: "Search first, extract after"
- `tavily_search` = Discovery (find sources), `tavily_extract` = Processing (read sources)
- Hard rule: never extract a URL you haven't seen in search results or a candidates file — that's skipping evaluation
- Brief note distinguishing automated discovery (`/research:discover` via playbooks) from manual `tavily_search` (targeted follow-up, one-off lookups, projects not using discover)
- Brief mention of DISCOVERED / ACCESSIBLE / PROCESSED status taxonomy with pointer to playbooks for full definition

### Channel-tool mapping
- Single table format: Channel | Primary Tool | Fallback | Key Param
- All 6 channels in one table: web-search, academic, regulatory, financial, social-signals, domain-specific
- Key params as hints in the table (e.g., `include_domains` for financial, `topic: "news"` for social signals) — just enough to orient, not full syntax
- Pointer after table to `.claude/reference/discovery/channel-playbooks/` for query templates and parameters
- Brief degradation summary after the table: primary fails → fallback automatically, results labeled, all-fail → empty candidates with status report

### Non-Tavily tool coverage
- Usage patterns only — WHEN to use each tool, not HOW to write the commands
- WebSearch: general web fallback when Tavily unavailable, less targeted, label results as degraded
- Bash curl: direct API access for OpenAlex (academic) and EDGAR/ProPublica (regulatory), returns structured JSON
- URL construction: build search URLs (Google Patents) for extraction via tavily_extract
- WebSearch added to the main tool reference table at the top alongside Tavily tools

### Common Mistakes section
- Short list of 3-5 anti-patterns at the end of the guide
- Covers: extracting before searching, using WebSearch when Tavily available, crawling without mapping, manual search for systematic discovery, extracting snippets instead of source URLs

### Claude's Discretion
- Exact wording of table entries and section prose
- Whether to add Bash curl to the main tool reference table (or keep it in channel mapping only)
- Ordering of new sections relative to each other
- Exact anti-patterns in the Common Mistakes list (3-5 items, covering the themes above)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.claude/reference/tools-guide.md`: The file being updated — currently 21 lines covering Tavily tool reference table, search patterns, and crawl discipline
- `.claude/reference/discovery/channel-playbooks/`: 6 playbooks with full query templates, tool mappings, credibility tiers, and degradation chains — the tools guide points here, doesn't duplicate
- `.claude/reference/discovery/type-channel-maps/`: 9 type-channel maps with `active-channels` frontmatter — not directly referenced in tools guide but provides context for "varies by type" entries

### Established Patterns
- Existing tools guide uses table format for tool/use/don't-use mappings
- Reference files use markdown with clear section headers
- Channel playbooks define exact tool-to-channel mappings that the tools guide summarizes

### Integration Points
- Tools guide is read by agents and users as a quick reference during research work
- Referenced from CLAUDE.md template (assembled by init skill) as part of the research workflow documentation
- Discover skill reads playbooks directly — tools guide provides orientation, not execution instructions

</code_context>

<specifics>
## Specific Ideas

- Preview mockups from discussion capture the intended feel: compact tables, clear rules, pointers not duplication
- "Search first, extract after" is the key message — should be prominent and unambiguous
- Channel-tool table should be the single place to answer "which tool for which channel?" at a glance

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-tools-guide-update*
*Context gathered: 2026-03-29*
