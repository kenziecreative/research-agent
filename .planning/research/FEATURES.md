# Feature Landscape: Structured Source Discovery

**Domain:** Source discovery layer for AI-assisted structured research tool
**Researched:** 2026-03-28
**Milestone:** v1.1 — Structured Source Discovery

---

## Context: What the Discovery System Is Solving

The existing system processes sources well once you hand it a URL. The gap is *finding* the right sources in the first place. Currently, the agent uses only `tavily_search` (general web), which cannot surface:

- SEC filings (EDGAR full-text search)
- Academic papers (OpenAlex, PubMed, Semantic Scholar)
- Patent filings (Google Patents, USPTO Patent Full-Text)
- Government datasets (data.gov, BLS, Census, OECD)
- Structured funding/company data (Crunchbase, PitchBook)
- Analyst report directories (Gartner, Forrester, IDC public summaries)
- Podcast and video content (YouTube, Podcast RSS)
- Google Trends data (market signals)

The discovery system maps each research type to the channels where its highest-credibility sources live, then constructs channel-appropriate queries to find them.

---

## Table Stakes

Features that must exist for the discovery system to be useful. Missing any of these means the Collect step is still just a general web search with extra steps.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Discovery playbooks per research type | Without type-aware routing, discovery is generic and misses the sources that matter most to each type's credibility hierarchy | Medium | 9 playbooks, one per type. Maps type → ordered channel list with rationale. Lives in `.claude/reference/` as a reference file, NOT a command. |
| Channel-specific query construction | SEC EDGAR needs form-type filters and CIK numbers; academic search needs field codes and Boolean operators; web search needs natural language. One query format doesn't work across channels. | Medium | Per-channel query templates with variable slots for topic, entity name, date range, and domain-specific filters. |
| Graceful degradation when channels are unavailable | Not all users will have all MCP servers or API keys. A channel being unavailable must not break the workflow — skip it and continue. | Low | Check-before-use pattern. Tell the user which channels were skipped and why. |
| Hand-off to existing process-source pipeline | Discovery finds URLs; process-source does the structured extraction and note creation. Discovery must output URLs in a format process-source can consume. | Low | Discovery outputs a list of candidate URLs with channel provenance and suggested order of processing. User selects which to process. |
| Multi-channel sequence execution | A single discovery run should search across all relevant channels for the current research type, not just one, and surface results as a ranked candidate list. | Medium | Sequence = ordered list of channels to try. Execute each, aggregate results, de-duplicate by URL. |
| `/research:discover` skill | The entry point for the discovery workflow. Takes the current phase topic (from research plan) as input, runs the type-appropriate channel sequence, and returns a ranked candidate list. | Medium | The orchestrating skill that ties playbooks, channel sequences, and query construction together. |

---

## Differentiators

