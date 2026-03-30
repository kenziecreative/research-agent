# Tools Guide — Research Discovery and Processing

Reference guide for using tools in the research discovery and processing workflow.

## Tool Reference

| Tool | Use For | Don't Use For |
|------|---------|---------------|
| `tavily_search` | Finding sources, data, comparisons, documentation; systematic discovery by channel | Getting full content from a known URL |
| `tavily_extract` | Pulling full content from a specific URL you already have | Discovery — use search first |
| `tavily_map` | Understanding a site's structure before crawling or extracting | General research questions |
| `tavily_crawl` | Systematically exploring a domain section by section | Quick lookups — too slow |
| `WebSearch` | General web fallback when Tavily is unavailable | Replacing Tavily — less targeted; label results as degraded |
| `Bash curl` | Direct API access for OpenAlex (academic) and EDGAR/ProPublica (regulatory) | Discovery channels that Tavily handles well |

URL construction (e.g., building a Google Patents search URL) is used alongside `tavily_extract` to access structured sources that don't surface well in search.

## Search vs. Extract Workflow

**Search first, extract after.** Never extract a URL you haven't seen in search results or a candidates file — that's skipping evaluation.

| Step | Tool | Purpose |
|------|------|---------|
| Discovery | `tavily_search` | Find candidate sources; produces DISCOVERED entries |
| Processing | `tavily_extract` | Read a specific source you've already found and evaluated |

**Automated vs. manual discovery:**
- `/research:discover` — systematic channel-by-channel discovery via playbooks; use for projects with a defined research type and phases
- Manual `tavily_search` — targeted follow-up queries, one-off lookups, projects not using the discover skill

**Status taxonomy:** Sources move through DISCOVERED → ACCESSIBLE → PROCESSED. See channel playbooks for full definitions.

## Channel-Tool Mapping

| Channel | Primary Tool | Fallback | Key Param |
|---------|-------------|----------|-----------|
| web-search | `tavily_search` | `WebSearch` | `include_domains`, `search_depth` |
| academic | `Bash curl` (OpenAlex API) | `tavily_search` with academic domains | `mailto` param for polite pool |
| regulatory | `Bash curl` (EDGAR/ProPublica) | `tavily_search` with SEC domains | `User-Agent` header required |
| financial | `tavily_search` | `WebSearch` | `include_domains` for financial sites |
| social-signals | `tavily_search` | `WebSearch` with `site:` operators | `topic: "news"`, `include_domains` |
| domain-specific | Varies (see playbook) | `tavily_search` / `WebSearch` | Type hooks per research type |

For full query templates and parameters, see `.claude/reference/discovery/channel-playbooks/`.

**Degradation:** Primary tool fails → fallback runs automatically; results are labeled with source method. If all fail → empty candidates file with status report.

## Search Patterns

Use `search_depth: "advanced"` for technical research, academic sources, and anything that needs more than surface results. Use `search_depth: "basic"` for quick fact checks and known-item lookups.

## Crawl Discipline

Crawling is powerful but slow. Use it deliberately. Map first, then crawl specific sections. Do not crawl entire domains without purpose.

## Common Mistakes

- **Extracting before searching** — Running `tavily_extract` on a URL you guessed or recalled, skipping search evaluation entirely. Always search first.
- **Using WebSearch when Tavily is available** — WebSearch is a degraded fallback. Prefer `tavily_search`; only fall back to WebSearch when Tavily tools are unavailable.
- **Crawling without mapping** — Crawling a domain without running `tavily_map` first wastes time on irrelevant sections.
- **Manual search for systematic discovery** — Running `tavily_search` manually for a full research project when `/research:discover` exists. Use the skill; it reads channel playbooks and handles degradation automatically.
- **Extracting snippet URLs** — Tavily search results include snippet or tracking URLs, not always the canonical source URL. Extract only the actual source URL shown in the result.
