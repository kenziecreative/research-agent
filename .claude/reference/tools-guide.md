# Tools Guide — Tavily MCP

Reference guide for using Tavily tools in the research workflow.

## Tool Reference

| Tool | Use For | Don't Use For |
|------|---------|---------------|
| `tavily_search` | Finding sources, data, comparisons, documentation | Getting full content from a known URL |
| `tavily_extract` | Pulling full content from a specific URL you already have | Discovery — use search first |
| `tavily_map` | Understanding a site's structure before crawling or extracting | General research questions |
| `tavily_crawl` | Systematically exploring a domain | Quick lookups — too slow |

## Search Patterns

Use `search_depth: "advanced"` for technical research, academic sources, and anything that needs more than surface results. Use `search_depth: "basic"` for quick fact checks and known-item lookups.

## Crawl Discipline

Crawling is powerful but slow. Use it deliberately. Map first, then crawl specific sections. Do not crawl entire domains without purpose.
