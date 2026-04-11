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
   - If `Active phase` is set to a completion sentinel like `— all phases complete` (or any value indicating no active phase remains): error: "All phases are complete per STATE.md. There is nothing to discover. Run `/research:progress` to review the project or `/research:check-gaps` for a final coverage pass." Do not proceed.

1a. **Stale-active-phase check (self-healing for missed closeouts).** Read the `Current Phase Cycle` block in STATE.md for the active phase. Count checked vs. unchecked steps:
   - If the active phase has **Verify checked `[x]`** (or all five steps checked), STATE.md is inconsistent: the phase has been completed but Active phase was never advanced. `/research:audit-claims` owns the closeout; this is its job, not discover's. Stop with an error: `"STATE.md inconsistency: Phase {N} ({name}) shows Verify checked in Current Phase Cycle, but Active phase still points at Phase {N}. This means the previous /research:audit-claims run promoted the draft but did not advance STATE.md. Do NOT run discovery against a completed phase. Options: (a) run /research:progress to see the full state, (b) manually advance STATE.md to the next phase using the format from /research:init (advance Active phase, replace Current Phase Cycle with a fresh next-phase checklist, mark Phase {N} complete in Completed Phases, reset Next Action), or (c) if you intended to re-run discovery for Phase {N}, first revert the completed marker in Completed Phases and uncheck Verify. Refuse to guess the right branch — the user must confirm which one applies."` Do not proceed until the user resolves the inconsistency.
   - If Verify is unchecked but earlier cycle steps (Collect/Connect/Assess/Synthesize) are mid-progress, this is a normal mid-phase discover re-run (e.g., gap-driven top-up) — proceed. Discovery in the middle of a phase is legitimate.

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

**Before printing the summary, verify the write succeeded.** Re-read `research/discovery/{phase}-candidates.md` and confirm it exists and contains the Summary table plus at least one channel section. If the read fails or the file is empty or missing the Summary table, do not print "Discovery complete" or "Results saved" — surface the write failure to the user with the target path, preserve the in-memory candidate list so the user can direct a retry, and stop. A silent write failure here would let the user move on to processing sources that were never actually recorded.

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

If the user says yes (or any affirmative), begin processing sources sequentially using `/research:process-source` for each URL — **in the main conversation, as the main agent**. Track the count — after processing 5-8 sources, pause and present the cross-reference checkpoint:

**Do not delegate source processing to a subagent.** Do not spawn the Agent tool to "run the batch in parallel," "work through the queue," or "process sources while I handle something else." Each `process-source` call reads, extracts, writes a note, updates `research/sources/registry.md`, increments the cross-reference counter in `research/STATE.md`, and may surface a contradiction or access failure the user needs to see. All of that has to land in the main agent's context — not a subagent's window that returns a summary 15 minutes later — so that:

