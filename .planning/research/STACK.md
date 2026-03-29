# Technology Stack: Multi-Channel Source Discovery

**Project:** research-agent v1.1 — Structured Source Discovery
**Researched:** 2026-03-28
**Milestone context:** Adding structured multi-channel source discovery to an existing Claude Code research tool

---

## Research Method & Confidence Notes

WebSearch and general WebFetch were blocked in this environment. All findings use one of:
- **HIGH confidence** — Verified directly against official documentation (Tavily: via allowed WebFetch to docs.tavily.com)
- **MEDIUM confidence** — From training data (cutoff August 2025) plus multiple consistent prior sources; rate limits and endpoints are stable APIs unlikely to have changed materially
- **LOW confidence** — Single training data source, or areas where the MCP ecosystem moves fast

**Critical gap:** The MCP server ecosystem moves quickly. MCP server availability and version numbers should be re-verified before implementation. Training data reflects the MCP landscape through ~August 2025.

---

## 1. Tavily — Existing Integration, Domain Scoping Available

**Confidence: HIGH** (verified against docs.tavily.com)

### Confirmed Parameters for Domain Scoping

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| `include_domains` | array of strings | `[]` | Whitelist specific domains — max 300 domains |
| `exclude_domains` | array of strings | `[]` | Blacklist specific domains — max 150 domains |
| `topic` | string | `"general"` | Channel filter: `"general"`, `"news"`, `"finance"` |
| `time_range` | string | null | `"day"`, `"week"`, `"month"`, `"year"` |
| `start_date` / `end_date` | string | null | Exact date range in YYYY-MM-DD format |
| `country` | string | null | Boost results from a specific country |
| `search_depth` | string | `"basic"` | `"basic"`, `"advanced"`, `"fast"`, `"ultra-fast"` |

### Domain-Scoping Patterns Available Immediately

The `include_domains` parameter accepts an array of domain strings, enabling scoped search without any new integrations:

```
Academic-adjacent:
  include_domains: ["arxiv.org", "pubmed.ncbi.nlm.nih.gov", "scholar.google.com",
                    "semanticscholar.org", "researchgate.net", "ssrn.com",
                    "jstor.org", "ncbi.nlm.nih.gov"]

Government sources:
  include_domains: ["*.gov", "sec.gov", "census.gov", "bls.gov",
                    "federalregister.gov", "gao.gov", "cbo.gov",
                    "data.gov", "hhs.gov", "cdc.gov", "fda.gov"]

News sources:
  topic: "news"   (built-in news channel — no domain list needed)
  OR
  include_domains: ["reuters.com", "apnews.com", "wsj.com", "ft.com",
                    "bloomberg.com", "economist.com", "politico.com"]

Finance:
  topic: "finance"   (built-in finance channel)
```

**Important note on wildcards:** The best-practices doc shows `*.com` as a wildcard pattern. Whether `*.gov` works as a wildcard (to catch all .gov subdomains) vs. needing explicit domain listing is not confirmed — verify in implementation.

**Verdict:** Tavily domain scoping is the primary mechanism for targeted discovery in this project. No new API keys needed. Covers academic-adjacent, government, and news channels with a single existing tool.

---

## 2. Academic Search APIs — Directly Callable via HTTP

These APIs are freely accessible via HTTP GET requests (callable through Bash with curl, or directly from Claude Code tools). No MCP server is required.

### OpenAlex

