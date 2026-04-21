# Phase 11: Claim Graph Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-20
**Phase:** 11-claim-graph-foundation
**Areas discussed:** Where the graph lives, When claims get recorded, What a claim node contains, How the graph gets queried
**Mode:** Auto (all areas auto-selected, recommended options chosen)

---

## Where the Graph Lives

| Option | Description | Selected |
|--------|-------------|----------|
| Single JSON file (`research/reference/claim-graph.json`) | Matches canonical-figures.json pattern exactly, trivially queryable by Read + grep, single source of truth, Phase 12 traversal is pure JSON navigation | ✓ |
| Structured markdown per-phase files (`research/claims/<phase-slug>.md`) | Familiar format, human-readable without tooling, aligns with notes/ and audits/ patterns — but no native graph structure, edges encoded in prose/tables, fragile drift detection | |

**User's choice:** [auto] Single JSON file (recommended default)
**Notes:** Matches the canonical-figures.json precedent. JSON gives reliable edge traversal for Phase 12 drift detection. Markdown-per-phase trades traversal reliability for readability — unacceptable tradeoff given Phase 12's transitive drift detection needs.

---

## When Claims Get Recorded

| Option | Description | Selected |
|--------|-------------|----------|
| Record nodes inside audit-claims | No new step in the cycle; audit already has every claim, its source trace, and its confidence tier in working memory; single pass does both audit and graph write | ✓ |
| Dedicated `record-claims` step after audit pass | Single-responsibility skills stay clean; graph write failure can't affect audit promotion; explicit user-visible step in cycle | |

**User's choice:** [auto] Record inside audit-claims (recommended default)
**Notes:** audit-claims already extracts every claim, traces it, and computes confidence — all the data needed for graph nodes is in context during the audit pass. A separate step risks users skipping it and the graph diverging from outputs. The advisor noted audit-claims is already complex (~200 lines), but graph write is append-only with low failure risk.

---

## What a Claim Node Contains

| Option | Description | Selected |
|--------|-------------|----------|
| Rich schema (~8 fields) | id, text, phase, section, confidence_tier, source_files[], figure_ids[], evidence_directness, source_count — Phase 12 reads only the graph, no cross-file joins | ✓ |
| Lightweight schema (~5 fields) | id, text, phase, section, source_files[], figure_ids[] only — Phase 12 must re-read source notes to compute confidence on every operation | |

**User's choice:** [auto] Rich schema (recommended default)
**Notes:** Phase 12 operations (drift detection, weakest-link rollup) all need per-claim confidence without re-reading source notes. Embedding confidence_tier, evidence_directness, and source_count follows the canonical-figures.json precedent of embedding confidence at registration time. Staleness risk is low — source notes are write-once.

---

## How the Graph Gets Queried

| Option | Description | Selected |
|--------|-------------|----------|
| Single file read directly by agents | Agents Read full claim-graph.json — matches canonical-figures.json access pattern; phase field on each node enables future sharding | ✓ |
| Sharded files (one JSON per phase) read via Glob + Read | Phase 12 loads only relevant phase's file; natural scoped query; but cross-phase figure edges span files, requiring multi-file reads | |

**User's choice:** [auto] Single file read directly (recommended default)
**Notes:** Phase 12 success criterion #1 — "when a canonical figure is revised, identify all claims that depend on it" — requires cross-phase lookup by figure ID. Single-file is lower risk for that traversal. Include `phase` field on each node so sharding is a mechanical migration if scale becomes an issue.

---

## Claude's Discretion

- Claim ID generation scheme
- Error handling for graph write failures during audit-claims
- Re-audit graph write behavior (overwrite vs. append)

## Deferred Ideas

None — discussion stayed within phase scope
