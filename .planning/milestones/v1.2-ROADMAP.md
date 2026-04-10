# Roadmap: Research Agent

## Milestones

- ✅ **v1.0 Core Research System** - Phases 1-5 (shipped 2026-03-29)
- ✅ **v1.1 Structured Source Discovery** - Phases 1-6 (shipped 2026-03-30)
- 🚧 **v1.2 Evidence Quality & Analytical Rigor** - Phases 1-4 (in progress)

## Phases

<details>
<summary>✅ v1.0 Core Research System — SHIPPED 2026-03-29</summary>

Shipped 9 slash commands, 9 research type templates, source-processing pipeline with audit gates, canonical figures registry, PreToolUse/PreCompact hooks, and 4 reference files. Full phase details in git history.

</details>

<details>
<summary>✅ v1.1 Structured Source Discovery — SHIPPED 2026-03-30</summary>

Shipped 6 channel playbooks, 9 type-channel maps, `/research:discover` skill, init discovery scaffolding, tools guide update, and cross-phase consistency fixes. 6 phases, 10 plans. Full details in milestones/v1.1-ROADMAP.md.

</details>

### 🚧 v1.2 Evidence Quality & Analytical Rigor (In Progress)

**Milestone Goal:** Make the existing pipeline smarter about evidence quality — catch contradictions, staleness, lopsided coverage, source laundering, and false triangulation before they reach the final output.

## Phase Details

### Phase 7: Cross-Reference Rigor
**Goal**: Users can trust that cross-ref output distinguishes genuine independent corroboration from false triangulation, surfaces real contradictions for resolution, and signals when more sources are unlikely to change the picture.
**Depends on**: Nothing (first phase of milestone)
**Requirements**: XREF-01, XREF-02, XREF-03
**Success Criteria** (what must be TRUE):
  1. User can see explicit contradiction flags when cross-ref identifies credible sources that genuinely conflict, and must make a resolution decision before synthesis can proceed
  2. User can see a saturation signal showing what percentage of cross-ref findings are new vs. confirmatory, with an advisory when convergence is high and more sources are unlikely to shift the picture
  3. User can see when multiple processed sources trace back to the same original claim, dataset, or report — so false triangulation is caught before it reaches synthesis
**Plans:** 2/2 plans complete

Plans:
- [ ] 07-01-PLAN.md — Enhance cross-ref with contradiction/saturation/laundering detection + process-source origin chain + template restructure
- [ ] 07-02-PLAN.md — Add contradiction resolution gate to summarize-section

### Phase 8: Pipeline Quality Gates
**Goal**: Users can see source staleness, confidence levels, and explicit assumptions throughout the pipeline, and the system blocks synthesis for validation research types until counter-evidence exists.
**Depends on**: Phase 7
**Requirements**: PIPE-01, PIPE-02, PIPE-03, PIPE-04
**Success Criteria** (what must be TRUE):
  1. User can see source age warnings during synthesis when a processed source exceeds the staleness threshold defined for that research type
  2. User can see a confidence level (not just pass/fail) from audit-claims, derived from source count, credibility tiers, and evidence directness
  3. User can see an explicit assumptions record — judgments synthesized from weak or thin coverage — that persists and can be revisited when later phases add evidence
  4. User cannot open synthesis for PRD Validation or Exploratory Thesis research types until at least one processed source challenges the central claim
**Plans:** 1/3 plans executed

Plans:
- [ ] 08-01-PLAN.md — Add staleness thresholds to type templates and staleness warnings to summarize-section
- [ ] 08-02-PLAN.md — Add confidence tier scoring to audit-claims
- [ ] 08-03-PLAN.md — Add assumption tracking and counter-evidence gate to summarize-section and start-phase

### Phase 9: Gap Analysis Depth
**Goal**: Users can see whether phase question coverage is backed by independent sources and whether matched sources genuinely answer the question or only address adjacent territory.
**Depends on**: Phase 7
**Requirements**: GAP-01, GAP-02
**Success Criteria** (what must be TRUE):
  1. User can see how many independent sources address each phase question, with lopsided coverage flagged and non-independent sources (those tracing to the same origin) identified
  2. User can see when processed sources answer adjacent-but-not-direct questions, with a clear distinction between genuine coverage and close-enough matches
**Plans:** 1/2 plans executed

Plans:
- [ ] 09-01-PLAN.md — Enhance check-gaps with independence counting, three-tier matching, and dashboard output
- [ ] 09-02-PLAN.md — Integrate enhanced gaps.md into phase-insight, summarize-section, and start-phase

### Phase 10: System Health Visibility
**Goal**: Users can confirm the research infrastructure is intact before reviewing project status, catching configuration drift before it silently undermines a session.
**Depends on**: Nothing (independent; can follow any phase)
**Requirements**: INFRA-01
**Success Criteria** (what must be TRUE):
  1. User can see infrastructure health status — hooks active, JSON valid, STATE.md structurally sound, reference files present, discovery strategy present — at the top of progress output, before project status
  2. Any infrastructure issue is surfaced as a named failure (not a silent omission) so the user knows what to fix
**Plans:** 1/1 plans complete

Plans:
- [ ] 10-01-PLAN.md — Add 5 infrastructure health checks to progress skill with named failures and compact all-pass display

## Progress

**Milestone:** v1.2 Evidence Quality & Analytical Rigor

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 7. Cross-Reference Rigor | 2/2 | Complete   | 2026-04-03 |
| 8. Pipeline Quality Gates | 1/3 | In Progress|  |
| 9. Gap Analysis Depth | 1/2 | In Progress|  |
| 10. System Health Visibility | 1/1 | Complete    | 2026-04-04 |
