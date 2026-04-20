# Phase 13: Academic & Evidence Layer Expansion - Context

**Gathered:** 2026-04-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Academic discovery queries Crossref and Unpaywall alongside OpenAlex to fill metadata gaps and provide legal open-access copies of paywalled papers. Gap analysis distinguishes between "no sources found" (absence of evidence) and "sources contradict hypothesis" (evidence against). This phase adds two API integrations to the academic channel and one classification extension to gap analysis — it does not add new skills or new channels.

</domain>

<decisions>
## Implementation Decisions

### Crossref Integration Architecture
- **D-01:** Crossref is integrated by extending the existing `academic.md` channel playbook — not as a separate channel. The discover skill already routes to academic.md; Crossref becomes a parallel query within that same channel execution.
- **D-02:** Query execution order within the academic channel: OpenAlex first (existing), then Crossref second. Crossref results are deduplicated against OpenAlex results by DOI match before adding to candidates.
- **D-03:** Crossref fills metadata gaps that OpenAlex missed — primarily DOI resolution, author disambiguation, and citation count. If a paper appears in both, OpenAlex data takes priority with Crossref enriching missing fields.

### Unpaywall Lookup Trigger
- **D-04:** Unpaywall is called only for papers where `is_oa=false` (paywalled) during the discovery pass — not for all DOI results. This is targeted enrichment, not blanket enrichment.
- **D-05:** The lookup happens inline during discovery (same pass as OpenAlex/Crossref), not as a separate post-discovery step. A paper that has a legal OA copy should show as ACCESSIBLE in the candidates file, not DISCOVERED.
- **D-06:** Unpaywall lookup is bounded by the existing 8-result-per-channel cap. Worst case: 8 Unpaywall API calls per query.
- **D-07:** If Unpaywall is unavailable (timeout, error, API down), the paper remains DISCOVERED and discovery continues. Graceful degradation — skip silently with a channel status note, don't block or retry.

### Gap Analysis: Absence vs. Contradiction
- **D-08:** The existing relevance classification (Direct/Adjacent/None) gains a fourth value: `Contradicts`. A source note that actively opposes or contradicts the research question's hypothesis is classified as Contradicts rather than Direct or Adjacent.
- **D-09:** Coverage status for questions with `Contradicts` sources and 0 Direct sources uses a new status label: "Evidence Against" (distinct from "Not Started" which means no sources found at all).
- **D-10:** The coverage-assessment-guide.md reference file is extended with definitions for the Contradicts classification and Evidence Against status.
- **D-11:** The "highest-priority gaps" list in gap output distinguishes the two: "No evidence found" questions are discovery targets; "Evidence Against" questions are synthesis challenges (the user needs to address the contradiction, not find more sources).

### Claude's Discretion
- Crossref query template design (field selection, filter parameters, pagination approach)
- Unpaywall API endpoint and response parsing details
- How the Contradicts classification interacts with the existing "Addressed but unbalanced" status (may overlap — Claude resolves the taxonomy)
- Whether Crossref results that duplicate OpenAlex should be silently dropped or noted in the channel status line

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Discovery Infrastructure
- `.claude/reference/discovery/channel-playbooks/academic.md` — The playbook being extended; contains OpenAlex query templates, credibility tiers, degradation chain, and source status taxonomy
- `.claude/commands/research/discover/SKILL.md` — The orchestrator skill that routes to channel playbooks; defines the per-channel execution flow, deduplication, and candidate file format
- `.claude/reference/discovery/channel-playbooks/web-search.md` — Contains the canonical source status taxonomy (DISCOVERED/ACCESSIBLE/PROCESSED) referenced by all playbooks

### Gap Analysis
- `.claude/commands/research/check-gaps/SKILL.md` — The skill being extended; contains the Direct/Adjacent/None classification, coverage status definitions, and gaps.md format
- `.claude/reference/coverage-assessment-guide.md` — Reference file with match classification criteria and coverage status definitions; must be extended with Contradicts classification

### Data Models
- `research/reference/canonical-figures.json` (per-project) — Existing registry pattern for reference
- `research/reference/claim-graph.json` (per-project) — Claim graph from Phase 11-12; gap analysis may reference claims when assessing contradiction

### Requirements
- `.planning/REQUIREMENTS.md` §DISC-01 — Crossref alongside OpenAlex requirement
- `.planning/REQUIREMENTS.md` §DISC-02 — Unpaywall for legal OA copies requirement
- `.planning/REQUIREMENTS.md` §TRACE-05 — Absence vs. evidence-against distinction requirement

### Prior Phase Context
- `.planning/phases/11-claim-graph-foundation/11-CONTEXT.md` — Claim graph schema and conventions
- `.planning/phases/12-claim-graph-operations/12-CONTEXT.md` — Drift detection and confidence tier patterns

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `academic.md` playbook — Existing OpenAlex integration with query templates, credibility tiers, degradation chain; Crossref and Unpaywall extend this same structure
- `discover` SKILL.md Step 2 — Per-channel execution loop with status reporting, 8-result cap, and degradation handling; Crossref executes within this same loop
- Source status taxonomy (DISCOVERED/ACCESSIBLE/PROCESSED) — Unpaywall's job is to upgrade DISCOVERED to ACCESSIBLE when an OA copy exists
- Coverage-assessment-guide.md — Existing Direct/Adjacent/None classification that gains the Contradicts value

### Established Patterns
- Channel playbooks contain all channel-specific intelligence (query templates, credibility tiers, degradation chains) — Crossref follows the same pattern within academic.md
- Degradation chains: primary tool → fallback → WebSearch floor. Crossref and Unpaywall each need their own degradation path
- Deduplication by URL in discover skill — Crossref deduplication by DOI is the same pattern applied to academic identifiers
- Advisory-not-gate: Gaps and coverage flags are informational, not blocking. Evidence Against status follows this pattern.

### Integration Points
- `academic.md` playbook — Primary integration for Crossref templates and Unpaywall lookup logic
- `check-gaps/SKILL.md` step 6 — Add Contradicts classification in the relevance assessment loop
- `coverage-assessment-guide.md` — Extend with Contradicts definition and Evidence Against status
- `discover/SKILL.md` Step 5 — Source status determination may need a note about Unpaywall upgrading status

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

*Phase: 13-academic-evidence-layer-expansion*
*Context gathered: 2026-04-20*
