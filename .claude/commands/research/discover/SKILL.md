---
name: discover
description: "Execute type-aware, multi-channel source discovery for the current research phase"
allowed-tools: [tavily_search, Bash, WebSearch, tavily_extract, Read, Grep, Glob]
disable-model-invocation: true
---

# /research:discover

Execute source discovery for the current research phase using all channels configured for the project's research type. Produces a reviewable candidate list — never auto-feeds into process-source.

Supports optional `--channel {name}` argument for targeted re-runs against a single channel (e.g., `--channel academic`).

## Pre-check (mandatory before execution)

1. **Read `research/STATE.md`** — extract the current active phase name. If no active phase field is present or it is empty, error: "No active phase. Run `/research:start-phase` first." Do not proceed.

2. **Read `research/research-plan.md`** — extract the research questions and research subject (the entity, topic, or organization being researched) for the active phase. These become the primary inputs for query construction.

3. **Determine the research type** — read the project's CLAUDE.md. Find the `research-type` field. This value (e.g., `company-for-profit`, `non-profit`, `market-industry`) selects the type-channel map.

4a. **Check for discovery strategy** — read `research/discovery/strategy.md` if it exists. If found, look up the current active phase name in the strategy file. The strategy contains pre-matched phase-to-channel mappings (primary and secondary channels per phase). If the current phase is found in the strategy:
- Use the pre-matched channels directly — no keyword guessing needed
- Print: "Using project discovery strategy (pre-matched channels)"
- Skip to step 5 check (if channels list is empty or marked "no discovery", report "No discovery channels mapped for this phase — this phase uses existing sources." and stop)

4b. **Fall back to type-channel map** (only if `research/discovery/strategy.md` does not exist OR the current phase was not found in strategy.md):
- Print: "Using type-channel map (keyword matching)"
- Read the type-channel map at `.claude/reference/discovery/type-channel-maps/{research-type}.md`. Parse `active-channels` from the frontmatter. Find the Discovery Group whose Phases list matches (or partially matches, via keyword) the current active phase name. The matched Discovery Group determines which channels to query and their priority order (Primary, Secondary).

5. **If no Discovery Group matches the current phase**, report: "No discovery channels mapped for this phase — this phase uses existing sources." and stop. This is expected for synthesis and output phases.

6. **If `--channel {name}` was provided**, filter the channel list to only that channel. Confirm it exists in the matched Discovery Group's channel list. If not found, error: "Channel '{name}' is not configured for this phase. Available channels: {list}."

7. **Check for existing candidates file** at `research/discovery/{phase}-candidates.md`. If it exists, new results will be appended with a timestamp separator and deduplicated by URL against existing entries. Note this to the user before proceeding.

## Process

### Step 1: Resolve channels

From the matched Discovery Group, collect Primary channels and Secondary channels. Primary channels execute first. If `--channel` filter was applied, use only that channel.

Print: "Running discovery for phase: {phase name} | Research type: {type} | Channels: {list}"

### Step 2: Execute each channel in priority order

For each channel:

**a.** Print status line: "{Channel Name}: querying..."

**b.** Read the channel playbook at `.claude/reference/discovery/channel-playbooks/{channel-name}.md`

**c.** Select the appropriate query template from the playbook:
- Broad/background phases: use Template A (topic/overview search)
- Company/entity-specific phases: use Template B (entity-targeted search)
- Recent developments or time-sensitive phases: use Template C (recent news, add `days=90`)
- When in doubt, use Template A for general coverage

**d.** Substitute template placeholders:
- `{topic}` or `{research_subject}` → research subject name from research-plan.md
- `{company_name}` or `{entity_name}` → research subject name
- `{year_minus_2}` → current year minus 2 (e.g., 2024 for 2026)
- `{year_minus_5}` → current year minus 5 (e.g., 2021 for 2026)
- `{email}` → `research-agent@example.com` (OpenAlex polite pool parameter)
- `{current_year}` → current year

**e.** Execute the query using the primary tool specified in the playbook (tavily_search, Bash curl, etc.)

**f.** Cap results at **8 sources maximum** per channel per query. If an API returns more, take the top 8 by relevance score or citation count. Never include more than 8.

**g.** Print result status: "{Channel Name}: found {N}" or "{Channel Name}: error — {reason}" or "{Channel Name}: degraded — using WebSearch fallback, found {N}" or "{Channel Name}: skipped (not in active channels)"

