---
name: social-signals
description: Social platforms and community discussion discovery
allowed-tools:
  - tavily_search
  - WebSearch
channel-type: social-signals
---

# Social-Signals Channel Playbook

## 1. Channel Overview

**What this channel discovers:** Community discussions, practitioner opinions, forum threads, social media commentary, and crowd-sourced knowledge across platforms. Surfaces what people actually say about a topic — not what organizations publish about it.

**When to use it:**
- Gauging community sentiment or practitioner consensus on a topic
- Finding expert opinions, critiques, or debates not covered in formal publications
- Identifying real-world usage patterns, problems, or workarounds
- Surfacing niche forums and communities relevant to a research domain
- Checking for emerging concerns, controversies, or grassroots signals

**What it cannot find:**
- Private or closed communities (Facebook groups, Slack workspaces, Discord servers)
- Deleted posts or shadow-banned content
- Content behind paywalls on Substack, LinkedIn, or Medium member sections
- Verified identity or credential validation — all social claims require external corroboration

---

## 2. Tool Configuration

**Primary tool:** `tavily_search`

**Core parameters:**

| Parameter | Value | Notes |
|-----------|-------|-------|
| `search_depth` | `"advanced"` | Standard for all community discovery |
| `max_results` | 5–8 | Higher for community discussion; lower for expert opinion |
| `topic` | `"general"` | Default; no `"news"` topic for social signals |
| `include_domains` | See templates | Platform-scoped lists defined per query variant |
| `days` | omit | Use only if recency is explicitly required |

**Authentication:** Tavily API key via MCP server. No platform-specific authentication needed — Tavily surfaces publicly indexed content only.

---

## 3. Query Templates

### Template A — Community Discussion

```
tavily_search(
  query="{topic} discussion",
  search_depth="advanced",
  max_results=8,
  include_domains=["reddit.com", "news.ycombinator.com", "stackoverflow.com", "community.*.com"]
)
```

**Placeholder substitution:**
- `{topic}` — subject of community interest (e.g., "remote work productivity tools", "LLM hallucination")

**Use when:** Seeking community perspectives, practitioner debate, or user experience reports on a topic. Reddit and HN surface high-signal discussions across most technology, business, and social topics.

**Note on wildcard domains:** `community.*.com` pattern behavior in Tavily `include_domains` is unconfirmed. If wildcard does not resolve correctly, replace with explicit community domains relevant to the research domain (e.g., `community.openai.com`, `community.atlassian.com`).

---

### Template B — Expert Opinion

```
tavily_search(
  query="{topic} {entity_name} review OR opinion OR analysis",
  search_depth="advanced",
  max_results=5,
  include_domains=["twitter.com", "x.com", "linkedin.com", "medium.com", "substack.com"]
)
```

**Placeholder substitution:**
- `{topic}` — subject domain (e.g., "AI safety", "startup fundraising")
- `{entity_name}` — optional specific person, company, or product to anchor the query (e.g., "Anthropic", "Claude")

**Use when:** Seeking practitioner-level analysis, informed opinions, or expert takes from professionals who publish on social platforms. Medium and Substack surface longer-form analysis; Twitter/X and LinkedIn surface shorter signals.

---

### Template C — Forum/Niche Discovery

```
tavily_search(
  query="{topic} forum",
  search_depth="basic",
  max_results=5,
  topic="general"
)
```

**Placeholder substitution:**
- `{topic}` — the specific domain or interest area (e.g., "organic chemistry reactions", "landlord tenant law California")

**Use when:** The research domain has dedicated forums or niche communities not covered by mainstream platforms. `search_depth: "basic"` is intentional — this is a discovery query to identify communities, not extract deep content.

---

## 4. Credibility Tiers

Channel-level source ranking for social signals content. Social signals require more active credibility assessment than other channels — anonymity and incentives to mislead are high.

**Tier 1 — Highest Credibility:**
- Verified expert accounts with publicly confirmed credentials (e.g., researchers posting preprints with institutional affiliation)
- Established community contributors with high karma/reputation scores on moderated platforms (e.g., top-quartile SO contributors in relevant tags)
- Official company social accounts for factual announcements (product launches, policy changes)
- Named practitioners citing first-hand professional experience with specifics (not generalities)

**Tier 2 — Reliable:**
- Industry practitioners with identifiable professional histories (LinkedIn profile, personal site, publication history)
- Moderated forum threads with multiple corroborating responses from different accounts
- Established newsletters and Substack publications with known authorship and consistent track records
- Community wikis and FAQ posts on well-moderated forums (r/personalfinance wiki, Stack Overflow tag wikis)

**Tier 3 — Contextual:**
- Anonymous users without verifiable credentials
- Single-source social media claims without corroboration
- Unverified accounts, new accounts (< 6 months), accounts with limited history
- Comment threads where the claim originates from one user and others simply agree (no independent corroboration)

**Red Flags — Treat with Skepticism:**
- Astroturfing patterns: new accounts with no prior history praising a specific product, service, or person — especially in product-relevant subreddits
- Engagement-farmed posts: high upvotes on generic content, low-specificity claims that feel designed for sharing
- Screenshots of claims without links to the original source — cannot verify context or accuracy
- Coordinated posting patterns: multiple similar-sounding posts across different communities in a short window
- Influencer posts with undisclosed commercial relationships ("I love this product" without disclosure)

---

## 5. Source Status Taxonomy

See `web-search.md` Section 5 for canonical definitions of `DISCOVERED`, `ACCESSIBLE`, and `PROCESSED`.

**Social signals note:** Many social posts are ephemeral or may be deleted. Mark `ACCESSIBLE` only after confirming content is readable. If a thread or post is removed between discovery and extraction, log as `DISCOVERED (deleted)` and note the claim cannot be used.

---

## 6. Degradation Behavior

**Primary tool:** `tavily_search`

**Fallback:** `WebSearch` with site-specific queries

**Unavailability criteria:**
- HTTP 5xx response from Tavily MCP server
- Request timeout > 30 seconds
- Rate limit response (429)
- Authentication failure

**Fallback protocol:**
1. Detect unavailability via criteria above
2. Construct `WebSearch` queries with explicit site operators:
   - `site:reddit.com {topic} discussion`
   - `site:news.ycombinator.com {topic}`
   - `site:twitter.com {topic} {entity_name}`
3. Label all results: `"via WebSearch (Tavily fallback)"`
4. Note in research log: "Tavily unavailable — social signals via WebSearch with site: operators. Coverage limited to indexed public content; no include_domains scoping."

**Degradation impact:** WebSearch site: operators partially replicate `include_domains` behavior but are less reliable. Results may include more noise from SEO-optimized social aggregation sites. Increase skepticism threshold for fallback results.

---

## 7. Rate Limits

**Tavily:** Same limits as web-search channel (~1,000 searches/month on free tier). Social signals queries tend to return noisier results — do not compensate by running more queries; instead refine the query.

**WebSearch (fallback):** No documented hard limit; use conservatively and avoid repeated identical queries within a session.