Features that make this discovery system better than a general-purpose web search but aren't strictly required for basic function. These create meaningful lift for specific research types.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| EDGAR full-text search integration | For company and person research, SEC filings (10-K, 10-Q, S-1, proxy, 990) are the highest-credibility source. General web search rarely surfaces specific filings. EDGAR EFTS (full-text search) is free and doesn't require an API key. | Medium | Query EDGAR EFTS with company name or CIK, filter by form type. Return direct filing URLs. Applies to: company-for-profit, company-non-profit, person-research, market-industry (for earnings signals). |
| OpenAlex/Semantic Scholar discovery | For academic-leaning research types, OpenAlex is a free, open API with 250M+ works. Semantic Scholar is similarly open. Both support field-code queries and return structured metadata (title, abstract, authors, citation count, open-access URL). High-value for exploratory thesis, curriculum research, market research. | Medium | Requires constructing academic-style queries (Boolean, field codes). OpenAlex API is well-documented and does not require auth for basic use. Semantic Scholar has rate limits on the free tier. |
| Patent database discovery | For company and person research involving technology and IP, patent search surfaces what a company has actually built and protected. Distinguishes between "claims to have X technology" and "has filed patents on X technology." Google Patents has a free API-like interface; USPTO Patent Full-Text is free. | Medium-High | Patent query construction is specialized: CPC classification codes, assignee fields, inventor name normalization. Complex enough to warrant a channel-specific query builder. |
| Google Trends integration | For market and competitive research, Trends data shows relative search volume over time — a proxy for public interest and adoption curves. Free, no API key required (unofficial API). | Low-Medium | Useful specifically for market-industry and competitive-analysis research types. Returns trend signals, not sources — outputs a data point to process, not a URL to extract. Different output format than other channels. |
| YouTube discovery | For curriculum and presentation research, video content from recognized practitioners often contains practical knowledge that isn't written anywhere. YouTube Data API (free tier) allows search by topic, channel, and recency. | Medium | Requires YouTube Data API v3 key (free). Relevant for curriculum-research (practitioner reality phases) and presentation-research (finding expert quotes and examples). Returns video URLs that process-source can extract via Tavily. |
| Podcast RSS discovery | Podcast episodes — especially interview-format shows — often contain on-record statements from practitioners and executives that don't appear in text form anywhere else. Discoverable via Podcast Index API (free, requires API key) or Listen Notes API. | High | High complexity: Podcast content requires transcription or summary extraction. Tavily extract handles some podcast pages; others require direct RSS parsing. Value is high for curriculum and person research, but implementation complexity is significant. Defer to a later phase. |
| Channel result ranking by credibility | After aggregating results across channels, rank them by the type's credibility hierarchy. An SEC filing should surface above a company blog post regardless of relevance scoring. | Medium | Requires knowing the credibility tier of each channel and applying the type's hierarchy to sort the candidate list before presenting it to the user. |

---

## Anti-Features

Features to explicitly NOT build in this milestone.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Automated source processing without user review | The AI Anthropology Toolkit notebooks are exploratory — they bulk-fetch and filter. The existing research tool has a different philosophy: human-in-the-loop, phase-sequential, with the user deciding which sources to process. Auto-processing would break this contract and risk polluting the source registry with low-quality sources. | Discovery outputs a *candidate list* with channel provenance and brief description. User selects which to process. Keep the human gate. |
| Paid API integrations requiring user billing setup | PitchBook, Bloomberg Terminal, Factiva, Crunchbase Pro all have exceptional data but require subscriptions. Setting up billing is friction that blocks the user before they get any value. | Use free tiers and open sources (EDGAR, OpenAlex, USPTO, Crunchbase basic web). Note in the candidate list where a paid source would improve quality — the user can manually pull it. |
| Full-text PDF ingestion pipeline | Discovery finds URLs and document references. Processing PDFs is already handled by process-source via direct file path or Tavily extract. Building a separate PDF ingestion layer for discovery duplicates existing capability and adds complexity. | Discovery returns the URL or PDF location. User runs `/research:process-source` on it as they already would. |
| Real-time data feeds or streaming | Research operates on point-in-time snapshots (per the project constraints in PROJECT.md). Live feeds would violate this design choice and add infrastructure complexity with no clear benefit to the research workflow. | Use date-filtered discovery queries to find recent-but-static sources. |
| Cross-project discovery coordination | Discovery should operate within the current research project's scope, feeding into that project's source registry. Multi-project coordination would require a global state model that doesn't exist and isn't needed. | Scope discovery strictly to the current project directory and research plan. |
| AI-generated source summaries as discovery output | The research tool's core principle is "every claim traces to a processed source." If discovery returns AI-generated summaries of sources rather than source URLs to process, it violates the traceability requirement. | Discovery returns URLs. Summaries are written by process-source after full content extraction. |
| Social media scraping | LinkedIn, Twitter/X, Reddit scraping requires unofficial APIs or browser automation, violates terms of service for most platforms, and produces low-credibility sources anyway. | For person research, use LinkedIn as a manual check (user navigates themselves). For community signals, use public forums accessible via Tavily web search (HN, Reddit via search, not scraping). |

