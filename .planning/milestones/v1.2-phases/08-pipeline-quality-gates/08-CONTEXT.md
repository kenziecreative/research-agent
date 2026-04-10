# Phase 8: Pipeline Quality Gates - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Add source staleness warnings, confidence levels, assumption tracking, and counter-evidence gates to the existing pipeline. All changes are behavior modifications to existing skills — no new commands. Users can see source quality signals throughout the pipeline, and the system blocks synthesis for validation research types until counter-evidence exists.

Requirements: PIPE-01 (staleness warnings), PIPE-02 (confidence levels), PIPE-03 (assumptions record), PIPE-04 (counter-evidence gate).

</domain>

<decisions>
## Implementation Decisions

### Staleness thresholds (PIPE-01)
- **Type-aware thresholds**: each research type defines its own staleness window in its type template file (e.g., Market Analysis might be 1 year, Historical Audit might be 10+ years) — not a single global 2-year default
- **Warn at synthesis only**: staleness warnings surface in summarize-section when it reads source notes before drafting — not during process-source (avoids noise during collection)
- **Warn but allow**: stale sources are displayed with age warnings but do not block synthesis — stale evidence is still evidence, just weaker
- **Feeds into confidence**: staleness is one input to the PIPE-02 confidence calculation — sections relying heavily on stale sources get a lower confidence tier

### Confidence scoring (PIPE-02)
- **Named tiers**: High / Moderate / Low / Insufficient — not numeric percentages (avoids false precision)
- **Four inputs**: source count (maps to Claim/Emerging/Pattern levels), credibility tiers, evidence directness, and staleness (from PIPE-01) — all four contribute to the tier calculation
- **Per-section granularity**: one confidence tier per drafted section, matching audit-claims' existing section-level evaluation — not per-claim
- **Warn, don't block**: confidence tier is displayed prominently in audit-claims output but does not block promotion — some research types (exploratory) legitimately have lower confidence

### Assumptions record (PIPE-03)
- **Dedicated file**: research/assumptions.md — a persistent record that accumulates across phases, easy to review all assumptions in one place
- **Generated during synthesis**: summarize-section identifies thin-coverage judgments as it writes and logs them to assumptions.md — the author knows what it's inferring
- **Revisited at phase-start**: start-phase reads assumptions.md and surfaces any assumptions relevant to the new phase's questions — user sees what prior assumptions might now be testable
- **Three-state lifecycle**: Open (still based on thin evidence) / Validated (later evidence confirmed) / Challenged (later evidence contradicts)

### Counter-evidence gate (PIPE-04)
- **Enforced at summarize-section**: pre-check for PRD Validation and Exploratory Thesis types — scans processed source notes for CHALLENGED/CONTRADICTED finding tags before allowing synthesis to proceed
- **One credible source minimum**: at least one processed source with CHALLENGED or CONTRADICTED tag from a credible source (not blog posts or opinion pieces) required to pass the gate
- **All phases gated**: every phase in PRD Validation and Exploratory Thesis types requires counter-evidence — the whole point of these types is to stress-test claims
- **Actionable block message**: when the gate blocks, suggest running /research:discover with terms likely to surface opposing views — user knows what to do next

### Claude's Discretion
- Exact staleness threshold values per research type (informed by the type's domain)
- Confidence tier weighting formula across the four inputs
- Assumptions.md file format and entry structure
- How start-phase matches prior assumptions to current phase questions
- Counter-evidence gate block message formatting and discovery channel suggestions
- Evidence directness assessment criteria

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `source-assessment-guide.md`: Already defines 2-year recency rules and primary/secondary source evaluation — staleness thresholds extend this
- `audit-claims/SKILL.md`: Already generates pass/fail scorecard with percentages — confidence tiers layer on top of existing output
- `pattern-recognition-guide.md`: Defines Claim/Emerging/Pattern/Echo levels — maps directly to source count input for confidence
- Type templates (`prd-validation.md`, `exploratory-thesis.md`): Already define CHALLENGED/CONTRADICTED finding tags — counter-evidence gate reads these

### Established Patterns
- **Gate pattern**: summarize-section already blocks on unresolved core contradictions (Phase 7) — PIPE-04 counter-evidence gate follows the same pre-check pattern
- **Source note structure**: process-source notes already track data year, publication year, credibility, and origin chain — staleness calculation reads existing fields
- **Transparency principle**: Phase 7 decided resolved contradictions appear in drafts with reasoning — assumptions record follows the same visibility approach
- **Single-source flagging**: summarize-section already flags findings with "single source suggests" language — PIPE-03 formalizes this into a persistent record

### Integration Points
- `summarize-section/SKILL.md`: Needs three new pre-checks (staleness warnings, counter-evidence gate, assumption logging)
- `audit-claims/SKILL.md`: Needs confidence tier output added to scorecard
- `start-phase/SKILL.md`: Needs to read assumptions.md and surface relevant open assumptions
- Research type template files: Need staleness threshold field added per type
- `research/assumptions.md`: New file created during first synthesis, persists across phases

</code_context>

<specifics>
## Specific Ideas

- Staleness and confidence are integrated, not independent — stale sources lower the confidence tier rather than being a separate signal to reconcile
- Counter-evidence gate should be actionable: when it blocks, point the user to discovery channels that can find opposing views
- Assumptions record follows the same transparency principle as contradiction resolutions — visible and revisitable, not silently absorbed

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 08-pipeline-quality-gates*
*Context gathered: 2026-04-03*
