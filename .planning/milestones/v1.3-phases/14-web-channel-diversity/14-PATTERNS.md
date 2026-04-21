# Phase 14: Web Channel Diversity - Pattern Map

**Mapped:** 2026-04-20
**Files analyzed:** 2 modified files
**Analogs found:** 2 / 2

## File Classification

| Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---------------|------|-----------|----------------|---------------|
| `.claude/reference/discovery/channel-playbooks/web-search.md` | channel playbook | request-response (parallel APIs) | `.claude/reference/discovery/channel-playbooks/academic.md` (Sections 2, 3, 6, 7, 8) | exact — same multi-API-within-one-playbook pattern |
| `.claude/commands/research/discover/SKILL.md` | orchestrator skill | request-response | `SKILL.md` existing Web Search subsection (lines 314–324) | self-referential update — extend existing subsection |

---

## Pattern Assignments

### `.claude/reference/discovery/channel-playbooks/web-search.md`

**Analog:** `.claude/reference/discovery/channel-playbooks/academic.md`

**Tool configuration pattern** (academic.md lines 26–43) — model for adding a second API block under Section 2:

```markdown
**API 2 — Crossref:**
- Base URL: `https://api.crossref.org/works`
- Authentication: None required — polite pool via `mailto` query parameter (same as OpenAlex convention)
- Response format: JSON
- Returns: Paper metadata including DOI, title, authors, citation count (is-referenced-by-count), publication date, and primary URL

**API 3 — Unpaywall:**
- Base URL: `https://api.unpaywall.org/v2/{doi}`
- Authentication: None required — email parameter required for identification: `?email={email}`
- Response format: JSON
- Returns: Open access status, best OA location URL, license, and OA type (gold/green/hybrid/bronze/closed)
```

Apply to web-search.md Section 2 by adding an **API 2 — Exa** block following the existing Tavily configuration block.

---

**Query template pattern** (academic.md lines 76–113) — model for Crossref/Unpaywall templates following OpenAlex templates:

```markdown
### Crossref Query Templates

### Template D — Crossref Topic Search
Find papers on a subject via Crossref, sorted by relevance:

```bash
curl -s "https://api.crossref.org/works?query={topic}&rows=8&sort=relevance&order=desc&mailto={email}"
```

Substitute: `{topic}` = search phrase (URL-encode spaces as `+`), `{email}` = contact email for polite pool.
```

Apply to web-search.md Section 3 by adding Exa query templates (Template D, E, F) after the existing Tavily Template A/B/C block. Templates follow the same structure: template name, code fence with the call, placeholder substitution table, and "Use when:" guidance.

---

**Per-API degradation pattern** (academic.md lines 184–201) — model for Exa's independent degradation path:

```markdown
**Unpaywall degradation (if api.unpaywall.org unavailable):**

If Unpaywall is unavailable (timeout > 15 seconds, HTTP 5xx, HTTP 429), the paper remains DISCOVERED. Skip silently. Log a one-line channel status note: `Unpaywall: unavailable — N papers remain DISCOVERED`. Do not retry. Do not block. Do not fall back to another service — there is no equivalent free OA lookup service.
```

Apply to web-search.md Section 6 by adding a dedicated **Exa degradation** block after the existing Tavily 3-tier chain. Exa's block is independent — Exa failure does not trigger Tavily fallbacks (D-13). Pattern: skip silently, log channel status note `Exa: unavailable — web search results from Tavily only`, continue with Tavily results.

---

**Rate limits per-API pattern** (academic.md lines 210–228) — model for adding Exa rate limits alongside Tavily:

```markdown
**OpenAlex polite pool (with mailto parameter):** 10 requests/second

**Without mailto:** 1 request/second

**Daily cap:** None documented for reasonable usage (hundreds of requests per session is fine).

**Crossref polite pool (with mailto parameter):** 50 requests/second
```

Apply to web-search.md Section 7 by adding an **Exa** rate limit entry after the existing Tavily entry: free tier 1,000 searches/month (D-05), no per-second throttle for typical sessions.

---

**Section 8 dedup and priority rules pattern** (academic.md lines 232–249) — direct template for new web-search.md Section 8:

```markdown
## 8. Deduplication and Priority Rules

**Query order:** OpenAlex first, Crossref second, Unpaywall third (inline during same pass).

**Deduplication by DOI:** If a paper appears in both OpenAlex and Crossref results (matched by DOI string equality after normalization to lowercase), the OpenAlex entry is kept. The Crossref entry is silently dropped. This mirrors the URL deduplication in the discover skill's Step 4.

