# Phase 15: Retrieval Provenance - Pattern Map

**Mapped:** 2026-04-20
**Files analyzed:** 3 modified files (1 new JSON file, 2 skill modifications)
**Analogs found:** 3 / 3

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `research/reference/retrieval-log.json` | data registry (JSON) | file I/O | `.claude/reference/templates/canonical-figures.json` + `research/reference/claim-graph.json` | exact — same flat-array JSON registry pattern, same `research/reference/` location, same Read-to-query access convention |
| `.claude/commands/research/discover/SKILL.md` | orchestrator skill | request-response with file I/O side-effect | `discover/SKILL.md` itself (modification) — Step 6 (candidates file write) and the channel execution loop in Step 2 | exact — log write step inserts immediately after Step 6's existing write-then-verify pattern |
| `.claude/commands/research/init/SKILL.md` | scaffolding skill | file I/O | `init/SKILL.md` itself (modification) — the "Other Files" block in Step 5 that writes `claim-graph.json` and `canonical-figures.json` | exact — one additional write statement in the same block, same format, same write-then-verify pattern in Step 6 |

---

## Pattern Assignments

### `research/reference/retrieval-log.json` (new JSON data registry)

**Analog:** `.claude/reference/templates/canonical-figures.json` (structure) and `research/reference/claim-graph.json` initial content `{"claims": []}` (write pattern)

**Schema pattern — canonical-figures.json** (full file):
```json
{
  "figures": []
}
```

**Schema pattern — claim-graph.json initial content** (init/SKILL.md line 686):
```
Write `research/reference/claim-graph.json` with initial content `{"claims": []}` — this is the claim graph registry, populated by `/research:audit-claims` during each phase's Verify step.
```

**Apply to retrieval-log.json:** Initial content follows the same `{"top_level_key": []}` pattern:
```json
{
  "entries": []
}
```

**Entry schema per D-03** — each entry represents one channel-tool execution within one discovery run:
```json
{
  "timestamp": "2026-04-20T14:23:00Z",
  "phase": "Phase 3: Financial Analysis",
  "channel": "web-search",
  "tool": "tavily",
  "query": "Acme Corp revenue 2024 site:sec.gov",
  "template": "B",
  "results_count": 6,
  "urls": [
    "https://example.com/article1",
    "https://example.com/article2"
  ],
  "status": "found",
  "degraded_to": null,
  "deduped_count": 2
}
```

**Read-to-query access pattern** (per D-06, mirroring claim-graph.json convention documented throughout SKILL.md files): Agents query by reading the file via the Read tool and filtering the `entries` array by field equality — e.g., filter where `phase == "Phase 3: Financial Analysis"` for phase-scoped queries, where `channel == "academic"` for channel-scoped queries, where `query == "<exact string>"` for query-match lookups.

**Write location:** `research/reference/retrieval-log.json` — same directory as `canonical-figures.json` and `claim-graph.json`.

---

### `.claude/commands/research/discover/SKILL.md` (skill modification)

**Analog:** `discover/SKILL.md` existing Step 6 (write candidates file) and Step 2 (channel execution loop). This phase adds a log write step after Step 6 and adds log-entry accumulation logic to Step 2.

---

#### Modification 1: Accumulate log entry data in Step 2 (channel execution loop)

**Existing Step 2 pattern** (discover/SKILL.md lines 78–108 — the per-channel execution loop):

```markdown
### Step 2: Execute each channel in priority order

For each channel:

**a.** Print status line: "{Channel Name}: querying..."
**b.** Read the channel playbook at `.claude/reference/discovery/channel-playbooks/{channel-name}.md`
**c.** Select the appropriate query template from the playbook:
...
**d.** Substitute template placeholders:
...
**e.** Execute the query using the primary tool specified in the playbook...
**f.** Cap results at **8 sources maximum** per channel per query.
**g.** Print result status: "{Channel Name}: found {N}" or "{Channel Name}: error — {reason}" or "{Channel Name}: degraded — using {fallback tool} fallback, found {N}"
**h.** If a channel fails..., log the specific failure reason, continue to the next channel.
```

**Pattern to add:** After step **g** (print result status) in the per-channel loop, accumulate one log entry object per channel-tool execution. Accumulate into an in-memory list — do not write to disk during the loop. The batch write happens after Step 6.

**Data already available from Step 2** that maps directly to log entry fields:
- `timestamp` — ISO 8601 timestamp at the moment of this channel execution (record when Step 2g prints)
- `phase` — from STATE.md pre-check (Step 1)
- `channel` — the channel name from the Discovery Group
- `tool` — the tool that executed (Tier 1 = "tavily", Tier 2 = "firecrawl", Tier 3 = "websearch"; for web-search channel: "tavily" or "exa" per tool)
- `query` — the exact query string or URL submitted (from Step 2d substitution)
- `template` — which template letter was used (A/B/C from Step 2c selection)
- `results_count` — count of results before dedup (from Step 2f)
- `urls` — array of all returned URLs from this call (available before Step 4 dedup)
- `status` — map from Step 2g output: "found" / "error" / "degraded" / "skipped"
- `degraded_to` — if degraded: the fallback tool name; otherwise null
- `deduped_count` — populated after Step 4 (dedup against existing candidates file); 0 for initial runs, N for re-runs where cross-tool dedup occurred

