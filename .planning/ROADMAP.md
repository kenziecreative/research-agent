# Roadmap: Research Agent

## Milestones

- ✅ **v1.0 Core Research System** - Phases 1-5 (shipped 2026-03-29)
- ✅ **v1.1 Structured Source Discovery** - Phases 1-6 (shipped 2026-03-30)
- ✅ **v1.2 Evidence Quality & Analytical Rigor** - Phases 7-10 (shipped 2026-04-04)
- 🚧 **v1.3 Evidence Depth & Retrieval Integrity** - Phases 11-15 (in progress)

## Phases

<details>
<summary>✅ v1.0 Core Research System — SHIPPED 2026-03-29</summary>

Shipped 9 slash commands, 9 research type templates, source-processing pipeline with audit gates, canonical figures registry, PreToolUse/PreCompact hooks, and 4 reference files. Full phase details in git history.

</details>

<details>
<summary>✅ v1.1 Structured Source Discovery — SHIPPED 2026-03-30</summary>

Shipped 6 channel playbooks, 9 type-channel maps, `/research:discover` skill, init discovery scaffolding, tools guide update, and cross-phase consistency fixes. 6 phases, 10 plans. Full details in milestones/v1.1-ROADMAP.md.

</details>

<details>
<summary>✅ v1.2 Evidence Quality & Analytical Rigor — SHIPPED 2026-04-04</summary>

Shipped contradiction detection, saturation signals, shared-origin cluster detection, source staleness warnings, confidence tier scoring, assumption lifecycle tracking, counter-evidence gate, independent source counting with Direct/Adjacent/None classification, and infrastructure health checks. 4 phases, 8 plans. Full details in milestones/v1.2-ROADMAP.md.

</details>

### 🚧 v1.3 Evidence Depth & Retrieval Integrity (In Progress)

**Milestone Goal:** Deepen evidence traceability from individual claims through cross-phase figures, expand index diversity for honest source counting, and make discovery reproducible.

- [x] **Phase 11: Claim Graph Foundation** - Represent claims as graph nodes with edges to sources and canonical figures (completed 2026-04-20)
- [x] **Phase 12: Claim Graph Operations** - Transitive drift detection, per-claim confidence, and weakest-link rollup (completed 2026-04-20)
- [x] **Phase 13: Academic & Evidence Layer Expansion** - Crossref + Unpaywall academic channel additions; absence-vs-contradiction gap distinction (completed 2026-04-20)
- [x] **Phase 14: Web Channel Diversity** - Exa neural search as parallel web-search tier with deduplication against Tavily (completed 2026-04-20)
- [x] **Phase 15: Retrieval Provenance** - Structured retrieval log for reproducible discovery (completed 2026-04-21)
- [ ] **Phase 16: CLI Polish** - Consistent formatting, next-action blocks, approachable language, and progressive disclosure across all 10 skills

## Phase Details

### Phase 11: Claim Graph Foundation
**Goal**: Claims are represented as discrete graph nodes with typed edges to their source notes and any canonical figures they reference
**Depends on**: Phase 10 (v1.2 confidence tier infrastructure)
**Requirements**: TRACE-01
**Success Criteria** (what must be TRUE):
  1. A claim extracted during audit-claims is recorded as a node with a unique identifier
  2. Each claim node carries edges pointing to the source note(s) that support it
  3. Each claim node carries an edge to any canonical figure it references (where applicable)
  4. The claim graph persists in a queryable structure within the project directory
**Plans**: 2 plans
Plans:
- [x] 11-01-PLAN.md — Add step 8b to audit-claims (claim graph write path)
- [x] 11-02-PLAN.md — Init scaffolding + research-integrity check 9

### Phase 12: Claim Graph Operations
**Goal**: The claim graph supports transitive drift detection, per-claim confidence scoring, and weakest-link section rollups
**Depends on**: Phase 11
**Requirements**: TRACE-02, TRACE-03, TRACE-04
**Success Criteria** (what must be TRUE):
  1. When a canonical figure is revised, the system identifies and flags all claim nodes that transitively depend on it
  2. Each claim node displays an individual confidence tier derived from its source evidence
  3. A section's reported confidence tier equals the lowest confidence tier of any claim within it
  4. Drift flags are visible in audit-claims output before the user promotes to synthesis
**Plans**: 2 plans
Plans:
- [x] 12-01-PLAN.md — Drift detection, issue type, weakest-link rollup, and drift_warning lifecycle in audit-claims
- [x] 12-02-PLAN.md — Drift warning surfacing in research-integrity agent check 9