---

## Channel-to-Research-Type Mappings

These mappings are derived directly from the credibility hierarchies in each type template. Priority = where to search first. Secondary = useful but lower-value. Skip = unlikely to yield relevant results.

### Company Research (For-Profit)

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| SEC EDGAR EFTS | Primary | 10-K, 10-Q, S-1, proxy statements | `company name` + form type filter (10-K, S-1) |
| Tavily web search | Primary | News, product pages, analyst summaries | `"[company name]" site:techcrunch.com OR site:wsj.com` |
| Google Patents | Primary | Patent filings, technology and IP claims | Assignee: `[company name]`, date range |
| OpenAlex / Semantic Scholar | Secondary | Academic papers mentioning company, citations of their tech | Author affiliation or title keyword |
| Crunchbase (web) | Secondary | Funding history, investor data, team | Manual URL construction: `crunchbase.com/organization/[slug]` |
| G2/Capterra (web) | Secondary | User reviews and product reality | `site:g2.com "[product name]"` |
| Glassdoor (web) | Secondary | Culture, employee sentiment patterns | `site:glassdoor.com "[company name]"` |
| Google Trends | Skip | Not useful for company-specific research | — |
| YouTube | Skip | Low credibility for company claims | — |

### Company Research (Non-Profit)

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| SEC EDGAR EFTS | Primary | 990 filings (non-profit financial disclosures) | Company name + form type filter (990, 990-EZ, 990-PF) |
| ProPublica Nonprofit Explorer | Primary | 990 data in structured form | URL pattern: `projects.propublica.org/nonprofits/organizations/[EIN]` |
| Tavily web search | Primary | News coverage, program descriptions | `"[org name]" site:guidestar.org OR site:charitynavigator.org` |
| GuideStar / Candid | Secondary | Rating, financials summary, leadership | Web search: `site:guidestar.org "[org name]"` |
| Charity Navigator | Secondary | Independent effectiveness ratings | Web search: `site:charitynavigator.org "[org name]"` |
| Academic databases | Secondary | Impact studies referencing the org | OpenAlex keyword search: org name + program name |
| Google Trends | Skip | — | — |
| Patent databases | Skip | — | — |

### Competitive Analysis

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| Tavily web search | Primary | Product pages, pricing, feature comparisons | Each competitor name individually; `site:g2.com "[product]"` |
| G2/Capterra | Primary | User reviews — feature reality vs. marketing claims | `site:g2.com "[product name] vs"` |
| SEC EDGAR | Secondary | Financials and strategy (for public competitors) | Company name + 10-K |
| Crunchbase | Secondary | Funding, team size, growth signals | Web search per competitor |
| Product Hunt | Secondary | New entrants and community reception | `site:producthunt.com "[product name]"` |
| GitHub | Secondary | Open source competitors, activity signals | `site:github.com "[project name]"` |
| Google Trends | Secondary | Relative search interest as proxy for adoption | Compare competitor terms side-by-side |
| YouTube | Skip | — | — |
| Academic databases | Skip | — | — |

### Person Research

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| SEC EDGAR EFTS | Primary | SEC filings if officer/director (proxy statements, insider filings) | `"[person name]"` in full-text; filter for DEF 14A, Form 4 |
| Google Patents | Primary | Patent filings (inventor field) | Inventor: `[last name, first name]` |
| OpenAlex / Semantic Scholar | Primary | Published papers, citation count, co-authors | Author name search; ORCID if known |
| Tavily web search | Primary | News coverage, interviews, talks | `"[full name]" site:linkedin.com` (for structure), general news search |
| Crunchbase | Secondary | Board roles, funding involvement, advisory positions | Web search: `site:crunchbase.com "[person name]"` |
| Court records / PACER | Secondary | Litigation (manual check — PACER requires account) | Note as a recommended manual check, not automated |
| YouTube | Secondary | Recorded talks, interviews, conference presentations | YouTube Data API: `"[person name]"`, filter by type=video |
| Google Scholar | Secondary | Academic citations (for researchers) | Scholar search by author name |
| LinkedIn | Note only | Career timeline structure (treat as self-reported) | Manual URL: `linkedin.com/in/[slug]` — do not scrape |

