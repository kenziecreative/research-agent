# Requirements: Research Agent

**Defined:** 2026-04-03
**Core Value:** Every claim in the research output must trace to a specific, credibility-assessed source. If it can't be traced, it doesn't ship.

## v1.2 Requirements

Requirements for v1.2: Evidence Quality & Analytical Rigor. All behavior changes to existing skills — no new commands.

### Cross-Reference Enhancements

- [x] **XREF-01**: User can see explicit contradiction flags when cross-ref finds credible sources that genuinely conflict, with a forced resolution decision before synthesis
- [x] **XREF-02**: User can see what percentage of cross-ref findings are new vs. confirmatory, with an advisory when evidence is converging and additional sources are unlikely to change the picture
- [x] **XREF-03**: User can see when multiple processed sources trace to the same original claim, dataset, or report, preventing false triangulation before synthesis

### Gap & Coverage Analysis

- [ ] **GAP-01**: User can see how many independent sources address each phase question, with lopsided coverage flagged and non-independent sources identified
- [ ] **GAP-02**: User can see when processed sources answer adjacent-but-not-direct questions, distinguishing genuine coverage from close-enough matches

### Pipeline Quality Gates

- [x] **PIPE-01**: User can see source age warnings during synthesis when a processed source exceeds the staleness threshold for that research type
- [x] **PIPE-02**: User can see a confidence level (not just pass/fail) from audit-claims based on source count, credibility tiers, and evidence directness
- [ ] **PIPE-03**: User can see an explicit record of assumptions — judgments synthesized from weak or thin coverage — that can be revisited when later phases add evidence
- [ ] **PIPE-04**: User cannot open synthesis for PRD Validation or Exploratory Thesis research types until at least one processed source challenges the central claim

### System Infrastructure

- [ ] **INFRA-01**: User can see infrastructure health status (hooks, JSON validity, STATE.md structure, reference files, discovery strategy) at the top of progress output before project status

## Future Requirements

Deferred to v1.3+. Tracked but not in current roadmap.

### New Research Types

- **TYPE-01**: Analyst Report / Vendor Evaluation research type (multi-layered: landscape, vendor deep-dives, comparative scoring, buyer guidance)
- **TYPE-02**: Custom research types (user-defined phase structure, finding tags, credibility hierarchy, validation standards)

### Additional Channels

- **CHAN-06**: YouTube Data API integration for video/transcript discovery
- **CHAN-07**: Semantic Scholar full integration
- **CHAN-08**: Podcast RSS discovery

### Discovery Enhancements

- **DSKL-08**: Cross-channel deduplication
- **DSKL-09**: Re-discovery mid-phase deduplication against already-processed sources

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| New slash commands | v1.2 is behavior changes only — all work modifies existing skills |
| Paid channel integrations (Crunchbase, LexisNexis, Factiva) | Requires user billing setup; revisit when user demand exists |
| LinkedIn Sales Navigator | SNAP partner program paused since Aug 2025 |
| Token/session budget tracking | Harness audit rec 2 — useful but orthogonal to evidence quality focus |
| Structured event log | Harness audit rec 5 — nice-to-have, lower priority than evidence quality |
| Permission audit trail | Already shipped in v1.0 (harness audit rec 1) |
| Idempotency guard for process-source | Already shipped in v1.0 (harness audit rec 4) |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| XREF-01 | Phase 1 | Complete |
| XREF-02 | Phase 1 | Complete |
| XREF-03 | Phase 1 | Complete |
| GAP-01 | Phase 3 | Pending |
| GAP-02 | Phase 3 | Pending |
| PIPE-01 | Phase 2 | Complete |
| PIPE-02 | Phase 2 | Complete |
| PIPE-03 | Phase 2 | Pending |
| PIPE-04 | Phase 2 | Pending |
| INFRA-01 | Phase 4 | Pending |

**Coverage:**
- v1.2 requirements: 10 total
- Mapped to phases: 10
- Unmapped: 0

---
*Requirements defined: 2026-04-03*
*Last updated: 2026-04-03 after roadmap creation*