**Multi-tool channels (web-search):** The web-search channel executes Tavily and Exa as independent parallel tools within one channel (per web-search.md Section 8). Log one entry per tool execution — so a web-search channel with both tools succeeding produces two log entries: one with `tool: "tavily"`, one with `tool: "exa"`. The `deduped_count` on the Exa entry reflects URL matches collapsed against Tavily results (per web-search.md Section 8 dedup rules).

**Step 2g status line** (existing, lines 103–108):
```markdown
**g.** Print result status: "{Channel Name}: found {N}" or "{Channel Name}: error — {reason}" or
"{Channel Name}: degraded — using {fallback tool} fallback, found {N}" or
"{Channel Name}: skipped (not mapped for this phase)"
```

The log entry `status` field maps from Step 2g's text output: "found" when Step 2g prints "found N", "error" when it prints "error —", "degraded" when it prints "degraded —", "skipped" when it prints "skipped".

---

#### Modification 2: Write log batch after Step 6 (candidates file write + verify)

**Existing Step 6 write-then-verify pattern** (discover/SKILL.md lines 139–214):

```markdown
### Step 6: Write candidates file

Write to `research/discovery/{phase}-candidates.md`. Create the `research/discovery/` directory if it does not exist.
...
```

**Existing Step 7 verify pattern** (discover/SKILL.md lines 212–214):
```markdown
**Before printing the summary, verify the write succeeded.** Re-read
`research/discovery/{phase}-candidates.md` and confirm it exists and contains the Summary table
plus at least one channel section. If the read fails or the file is empty or missing the Summary
table, do not print "Discovery complete" — surface the write failure to the user with the target
path...
```

**Pattern to add — new Step 6a** (insert between existing Step 6 and Step 7):

```markdown
### Step 6a: Append retrieval log entries

After the candidates file write and verification succeed, write the accumulated log entries to
`research/reference/retrieval-log.json`.

**Read-modify-write pattern** (mirrors claim-graph.json write in audit-claims step 8b):

1. **Read** `research/reference/retrieval-log.json`.
   - If the file does not exist: initialize with `{"entries": []}` and proceed.
   - If it exists but fails to parse as JSON: log a warning and skip the log write without failing
     the discovery run. Print: "WARNING: retrieval-log.json could not be parsed — log entries not
     written. Discovery output is unaffected." Do not block the user from proceeding.
   - If it parses correctly: load the existing `entries` array.
2. **Append** all log entry objects accumulated during Step 2 to the `entries` array.
   - Write the entire updated JSON back to `research/reference/retrieval-log.json`.
   - One entry per channel-tool execution. Entry order: channel priority order (Primary channels
     before Secondary channels), matching the execution order from Step 2.
3. **Verify** the write succeeded: re-read the file and confirm it parses as valid JSON and the
   entry count has increased by the expected number. If verification fails: log "WARNING:
   retrieval-log.json write failed — log entries not persisted. Discovery output is unaffected."
   Do not fail or retry discovery.

**Failure contract** (per D-05): If the discover run crashes before Step 6 (the candidates file
write), no log entries are written. If Step 6 fails (candidates file not written), do not attempt
Step 6a. The candidates file and retrieval log are peers — both exist or neither exists for a given
run.
```

**Error handling pattern to follow** (from audit-claims/SKILL.md step 8b — the claim-graph.json write pattern, referenced in Phase 12 PATTERNS.md):
```markdown
If the file does not exist, [note absence and skip].
If it exists but fails to parse as JSON, log a warning [...] and skip — do not fail the audit.
After writing, verify the write succeeded. Re-read the file and confirm it parses as valid JSON.
If the read fails [...], log: "WARNING: claim-graph.json write failed..."
Do not fail the audit or block promotion.
```

Apply identically: retrieval-log.json parse failure or write failure is non-blocking. Discovery output (the candidates file) is the primary artifact — the log is supplementary infrastructure.

---

### `.claude/commands/research/init/SKILL.md` (skill modification)

**Analog:** `init/SKILL.md` Step 5 "Other Files" block — specifically the `claim-graph.json` write statement (line 686) and the Step 6 verify checklist (lines 718–734).

**Existing claim-graph.json write pattern** (init/SKILL.md line 686 — the exact statement to mirror):
```markdown
- Write `research/reference/claim-graph.json` with initial content `{"claims": []}` — this is the
  claim graph registry, populated by `/research:audit-claims` during each phase's Verify step.
```

**Pattern to add** — append one bullet immediately after the claim-graph.json write statement, following the exact same sentence structure:
```markdown
- Write `research/reference/retrieval-log.json` with initial content `{"entries": []}` — this is
  the retrieval log registry, populated by `/research:discover` after each discovery run.
```

**Existing Step 6 verify checklist pattern** (init/SKILL.md lines 718–734 — the ls-then-check list):
```markdown
1. **Run `ls research/`** — confirm all expected files and directories exist:
   - `research-plan.md`
   - `STATE.md`
   ...
   - `reference/canonical-figures.json`
   - `reference/claim-graph.json`
   - `discovery/strategy.md`
```