### Market/Industry Research

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| Tavily web search | Primary | Analyst summaries, trade press, market reports | `"[market name]" market size OR forecast site:gartner.com OR site:forrester.com` |
| Government statistics | Primary | BLS, Census, OECD, Eurostat data | Direct URL construction or web search targeting `.gov` and `.oecd.org` domains |
| OpenAlex / Semantic Scholar | Primary | Peer-reviewed research on market trends, adoption studies | Topic keyword + field: economics, computer science (for tech markets) |
| Crunchbase | Secondary | VC funding patterns as leading indicator | Web search for "funding" + sector + year |
| Google Trends | Secondary | Search volume trends as adoption proxy | Compare market terms over time |
| SEC EDGAR | Secondary | Earnings calls and 10-K risk sections from major players | Ticker + 10-K, search for market-sizing language in risk factors |
| Developer surveys | Secondary | Adoption within tech (Stack Overflow, JetBrains) | Tavily web search for survey report URLs |
| YouTube | Skip | — | — |
| Patent databases | Skip (unless technology market) | — | — |

### PRD Validation

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| Tavily web search | Primary | Official API documentation, technical specs | `"[technology name]" documentation site:[vendor].com` |
| OpenAlex / Semantic Scholar | Primary | Benchmark studies, performance comparisons | Technology name + "benchmark" OR "performance" OR "evaluation" |
| GitHub | Primary | Open source implementation reality, issues, community size | `site:github.com "[library or project name]"` |
| Stack Overflow | Secondary | Implementation reality, known gotchas | Tavily: `site:stackoverflow.com "[technology]"` |
| Changelog / release notes | Secondary | API stability, deprecation patterns | Direct URL construction for vendor changelog |
| HN threads | Secondary | Developer community assessment of the technology | Tavily: `site:news.ycombinator.com "[technology name]"` |
| Google Trends | Secondary | Adoption trajectory for the technology | Technology name vs. alternatives |
| SEC EDGAR | Skip | — | — |
| Patent databases | Skip | — | — |

### Exploratory Thesis

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| OpenAlex / Semantic Scholar | Primary | Academic foundations, citation networks, counter-evidence | Topic keywords + Boolean; filter by year, citation count |
| Government data | Primary | BLS, Census, Pew Research, Gallup for behavioral and economic claims | Domain-targeted web search: `site:pewresearch.org "[topic]"` |
| Tavily web search | Primary | Long-form journalism, thought pieces, landscape surveys | `"[thesis topic]"` + recency filter |
| Google Scholar | Secondary | Citation count to assess claim's standing in the field | Scholar search for key papers in the thesis area |
| YouTube | Secondary | Subject-matter expert talks that may not be in written form | YouTube API: topic keyword, filter for long-form content |
| Google Trends | Secondary | Public interest trajectory for the thesis topic | Thesis topic keyword over time |
| Patent databases | Skip (unless thesis involves IP/technology) | — | — |
| SEC EDGAR | Skip | — | — |

### Curriculum Research

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| OpenAlex / Semantic Scholar | Primary | Peer-reviewed research on the subject domain | Topic keyword + field filter |
| Professional body / certification frameworks | Primary | Accepted practice, competency models | Domain-targeted web search: professional association sites |
| Tavily web search | Primary | Practitioner blogs, course syllabi, community discussions | `"[skill name]" how practitioners OR real-world + site:medium.com` |
| Government labor statistics | Secondary | Occupational data, skill demand signals | `site:bls.gov "[occupation]"` |
| YouTube | Secondary | Practitioner walkthroughs, expert talks | YouTube API: topic keyword, filter for instructional content |
| Podcast RSS / Listen Notes | Secondary | Practitioner interviews, domain conversations | High value but high complexity — see Anti-Features note |
| Google Trends | Secondary | Relative search interest in skills (adoption signal) | Skill name comparisons over time |
| Patent databases | Skip | — | — |
| SEC EDGAR | Skip | — | — |