**h.** If a channel fails (timeout, rate limit, API error, tool unavailable), log the specific failure reason, continue to the next channel. Never abort discovery because one channel failed.

### Step 3: Degradation handling

- **Tavily unavailable (any Tavily channel):** Switch to WebSearch-only mode automatically. Print prominent warning: "WARNING: Tavily unavailable. Switching all Tavily channels to WebSearch fallback. Results labeled '[WebSearch fallback]'." Label all affected results inline.
- **The attempt IS the check** — no pre-flight availability detection. Try the tool, handle failure inline.
- **HTTP API failure (OpenAlex, EDGAR, ProPublica):** Log as channel error, attempt Tavily fallback, then WebSearch fallback per the playbook's degradation chain.
- **Absolute floor:** If even WebSearch fails for all channels, produce the candidates file with empty channel sections and an all-channels-failed status report. Never leave the user without a file.

### Step 4: Deduplicate

Before writing, check if `research/discovery/{phase}-candidates.md` already exists. If it does:
- Parse all existing URLs from the file
- Remove any new results whose URL already appears in the existing file
- Track count of skipped duplicates
- Print: "Deduplication: {N} duplicates skipped (already in candidates file)"

### Step 5: Determine source status for each candidate

Apply the canonical status taxonomy (DISCOVERED / ACCESSIBLE / PROCESSED) to each result:

- **ACCESSIBLE**: Tavily returned full content snippets, OR source is known open-access (e.g., OpenAlex `is_oa=true`, Wikipedia, government data portals, arxiv.org, SEC EDGAR filings)
- **DISCOVERED**: URL returned but content not verified — applies to URL-only results, paywalled domains (wsj.com, ft.com, bloomberg.com, economist.com, hbr.org), Google Patents constructed URLs, and any result where only a title/snippet was returned without confirmed content extraction
- **PROCESSED**: Reserved — do not assign PROCESSED status during discovery. This status is set by process-source when the source is fully extracted and integrated into research notes.

When uncertain, default to DISCOVERED. Better to underestimate than to claim accessibility incorrectly.

### Step 6: Write candidates file

Write to `research/discovery/{phase}-candidates.md`. Create the `research/discovery/` directory if it does not exist.

**New file format:**

```
# Discovery Candidates: {Phase Name}

**Research type:** {type}
**Phase:** {phase name}
**Discovered:** {ISO timestamp}
**Channels run:** {comma-separated list}

## Summary

| Channel | Status | Sources |
|---------|--------|---------|
| Web Search | found 6 | 6 |
| Financial | found 3 | 3 |
| Social Signals | skipped (not in active channels) | 0 |
| Academic | found 5 | 5 |
| Regulatory | error (timeout) | 0 |
| Domain-Specific | found 2 | 2 |

**Total candidates:** {N}
**Duplicates skipped:** {N}

---

## Web Search

- [ACCESSIBLE] Title of source — https://example.com/article
  Brief 1-2 sentence snippet describing what this source contains and why it is relevant.

- [DISCOVERED] Title of paywalled source — https://wsj.com/article
  Brief snippet. Note: paywalled — content not verified accessible.

## Financial

...

## Academic

...

## Regulatory

...

## Social Signals

...

## Domain-Specific

...
```

**Appending to existing file format (re-run):**

```
---
## Re-discovery: {ISO timestamp}

**New candidates added:** {N}
**Duplicates skipped:** {N}
**Channels run:** {list}

## Web Search (re-run)

...
```

### Step 7: Print completion summary

```
Discovery complete.
  {N} candidates found across {M} channels.
  {P} duplicates skipped.
  Results saved to: research/discovery/{phase}-candidates.md

Channel results:
  Web Search    found {N}
  Academic      found {N}
  Regulatory    skipped (not configured)
  ...

Next steps:
  Review candidates in research/discovery/{phase}-candidates.md
  Process selected sources with /research:process-source <url>
```

---

## Channel Execution: Tavily-Based Channels

### Web Search (channel-type: web-search)

Primary tool: `tavily_search`

Execution parameters (from web-search.md playbook):
- `topic: "general"` for background/overview phases
- `topic: "news"` with `days: 90` for recent-developments phases
- `include_domains`: leave empty for general web search (returns broadest results)
- `exclude_domains`: exclude low-credibility aggregators if specified in playbook

Fallback: `WebSearch` with the same query text. Label results: `[WebSearch fallback]`

### Financial (channel-type: financial)

