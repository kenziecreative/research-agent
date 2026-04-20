# Phase 12: Claim Graph Operations - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-20
**Phase:** 12-claim-graph-operations
**Mode:** --auto (all decisions auto-selected from advisor recommendations)
**Areas discussed:** Drift detection mechanism, Drift flag presentation, Confidence rollup behavior, Revision response policy

---

## Drift Detection Mechanism

| Option | Description | Selected |
|--------|-------------|----------|
| Comparison-on-read in audit-claims | Extends existing canonical-figures check (step 6a) to walk claim-graph.json and compare figure_ids against registry values | ✓ |
| Event-driven trigger | Figure update itself triggers a scan — requires runtime event hooks | |

**User's choice:** Comparison-on-read (auto-selected — recommended default)
**Notes:** Event-driven is impossible with no external runtime. The audit pass is already the integrity checkpoint. Integrity agent check (option B) was noted as viable but redundant with extending the audit step.

---

## Drift Flag Presentation

| Option | Description | Selected |
|--------|-------------|----------|
| Inline in findings table | Drift as 10th issue type, moderate-severity, in existing findings taxonomy | ✓ |
| Separate "Drift Warnings" section | New output section before pass/fail | |
| Blocking gate | Prevents promotion until drift resolved | |

**User's choice:** Inline in findings table (auto-selected — recommended default)
**Notes:** Blocking gate rejected — drift is evidence weakness over time, not accuracy failure. Separate section rejected — creates structural inconsistency when canonical-figures mismatch already lives in findings table. Inline keeps all claim-level issues in one place.

---

## Confidence Rollup Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Read and roll up (no recompute) | Read embedded confidence_tier per node, group by section, take minimum | ✓ |
| Recompute from graph edges | Re-derive confidence from source_files/source_count/evidence_directness, overwrite stored value | |

**User's choice:** Read and roll up (auto-selected — recommended default)
**Notes:** Recomputation produces identical results (source notes are write-once, inputs never change). D-06 from Phase 11 was deliberately adopted to avoid recomputation. Re-audit is the natural recompute trigger via step 8a+8b upsert.

---

## Revision Response Policy

| Option | Description | Selected |
|--------|-------------|----------|
| Flag-only with drift_warning field | Annotate claim with drift_warning object; confidence_tier unchanged; warning persists until re-audit | ✓ |
| Auto-invalidate to Insufficient | Force-downgrade confidence_tier without human review | |

**User's choice:** Flag-only (auto-selected — recommended default)
**Notes:** Auto-invalidate contradicts write-once philosophy and advisory-not-gate confidence design. Quarantine (option C, not tabled) would make drift stronger than contradictions, inverting severity model. Flag-only holds both governing constraints: confidence is advisory, source notes are write-once.

---

## Claude's Discretion

- Exact positioning of drift detection step within audit-claims
- drift_warning field schema details beyond core fields
- Whether drift count appears in scorecard summary or only findings table
- Formatting of weakest-link rollup in output

## Deferred Ideas

None — all discussion stayed within phase scope.