### Presentation Research

| Channel | Priority | What It Finds | Query Pattern |
|---------|----------|---------------|---------------|
| Tavily web search | Primary | Statistics, case studies, analyst reports, news | Claim keyword + `statistics` OR `study` OR `report` |
| OpenAlex / Semantic Scholar | Primary | Peer-reviewed research backing claims | Claim keyword + field filter, filter recent years |
| Government data | Primary | Official statistics that carry on-stage credibility | Domain-targeted search: `.gov`, `.oecd.org`, `census.gov` |
| YouTube | Secondary | Expert quotes, TED/conference talks | YouTube API: speaker name OR topic keyword |
| Google Trends | Secondary | "This trend is accelerating right now" data | Thesis topic over recent time window |
| News archives | Secondary | Named recent examples and case studies | Tavily: topic + recency filter, target major outlets |
| Patent databases | Skip | — | — |
| SEC EDGAR | Skip (unless the presentation is about a specific company) | — | — |

---

## Query Construction Patterns by Channel

Different channels require fundamentally different query syntax. Using the same natural-language query across all channels misses most of what each channel can find.

### Tavily (General Web + Advanced)

```
Basic:   "[topic keywords]"
Advanced: "[topic]" site:[domain.com] OR site:[domain2.com]
          "[entity name]" "[specific claim type]" filetype:pdf
          "[topic]" after:2024-01-01
```

Use `search_depth: "advanced"` for academic sources, technical research, anything that needs deeper indexing than surface pages.

### SEC EDGAR Full-Text Search (EFTS)

```
Base URL: https://efts.sec.gov/LATEST/search-index?q=%22[company name]%22&dateRange=custom&startdt=[YYYY-MM-DD]&enddt=[YYYY-MM-DD]&forms=[FORM-TYPE]

Form type examples:
  10-K   — Annual report
  10-Q   — Quarterly report
  S-1    — IPO registration
  DEF 14A — Proxy statement (leadership, compensation)
  Form 4 — Insider transactions (for person research)
  990    — Non-profit financial disclosure
  990-EZ — Small non-profit disclosure
```

The EDGAR EFTS API is free, no auth required. Returns JSON with direct filing URLs. Key parameters: `q` (search term), `forms` (form type filter), `dateRange` + `startdt`/`enddt`.

### OpenAlex (Academic — Free, No Auth Required)

```
Works endpoint: https://api.openalex.org/works?search=[query]&filter=publication_year:>[YEAR]&sort=cited_by_count:desc

Useful filters:
  publication_year:>2020   — Filter by year
  open_access.is_oa:true   — Open access only (full text available)
  type:article             — Filter to journal articles
  cited_by_count:>50       — Minimum citation threshold

Field-specific search:
  title.search:[keyword]   — Title only
  abstract.search:[keyword] — Abstract only
  author.display_name.search:[name] — Author name search
```

OpenAlex returns DOIs and open-access URLs. High-confidence source for finding relevant academic work. Rate limit: 100k requests/day, no key needed; faster with `?email=[email]` polite pool.

### Semantic Scholar (Academic — Free, Rate Limited)

```
Base URL: https://api.semanticscholar.org/graph/v1/paper/search?query=[keywords]&fields=title,abstract,year,citationCount,openAccessPdf,authors

Rate limit: 100 req/5 min (no key); 1 req/sec (with API key — free registration)
```

Returns papers with citation counts, open-access PDF links, and author data. Useful for quickly assessing a paper's standing in the field.

### Google Patents (Via Web Search — No Official API)

