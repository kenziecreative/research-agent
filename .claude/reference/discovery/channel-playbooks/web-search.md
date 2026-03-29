---
name: web-search
description: General web discovery via Tavily search
allowed-tools:
  - tavily_search
  - WebSearch
channel-type: web-search
---

# Web-Search Channel Playbook

## 1. Channel Overview

**What this channel discovers:** General web content — articles, blog posts, official pages, news, documentation, and public-facing organizational content. The broadest discovery channel and the default fallback for other channels when their specialized tools are unavailable.

**When to use it:**
- General topic research without a specific domain constraint
- Entity lookup (company, person, product, concept) with no channel preference
- Recent news and developments on any topic
- Background context gathering before activating specialized channels

**What it cannot find:**
- Paywalled content (surfaces summaries or citations only)
- Private databases, intranets, or authenticated portals
- Real-time data (stock prices, live feeds) — use financial or domain-specific channels
- Deep academic literature — academic channel provides better coverage

---

## 2. Tool Configuration

**Primary tool:** `tavily_search`

**Core parameters:**

| Parameter | Value | Notes |
|-----------|-------|-------|
| `search_depth` | `"advanced"` | Use for all research queries; `"basic"` only for quick fact checks |
| `max_results` | 5–8 | Higher for broad topic searches, lower for entity lookups |
| `topic` | `"general"` or `"news"` | `"news"` activates recency ranking and `days` parameter |
| `include_domains` | `[]` (empty) | Leave empty for general web; populate for domain-scoped searches |
| `exclude_domains` | omit or `[]` | Add known low-quality domains if needed |
| `days` | 90 | Only valid when `topic: "news"`; adjust for recency requirements |

**Authentication:** Tavily API key configured via MCP server. No per-request authentication needed.

---

## 3. Query Templates

### Template A — Topic Search

```
tavily_search(
  query="{topic} {context_keywords}",
  search_depth="advanced",
  max_results=8,
  topic="general"
)
```

**Placeholder substitution:**
- `{topic}` — the primary research subject (e.g., "renewable energy storage")
- `{context_keywords}` — 1–3 constraining terms from the research brief (e.g., "policy regulation 2024")

**Use when:** Broad topic coverage is needed; no specific entity or domain constraint.

---

### Template B — Entity Search

```
tavily_search(
  query="{entity_name} {entity_type}",
  search_depth="advanced",
  max_results=5,
  include_domains=[]
)
```

**Placeholder substitution:**
- `{entity_name}` — proper name of the entity (e.g., "OpenAI", "Jensen Huang")
- `{entity_type}` — category term that disambiguates (e.g., "company AI", "CEO NVIDIA", "nonprofit climate")

**Use when:** Researching a specific named entity (company, person, product, organization). No domain filtering applied — surface all relevant web presence.

---

### Template C — News/Recent Search

```
tavily_search(
  query="{topic} recent developments",
  search_depth="advanced",
  max_results=5,
  topic="news",
  days=90
)
```

**Placeholder substitution:**
- `{topic}` — subject of interest
- Adjust `days` to match recency requirement (30 = last month, 90 = last quarter, 365 = last year)

**Use when:** The research brief calls for recent developments, current events, or time-bounded discovery.

---

## 4. Credibility Tiers

Channel-level source ranking for results returned via web-search. These tiers rank within this channel; cross-channel ranking is defined in type templates.

**Tier 1 — Highest Credibility:**
- Government databases and official agency pages (.gov, .gov.uk, .europa.eu)
- Peer-reviewed publication landing pages and publisher archives
- Official regulatory filings and public records
- Recognized academic and research institution sites (.edu domains with institutional content)

**Tier 2 — Reliable:**
- Established national and international news organizations (AP, Reuters, BBC, NYT, WSJ)
- Industry analyst reports from recognized firms (Gartner, IDC, Forrester)
- Professional associations and standards bodies
- Major reference databases (Wikipedia for factual claims only, with source verification)

**Tier 3 — Contextual:**
- Company websites and official product pages (treat as primary source for company facts, secondary for industry claims)
- Press releases (source is the organization, not an independent observer)
- Blog posts, op-eds, and personal sites (useful for perspectives, not facts)
- User-generated content and forums

**Red Flags — Treat with Skepticism:**
- SEO-optimized listicles with no byline, no date, no cited sources
- Content farms producing high-volume generic articles (Demand Media pattern)
- AI-generated aggregation sites that summarize without original sourcing
- Press releases published through wire services (PR Newswire, Business Wire) presented as journalism
- Sites with excessive advertising-to-content ratios
- Undated content on time-sensitive topics

---

## 5. Source Status Taxonomy

**Canonical definitions** — all other channel playbooks reference this section.

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `DISCOVERED` | URL returned by search; content not yet verified accessible | Attempt extraction with `tavily_extract` or direct fetch |
| `ACCESSIBLE` | Content confirmed reachable and extractable; key facts visible | Extract and process; move to research notes |
| `PROCESSED` | Content extracted and integrated into research notes; claim traced | No further action needed; cite in output |

**Recording format:** When logging candidates in `research/discovery/`, annotate each URL with its current status.

```
- [DISCOVERED] https://example.com/article — "title or description"
- [ACCESSIBLE] https://example.com/report — key claim confirmed: "direct quote or paraphrase"
- [PROCESSED] https://example.com/filing — integrated into §3 financials
```

**Status does not imply credibility.** A `PROCESSED` source can still be Tier 3. Always record both status and tier assessment.

---

## 6. Degradation Behavior

**Primary tool:** `tavily_search`

**Fallback:** `WebSearch` (if Tavily unavailable)

**Unavailability criteria:**
- HTTP 5xx response from Tavily MCP server
- Request timeout > 30 seconds
- Rate limit response (429 or equivalent)
- Authentication failure (API key invalid or expired)

**Fallback protocol:**
1. Detect unavailability via one of the criteria above
2. Switch to `WebSearch` for the same query
3. Label all results obtained via fallback as: `"via WebSearch (Tavily fallback)"`
4. Note in research log: "Tavily unavailable — using WebSearch fallback. Results will be less targeted: no include_domains filtering, no topic parameter, no days scoping."

**Degradation impact:** WebSearch is a direct functional replacement for general web discovery. The primary limitations are:
- No `include_domains` scoping (results are broader)
- No `topic: "news"` with `days` parameter (recency filtering is manual)
- Result quality may be lower for specialized queries

**Recovery:** On subsequent research sessions, verify Tavily availability and re-run degraded queries if result quality was insufficient.

---

## 7. Rate Limits

**Tavily:**
- Free tier: ~1,000 searches/month (shared across all channels)
- No per-second throttle required for typical research sessions (1–20 searches per session)
- If approaching monthly limit: prioritize searches, batch related queries, use `max_results` conservatively
- Rate limit detection: 429 response → trigger degradation behavior (Section 6)

**WebSearch (fallback):**
- No documented hard limit; use conservatively
- Avoid repeated identical queries — cache results within a session
