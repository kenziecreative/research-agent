# Phase 12: Claim Graph Operations - Context

**Gathered:** 2026-04-20
**Status:** Ready for planning

<domain>
## Phase Boundary

The claim graph (built in Phase 11) gains three operational capabilities: transitive drift detection when canonical figures change, per-claim confidence display, and weakest-link section rollups. This phase adds detection and reporting logic — it does not add new data structures or new skills.

</domain>

<decisions>
## Implementation Decisions

### Drift Detection Mechanism
- **D-01:** Drift detection runs inside `audit-claims` as an extension of the existing canonical-figures check (step 6a). No new skill or agent needed.
- **D-02:** On each audit run, read `canonical-figures.json` and `claim-graph.json`. For every claim node with non-empty `figure_ids`, compare the stored figure values against the current registry values. Mismatches are flagged as drift.
- **D-03:** Transitive detection is resolved in the same read pass — follow `figure_ids` chains through the graph to find all downstream dependents of a revised figure.

### Drift Flag Presentation
- **D-04:** Drift appears as a new issue type (`Drift detected`) in the existing findings table (step 7 taxonomy), treated as moderate-severity by default.
- **D-05:** Drift is advisory, not blocking — consistent with confidence tier philosophy. A drift-heavy draft can still fail through the standard moderate-severity gate, but drift alone does not create a special blocking path.
- **D-06:** Drift flags are visible in audit-claims output before the pass/fail determination, satisfying success criterion #4.

### Confidence Rollup Behavior
- **D-07:** Phase 12 reads the `confidence_tier` already embedded per node in `claim-graph.json` (written by step 8b during audit). No recomputation of per-claim confidence — D-06 from Phase 11 ("embed at write time, trust as stable") holds.
- **D-08:** Section rollup is a pure aggregation: group nodes by `section` field, take the minimum tier per group. Tier ordering: Insufficient < Low < Moderate < High.
- **D-09:** TRACE-03 (per-claim confidence) is satisfied by the embedded field on each node. TRACE-04 (weakest-link) is satisfied by the section minimum computation.

### Revision Response Policy
- **D-10:** Flag-only policy. When drift is detected, annotate the claim node with a `drift_warning` object (e.g., `{ "figure_id": "...", "expected_value": ..., "canonical_value": ... }`). The claim's `confidence_tier` is NOT auto-downgraded.
- **D-11:** The `drift_warning` field persists until the next re-audit clears it (re-audit runs step 8b which overwrites the node with fresh data from the current source state).
- **D-12:** Drift warnings must surface in the audit report output so the human is prompted to act — not just stored in JSON silently.

### Claude's Discretion
- Exact positioning of the drift detection step within audit-claims (before or after step 8a, as long as it's before pass/fail)
- `drift_warning` field schema details beyond the three core fields
- Whether to show a count summary of drift warnings in the scorecard section or only in the findings table
- Formatting of the weakest-link rollup in the confidence tier table output

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing Infrastructure
- `.claude/commands/research/audit-claims/SKILL.md` — The skill being extended; contains the findings taxonomy (step 7), canonical-figures check (step 6a), claim graph write (step 8b), and confidence tier computation (step 8a)
- `.claude/agents/research-integrity.md` — Integrity agent with check 9 (claim graph consistency); may need extension to surface drift warnings
- `.claude/reference/templates/source-standards.md` — Cross-phase citation rules and canonical figures registry contract

### Data Models
- `research/reference/claim-graph.json` (per-project) — The graph being operated on; flat claims array with `figure_ids`, `confidence_tier`, `section` fields
- `research/reference/canonical-figures.json` (per-project) — The figures registry; changes to values here trigger drift detection

### Requirements
- `.planning/REQUIREMENTS.md` §TRACE-02 — Transitive drift detection requirement
- `.planning/REQUIREMENTS.md` §TRACE-03 — Per-claim confidence tier requirement
- `.planning/REQUIREMENTS.md` §TRACE-04 — Weakest-link section rollup requirement

### Prior Phase Context
- `.planning/phases/11-claim-graph-foundation/11-CONTEXT.md` — Phase 11 decisions on graph schema, storage location, and write-time embedding philosophy

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `audit-claims` step 6a (canonical-figures check) — Already reads `canonical-figures.json` and compares values; drift detection extends this same pattern to claim nodes
- `audit-claims` step 8a (confidence tier computation) — Per-section tier logic already implemented; weakest-link rollup reuses the same tier ordering
- `audit-claims` step 8b (claim graph write) — Upsert logic for claim nodes; `drift_warning` field can be cleared here on re-audit
- `research-integrity` check 9 — Already reads claim-graph.json and checks consistency; drift warning detection could piggyback on this

### Established Patterns
- Advisory-not-gate: Confidence tiers, staleness warnings, lopsided coverage are all advisory. Drift follows the same pattern.
- Issue taxonomy in step 7: Currently 9 issue types with severity classification. Drift becomes the 10th.
- Write-once source notes: Means embedded confidence is stable — no need for recomputation path.
- Comparison-on-read: The canonical-figures check already does value comparison at audit time; drift detection is the same pattern applied to the graph.

### Integration Points
- `audit-claims` SKILL.md — Primary integration point; add drift detection step, add `Drift detected` issue type, add drift_warning write to step 8b
- `research-integrity` agent — May need extension to check for active drift_warnings and surface them outside of audit runs
- Scorecard output (step 8) — Add weakest-link rollup display using the section minimum computation

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

*Phase: 12-claim-graph-operations*
*Context gathered: 2026-04-20*