```
Base URL: https://patents.google.com/?q=[keywords]&assignee=[Company Name]&inventor=[Last+First]&after=priority:[YYYY-MM-DD]

Parameters:
  q=[keywords]          — Claims and description keywords
  assignee=[name]       — Company that owns the patent
  inventor=[name]       — Inventor name
  cl=[CPC-code]         — CPC classification (e.g., cl=G06F for computing)
  after=priority:[date] — Filed after date
```

No official API. Construct URLs and use Tavily extract to pull the patent list page. Patent Query construction is specialized — for technology research, CPC codes narrow results dramatically.

### YouTube Data API v3

```
Search endpoint: https://www.googleapis.com/youtube/v3/search
  ?part=snippet
  &q=[query]
  &type=video
  &order=relevance OR date
  &publishedAfter=[ISO-8601-date]
  &maxResults=10
  &key=[API-KEY]
```

Requires a YouTube Data API v3 key (free via Google Cloud console, generous daily quota). Returns video titles, channel names, publish dates, and video IDs. Construct watch URLs from video IDs: `youtube.com/watch?v=[id]`. Useful for finding conference talks, practitioner walkthroughs, and recorded expert interviews.

### Government Statistics (Direct URL Construction)

No unified API. Use domain-targeted Tavily search and direct URL construction:

```
BLS:      site:bls.gov "[occupation or topic]"
Census:   site:census.gov "[topic]"
Pew:      site:pewresearch.org "[topic]"
Gallup:   site:gallup.com "[topic]"
OECD:     site:oecd.org "[topic]" data OR statistics
Eurostat: site:ec.europa.eu/eurostat "[topic]"
```

For known BLS series, construct direct API calls: `https://api.bls.gov/publicAPI/v2/timeseries/data/[series-id]` — no key required for basic access.

### ProPublica Nonprofit Explorer (For 990 Data)

```
API: https://projects.propublica.org/nonprofits/api/v2/organizations.json?q=[org+name]
Returns: EIN, filing years, direct 990 PDF links
```

Free, no key required. Best for non-profit financial data — faster and more structured than searching EDGAR for 990s directly.

### Google Trends (Unofficial — Pytrends Pattern)

No official API. The AI Anthropology Toolkit uses `pytrends` (Python), which wraps the unofficial Trends endpoint. In a Claude Code context without Python execution, the practical approach is:

- Construct a Google Trends URL for the user to review manually: `https://trends.google.com/trends/explore?q=[topic]&date=today 5-y`
- Note: Do not attempt to call the unofficial API directly — it rate-limits aggressively and has no stability guarantees.
- This is useful for the user to validate trend direction; do not treat Trends output as a citable source.

---

## Feature Dependencies

```
/research:discover
  → requires: discovery playbooks (reference file)
  → requires: channel-specific query builders (logic within the skill)
  → requires: channel availability check (which MCP servers/APIs are configured)
  → outputs: candidate URL list
  → feeds into: existing /research:process-source (unchanged)

Discovery playbooks
  → derived from: existing credibility hierarchies in type templates
  → no new dependencies

EDGAR EFTS integration
  → no API key required
  → uses: tavily_extract or WebFetch to pull EDGAR EFTS JSON response
  → outputs: filing URLs → /research:process-source

OpenAlex integration
  → no API key required
  → uses: WebFetch to call OpenAlex API
  → outputs: paper URLs (open-access PDFs or abstract pages) → /research:process-source

YouTube integration
  → requires: YouTube Data API v3 key (user must configure)
  → degrade gracefully if key not present
  → outputs: youtube.com/watch URLs → /research:process-source (via tavily_extract)

Google Trends
  → no API (unofficial only)
  → outputs: URL for user to review manually, NOT a processable source
  → treated as a signal, not a source

Patent discovery
  → no API key required (uses web URL construction)
  → uses: tavily_extract on Google Patents search result pages
  → outputs: individual patent URLs → /research:process-source

ProPublica Nonprofit Explorer
  → no API key required
  → uses: WebFetch to call ProPublica API
  → outputs: 990 PDF URLs → /research:process-source
```

