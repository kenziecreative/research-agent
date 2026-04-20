---
name: academic
description: Academic paper and scholarly source discovery via OpenAlex API
allowed-tools: [Bash, WebSearch]
channel-type: academic
---

# Academic Channel Playbook

## 1. Channel Overview

**Discovers:** Peer-reviewed journal articles, conference proceedings, preprints, books, systematic reviews, and meta-analyses.

**Best for:** Research types requiring empirical evidence, literature reviews, technical depth, or citation-backed claims. Ideal for validating scientific claims, identifying domain experts, and establishing research consensus.

**Cannot find:** Unpublished manuscripts, most dissertations and theses, non-English publications with poor OpenAlex indexing, proprietary research, classified reports, very recent preprints not yet indexed.

---

## 2. Tool Configuration

**Primary tool:** Bash (curl to OpenAlex HTTP API)

**Authentication:** None required — OpenAlex is fully open access.

**Base URL:** `https://api.openalex.org`

**Polite pool:** Include `mailto` parameter with a contact email for priority rate limit tier (10 req/s vs 1 req/s without).

**Response format:** JSON

---

## 3. Query Templates

### Template A — Topic Search
Find papers on a subject, filtered by citation count for quality:

```bash
curl -s "https://api.openalex.org/works?search={topic}&filter=cited_by_count:>10&per_page=8&sort=relevance_score:desc&mailto={email}"
```

Substitute: `{topic}` = search phrase, `{email}` = contact email for polite pool.

### Template B — Author Search
Find recent papers by a specific researcher:

```bash
curl -s "https://api.openalex.org/works?filter=authorships.author.display_name.search:{author_name}&per_page=8&sort=publication_date:desc&mailto={email}"
```

Substitute: `{author_name}` = full or partial name (URL-encode spaces as `+`), `{email}` = contact email.

### Template C — Filtered Search (Recent, Open Access, High-Impact)
Find recent open-access papers with meaningful citation counts:

```bash
curl -s "https://api.openalex.org/works?search={topic}&filter=from_publication_date:{year_minus_5},is_oa:true,cited_by_count:>5&per_page=8&sort=cited_by_count:desc&mailto={email}"
```

Substitute: `{topic}` = search phrase, `{year_minus_5}` = current year minus 5 (e.g., `2020` if current year is 2025), `{email}` = contact email.

---

## 4. Credibility Tiers

**Tier 1 (Highest credibility):**
- Papers in peer-reviewed journals with high citation counts (>50)
- Systematic reviews and meta-analyses
- Papers from journals with established impact factors
- Works by authors at recognized research institutions

**Tier 2 (Reliable with context):**
- Recent peer-reviewed papers with <50 citations (may simply be new, not low quality)
- Conference proceedings from top-tier venues (NeurIPS, ICML, CVPR, ICLR, CHI, etc.)
- Preprints from established researchers with institutional affiliations
- Book chapters from academic presses

**Tier 3 (Contextual — use cautiously):**
- Preprints without peer review from unknown authors
- Very low-citation papers (<5 citations, >2 years old)
- Conference workshop papers
- Book chapters from non-academic or vanity publishers

**Red flags:**
- **Predatory journal indicators (predatory publishers):** Implausibly fast review times (<1 week), journals indexed only in DOAJ without SCOPUS/WoS, journals not matching declared scope, excessive article processing charges with no clear review process
- **Retraction notices:** OpenAlex `is_retracted: true` field — always check before citing
- **Self-citation inflation:** Author has high citation count but most citations are from co-authored papers with overlapping author lists
- **Paper mills:** Multiple papers with suspiciously similar structures, methodologies, or figure patterns — common in life sciences and materials science
- **Citation manipulation:** Sudden spike in citations after long dormancy, especially for commercial claims

---

## 5. Source Status Taxonomy

Reference `.claude/reference/discovery/channel-playbooks/web-search.md` for canonical definitions of DISCOVERED / ACCESSIBLE / PROCESSED.

**Academic-channel notes:**
- OpenAlex `is_oa: true` indicates open access — the full text is likely ACCESSIBLE via `open_access.oa_url`
- Paywalled papers (is_oa: false) are DISCOVERED only unless the researcher has institutional access
- DOI links always resolve to a landing page (ACCESSIBLE for metadata), but full text may be paywalled
- arXiv preprints (`open_access.oa_url` contains "arxiv.org") are always ACCESSIBLE

---

## 6. Degradation Behavior

**Primary:** Bash curl to OpenAlex API (`https://api.openalex.org`)

**Tier 2 [Tavily fallback]:** `tvly search` with academic domain scoping:
```bash
tvly search "{topic} site:scholar.google.com OR site:arxiv.org OR site:pubmed.ncbi.nlm.nih.gov" --depth advanced --max-results 8 --json
```
Label results: "via tvly (OpenAlex fallback)"

**Tier 3 [Firecrawl fallback]:** `npx firecrawl-cli search` with academic keywords:
```bash
npx firecrawl-cli search "{topic} academic paper arxiv pubmed" --limit 8 --format json
```
Label results: "via Firecrawl (OpenAlex+tvly fallback)"

**Tier 4 [WebSearch fallback]:** WebSearch with academic domain keywords:
```
query: "{topic} academic paper OR research study OR systematic review"
```
Label results: "via WebSearch (OpenAlex+tvly+Firecrawl fallback)". Warn user that results will be less targeted — quality filtering not available.

> The agent works out of the box with zero CLIs installed — WebSearch is always available.

**Unavailable criteria:** Trigger next tier when:
- HTTP 5xx response from api.openalex.org (or non-zero exit from CLI)
- Request timeout > 15 seconds
- HTTP 429 rate limit (without mailto parameter — add mailto and retry once before falling back)

---

## 7. Rate Limits

**OpenAlex polite pool (with mailto parameter):** 10 requests/second

**Without mailto:** 1 request/second

**Daily cap:** None documented for reasonable usage (hundreds of requests per session is fine).

**Tavily (`tvly search`, fallback):** ~1,000 searches/month on free tier.

**Firecrawl (`npx firecrawl-cli search`, fallback):** Free tier: 500 credits/month; each search consumes credits based on result count.

**Best practice:** Always include `mailto={email}` parameter for OpenAlex. For bulk retrieval, use cursor-based pagination with `cursor=*` parameter rather than high `per_page` values.

---

## Example Response

Trimmed OpenAlex JSON response for a works query. The discover skill should extract these fields:

```json
{
  "results": [
    {
      "id": "https://openalex.org/W2741809807",
      "title": "Attention Is All You Need",
      "doi": "https://doi.org/10.48550/arXiv.1706.03762",
      "publication_date": "2017-06-12",
      "cited_by_count": 95000,
      "authorships": [
        {
          "author": {
            "display_name": "Ashish Vaswani"
          }
        }
      ],
      "open_access": {
        "is_oa": true,
        "oa_url": "https://arxiv.org/abs/1706.03762"
      },
      "primary_location": {
        "source": {
          "display_name": "arXiv"
        }
      },
      "is_retracted": false
    }
  ],
  "meta": {
    "count": 1,
    "per_page": 8,
    "page": 1
  }
}
```

**Fields to extract per result:**
- `title` — paper title
- `doi` — canonical identifier and link
- `publication_date` — for recency assessment
- `cited_by_count` — for credibility tier assignment
- `authorships[].author.display_name` — author names (may be multiple)
- `open_access.is_oa` — true = ACCESSIBLE, false = DISCOVERED
- `open_access.oa_url` — direct full-text URL if open access
- `primary_location.source.display_name` — journal or repository name
- `is_retracted` — if true, flag prominently before including in research