**Confidence: MEDIUM** (training data, stable open API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://api.openalex.org/` |
| Authentication | None required for unauthenticated use |
| Rate limit (unauthenticated) | 10 requests/second, 100,000 requests/day |
| Rate limit (with email polite pool) | Same limits, prioritized service — add `?email=you@example.com` |
| Coverage | 240M+ academic works across all disciplines; includes works, authors, institutions, concepts, sources |
| Key endpoints | `/works`, `/authors`, `/institutions`, `/concepts`, `/sources` |
| Response format | JSON |
| Integration method | Direct HTTP / curl — no MCP needed |

**Search example:**
```bash
curl "https://api.openalex.org/works?search=machine+learning+in+healthcare&filter=publication_year:2023-2026&per-page=25"
```

**Why use it:** Largest fully open academic index. Free, no API key, high rate limits. Covers papers, conference proceedings, books. Good for market/industry research and exploratory thesis types where academic evidence matters.

**Limitation:** Coverage of very recent papers (<3 months) can lag. No full-text content — returns metadata and abstract. For full text, combine with tavily_extract on the DOI/URL.

### Semantic Scholar

**Confidence: MEDIUM** (training data, stable open API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://api.semanticscholar.org/graph/v1/` |
| Authentication | None for basic use; API key available for higher rate limits |
| Rate limit (unauthenticated) | 100 requests/5 minutes (~1/3 per second) |
| Rate limit (with API key) | 1 request/second |
| Coverage | 200M+ papers; strong in CS, AI/ML, biomedical |
| Key endpoints | `/paper/search`, `/paper/{paper_id}`, `/author/search` |
| Response format | JSON |
| Integration method | Direct HTTP / curl — no MCP needed |

**Search example:**
```bash
curl "https://api.semanticscholar.org/graph/v1/paper/search?query=transformer+architecture&fields=title,authors,year,abstract,citationCount&limit=20"
```

**Why use it:** Stronger than OpenAlex for AI/ML/CS papers. Citation graph data is uniquely useful for validating influence claims. Free API key available at semanticscholar.org — worth getting for the improved rate limit.

**Limitation:** More narrow coverage than OpenAlex for humanities and social sciences. Unauthenticated rate limits are tight for bulk queries.

### PubMed / NCBI E-utilities

**Confidence: MEDIUM** (training data, very stable government API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/` |
| Authentication | None required; NCBI API key available for higher limits |
| Rate limit (without key) | 3 requests/second |
| Rate limit (with NCBI API key) | 10 requests/second |
| Coverage | 35M+ biomedical/life science citations (PubMed); also covers other NCBI databases |
| Key endpoints | `esearch.fcgi` (search), `efetch.fcgi` (fetch full records), `elink.fcgi` (related articles) |
| Response format | XML (default), JSON (some endpoints) |
| Integration method | Direct HTTP / curl — no MCP needed |

**Search example:**
```bash
# Search returns PMIDs
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=CRISPR+gene+therapy&retmax=20&retmode=json"
# Then fetch abstracts by PMID list
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=12345678,87654321&rettype=abstract&retmode=text"
```

**Why use it:** Gold standard for biomedical research. If the research type involves health, medicine, biology, pharmaceuticals, or clinical research, PubMed is the authoritative source. Fully free.

**Limitation:** Biomedical only. Two-step process (search for IDs, then fetch records). XML parsing adds complexity.

### CrossRef

**Confidence: MEDIUM** (training data, stable open API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://api.crossref.org/` |
| Authentication | None required; "polite pool" with email in User-Agent |
| Rate limit | Unspecified; generous for polite pool users |
| Coverage | 145M+ DOI-registered works; strong in journal articles |
| Key endpoints | `/works`, `/works/{doi}`, `/journals`, `/funders` |
| Response format | JSON |
| Integration method | Direct HTTP / curl — no MCP needed |

**Why use it:** Best for DOI-based lookups and verifying publication metadata. Complements OpenAlex. Useful when you have a citation and want to verify its details.

**Limitation:** Not a full-text search engine. Better for metadata verification than discovery.

### arXiv

**Confidence: MEDIUM** (training data, stable open API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://export.arxiv.org/api/query` |
| Authentication | None required |
| Rate limit | 3 requests/second recommended; be polite |
| Coverage | 2M+ preprints in physics, math, CS, quantitative biology, economics |
| Response format | Atom/XML |
| Integration method | Direct HTTP / curl — no MCP needed |

**Search example:**
```bash
curl "https://export.arxiv.org/api/query?search_query=ti:large+language+model&start=0&max_results=20&sortBy=submittedDate&sortOrder=descending"
```

**Why use it:** Essential for cutting-edge AI/ML, physics, and CS research. Papers appear here before journal publication, often by 6-12 months.

**Limitation:** Preprints only — not peer-reviewed. Atom/XML response format requires parsing.

---

## 3. Government Data Sources — HTTP APIs

### SEC EDGAR

**Confidence: MEDIUM** (training data, stable SEC API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://data.sec.gov/` |
| Authentication | None; User-Agent header with contact email required |
| Rate limit | 10 requests/second |
| Coverage | All public company filings: 10-K, 10-Q, 8-K, DEF 14A, S-1, etc. |
| Key endpoints | `/submissions/{CIK}.json` (company filings index), `/api/xbrl/companyfacts/{CIK}.json` (structured financials) |
| Full-text search | `https://efts.sec.gov/LATEST/search-index?q="search+term"&dateRange=custom` |
| Response format | JSON |
| Integration method | Direct HTTP / curl — no MCP needed |

**Why use it:** Authoritative for public company financials, executive compensation, risk factors, ownership, and disclosures. Required for company for-profit research and investor due diligence research types. Free, reliable, no API key.

**Limitation:** Requires knowing the company's CIK number (easily looked up). XBRL data needs some parsing sophistication for complex financial analysis.

### U.S. Census Bureau

**Confidence: MEDIUM** (training data, stable government API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://api.census.gov/data/` |
| Authentication | API key recommended (free, instant registration at api.census.gov) |
| Rate limit | 500 requests/day without key; generous with key |
| Coverage | Demographic, economic, housing data from Decennial Census, ACS, Economic Census, and more |
| Integration method | Direct HTTP / curl — no MCP needed |

**Why use it:** Market sizing, demographic analysis, economic context. Essential for market/industry research types when quantifying market characteristics.

### Bureau of Labor Statistics (BLS)

**Confidence: MEDIUM** (training data, stable government API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://api.bls.gov/publicAPI/v2/` |
| Authentication | API key for v2 (free registration); v1 works without key |
| Rate limit | 500 queries/day (v2 with key), 25/day (v1 without) |
| Coverage | Employment, unemployment, CPI, wages, productivity, occupational data |
| Key endpoint | `/timeseries/data/` |
| Response format | JSON |
| Integration method | Direct HTTP / curl — no MCP needed |

**Why use it:** Authoritative labor market data. Employment statistics, wage data, occupational outlook — essential for market/industry research and PRD validation.

### USPTO Patent Data (PatentsView / Open Data Portal)

**Confidence: MEDIUM** (training data; PatentsView is the primary open API)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://search.patentsview.org/api/v1/` |
| Authentication | API key (free, fast registration) |
| Rate limit | 45 requests/minute with key |
| Coverage | US patents 1976–present; patent applications; inventors; assignees |
| Response format | JSON |
| Integration method | Direct HTTP / curl — no MCP needed |

**Why use it:** PRD validation (IP landscape), competitive analysis (competitor patent activity), technology research. Use PatentsView rather than raw USPTO, which has a worse API.

**Alternative:** Google Patents is more comprehensive for global patents but has no official API (see below).

### Federal Reserve (FRED)

**Confidence: MEDIUM** (training data, stable and widely used)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://api.stlouisfed.org/fred/` |
| Authentication | API key (free registration at fred.stlouisfed.org) |
| Rate limit | 120 requests/minute |
| Coverage | 800,000+ US and international economic time series |
| Response format | JSON or XML |
| Integration method | Direct HTTP / curl — no MCP needed |

**Why use it:** Economic context for market research, industry analysis, company financial environment.

---

## 4. News and Trends Sources

### Google News

**Confidence: MEDIUM** (training data; no official API)

Google News has **no official public API**. Access options:

| Method | Access | Reliability | Integration |
|--------|--------|-------------|-------------|
| Tavily `topic: "news"` | Via existing Tavily | HIGH — already integrated | Use immediately |
| RSS feeds (`news.google.com/rss/search?q=...`) | Free, no auth | Medium — may change format | curl-accessible |
| SerpAPI Google News | Paid ($50/mo+) | High | HTTP API |
| NewsAPI.org | Free tier: 100 req/day | Medium | HTTP API |

**Recommendation:** Use Tavily `topic: "news"` as the primary news search channel. It's already integrated and requires no additional setup. The RSS feed is a curl-accessible fallback for specific queries.

**RSS example:**
```bash
curl "https://news.google.com/rss/search?q=AI+regulation&hl=en-US&gl=US&ceid=US:en"
```

### Google Scholar

**Confidence: MEDIUM** (training data; no official API)

Google Scholar has **no official public API**. Google explicitly prohibits scraping.

| Method | Access | Reliability |
|--------|--------|-------------|
| Tavily `include_domains: ["scholar.google.com"]` | Via Tavily | Partial — Scholar often blocks crawlers |
| SerpAPI Google Scholar API | Paid | Reliable but paid |
| OpenAlex / Semantic Scholar | Free, official | High — recommended alternative |

**Recommendation:** Do not build Google Scholar integration. Use OpenAlex and Semantic Scholar as the academic discovery channels — they cover the same material with official APIs. Google Scholar scoping via Tavily is unreliable.

### Google Trends

**Confidence: MEDIUM** (training data; no official API)

Google Trends has **no official public API**.

| Method | Access | Reliability |
|--------|--------|-------------|
| pytrends (Python) | Unofficial library, reverse-engineered | Fragile, rate-limited, Google actively blocks |
| SerpAPI Google Trends | Paid | Reliable but paid |
| Manual export (CSV) | Free, manual | Not automatable |

**Recommendation:** Do not build Google Trends integration. Fragile unofficial APIs are a maintenance liability. If trend data is needed, scope the research type to use Tavily news with time_range filtering to observe coverage trends, or document Google Trends as a manual step.

### NewsAPI.org

**Confidence: MEDIUM** (training data; free tier available)

| Attribute | Value |
|-----------|-------|
| Base URL | `https://newsapi.org/v2/` |
| Authentication | API key (free tier: developer use, 100 req/day, delayed 24h) |
| Rate limit | 100 requests/day (free), higher on paid plans |
| Coverage | 80,000+ news sources; headlines and full article metadata |
| Response format | JSON |
| Integration method | Direct HTTP / curl |

**Verdict:** Usable as a supplementary news channel, but the 24-hour delay on the free tier limits its utility for current events research. Tavily `topic: "news"` is superior for this use case.

---

## 5. MCP Server Ecosystem

**Confidence: LOW** — MCP ecosystem was rapidly evolving through my training cutoff. Server availability and quality must be verified before implementation. The official MCP server list at modelcontextprotocol.io/servers is the authoritative source.

### Academic / Research MCP Servers

| Server | Status | Source | Notes |
|--------|--------|--------|-------|
| `mcp-server-pubmed` | Unverified | Various GitHub repos | Multiple community implementations exist; quality varies. No official NCBI MCP server known. |
| `mcp-openalex` | Unverified | Community | Unverified existence/quality. OpenAlex's API is clean enough that direct HTTP via Bash is simpler. |
| `arxiv-mcp-server` | Unverified | Community | Community implementations exist; verify before using. |

**Verdict on academic MCP servers:** The HTTP APIs for OpenAlex, Semantic Scholar, PubMed, and arXiv are well-designed, free, and callable via Bash. The overhead of installing and configuring community MCP servers for these sources is not justified. Direct HTTP access is the recommended approach.

### Government Data MCP Servers

| Server | Status | Notes |
|--------|--------|-------|
| SEC EDGAR MCP | Unverified | No official server known. Direct HTTP via `data.sec.gov` is straightforward. |
| Census/BLS MCP | Unverified | No official servers known. HTTP APIs are well-documented. |

**Verdict on government MCP servers:** No authoritative MCP servers found for these sources. Direct HTTP is the recommended approach.

### Confirmed MCP Servers in Use

| Server | Status | Purpose |
|--------|--------|---------|
| Tavily MCP | CONFIRMED — already installed and working | Web search, extract, map, crawl |

### MCP Servers Worth Investigating

**LOW confidence — check modelcontextprotocol.io/servers before implementing:**

| Server | What it Would Enable | Check At |
|--------|---------------------|----------|
| `@modelcontextprotocol/server-brave-search` | Brave Search as alternative/supplement to Tavily | npmjs.com |
| Exa MCP server | Neural search — good for academic-style semantic queries | exa.ai/docs |

---

## 6. Integration Method Summary

| Source | Integration Method | Effort | Recommendation |
|--------|-------------------|--------|----------------|
| Tavily domain scoping | Existing tool parameter | Zero — already works | Use immediately |
| Tavily news channel | Existing tool parameter (`topic: "news"`) | Zero | Use immediately |
| Tavily finance channel | Existing tool parameter (`topic: "finance"`) | Zero | Use immediately |
| OpenAlex | Direct HTTP (curl in Bash) | Low | Implement in discovery playbooks |
| Semantic Scholar | Direct HTTP (curl in Bash) | Low | Implement for CS/AI research types |
| PubMed E-utilities | Direct HTTP (curl in Bash) | Low | Implement for biomedical research types |
| CrossRef | Direct HTTP (curl in Bash) | Low | Implement as metadata verification tool |
| arXiv | Direct HTTP (curl in Bash) | Low | Implement for CS/physics/AI research types |
| SEC EDGAR | Direct HTTP (curl in Bash) | Low | Implement for company for-profit research type |
| Census API | Direct HTTP (curl in Bash) | Low — free API key needed | Implement for market/industry research type |
| BLS API | Direct HTTP (curl in Bash) | Low — free API key needed | Implement for market/industry research type |
| PatentsView | Direct HTTP (curl in Bash) | Low — free API key needed | Implement for PRD validation and competitive analysis |
| FRED | Direct HTTP (curl in Bash) | Low — free API key needed | Implement for market/industry research type |
| Google Scholar | Do not implement | — | Use OpenAlex + Semantic Scholar instead |
| Google Trends | Do not implement | — | Unstable unofficial API; not worth the fragility |
| Google News | Do not implement separately | — | Tavily `topic: "news"` is sufficient |
| NewsAPI.org | Optional supplement | Low | 24h delay on free tier limits utility |
| Academic MCP servers | Do not implement | — | HTTP APIs are simpler and more reliable |
| Government MCP servers | Do not implement | — | No authoritative servers exist |

---

## 7. Key Design Decisions for v1.1

**Decision 1: Tavily domain scoping is the primary mechanism.**
The `include_domains` and `topic` parameters cover academic-adjacent, government, news, and finance channels without any new integrations. This should be the first implementation target.

**Decision 2: Direct HTTP for specialized academic/government APIs.**
OpenAlex, Semantic Scholar, PubMed, arXiv, SEC EDGAR, BLS, Census, and PatentsView all offer clean, free HTTP APIs callable via Bash. No MCP server installs required. The discovery playbooks can emit curl commands as instructions, or the `/research:discover` skill can call them directly.

**Decision 3: No Google services.**
Google Scholar (no API, blocks crawlers), Google Trends (fragile unofficial API), and Google News (no API) are not practical to integrate. Alternatives (OpenAlex for academic, Tavily news for news) are superior.

**Decision 4: Graceful degradation by design.**
Not all users will have Bash access or want to install additional tools. Discovery playbooks should list channels in priority order, note which require API keys or Bash, and instruct the agent to skip unavailable channels rather than error.

**Decision 5: API keys stay user-managed.**
APIs that offer better rate limits with a free key (Census, BLS, PatentsView, FRED, Semantic Scholar) should document the key registration process, but the project should not require or store keys. Keys go in the user's environment; discovery instructions reference them by name (e.g., `$CENSUS_API_KEY`).

---

## 8. Tavily Rate Limits (Current)

**Confidence: MEDIUM** — Rate limit documentation was not detailed on the rate-limits page. From docs: development keys support 100 req/minute, production keys support 1,000 req/minute. Production keys require an active paid plan. Monthly credit limits are plan-dependent (not publicly documented).

**Implication for discovery:** For a research session, the multi-channel discovery sequences will issue 5-15 Tavily searches. This is well within any tier's per-minute limits. Rate limiting is not a practical concern for this use case.

---

## Sources

| Source | Confidence | URL |
|--------|------------|-----|
| Tavily Search endpoint docs | HIGH | https://docs.tavily.com/documentation/api-reference/endpoint/search.md |
| Tavily Search best practices | HIGH | https://docs.tavily.com/documentation/best-practices/best-practices-search.md |
| Tavily Extract endpoint docs | HIGH | https://docs.tavily.com/documentation/api-reference/endpoint/extract.md |
| Tavily Research endpoint docs | HIGH | https://docs.tavily.com/documentation/api-reference/endpoint/research.md |
| Tavily rate limits | MEDIUM | https://docs.tavily.com/documentation/rate-limits.md (limited detail) |
| OpenAlex API | MEDIUM | Training data — verify at https://docs.openalex.org |
| Semantic Scholar API | MEDIUM | Training data — verify at https://api.semanticscholar.org/graph/v1 |
| PubMed E-utilities | MEDIUM | Training data — verify at https://www.ncbi.nlm.nih.gov/home/develop/api/ |
| CrossRef API | MEDIUM | Training data — verify at https://api.crossref.org |
| arXiv API | MEDIUM | Training data — verify at https://arxiv.org/help/api |
| SEC EDGAR API | MEDIUM | Training data — verify at https://www.sec.gov/developer |
| Census API | MEDIUM | Training data — verify at https://api.census.gov |
| BLS API | MEDIUM | Training data — verify at https://www.bls.gov/developers/ |
| PatentsView API | MEDIUM | Training data — verify at https://search.patentsview.org/api/v1/ |
| FRED API | MEDIUM | Training data — verify at https://fred.stlouisfed.org/docs/api/fred/ |
| MCP server ecosystem | LOW | Training data — verify at https://modelcontextprotocol.io/servers |