Primary tool: `tavily_search`

Execution parameters (from financial.md playbook):
- `topic: "finance"` for market, earnings, and investment queries
- `include_domains: ["sec.gov", "finance.yahoo.com", "bloomberg.com", "reuters.com", "wsj.com", "ft.com", "marketwatch.com"]`
- Note: wildcard domains (e.g., `investor.*.com`) are unconfirmed in Tavily — if the playbook lists wildcards, replace with explicit domains from the target company's investor relations URL.

Fallback: `WebSearch` with `site:sec.gov OR site:finance.yahoo.com` operators. Label results: `[WebSearch fallback]`

### Social Signals (channel-type: social-signals)

Primary tool: `tavily_search`

Execution parameters (from social-signals.md playbook):
- `topic: "general"` or `topic: "news"` depending on query type
- `include_domains: ["reddit.com", "news.ycombinator.com", "stackoverflow.com", "twitter.com", "linkedin.com", "medium.com"]`
- Note: wildcard community domains (e.g., `community.*.com`) are unconfirmed in Tavily — omit wildcards and use only the explicit domains listed above.

Fallback: `WebSearch` with `site:reddit.com OR site:news.ycombinator.com` operators. Label results: `[WebSearch fallback]`

### Domain-Specific (channel-type: domain-specific)

Read the type-channel map's "Domain-Specific Sources" section to identify which type hooks apply to the current research type. Execute ONLY the hooks specified for that research type — do not run all hooks for every research type.

**Patent Search hook** (company-for-profit, technology research types):
- Construct Google Patents URL: `https://patents.google.com/?q={research_subject}&assignee={company_name}`
- Attempt `tavily_extract` on the constructed URL to get patent listings
- If `tavily_extract` is unavailable or returns no results: log the URL as DISCOVERED with note "extraction unavailable — manual review required"
- Status: DISCOVERED (patent content requires individual extraction)

**Industry Databases hook** (for-profit, market-industry types):
- Use `tavily_search` with domain scoping to Crunchbase, PitchBook, CB Insights per the hook template in the type-channel map
- `include_domains: ["crunchbase.com", "pitchbook.com", "cbinsights.com"]`
- Status: DISCOVERED for paywalled databases, ACCESSIBLE for free-tier results

**Educational Resources hook** (curriculum-research type only):
- Use `tavily_search` per the educational resources hook template
- Target curriculum aggregators, open courseware, learning platforms
- Status: ACCESSIBLE for open platforms, DISCOVERED for gated content

**Specialized Registries hook** (person-research type only):
- Use `tavily_search` per the specialized registries hook template
- Target LinkedIn, professional association directories, academic profiles
- Status: DISCOVERED (profile content requires individual extraction)

Fallback for all domain-specific hooks: `WebSearch` with `site:` operators for the target domains.

---

## Channel Execution: HTTP API Channels

For academic and regulatory channels, read the full playbooks at:
- `.claude/reference/discovery/channel-playbooks/academic.md`
- `.claude/reference/discovery/channel-playbooks/regulatory.md`

These playbooks contain curl templates, response parsing instructions, rate limits, and complete degradation chains. Read them at execution time, not from memory.

### Academic (channel-type: academic)

Primary: `Bash` curl to OpenAlex API

Key parameters:
- Include `mailto=research-agent@example.com` in all OpenAlex requests (activates 10 req/s polite pool)
- Extract per result: title, DOI, authors, citation count, open-access status (`is_oa`), OA URL (`open_access.oa_url`)
- Status determination: `is_oa=true` → ACCESSIBLE, `is_oa=false` → DISCOVERED

Rate limit: 10 req/s with mailto, 1 req/s without.

Fallback chain (per academic.md):
1. Semantic Scholar API (Bash curl) — if OpenAlex fails
2. `tavily_search` with academic domain scoping (scholar.google.com, pubmed.ncbi.nlm.nih.gov, semanticscholar.org, jstor.org, arxiv.org)
3. `WebSearch` with site: operators

Label degraded results: `[via Semantic Scholar fallback]`, `[via Tavily fallback]`, `[via WebSearch fallback]`

### Regulatory (channel-type: regulatory)

Primary: `Bash` curl to EDGAR EFTS and ProPublica APIs