- the cross-reference checkpoint actually interrupts the work visibly at source 5 instead of sitting as a silent task-list item a subagent walks past;
- the user can react to contradictions, access failures, and surprises as they happen instead of reviewing them as a batch report;
- STATE.md, registry.md, and the cross-ref counter update in real time (a subagent either can't see STATE.md updates made between sources or races with the main agent over the same file);
- the commonplace book, assumptions, and prior source notes inform each processing call with fresh main-agent context, not a cold subagent context;
- a `/clear` recovery can read STATE.md and know exactly where processing stopped, to the source, not to the last batch report.

**Do not build a TodoWrite/TaskCreate task list of "Process Source 39, Process Source 40, Process Source 41, run cross-ref, Process Source 42…" to drive the batch.** The candidates file at `research/discovery/{phase}-candidates.md` IS the work queue. `research/STATE.md`'s "Sources since last cross-reference" counter IS the checkpoint trigger. The sources registry at `research/sources/registry.md` IS the completion ledger. A parallel task list duplicates that state in a place that disappears on `/clear` and drifts from the authoritative files. Read the candidates file top-to-bottom, process each source in-line in the main conversation, print one status line per source, stop at the cross-ref checkpoint, and resume — no task list, no subagent, no background queue.

A one-line status per completed source is the right cadence (`✓ Source 39: AccessU 2022 Sponsors page — ACCESSIBLE, 6 findings, 0 contradictions`). The user does not want a progress bar; they want to see the work happening and to be able to interrupt at any point.

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
2. **Never auto-process without user approval — but approval is one gate, not many.** After discovery, present the prioritized candidate list and ask the user before processing. Once the user approves the batch, process sources sequentially through the list without asking for re-confirmation between sources. The human gate sits between discovery and processing, not between every source. See "Legitimate Pause Points" below for the exhaustive list of when you MAY pause; a clean source completion is not on that list.
3. **Cap results at 8 sources per channel per query.** If an API returns more results, take the top 8 by relevance score or citation count. Exceeding 8 per channel defeats the purpose of the candidate review step.
4. **Always include `User-Agent: ResearchAgent (contact@example.com)` for SEC EDGAR requests.** This is required by SEC policy — the header value is defined in regulatory.md.
5. **Include `mailto=research-agent@example.com` for all OpenAlex API requests.** This activates the 10 req/s polite pool. Without it, rate limit is 1 req/s.
6. **Do not run all domain-specific hooks.** Only execute the hooks specified in the current research type's channel map. Running patent search for a non-profit research project wastes time and produces irrelevant results.
7. **When a channel fails, continue with remaining channels.** Never abort discovery due to a single channel failure. Log the failure, report it in the summary table, move on.
8. **Label all degraded and fallback results inline.** Every result from a fallback method must be tagged with the actual method used: `[via WebSearch fallback]`, `[via Tavily fallback]`, etc.

---

## Legitimate Pause Points During Batch Processing

Once the user has approved a batch of candidates for processing, you drive the workflow forward. You may pause ONLY at these points:

1. **Mandatory cross-ref checkpoint.** When "Sources since last cross-reference" in STATE.md reaches 5 (or whatever interval the project has configured, typically 5–8). Stop and run `/research:cross-ref` before processing the next source. This is the only scheduled pause.
2. **Real access failure.** A source cannot be fetched — domain block, paywall, 403, rendering issue, extraction returned stub content. Present the options defined in `process-source` step 1 and wait for the user.
3. **Genuine strategic decision surfaces.** Something the user needs to decide because it changes the approach: a gap analysis result that suggests the phase needs different sources, a contradiction that needs resolution before more processing is useful, a discovery that the candidate list is wrong for the phase. These are rare.
4. **End of the approved candidate list.** You finished the batch. Report what was processed, surface the cross-ref or gap-check status, and ask the user what's next.

A successful source completion — "processed, note written, no issues" — is NOT a pause point. A one-line status line is fine. An "OK to continue?" prompt is not.

If you catch yourself wanting to ask "should I keep going?" after a clean source, the answer is yes. You were already told yes when the batch was approved.

---

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Running discovery with no active phase | Pre-check step 1 reads `research/STATE.md`. If no active phase, error with guidance before any channel execution. |
| Silently re-discovering a phase that was already completed (audit-claims forgot to advance STATE.md) | Pre-check step 1a detects `Verify` already checked on the active phase and refuses to run. `/research:audit-claims` owns phase closeout — if it skipped the STATE.md advance, discovery must not paper over it. Surface the inconsistency and make the user (or a targeted STATE.md edit) resolve it before any queries execute. |
| Backgrounding source processing into a subagent or Agent-tool spawn after the user approves a batch | Source processing runs in the main conversation, full stop. A subagent loses the cross-ref checkpoint (it walks past the 5-source trigger silently because the main agent isn't watching), loses per-source STATE.md updates (they either race with the main agent or happen in bulk at the end), loses the user's ability to react to contradictions and access failures in real time, and loses recoverability on `/clear` (STATE.md lags by a whole batch). When the user approves a candidate batch, the main agent processes sources sequentially itself — one at a time, one status line per source, cross-ref at the threshold, done. Do not spawn the Agent tool for batch processing regardless of how many candidates are queued. |
| Building a TodoWrite/TaskCreate task list to drive source processing | The candidates file is the queue, STATE.md is the counter, registry.md is the ledger. A parallel task list ("Process Source 39", "Process Source 40", "Run cross-ref at 5-source threshold", "Process Source 42", …) duplicates state that already exists in authoritative files, lives in a place that disappears on `/clear`, and turns the cross-ref checkpoint from a hard gate into just another checkbox a subagent will happily cross. Read the candidates file in order and process each source inline — no todo list wrapping the batch. |
| Querying channels not relevant to the research type | Pre-check step 4 reads the type-channel map first. Only execute channels in the matched Discovery Group — never execute all 6 channels by default. |
| Overwriting prior discovery work on re-run | Pre-check step 7 checks for existing candidates file. If it exists, append with timestamp separator and deduplicate by URL. Never overwrite. |
| Processing sources without user approval | Guardrail 2: present prioritized candidates and ask the user before processing. Once approved, process sequentially — but the transition from discovery to processing requires explicit user approval. |
| Accountability avoidance — asking "should I continue?" after every clean source completion | Once the user approved the batch, you were told yes. Re-asking between successful sources is friction without value — it hands the steering wheel back to the user instead of holding the workflow. A clean source completion is a status line, not a decision point. Pause only at the points listed in "Legitimate Pause Points" — cross-ref checkpoint, real access failure, strategic decision, end of batch. Nothing else. |
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
