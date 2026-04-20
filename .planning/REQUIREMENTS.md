# Requirements: v1.3 Evidence Depth & Retrieval Integrity

## Active Requirements

### Claim Traceability (TRACE)

- [ ] **TRACE-01**: System represents each claim as a graph node with edges to its source note(s) and any canonical figure it references
- [ ] **TRACE-02**: When a canonical figure is revised, system identifies and flags all downstream claims that depend on it (transitive drift detection)
- [ ] **TRACE-03**: Each claim receives an individual confidence tier based on its supporting evidence
- [ ] **TRACE-04**: Section-level confidence tier is computed as the weakest claim tier within that section (weakest-link rollup)
- [ ] **TRACE-05**: Gap analysis distinguishes between "absence of evidence" (no sources found) and "evidence against" (sources contradicting the hypothesis)

### Discovery Channels (DISC)

- [ ] **DISC-01**: Academic channel queries Crossref API alongside OpenAlex to fill metadata gaps (DOI, author, citation count)
- [ ] **DISC-02**: Academic channel queries Unpaywall to find legal open-access copies of papers discovered via OpenAlex or Crossref
- [ ] **DISC-03**: Web-search channel includes Exa neural search as a parallel tier surfacing semantically relevant non-SEO sources
- [ ] **DISC-04**: Discovery results from Exa are deduplicated against Tavily results before adding to candidates

### Discovery Provenance (PROV)

- [ ] **PROV-01**: Every discovery call logs the exact query string, channel used, and full list of returned URLs to a retrieval log
- [ ] **PROV-02**: Retrieval log is structured and queryable (which queries produced which sources for which phase)

### CLI Experience (UX)

- [ ] **UX-01**: All 10 skills use consistent section dividers, headings, and bullet formatting for output
- [ ] **UX-02**: Every skill ends with a clear next-action block telling the user what to do next and what other commands are available
- [ ] **UX-03**: Transition text between workflow steps uses approachable, non-academic language
- [ ] **UX-04**: Skills that produce long output use progressive disclosure (summary first, details on request)

## Future Requirements

- Red-team pass / adversarial counter-search before synthesis (v1.4 candidate — requires claim graph infrastructure from TRACE-01)
- GROBID for structured academic PDF reference extraction (v1.4+ — feeds origin-chain dedup at DOI level)
- CourtListener / RECAP API for company litigation research (future channel addition)
- GDELT integration for market/industry trend detection (future channel addition)

## Out of Scope

- Paid APIs requiring user billing setup (Kagi, premium Exa tiers) — free/freemium tiers only
- Automated red-team synthesis pass — deferred to v1.4 when claim graph exists to operate on
- NotebookLM integration — process-source already handles fixed corpora adequately
- Perplexity Sonar as corroboration pass — cross-ref system already fills this role

## Traceability

| Requirement | Phase | Verified |
|-------------|-------|----------|
| TRACE-01 | — | — |
| TRACE-02 | — | — |
| TRACE-03 | — | — |
| TRACE-04 | — | — |
| TRACE-05 | — | — |
| DISC-01 | — | — |
| DISC-02 | — | — |
| DISC-03 | — | — |
| DISC-04 | — | — |
| PROV-01 | — | — |
| PROV-02 | — | — |
| UX-01 | — | — |
| UX-02 | — | — |
| UX-03 | — | — |
| UX-04 | — | — |
