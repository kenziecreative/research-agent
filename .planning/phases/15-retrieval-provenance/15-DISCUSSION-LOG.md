# Phase 15: Retrieval Provenance - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-20
**Phase:** 15-retrieval-provenance
**Mode:** --auto (all decisions auto-selected from advisor research)
**Areas discussed:** Log storage & shape, Log write timing, Result drift comparison, Queryability approach

---

## Log Storage & Shape

| Option | Description | Selected |
|--------|-------------|----------|
| Single JSON file (`research/reference/retrieval-log.json`) | Consistent with existing registry pattern (canonical-figures.json, claim-graph.json); agents read/write with familiar pattern | :heavy_check_mark: |
| JSONL file (`research/reference/retrieval-log.jsonl`) | Append-only by design, grep-friendly, scales to large logs; breaks existing registry pattern | |

**User's choice:** Single JSON file (auto-selected: matches existing registry pattern; concurrent write concerns from JSONL recommendation don't apply since discover runs channels sequentially within a single agent session)
**Notes:** Advisory research recommended JSONL for write-safety but the concurrency concern is moot — discover is always a single-agent sequential process.

---

## Log Write Timing

| Option | Description | Selected |
|--------|-------------|----------|
| After each channel completes (incremental) | Partial runs auditable; log may contain pre-dedup duplicates | |
| After all channels, before dedup (raw results) | Captures URLs that get deduped away; log diverges from candidates file | |
| After candidates file write, Step 6 (final results) | Log mirrors candidates file cleanly; single write point; minimal implementation surface | :heavy_check_mark: |

**User's choice:** After candidates file write (auto-selected: recommended default — crash-before-Step-6 means no candidates to audit anyway)
**Notes:** None

---

## Result Drift Comparison

| Option | Description | Selected |
|--------|-------------|----------|
| Structural queryability only (manual comparison) | Two entries share phase/channel/query fields; user reads and compares URL arrays side-by-side | :heavy_check_mark: |
| Run ID linking + automated diff | Each run gets run_id with back-pointer; discover computes URL-set delta at completion | |

**User's choice:** Structural queryability only (auto-selected: consistent with advisory-not-gate philosophy; SC#3 satisfied by structural alignment)
**Notes:** None

---

## Queryability Approach

| Option | Description | Selected |
|--------|-------------|----------|
| Flat JSON array with typed fields | Matches canonical-figures.json / claim-graph.json; agents Read + parse; filter by iterating entries array | :heavy_check_mark: |
| JSONL with grep-friendly lines | Each line independently greppable; different read contract from all other registries | |

**User's choice:** Flat JSON array (auto-selected: matches existing registry pattern exactly; no new query contract for agents)
**Notes:** None

---

## Claude's Discretion

- Log entry schema details beyond the core fields specified in D-03
- Whether to log failed channel attempts
- Exact ordering of entries within a batch
- Optional `run_batch` grouping field

## Deferred Ideas

None — discussion stayed within phase scope