**Pattern to add** — append one line immediately after `reference/claim-graph.json` in the verify checklist:
```
   - `reference/retrieval-log.json`
```

**Existing CLAUDE.md directory structure pattern** (init/SKILL.md lines 408–414 — the reference/ directory listing):
```markdown
├── reference/                # Protocol and standards reference files
│   ├── canonical-figures.json # Single source of truth for cross-phase numbers
│   └── claim-graph.json       # Claim graph registry, written by /research:audit-claims
```

**Pattern to add** — append one line after claim-graph.json in the CLAUDE.md directory structure block:
```
│   └── retrieval-log.json     # Retrieval log registry, written by /research:discover
```

---

## Shared Patterns

### JSON Registry Read-Modify-Write Pattern
**Source:** `.claude/commands/research/audit-claims/SKILL.md` step 8b (referenced in Phase 12 PATTERNS.md lines 208–219) — the established contract for all JSON registry files
**Apply to:** `discover/SKILL.md` Step 6a (retrieval-log.json append)

The established pattern (all four steps are mandatory):
1. Read the registry file
2. If it does not exist — initialize with empty structure, proceed gracefully (do not fail)
3. If it exists but fails to parse — log warning, skip (do not fail the calling operation)
4. If it parses — operate on the data (append entries), write back, re-read to verify

This pattern already governs `canonical-figures.json` and `claim-graph.json` writes. `retrieval-log.json` follows identically — it is supplementary infrastructure, never a blocking gate.

### Flat Array JSON Registry Format
**Source:** `.claude/reference/templates/canonical-figures.json` (full file — `{"figures": []}`) and `init/SKILL.md` line 686 (`{"claims": []}`)
**Apply to:** `retrieval-log.json` initial content and entry schema

The established convention: top-level object with a single named array key. No nested structure, no index, no secondary keys. Entries appended as objects with typed fields. Queried by loading the file and filtering the array — no query layer.

`retrieval-log.json` follows: `{"entries": [...]}` with each entry as a flat object containing the 11 typed fields from D-03.

### Scaffolding Write Statement Format
**Source:** `init/SKILL.md` lines 684–686 — the claim-graph.json write statement
**Apply to:** `init/SKILL.md` modification (retrieval-log.json scaffold write)

Statement format: `- Write \`{path}\` with initial content \`{json}\` — this is the {description}, populated by \`{skill}\` during {when}.`

Retrieval-log version: `- Write \`research/reference/retrieval-log.json\` with initial content \`{"entries": []}\` — this is the retrieval log registry, populated by \`/research:discover\` after each discovery run.`

### Advisory-Not-Gate / Non-Blocking Write Pattern
**Source:** `discover/SKILL.md` Step 3 degradation handling (lines 109–118) — "Never abort discovery because one channel failed" and `init/SKILL.md` Step 6 verify — recovery on missing files without halting
**Apply to:** `discover/SKILL.md` Step 6a (retrieval-log.json write failure handling)

The established rule for all infrastructure writes in this project: a write failure for supplementary infrastructure (log files, registries) must never abort or roll back the primary artifact (candidates file, draft, output). Log the failure, report to the user with the specific path and reason, and continue. The retrieval log is a peer artifact to the candidates file — if the candidates file write failed (Step 6), do not attempt the log write either. If Step 6 succeeded but Step 6a fails, report the log failure and proceed to Step 7 without blocking.

### Channel Status Line Accumulation Pattern
**Source:** `discover/SKILL.md` Step 2g (lines 103–108) — the per-channel result status print
**Apply to:** `discover/SKILL.md` Step 2 modification (log entry accumulation)

The existing status line format per Step 2g:
```
{Channel Name}: found {N}
{Channel Name}: error — {reason}
{Channel Name}: degraded — using {fallback tool} fallback, found {N}
{Channel Name}: skipped (not mapped for this phase)
```

Log entry `status` values map directly from these printed strings: "found" / "error" / "degraded" / "skipped". `degraded_to` captures the fallback tool name when status is "degraded", null otherwise. This ensures no new in-loop data collection is needed beyond what Step 2 already computes — the log entry is assembled from data already available at Step 2g.

---

## No Analog Found

No files fall into this category. All three files/modifications have exact analogs in the codebase.

The closest "no prior analog" element is the `retrieval-log.json` entry schema itself (11 typed fields per D-03). However, the schema is fully specified in the CONTEXT.md decisions and the field values map directly to data already tracked during Step 2 channel execution — no new data structures need to be invented.

---

## Metadata

**Analog search scope:** `.claude/commands/research/discover/`, `.claude/commands/research/init/`, `.claude/reference/templates/`, `.planning/phases/12-claim-graph-operations/12-PATTERNS.md`, `.planning/phases/14-web-channel-diversity/14-PATTERNS.md`
**Files scanned:** 7 (discover/SKILL.md full, init/SKILL.md full, canonical-figures.json, web-search.md, academic.md, 12-PATTERNS.md, 14-PATTERNS.md)
**Pattern extraction date:** 2026-04-20
