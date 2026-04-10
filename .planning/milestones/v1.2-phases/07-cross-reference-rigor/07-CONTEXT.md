# Phase 7: Cross-Reference Rigor - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Enhance the existing `/research:cross-ref` skill so its output distinguishes genuine independent corroboration from false triangulation, surfaces real contradictions for resolution, and signals when more sources are unlikely to change the picture. All changes are behavior modifications to existing skills — no new commands.

Requirements: XREF-01 (contradiction flags + forced resolution), XREF-02 (saturation signal), XREF-03 (source laundering detection).

</domain>

<decisions>
## Implementation Decisions

### Contradiction handling (XREF-01)
- Contradictions are logged in cross-reference.md with both sides cited and Claude's suggested resolution (based on recency, methodology, or source tier) — but user must explicitly confirm
- **Block at synthesis**: summarize-section refuses to proceed until all contradictions relevant to core phase questions are resolved
- Only contradictions that directly address a current phase question block synthesis; peripheral disagreements are flagged but non-blocking
- Resolution format is Claude's discretion (inline tag vs. separate section — whichever is simplest to parse and validate downstream)

### Saturation signal (XREF-02)
- **Per-pattern ratio**: for each pattern, track how many sources confirm vs. add new information; report per-pattern and aggregate
- **Per-question saturation**: each phase question gets its own saturation signal, directing the user where to focus further discovery
- **Threshold-based advisory**: triggers when aggregate confirmatory rate exceeds a threshold (exact threshold is Claude's discretion)
- **Informational with nudge**: displays the signal and suggests moving to synthesis when saturated, but does not hard-block

### Source laundering detection (XREF-03)
- **Origin field in source notes**: process-source captures the origin chain (primary/secondary) when processing; cross-ref compares origin citations across notes to detect shared-origin clusters
- **Both process-source and cross-ref**: process-source captures origin data, cross-ref does the cluster detection and comparison
- **Collapse and flag**: shared-origin clusters collapse to one data point in pattern strength assessment (Echo level per existing pattern guide); flagged visibly in cross-ref output
- Laundering warning visibility is Claude's discretion (dedicated section vs. inline with affected patterns)

### Cross-ref output format
- **Sectioned by signal type**: Contradictions (with resolution status) -> Saturation Summary (per-question table) -> Shared-Origin Clusters -> then existing pattern types (Convergence, Gap Clusters, Temporal Trends, Source-Type Skew, Outliers)
- **Brief dashboard at top**: counts of unresolved contradictions, aggregate saturation %, number of shared-origin clusters detected
- **Regenerate each run**: cross-ref reads ALL notes and regenerates the full file each time for consistency
- **Persist resolutions**: existing contradiction resolutions are read before regeneration and carried forward if the contradiction still exists in the data; dropped if the contradiction no longer exists

### Claude's Discretion
- Exact saturation threshold percentage for advisory trigger
- Contradiction resolution format (inline tag vs. separate section)
- Source laundering warning presentation (dedicated section vs. inline with affected patterns)
- Internal ordering within signal-type sections
- Dashboard formatting details

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.claude/commands/research/cross-ref/SKILL.md`: Current cross-ref skill — already identifies contradictions, convergence, gap clusters, temporal trends, source-type skew, and outliers; needs enhancement not replacement
- `.claude/reference/pattern-recognition-guide.md`: Defines pattern strength levels (Claim -> Emerging -> Pattern -> Echo) — Echo level directly supports source laundering collapse behavior
- `.claude/reference/source-assessment-guide.md`: Primary vs. secondary source chain tracking — basis for origin field detection
- `.claude/reference/templates/cross-reference.md`: Current minimal template — needs restructuring to carry new signal types

### Established Patterns
- Cross-ref guardrail #4 already warns about echo-chamber patterns ("three blog posts citing the same study are one data point") — XREF-03 formalizes this into enforced detection
- Process-source already captures primary/secondary chain in source notes — XREF-03 builds on this existing data
- Summarize-section already has a gate pattern (audit-claims must pass before promotion) — XREF-01 synthesis block follows the same gate pattern

### Integration Points
- `summarize-section/SKILL.md`: Needs new pre-check — read cross-reference.md for unresolved contradictions on core questions before proceeding
- `process-source/SKILL.md`: Needs enhanced origin chain capture for laundering detection
- `cross-reference.md` template: Needs restructuring with new sections (dashboard, contradictions, saturation, shared-origin clusters)
- Pattern recognition guide: Echo level already defined — cross-ref enforcement makes it actionable

</code_context>

<specifics>
## Specific Ideas

- Contradiction suggestions should cite specific evidence (recency, methodology quality, source tier) — not just "Source B is newer"
- Saturation signal should direct users to under-covered questions, not just report a number
- Source laundering detection leverages the existing primary/secondary chain in source notes — no new data model needed, just comparison logic in cross-ref

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-cross-reference-rigor*
*Context gathered: 2026-04-03*
