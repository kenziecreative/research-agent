# Phase 11: Claim Graph Foundation - Context

**Gathered:** 2026-04-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Represent claims as discrete graph nodes with typed edges to their source notes and any canonical figures they reference. The graph persists as a queryable JSON structure within the project directory. This phase builds the data model and write path only — graph operations (drift detection, confidence rollup) belong to Phase 12.

</domain>

<decisions>
## Implementation Decisions

### Graph Storage
- **D-01:** Claim graph persists as a single JSON file at `research/reference/claim-graph.json`, following the canonical-figures.json pattern already established in the project
- **D-02:** Schema is a flat top-level array of claim node objects with typed string arrays for edges — no nested graph structures

### Claim Recording Timing
- **D-03:** Claims are recorded as graph nodes inside the existing `audit-claims` skill, during the audit pass that already extracts and traces every factual claim
- **D-04:** Graph write happens after the audit pass/fail determination — graph captures all claims from the audited draft regardless of pass/fail outcome, so the graph reflects what was checked, not just what passed

### Claim Node Schema
- **D-05:** Rich node schema with embedded metadata for Phase 12 self-sufficiency. Fields per node:
  - `id` — unique claim identifier (short slug)
  - `text` — the claim text as extracted from the draft
  - `phase` — research phase number (enables future sharding if needed)
  - `section` — section name within the draft (required for Phase 12 weakest-link rollup)
  - `confidence_tier` — High/Moderate/Low/Insufficient (computed at extraction time)
  - `source_files` — array of source note filenames that support this claim
  - `figure_ids` — array of canonical figure IDs this claim references (empty array if none)
  - `evidence_directness` — Direct/Indirect classification
  - `source_count` — integer count of independent sources
- **D-06:** Schema follows canonical-figures.json precedent — embed confidence at write time, trust it as stable since source notes are write-once in this pipeline

### Graph Query Pattern
- **D-07:** Agents query the graph by reading `claim-graph.json` directly via the Read tool — no query interface or lookup layer needed
- **D-08:** The `phase` field on each node enables mechanical sharding to per-phase files if the graph outgrows single-file reads (migration path, not Phase 11 scope)

### Claude's Discretion
- Claim ID generation scheme (slugified text, sequential numbering, UUID — whatever is most practical)
- Error handling when graph write fails during audit-claims (log warning vs. retry vs. fail the audit)
- Whether to write the graph file on every audit run or only on audit pass (D-04 says capture all, but edge cases like re-audits may need judgment)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing Infrastructure
- `.claude/commands/research/audit-claims/SKILL.md` — The skill that will be extended to write claim graph nodes; contains claim extraction logic, confidence tier computation, and pass/fail determination
- `.claude/reference/templates/source-standards.md` — Cross-phase citation rules and canonical figures registry contract
- `.claude/agents/research-integrity.md` — Integrity agent that already reads canonical-figures.json for drift detection; must be updated to also check claim-graph.json

### Data Models
- `research/reference/canonical-figures.json` (per-project, created at init) — Existing JSON registry pattern that claim-graph.json should mirror in style and access conventions
- `.claude/commands/research/init/SKILL.md` — Init scaffolding that creates canonical-figures.json; must be extended to also create empty claim-graph.json

### Requirements
- `.planning/REQUIREMENTS.md` §TRACE-01 — The requirement this phase satisfies

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `canonical-figures.json` schema and conventions — direct pattern to follow for claim-graph.json (flat array, string-typed fields, embedded confidence)
- `audit-claims` claim extraction loop — already walks every factual claim, traces to source notes, computes confidence tiers; graph node creation hooks into this existing pass
- Confidence tier computation logic in audit-claims (step 8a) — reusable for populating `confidence_tier` field on claim nodes

### Established Patterns
- JSON registries at `research/reference/` — canonical-figures.json lives here, claim-graph.json follows the same convention
- Write-once source notes — source notes in `research/notes/` are stable after processing, which makes embedding their data in claim nodes safe from staleness
- Origin chain field on source notes — used for shared-origin cluster detection in cross-ref; available as input for `source_count` (independent count) on claim nodes

### Integration Points
- `audit-claims` SKILL.md — primary integration point; add graph write step after step 8a (confidence tier computation)
- `init` SKILL.md — must scaffold empty `claim-graph.json` alongside canonical-figures.json during project init
- `research-integrity` agent — should be extended to check claim-graph.json for consistency (Phase 12 concern, but the file must exist for the agent to eventually read)

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

*Phase: 11-claim-graph-foundation*
*Context gathered: 2026-04-20*
