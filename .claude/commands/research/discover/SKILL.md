---
name: discover
description: "Execute type-aware, multi-channel source discovery for the current research phase"
allowed-tools: [tavily_search, Bash, WebSearch, tavily_extract, Read, Grep, Glob]
---

# /research:discover

Execute source discovery for the current research phase using all channels configured for the project's research type. Produces a reviewable candidate list — never auto-feeds into process-source.

Supports optional `--channel {name}` argument for targeted re-runs against a single channel (e.g., `--channel academic`).

## Pre-check (mandatory before execution)

1. **Read `research/STATE.md`** — extract the current active phase name.
   - If `research/STATE.md` does not exist at all: error: "No STATE.md found — this project hasn't been initialized. Run `/research:init` first." Do not proceed. (Note: `/research:start-phase` won't help here either — it also requires STATE.md.)
   - If `research/STATE.md` exists but the "Active phase" field is missing or empty: error: "STATE.md exists but has no active phase set. Check STATE.md — the active phase may need to be set manually." Do not proceed.

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

6. **If `--channel {name}` was provided**, filter the channel list to only that channel. Confirm it exists in the matched Discovery Group's channel list. If not found, error: "Channel '{name}' is not mapped for this phase. Available channels: {list}."

7. **Check for existing candidates file** at `research/discovery/{phase}-candidates.md`. If it exists, new results will be appended with a timestamp separator and deduplicated by URL against existing entries. Note this to the user before proceeding.

## Process

### Step 1: Resolve channels

From the matched Discovery Group, collect Primary channels and Secondary channels. Primary channels execute first. If `--channel` filter was applied, use only that channel.

Print the following orientation block before executing any queries:

```
Running discovery for phase: {phase name}
Research type: {type}
Channels: {list}

What we're looking for:
  {Briefly restate the 2-3 core research questions for this phase from research-plan.md}

I'll search across {N} channels and present what I find. You'll get to review
candidates and decide which ones to process — nothing gets processed automatically.
```

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

**g.** Print result status: "{Channel Name}: found {N}" or "{Channel Name}: error — {reason}" or "{Channel Name}: degraded — using WebSearch fallback, found {N}" or "{Channel Name}: skipped (not mapped for this phase)"

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
| Social Signals | skipped (not mapped for this phase) | 0 |
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

### Step 7: Print completion summary and offer to process

```
Discovery complete.
  {N} candidates found across {M} channels.
  {P} duplicates skipped.
  Results saved to: research/discovery/{phase}-candidates.md

Channel results:
  Web Search    found {N}
  Academic      found {N}
  Regulatory    skipped (not mapped for this phase)
  ...
```

After printing the summary, present the top candidates in priority order (highest-credibility and most relevant first) and offer to begin processing:

```
Top candidates for this phase:

1. {Title} — {source} — {why it's high priority}
2. {Title} — {source} — {why it's high priority}
3. {Title} — {source} — {why it's high priority}
...

Want me to start processing these? I'll work through them in priority order.
You can skip any that don't look relevant. After 5-8 sources I'll pause
for cross-referencing.
```

If the user says yes (or any affirmative), begin processing sources sequentially using `/research:process-source` for each URL. Track the count — after processing 5-8 sources, pause and present the cross-reference checkpoint:

```
Pausing after {N} sources to cross-reference before continuing.

What we've processed so far:
  {1-line summary per processed source — title and what it contributed}

Why pause now: Cross-referencing at this point lets us spot patterns, contradictions,
and gaps while the data is fresh — so remaining sources can fill holes instead of
piling on what we already know.

Want me to run cross-referencing now? ({M} candidates remaining after this.)
```

If the user approves, run `/research:cross-ref`, then resume processing the remaining candidates with the same pause cadence.

If the user wants to skip a source during processing, skip it and move to the next.

If the user wants to review the full candidates file first or pick specific sources, respect that — show them the file path and let them direct which sources to process.

### Decision points: always recommend, don't just list options

When presenting a choice to the user (process another source, move to gap assessment, run cross-ref, etc.), **state your recommendation and reasoning first**, then ask for confirmation. You have the context — use it.

Bad (options without opinion):
```
Want me to process the last source, or move to gap assessment?
```

Good (recommendation with reasoning):
```
I'd recommend skipping the last candidate (topstartups.io broader data) — we already
have strong startup-specific salary data from the earlier topstartups.io source, and
the 7 sources processed give solid coverage across all three research questions.

My recommendation: move to gap assessment (/research:check-gaps) to confirm coverage
before writing. If gaps surface, we can circle back to remaining candidates.

Sound good?
```

Apply this pattern at every pause point — cross-ref checkpoints, end-of-candidates, and any mid-processing decision. The user can always override, but the agent should have an opinion.

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
1. `tavily_search` with academic domain scoping (scholar.google.com, arxiv.org, pubmed.ncbi.nlm.nih.gov) — label: `[via Tavily fallback]`
2. `WebSearch` with academic domain keywords — label: `[via WebSearch fallback]`

### Regulatory (channel-type: regulatory)

Primary: `Bash` curl to EDGAR EFTS and ProPublica APIs

**EDGAR EFTS (SEC filings):**
- Always include `User-Agent: ResearchAgent (contact@example.com)` header — required by SEC policy
- Rate limit: max 5 req/s; never exceed
- Extract per result: filing date, form type (10-K, 10-Q, 8-K, DEF 14A, etc.), entity name
- Construct filing URL from accession number: `https://www.sec.gov/Archives/edgar/data/{cik}/{accession-number-formatted}/`
- Status: ACCESSIBLE — all SEC filings are public record and legally accessible

**ProPublica Nonprofit Explorer (990 data):**
- Extract per result: EIN, organization name, total revenue, filing year
- Construct 990 profile URL: `https://projects.propublica.org/nonprofits/organizations/{ein_no_dashes}` — remove dashes from EIN (e.g., `13-1837418` → `131837418`)
- PDF link for individual 990: `https://projects.propublica.org/nonprofits/organizations/{ein_no_dashes}/{filing_id}/full`
- Status: ACCESSIBLE — IRS 990 data is public record

Fallback chain (per regulatory.md):
1. `tavily_search` with `include_domains: ["sec.gov", "projects.propublica.org"]`
2. `WebSearch` with `site:sec.gov OR site:projects.propublica.org`

---

## Guardrails

1. **Discovery output goes to `research/discovery/` ONLY.** Never write to `research/notes/`, `research/sources/registry.md`, or any other research file. The boundary between discovery and processing belongs to process-source — do not cross it.
2. **Never auto-process without user approval.** After discovery, present the prioritized candidate list and ask the user before processing. Once the user approves, process sources sequentially — but the human gate between discovery and processing must be an explicit approval, not a silent transition.
3. **Cap results at 8 sources per channel per query.** If an API returns more results, take the top 8 by relevance score or citation count. Exceeding 8 per channel defeats the purpose of the candidate review step.
4. **Always include `User-Agent: ResearchAgent (contact@example.com)` for SEC EDGAR requests.** This is required by SEC policy — the header value is defined in regulatory.md.
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
| Processing sources without user approval | Guardrail 2: present prioritized candidates and ask the user before processing. Once approved, process sequentially — but the transition from discovery to processing requires explicit user approval. |
| Silent channel failure with no status reporting | Print per-channel status lines during execution. Include all channels in summary table with explicit status — even channels that were skipped or errored. |
| Exceeding API rate limits | Follow rate limits from playbooks: EDGAR max 5 req/s, OpenAlex 10 req/s with mailto (1 req/s without), Tavily usage is monthly-quota-based. Space Bash curl calls with brief pauses if running multiple EDGAR queries. |
| Missing User-Agent for SEC EDGAR | Guardrail 4: always include `User-Agent: ResearchAgent (contact@example.com)`. The value is defined in regulatory.md. |
| Assigning PROCESSED status during discovery | Pre-check: PROCESSED is reserved for process-source. Assign only DISCOVERED or ACCESSIBLE during discovery. |
| Running domain-specific hooks for wrong research type | Guardrail 6: read the type-channel map's hook list. Only run hooks that appear in the current research type's channel map. |
| wildcard include_domains failing in Tavily | If a playbook lists wildcard domains (e.g., `investor.*.com`), replace with explicit domain list. Wildcards are unconfirmed in Tavily — use specific URLs instead. |

---

## Output

Print the completion summary (Step 7 format) with:
- Total candidates found
- Per-channel status (found N / skipped / error / degraded)
- Path to candidates file
- Prioritized candidate list with offer to begin processing

After discovery, the agent should guide the user through source processing — not hand back control and wait for manual URL entry. The user's job is to review and approve; the agent's job is to drive the workflow forward.

The candidates file at `research/discovery/{phase}-candidates.md` is the primary artifact of this skill.