### Phase 13: Academic & Evidence Layer Expansion
**Goal**: Academic discovery queries Crossref and Unpaywall alongside OpenAlex; gap analysis distinguishes absence of evidence from evidence against
**Depends on**: Phase 11
**Requirements**: DISC-01, DISC-02, TRACE-05
**Success Criteria** (what must be TRUE):
  1. Running discover on an academic-relevant phase returns Crossref DOI/author/citation metadata that OpenAlex did not surface
  2. Papers found via OpenAlex or Crossref that have paywalled URLs are augmented with legal OA copy links from Unpaywall
  3. Gap analysis output explicitly labels uncovered research questions as either "no sources found" or "sources contradict hypothesis" rather than a single gap status
  4. All three academic integrations degrade gracefully when an API is unavailable
**Plans**: 2 plans
Plans:
- [x] 13-01-PLAN.md — Crossref + Unpaywall integration in academic channel playbook
- [x] 13-02-PLAN.md — Contradicts classification and Evidence Against status in gap analysis
**UI hint**: no

### Phase 14: Web Channel Diversity
**Goal**: Web search runs Exa neural search as a parallel tier, and duplicate URLs are removed before candidates are presented
**Depends on**: Phase 13
**Requirements**: DISC-03, DISC-04
**Success Criteria** (what must be TRUE):
  1. A discover run for a web-search phase returns candidates from both Tavily and Exa
  2. URLs that appear in both Exa and Tavily results are collapsed to a single candidate entry
  3. The source of each candidate (Tavily, Exa, or both) is visible in the candidate list
  4. Exa integration degrades gracefully when the API key is absent or the call fails
**Plans**: 2 plans
Plans:
- [x] 14-01-PLAN.md — Exa tool config, query templates, degradation, rate limits, and Section 8 dedup/attribution in web-search.md
- [x] 14-02-PLAN.md — Extend discover/SKILL.md Web Search subsection with dual-tool execution documentation

### Phase 15: Retrieval Provenance
**Goal**: Every discovery call is logged with its query, channel, and returned URLs so any discovery run can be reproduced or audited
**Depends on**: Phase 10
**Requirements**: PROV-01, PROV-02
**Success Criteria** (what must be TRUE):
  1. After running discover, a retrieval log file exists containing the query string, channel name, and all returned URLs for that call
  2. The log is structured such that a user can filter entries by phase, channel, or query without parsing free text
  3. Re-running discover with the same inputs produces a log entry that can be compared to the prior entry to detect result drift
**Plans**: 2 plans
Plans:
- [x] 15-01-PLAN.md — Log entry accumulation in discover Step 2 and batch write Step 6a to retrieval-log.json
- [x] 15-02-PLAN.md — Scaffold empty retrieval-log.json in init Step 5, verify checklist, and CLAUDE.md tree

### Phase 16: CLI Polish
**Goal**: All 10 skills present output with consistent structure, clear next-action guidance, plain language, and progressive disclosure for long responses
**Depends on**: Phases 11-15 (UX changes applied after functional changes exist)
**Requirements**: UX-01, UX-02, UX-03, UX-04
**Success Criteria** (what must be TRUE):
  1. Every skill's output uses the same section dividers, heading hierarchy, and bullet style
  2. Every skill ends with a next-action block naming the recommended next command and at least one alternative
  3. Transition text in all skills reads in plain, direct language with no academic hedging or jargon
  4. Skills that produce more than one screen of output lead with a summary section and gate details behind a clear separator or explicit prompt
**Plans**: 2 plans
Plans:
- [ ] 16-01-PLAN.md — [to be planned]
- [ ] 16-02-PLAN.md — [to be planned]
**UI hint**: yes

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1-5 | v1.0 | 15/15 | Complete | 2026-03-29 |
| 1-6 | v1.1 | 10/10 | Complete | 2026-03-30 |
| 7-10 | v1.2 | 8/8 | Complete | 2026-04-04 |
| 11. Claim Graph Foundation | v1.3 | 2/2 | Complete    | 2026-04-20 |
| 12. Claim Graph Operations | v1.3 | 2/2 | Complete    | 2026-04-20 |
| 13. Academic & Evidence Layer Expansion | v1.3 | 2/2 | Complete    | 2026-04-20 |
| 14. Web Channel Diversity | v1.3 | 2/2 | Complete    | 2026-04-20 |
| 15. Retrieval Provenance | v1.3 | 2/2 | Complete    | 2026-04-21 |
| 16. CLI Polish | v1.3 | 0/? | Not started | - |