---

## MVP Recommendation

**Build first (table stakes, unlock the core value proposition):**

1. Discovery playbooks as reference files — one per research type, maps type to ordered channel list with rationale. This is the intellectual work; execution follows from it.
2. `/research:discover` skill — takes the current phase topic, reads the playbook for this project's type, executes available channels in priority order, returns a ranked candidate URL list.
3. EDGAR EFTS integration — no key required, dramatically improves company and person research. High value, low implementation friction.
4. OpenAlex integration — no key required, unlocks academic source discovery for thesis, curriculum, market, and presentation research types.
5. Channel-specific query construction — at minimum, distinct query patterns for: web search (Tavily), EDGAR, and OpenAlex. These three channels cover most research types.

**Build second (differentiators, meaningful lift for specific types):**

6. ProPublica integration for non-profit 990 discovery
7. Google Patents URL construction + Tavily extract pattern
8. YouTube Data API integration (for curriculum and person research)
9. Google Trends URL construction + manual review pattern
10. Channel result ranking by credibility hierarchy

**Defer (high complexity, limited marginal value):**

11. Podcast RSS discovery — requires transcription pipeline or RSS parsing; complex implementation, limited incremental value over YouTube + web search
12. Semantic Scholar (redundant with OpenAlex for most use cases; OpenAlex has better coverage for non-biomedical fields)
13. PACER court record integration — requires account, complex authentication, niche use case (covered adequately by "note as a manual check" in person research playbook)

---

## Complexity Assessment

| Feature | Complexity | Blocking Dependency | Notes |
|---------|------------|---------------------|-------|
| Discovery playbooks (reference files) | Low | None | Pure writing; no code |
| `/research:discover` skill | Medium | Playbooks | Orchestration logic; channel availability detection |
| Graceful degradation | Low | `/research:discover` | Check-before-use pattern in the skill |
| Hand-off to process-source | Low | None | Already how process-source works; just need to output URLs |
| EDGAR EFTS integration | Medium | `/research:discover` | Requires URL construction and JSON response parsing |
| OpenAlex integration | Medium | `/research:discover` | Requires API call and result normalization |
| Query construction per channel | Medium | None | Patterns can be documented in reference file and called from the skill |
| Channel result ranking | Medium | All channels | Requires knowing credibility tier per channel per type |
| ProPublica integration | Low | `/research:discover` | Simple REST API, no key, well-documented |
| Google Patents discovery | Medium | `/research:discover` | No API; URL construction + Tavily extract on result pages |
| YouTube Data API | Medium | `/research:discover` | Requires API key config; graceful skip if absent |
| Google Trends | Low | None | URL construction only; manual user step |
| Podcast RSS discovery | High | Transcription infrastructure | Not worth building in this milestone |

---

## Sources

**Confidence assessment:**
- Research type channel mappings: HIGH — derived directly from the existing type template credibility hierarchies, which were already authored by the project
- EDGAR EFTS API pattern: HIGH — EDGAR full-text search API is well-documented public infrastructure, stable
- OpenAlex API pattern: HIGH — OpenAlex is a well-established open scholarly graph with stable REST API documentation
- YouTube Data API: HIGH — Google's stable v3 API, well-documented
- Google Patents URL construction: MEDIUM — No official API; URL pattern is stable but not guaranteed
- ProPublica Nonprofit Explorer API: HIGH — Documented public API, stable
- Google Trends assessment: MEDIUM — Unofficial API is fragile; assessment based on known pytrends patterns and rate-limiting behavior
- AI Anthropology Toolkit pattern descriptions: MEDIUM — Based on training knowledge of the toolkit's approach; WebFetch was blocked so direct notebook inspection was not possible. The general pattern (per-channel notebooks, query construction, result normalization) is well-known from the toolkit's documentation and community usage. Specific implementation details may differ from current versions.
