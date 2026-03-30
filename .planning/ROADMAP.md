# Roadmap: Research Agent

## Milestones

- ✅ **v1.0 Core Research System** - Phases 1-5 (shipped 2026-03-29)
- 🚧 **v1.1 Structured Source Discovery** - Phases 1-5 (in progress)

## Phases

<details>
<summary>✅ v1.0 Core Research System — SHIPPED 2026-03-29</summary>

Shipped 9 slash commands, 9 research type templates, source-processing pipeline with audit gates, canonical figures registry, PreToolUse/PreCompact hooks, and 4 reference files. Full phase details in git history.

</details>

### 🚧 v1.1 Structured Source Discovery (In Progress)

**Milestone Goal:** Make the Collect step type-aware and multi-channel so the agent knows where to look for sources, not just how to process them once found.

- [x] **Phase 1: Channel Playbooks** - Reference files that define query construction, credibility tiers, and graceful degradation for each discovery channel type (completed 2026-03-29)
- [x] **Phase 2: Type-Channel Maps** - Per-research-type maps that route each phase of research to its highest-credibility channels (completed 2026-03-29)
- [ ] **Phase 3: Discover Skill** - The `/research:discover` slash command that orchestrates type-aware, multi-channel source discovery
- [ ] **Phase 4: Init Modifications** - Updated init skill that scaffolds discovery infrastructure and advertises the discover command to new projects
- [ ] **Phase 5: Tools Guide Update** - Updated tools guide with discovery-specific patterns and channel-specific tool recommendations

## Phase Details

### Phase 1: Channel Playbooks
**Goal**: Reference infrastructure for all six discovery channel types exists, each with enough structure for the discover skill to read and execute
**Depends on**: Nothing (first v1.1 phase)
**Requirements**: DISC-01
**Success Criteria** (what must be TRUE):
  1. Six channel playbook files exist in `.claude/reference/discovery/channel-playbooks/` covering web-search, academic, regulatory, financial, social-signals, and domain-specific
  2. Each playbook documents query construction syntax specific to that channel (Tavily parameters, HTTP API endpoints, or URL patterns)
  3. Each playbook specifies which tool to use (tavily_search, Bash HTTP, URL construction) and a graceful degradation instruction for when the channel is unavailable
  4. Each playbook defines a source status taxonomy (DISCOVERED / ACCESSIBLE / PROCESSED) so the skill can label paywalled or inaccessible sources
  5. No playbook files exist inside `.claude/commands/research/` (phantom command constraint satisfied)
**Plans:** 2/2 plans complete
Plans:
- [ ] 01-01-PLAN.md — Tavily-based playbooks (web-search, social-signals, financial)
- [ ] 01-02-PLAN.md — HTTP API playbooks (academic, regulatory, domain-specific)

### Phase 2: Type-Channel Maps
**Goal**: All nine research types have maps that route each phase to prioritized discovery channels derived from existing credibility hierarchies
**Depends on**: Phase 1
**Requirements**: DISC-02
**Success Criteria** (what must be TRUE):
  1. Nine type-channel map files exist in `.claude/reference/discovery/type-channel-maps/`, one per research type
  2. Each map lists primary and secondary channels per research phase, referencing channel names defined in Phase 1 playbooks
  3. Channel priorities in each map are consistent with the credibility hierarchies already documented in the project's type templates
  4. A channel appears in a type map only if it serves at least one research phase for that type (no speculative mappings)
**Plans:** 3/3 plans complete
Plans:
- [ ] 02-01-PLAN.md — Company/competitive type-channel maps (company-for-profit, company-non-profit, competitive-analysis)
- [ ] 02-02-PLAN.md — Market/product type-channel maps (market-industry, prd-validation, presentation-research)
- [ ] 02-03-PLAN.md — Knowledge/people type-channel maps (exploratory-thesis, curriculum-research, person-research)

### Phase 3: Discover Skill
**Goal**: Users can run `/research:discover` to get a prioritized, reviewable candidate list of sources for the current phase, routed through the channels appropriate for their research type
**Depends on**: Phase 2
**Requirements**: DSKL-01, DSKL-02, DSKL-03, DSKL-04, DSKL-05, DSKL-06, DSKL-07, DISC-03, CHAN-01, CHAN-02, CHAN-03, CHAN-04, CHAN-05
**Success Criteria** (what must be TRUE):
  1. Running `/research:discover` produces a candidate file at `research/discovery/<phase>-candidates.md` — separate from `research/notes/` — with no sources auto-fed into process-source
  2. Each candidate entry includes title, URL, and a status label (DISCOVERED / ACCESSIBLE / PROCESSED) so the user knows which sources are immediately processable
  3. The skill reports explicit status for every channel attempted: found N / rate limited / error / skipped / not configured — the user can distinguish "no sources exist" from "channel failed"
  4. Channel results are capped at 5-8 sources per channel per query; the candidate list is reviewable, not overwhelming
  5. The skill degrades gracefully to Tavily-only when other channels are unavailable, completing successfully rather than erroring
**Plans:** 1 plan
Plans:
- [ ] 03-01-PLAN.md — Complete discover skill with orchestration, all 6 channels, candidate output format

### Phase 4: Init Modifications
**Goal**: New projects scaffolded with `/research:init` include the discovery directory, a discovery strategy, and CLAUDE.md instructions that advertise the discover command from day one
**Depends on**: Phase 3
**Requirements**: DISC-04, INIT-01, INIT-02
**Success Criteria** (what must be TRUE):
  1. Running `/research:init` creates a `research/discovery/` directory in the project scaffold alongside the existing `research/notes/` and `research/sources/` directories
  2. The plan-generator subagent produces a `discovery-strategy.md` file mapping each research phase to its highest-value channels, as part of the init output
  3. The CLAUDE.md template assembled by init includes `/research:discover` in the skills table and the phase cycle workflow
**Plans:** 2 plans
Plans:
- [ ] 04-01-PLAN.md — Init skill modifications (directory scaffold, strategy generation, CLAUDE.md/STATE.md templates, verification, report)
- [ ] 04-02-PLAN.md — Cross-skill integration (discover strategy.md priority path, start-phase discover recommendation)

### Phase 5: Tools Guide Update
**Goal**: The tools guide contains discovery-specific guidance so users and agents know when to use search vs. extract and which tools to reach for per channel
**Depends on**: Phase 4
**Requirements**: INIT-03
**Success Criteria** (what must be TRUE):
  1. The tools guide documents when to use `tavily_search` (discovery) vs. `tavily_extract` (source processing), preventing the common mistake of extracting before evaluating
  2. The tools guide includes channel-specific tool recommendations (Tavily parameters for web/news/financial, Bash HTTP for academic/regulatory APIs, URL construction for patents)
**Plans**: TBD

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Channel Playbooks | 2/2 | Complete   | 2026-03-29 | - |
| 2. Type-Channel Maps | 3/3 | Complete   | 2026-03-29 | - |
| 3. Discover Skill | v1.1 | 0/1 | Planning | - |
| 4. Init Modifications | v1.1 | 0/2 | Planning | - |
| 5. Tools Guide Update | v1.1 | 0/TBD | Not started | - |
