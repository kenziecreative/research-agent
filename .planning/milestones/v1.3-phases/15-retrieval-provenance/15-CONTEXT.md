# Phase 15: Retrieval Provenance - Context

**Gathered:** 2026-04-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Every discovery call is logged with its exact query string, channel name, and full list of returned URLs to a structured retrieval log. The log is queryable by phase, channel, or query without free-text parsing. Re-running discover with the same inputs produces a log entry structurally comparable to prior entries for drift detection. This phase adds a log file, a write step in the discover skill, and scaffolding in init — it does not add new skills, new channels, or new commands.

</domain>

<decisions>
## Implementation Decisions

### Log Storage & Format
- **D-01:** Retrieval log persists as a single JSON file at `research/reference/retrieval-log.json`, following the canonical-figures.json and claim-graph.json registry pattern
- **D-02:** Schema is `{ "entries": [...] }` — a flat array of entry objects with typed fields. Each entry represents one channel execution within one discovery run.
- **D-03:** Entry schema per channel execution:
  - `timestamp` — ISO 8601 timestamp of the discovery call
  - `phase` — research phase name (string, matches research-plan.md phase names)
  - `channel` — channel name (e.g., "web-search", "academic", "financial")
  - `tool` — specific tool used (e.g., "tavily", "exa", "openalex", "crossref")
  - `query` — exact query string or URL submitted to the tool
  - `template` — which query template was used (A/B/C)
  - `results_count` — integer count of URLs returned
  - `urls` — array of all returned URLs from this call
  - `status` — execution result ("found", "error", "degraded", "skipped")
  - `degraded_to` — tool name if degradation was triggered (null otherwise)
  - `deduped_count` — number of results removed by cross-tool dedup (0 for single-tool channels)

### Log Write Timing
- **D-04:** Log entries are written after the candidates file write (Step 6 in discover). One entry per channel-tool execution in the run, all written in a single append batch.
- **D-05:** If the discover run crashes before Step 6, no log entry is produced — acceptable because no candidates file exists to audit either. The candidates file and retrieval log are peers: both exist or neither exists.

### Queryability Contract
- **D-06:** Agents query the log by reading `retrieval-log.json` via the Read tool and filtering the `entries` array by field equality — identical to how claim-graph.json nodes are queried. No programmatic query layer or separate index needed.
- **D-07:** PROV-02 is satisfied by the typed fields: filter by `phase` for phase-scoped queries, by `channel` for channel-scoped queries, by `query` for exact-query matches.

### Drift Comparison Approach
- **D-08:** Structural queryability only — no run IDs, no automated diff, no back-pointers between entries. Two entries for the same phase/channel/query are comparable by inspecting the `urls` arrays side-by-side.
- **D-09:** SC#3 ("can be compared to the prior entry") is satisfied by the entry structure: same phase + channel + query fields locate the two entries; URL arrays can be compared for additions/removals. This follows the advisory-not-gate pattern — drift is visible to the human investigator, not auto-flagged.
- **D-10:** The existing re-discovery timestamp separator in candidates files provides the run boundary; the retrieval log's `timestamp` field provides the same boundary for log entries.

### Init Scaffolding
- **D-11:** `init` SKILL.md must scaffold an empty `retrieval-log.json` file (`{ "entries": [] }`) alongside canonical-figures.json and claim-graph.json during project initialization.

### Claude's Discretion
- Whether to log failed channel attempts (status: "error") or only successful ones — recommendation: log all attempts including failures for full audit trail
- Whether to include the `useAutoprompt` / `autopromptString` from Exa responses in the log entry
- Exact ordering of entries within a single discovery run batch (channel priority order vs. completion order)
- Whether to add a `run_batch` or `run_timestamp` field that groups all entries from a single discover invocation (nice-to-have, not required by PROV-01/02)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Discovery Infrastructure
- `.claude/commands/research/discover/SKILL.md` — The skill being extended; contains Step 2 (channel execution), Step 4 (dedup), Step 6 (candidates file write). Log write step inserts after Step 6.
- `.claude/reference/discovery/channel-playbooks/web-search.md` — Web search playbook with Tavily + Exa execution params, dedup rules, and combined status line format
- `.claude/reference/discovery/channel-playbooks/academic.md` — Academic playbook with OpenAlex + Crossref + Unpaywall execution params and Section 8 dedup rules

### Init Infrastructure
- `.claude/commands/research/init/SKILL.md` — Init scaffolding that creates canonical-figures.json and claim-graph.json; must be extended to also create empty retrieval-log.json

### Data Models (pattern references)
- `research/reference/canonical-figures.json` (per-project) — Existing JSON registry pattern that retrieval-log.json mirrors in style and access conventions
- `research/reference/claim-graph.json` (per-project) — Existing JSON registry showing flat array with typed fields

### Requirements
- `.planning/REQUIREMENTS.md` PROV-01 — Log query/channel/URLs per discovery call
- `.planning/REQUIREMENTS.md` PROV-02 — Structured queryable log (filter by phase/channel/query)

### Prior Phase Context
- `.planning/phases/14-web-channel-diversity/14-CONTEXT.md` — Phase 14 decisions on multi-tool execution within web-search channel (Tavily + Exa), dedup, and source attribution tags

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `canonical-figures.json` / `claim-graph.json` schema conventions — direct pattern to follow for retrieval-log.json (flat array at top-level key, typed fields, Read-to-query)
- Discover SKILL.md Step 2 channel execution loop — already tracks channel name, query text, tool used, result count, and status per channel; these become log entry fields
- Discover SKILL.md Step 6 candidates file write — the insertion point for log write (append to retrieval-log.json immediately after)
- Init SKILL.md scaffolding section — already creates two JSON registry files; retrieval-log.json is the third

### Established Patterns
- JSON registries at `research/reference/` — all structured data lives here; retrieval log follows the same convention
- Read-to-query: agents filter JSON arrays by reading the file and iterating — no query layer, no CLI tool
- Advisory-not-gate: drift/staleness/confidence are surfaced, not enforced — retrieval drift comparison is manual, not automated
- Candidates file as primary artifact: the retrieval log complements (not replaces) the candidates file with structured metadata

### Integration Points
- `discover/SKILL.md` Step 6 — Primary integration point; add log write step after candidates file write
- `init/SKILL.md` — Must scaffold empty `retrieval-log.json` during project initialization
- Channel execution loop (Step 2) — Must accumulate log entry data (query, tool, URLs, status) for batch write at Step 6

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 15-retrieval-provenance*
*Context gathered: 2026-04-20*