**Channel status line:** After all three APIs complete, report a single academic channel status line:
```
Academic: {N} results (OpenAlex: {n1}, Crossref-only: {n2}, Unpaywall upgrades: {n3}) [degraded: {list}]
```
Where `{list}` names any API that was unavailable during this run (empty if all succeeded).
```

Apply as new web-search.md Section 8 with these substitutions:
- Dedup key: URL string equality (not DOI) — exact match, no normalization (D-07)
- Priority: Tavily entry kept when URL matches; Exa entry silently dropped (mirrors academic.md's OpenAlex-priority rule)
- Status line format (D-10): `Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3})`
- Degradation annotation: `[degraded: Exa]` if Exa was unavailable

---

**Inline source attribution tag pattern** — existing tags in web-search.md Section 5 and SKILL.md Step 6 candidate format:

```
- [ACCESSIBLE] https://example.com/report — key claim confirmed: "direct quote or paraphrase"
- [DISCOVERED] https://example.com/article — "title or description"
```

Existing extended tags from SKILL.md Step 3 degradation:
```
[Firecrawl fallback]
[WebSearch fallback]
[via tvly fallback]
```

Apply D-09: add engine attribution tags `[Tavily]`, `[Exa]`, `[Tavily+Exa]` after the status tag and before the title. Full format: `- [ACCESSIBLE] [Exa] Title — URL`. Document this in web-search.md Section 8 alongside the dedup rules.

---

### `.claude/commands/research/discover/SKILL.md`

**Analog:** SKILL.md existing Web Search channel execution subsection (lines 314–324)

**Current Web Search subsection** (lines 314–324) — the block being extended:

```markdown
### Web Search (channel-type: web-search)

Primary tool: `tvly search` (via Bash)

Execution parameters (from web-search.md playbook):
- `--topic general` for background/overview phases
- `--topic news --time-range month` for recent-developments phases
- `--include-domains`: leave empty for general web search (returns broadest results)
- `--exclude-domains`: exclude low-credibility aggregators if specified in playbook

Fallback chain: `npx firecrawl-cli search` (label: `[Firecrawl fallback]`) → `WebSearch` (label: `[WebSearch fallback]`)
```

**Pattern for parallel-API execution documentation** — academic.md subsection in SKILL.md (lines 382–396) shows how a multi-API channel documents its execution params:

```markdown
### Academic (channel-type: academic)

Primary: `Bash` curl to OpenAlex API

Key parameters:
- Include `mailto=research-agent@example.com` in all OpenAlex requests (activates 10 req/s polite pool)
- Extract per result: title, DOI, authors, citation count, open-access status (`is_oa`), OA URL (`open_access.oa_url`)
- Status determination: `is_oa=true` → ACCESSIBLE, `is_oa=false` → DISCOVERED

Rate limit: 10 req/s with mailto, 1 req/s without.

Fallback chain (per academic.md):
1. `tvly search --include-domains "scholar.google.com,arxiv.org,pubmed.ncbi.nlm.nih.gov"` — label: `[via tvly fallback]`
```

Apply to SKILL.md Web Search subsection: extend to document Exa as a parallel secondary tool after Tavily. Add:
- Secondary tool: Exa API (after Tavily, per D-02)
- Exa auth: `EXA_API_KEY` environment variable (D-05)
- Execution order: Tavily first (8 results), Exa second (8 results), dedup collapses URL matches
- Combined status line format: `Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3})`
- Exa degradation: skip silently if unavailable; Tavily degradation chain unchanged (D-13)

---

## Shared Patterns

### Multi-API Within One Playbook
**Source:** `.claude/reference/discovery/channel-playbooks/academic.md` (full file)
**Apply to:** `web-search.md` extension

The established contract:
- One playbook owns one channel; additional APIs are added as numbered subsections within the same file
- Query execution order is fixed and documented (primary API first, secondary second)
- Each API has its own tool configuration block (Section 2), query templates (Section 3), rate limits (Section 7), and degradation path (Section 6)
- A Section 8 dedup rules block handles cross-API result merging; the primary API's results take priority

### Per-API Independent Degradation
**Source:** `.claude/reference/discovery/channel-playbooks/academic.md` lines 184–201
**Apply to:** `web-search.md` Section 6 (Exa degradation path)

Contract: each API's degradation is isolated. Unpaywall unavailability does not trigger OpenAlex fallbacks. Applied to Exa: Exa failure does not touch Tavily's 3-tier chain. Log `Exa: unavailable — web search results from Tavily only` and continue.

### Combined Channel Status Line
**Source:** `.claude/reference/discovery/channel-playbooks/academic.md` lines 246–249
**Apply to:** `web-search.md` Section 8, `discover/SKILL.md` Web Search subsection

```markdown
Academic: {N} results (OpenAlex: {n1}, Crossref-only: {n2}, Unpaywall upgrades: {n3}) [degraded: {list}]
```

Web Search analog (D-10):
```
Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3})
```

### Inline Source Attribution Tags
**Source:** `.claude/reference/discovery/channel-playbooks/web-search.md` Section 5, `discover/SKILL.md` Step 6
**Apply to:** `web-search.md` Section 8 (tag definitions), candidate file output format

Existing tag idiom (status tags precede title, fallback tags follow status tag):
```
- [ACCESSIBLE] Title — URL
- [DISCOVERED] [Firecrawl fallback] Title — URL
```

New engine attribution tags (D-09) follow same idiom:
```
- [ACCESSIBLE] [Tavily] Title — URL
- [ACCESSIBLE] [Exa] Title — URL
- [ACCESSIBLE] [Tavily+Exa] Title — URL  ← deduped: Tavily entry kept, Exa match noted
```

---

## No Analog Found

None — both modified files have direct analogs in the codebase.

---

## Metadata

**Analog search scope:** `.claude/reference/discovery/channel-playbooks/`, `.claude/commands/research/discover/`
**Files scanned:** 4 (web-search.md, academic.md, discover/SKILL.md, 13-CONTEXT.md)
**Pattern extraction date:** 2026-04-20