**EDGAR EFTS (SEC filings):**
- Always include `User-Agent: Research Agent research-agent@example.com` header — required by SEC policy
- Rate limit: max 5 req/s; never exceed
- Extract per result: filing date, form type (10-K, 10-Q, 8-K, DEF 14A, etc.), entity name
- Construct filing URL from accession number: `https://www.sec.gov/Archives/edgar/data/{cik}/{accession-number-formatted}/`
- Status: ACCESSIBLE — all SEC filings are public record and legally accessible

**ProPublica Nonprofit Explorer (990 data):**
- Extract per result: EIN, organization name, total revenue, filing year
- Construct 990 profile URL: `https://projects.propublica.org/nonprofits/organizations/{ein}`
- PDF link for individual 990: `https://projects.propublica.org/nonprofits/organizations/{ein}/{filing_id}/full`
- Status: ACCESSIBLE — IRS 990 data is public record

Fallback chain (per regulatory.md):
1. `tavily_search` with `include_domains: ["sec.gov", "projects.propublica.org"]`
2. `WebSearch` with `site:sec.gov OR site:projects.propublica.org`

---

## Guardrails

1. **Discovery output goes to `research/discovery/` ONLY.** Never write to `research/notes/`, `research/sources/registry.md`, or any other research file. The boundary between discovery and processing belongs to process-source — do not cross it.
2. **Never auto-feed discovered sources into process-source.** The candidate list is for human review. Suggest process-source in the completion message but never invoke it.
3. **Cap results at 8 sources per channel per query.** If an API returns more results, take the top 8 by relevance score or citation count. Exceeding 8 per channel defeats the purpose of the candidate review step.
4. **Always include `User-Agent: Research Agent research-agent@example.com` for SEC EDGAR requests.** This is required by SEC policy. The header is embedded in the curl template in regulatory.md — copy it exactly.
5. **Include `mailto=research-agent@example.com` for all OpenAlex API requests.** This activates the 10 req/s polite pool. Without it, rate limit is 1 req/s.
6. **Do not run all domain-specific hooks.** Only execute the hooks specified in the current research type's channel map. Running patent search for a non-profit research project wastes time and produces irrelevant results.
7. **When a channel fails, continue with remaining channels.** Never abort discovery due to a single channel failure. Log the failure, report it in the summary table, move on.
8. **Label all degraded and fallback results inline.** Every result from a fallback method must be tagged with the actual method used: `[via WebSearch fallback]`, `[via Tavily fallback]`, etc.

---

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Running discovery with no active phase | Pre-check step 1 reads `research/STATE.md`. If no active phase, error with guidance before any channel execution. |
| Querying channels not relevant to the research type | Pre-check step 4 reads the type-channel map first. Only execute channels in the matched Discovery Group — never execute all 6 channels by default. |
| Overwriting prior discovery work on re-run | Pre-check step 7 checks for existing candidates file. If it exists, append with timestamp separator and deduplicate by URL. Never overwrite. |
| Feeding discovered sources directly into processing pipeline | Guardrail 1 and 2: output to `research/discovery/` only. Suggest process-source in completion message but never invoke it. |
| Silent channel failure with no status reporting | Print per-channel status lines during execution. Include all channels in summary table with explicit status — even channels that were skipped or errored. |
| Exceeding API rate limits | Follow rate limits from playbooks: EDGAR max 5 req/s, OpenAlex 10 req/s with mailto (1 req/s without), Tavily usage is monthly-quota-based. Space Bash curl calls with brief pauses if running multiple EDGAR queries. |
| Missing User-Agent for SEC EDGAR | Guardrail 4: always include the User-Agent header. The curl template in regulatory.md embeds it. Copy the template exactly. |
| Assigning PROCESSED status during discovery | Pre-check: PROCESSED is reserved for process-source. Assign only DISCOVERED or ACCESSIBLE during discovery. |
| Running domain-specific hooks for wrong research type | Guardrail 6: read the type-channel map's hook list. Only run hooks that appear in the current research type's channel map. |
| wildcard include_domains failing in Tavily | If a playbook lists wildcard domains (e.g., `investor.*.com`), replace with explicit domain list. Wildcards are unconfirmed in Tavily — use specific URLs instead. |

---

## Output

Print the completion summary (Step 7 format) with:
- Total candidates found
- Per-channel status (found N / skipped / error / degraded)
- Path to candidates file
- Next-step guidance: "Review candidates in `research/discovery/{phase}-candidates.md`. Process selected sources with `/research:process-source <url>`."

The candidates file at `research/discovery/{phase}-candidates.md` is the primary artifact of this skill.
