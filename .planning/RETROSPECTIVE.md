# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.1 — Structured Source Discovery

**Shipped:** 2026-03-30
**Phases:** 6 | **Plans:** 10

### What Was Built
- 6 channel playbooks (web-search, academic, regulatory, financial, social-signals, domain-specific) with query templates, credibility tiers, and degradation chains
- 9 type-channel maps routing research phases to prioritized discovery channels per research type
- `/research:discover` slash command — thin orchestrator for multi-channel source discovery
- Init scaffolding for discovery (directory, strategy.md generation, CLAUDE.md integration)
- Tools guide expansion with search-vs-extract workflow and channel-tool mapping
- Cross-phase consistency fixes closing 4 integration gaps from first audit

### What Worked
- Thin orchestrator pattern: keeping channel intelligence in playbooks (not the skill) made updates trivial — Phase 6 fixes only touched SKILL.md, not channel logic
- Phased reference-first approach: building playbooks (Phase 1) then maps (Phase 2) before the skill (Phase 3) meant the skill had stable interfaces to code against
- Milestone audit after Phase 5 caught 4 real integration inconsistencies before shipping — Phase 6 closed all of them
- Plan-level parallelism: Phase 2 split into 3 plans (company, market, knowledge) that could execute independently

### What Was Inefficient
- Phase 6 was entirely rework from integration gaps that could have been caught during Phase 3/4 execution with stricter cross-file validation
- STATE.md fell behind reality — showed Phase 1 / 0% even after all 6 phases completed; performance metrics table was never properly updated
- ROADMAP.md Phase 3 checkbox was never marked `[x]` despite completion — manual bookkeeping drift

### Patterns Established
- Channel playbook 7-section layout (Overview, Templates, Parameters, Credibility, Status, Degradation, Notes) — reuse for future channels
- Type-channel map format with YAML `active-channels` frontmatter and phase-grouped discovery sections
- Strategy.md express lane pattern: init pre-computes phase-to-channel mappings so discover skips keyword matching
- Source status taxonomy (DISCOVERED/ACCESSIBLE/PROCESSED) canonically defined in one file, referenced everywhere else

### Key Lessons
1. Run integration checks after each cross-phase dependency, not just at milestone audit time — would have caught the 4 inconsistencies 2 phases earlier
2. Reference-document-heavy milestones (playbooks, maps) benefit from structural templates established in the first plan — Phase 2's 3 plans all followed Phase 1's layout and moved fast
3. Thin orchestrator + playbook delegation is the right pattern for this project — the skill stays small and stable while channel details evolve independently

### Cost Observations
- Model mix: primarily sonnet for execution, opus for planning/verification
- Notable: Phase 2 (9 type-channel maps across 3 plans) was the highest-volume phase but executed cleanly due to consistent template pattern

---

## Milestone: v1.2 — Evidence Quality & Analytical Rigor

**Shipped:** 2026-04-04
**Phases:** 4 | **Plans:** 8

### What Was Built
- Contradiction detection in cross-ref with forced resolution gate blocking synthesis until core contradictions resolved
- Saturation signals (new vs. confirmatory) with 75% aggregate advisory and per-question directional flags
- Shared-origin cluster detection collapsing dependent sources to Echo level, preventing false triangulation
- Source staleness warnings with domain-differentiated thresholds (1-5 years) across all 11 type templates
- Confidence tier scoring (High/Moderate/Low/Insufficient) in audit-claims from 4 inputs
- Assumption lifecycle (Open/Validated/Challenged) persisting from summarize-section to start-phase
- Counter-evidence gate for PRD Validation and Exploratory Thesis types, applied per-phase
- Independent source counting via origin_chain with Direct/Adjacent/None classification
- Lopsided coverage advisory in summarize-section and coverage snapshot in start-phase
- Infrastructure health checks (5 named checks) at top of progress output

### What Worked
- Origin chain as a shared primitive: one field in process-source enabled three downstream consumers (cross-ref cluster detection, check-gaps independence counting, coverage-assessment-guide definitions) without any of them needing to coordinate
- Advisory-not-gate pattern: staleness, lopsided coverage, confidence tiers all surface information without blocking — consistent UX and preserves user agency
- Verification files caught ROADMAP documentation lag and SUMMARY frontmatter omissions before they propagated
- Integration checker identified the audit-claims staleness Read gap — a real functional issue missed by individual phase verifications

### What Was Inefficient
- ROADMAP.md plan checkboxes and progress table never updated during execution — same documentation drift as v1.1 Phase 3
- 07-01-SUMMARY.md `requirements_completed` frontmatter left empty despite implementing all 3 XREF requirements — bookkeeping gap carried through to audit
- STATE.md showed "Phase 7 / 0%" throughout the entire milestone — never updated as phases completed
- Phase numbering mismatch between REQUIREMENTS.md traceability table ("Phase 1-4") and actual execution phases (07-10) caused confusion during audit

### Patterns Established
- Advisory pre-check pattern: surface risk but don't block (staleness, lopsided coverage, confidence tier)
- Blocking gate pattern: hard-stop with actionable guidance (contradictions, counter-evidence, cross-ref currency)
- Origin chain as independence primitive: one captured field enables multiple downstream analyses
- Coverage-assessment-guide.md as single source of truth for classification definitions
- Named failure pattern: infrastructure issues reported with specific failure name + WHY description

### Key Lessons
1. STATE.md and ROADMAP.md bookkeeping drift is a recurring pattern (v1.1 and v1.2) — these files are not updated during execution. Consider whether the complete-milestone workflow should fix this automatically rather than flagging as tech debt.
2. SUMMARY frontmatter `requirements_completed` must be populated at plan execution time, not retroactively — the 07-01 omission wasn't caught until milestone audit.
3. The 3-source cross-reference (VERIFICATION + SUMMARY frontmatter + REQUIREMENTS traceability) is effective at catching documentation gaps but only when all three sources are maintained during execution.
4. Integration checking after individual phase verifications catches cross-phase wiring gaps that per-phase verification misses — the audit-claims staleness Read gap was only visible when checking the staleness flow end-to-end.

### Cost Observations
- Model mix: sonnet for execution agents, opus for planning/verification/orchestration
- Sessions: All 4 phases planned, executed, and verified in a single day
- Notable: All work was behavior changes to existing skills — no new commands created, which kept the blast radius small

---

## Milestone: v1.3 — Evidence Depth & Retrieval Integrity

**Shipped:** 2026-04-21
**Phases:** 6 | **Plans:** 12

### What Was Built
- Claim graph representing claims as nodes with typed edges to source notes and canonical figures; init scaffolds, audit-claims writes, research-integrity validates
- Transitive drift detection flagging downstream claims when canonical figures change; weakest-link section rollup computing section confidence as lowest claim tier
- Crossref + Unpaywall as APIs 2 and 3 in academic channel playbook (DOI/citation metadata, legal OA copy lookup)
- Exa neural search as parallel web-search tier with URL-based dedup against Tavily, source attribution tags, and independent degradation
- Gap analysis 4-tier classification (Direct/Adjacent/Contradicts/None) distinguishing absence of evidence from active counter-evidence
- Retrieval provenance logging — per-channel-tool log entry accumulation in discover Step 2 with batch write to retrieval-log.json in Step 6a
- CLI polish — CLI Tone Rules in prompt-templates.md, consistent output structure across all 10 skills, ▶ NEXT: blocks with context-sensitive recommendations, progressive disclosure for long-output skills

### What Worked
- Consistent infrastructure pattern: claim-graph.json and retrieval-log.json both followed the canonical-figures.json pattern (flat JSON, init scaffolds, non-blocking writes) — each new registry took less time to implement than the last
- Phase dependency planning: 11 → 12 (graph → operations) and 13 → 14 (academic channels → web channel) avoided rework within each chain
- CLI polish as final phase: applying UX changes after all functional changes existed meant no rework from later phases breaking formatting
- Milestone audit caught the discover/SKILL.md academic channel documentation asymmetry — correctly classified as advisory since thin orchestrator pattern is by-design

### What Was Inefficient
- ROADMAP.md and STATE.md bookkeeping drift continues from v1.1/v1.2 — STATE.md showed "Phase 16 / 0%" throughout entire milestone execution
- gsd-tools summary-extract has a parsing bug — `one_liner` field extraction fails for most SUMMARY.md files, requiring manual accomplishment writing during milestone close
- gsd-tools audit-open command crashes with `ReferenceError: output is not defined` — pre-close artifact audit had to be skipped
- Nyquist compliance was missing for all 6 phases (research was disabled) — no VALIDATION.md files exist

### Patterns Established
- JSON registry pattern: flat array, init scaffolds empty structure, non-blocking read-modify-write — claim-graph.json, retrieval-log.json, canonical-figures.json all follow this
- Phase-pair dependency: foundation phase builds data structure, operations phase builds behaviors on top (11→12, 13→14)
- Advisory documentation gap: thin orchestrator pattern means skill summary intentionally under-documents channel details — playbooks are authoritative
- ▶ NEXT: block format with context-sensitive dual blocks (different recommendations based on output state)

### Key Lessons
1. STATE.md / ROADMAP.md bookkeeping drift is now a 3-milestone pattern (v1.1, v1.2, v1.3) — this is a systemic tooling gap, not a one-off oversight
2. gsd-tools has multiple parsing bugs (summary-extract, audit-open) that add manual overhead at milestone close — worth reporting or fixing
3. The JSON registry pattern (flat array, scaffold at init, non-blocking writes) is now proven across 3 registries — it's the right pattern for this project's reference data
4. CLI polish is best applied as a final phase after all functional changes — avoids cross-phase UX rework

### Cost Observations
- Model mix: primarily sonnet for execution, opus for planning/verification/orchestration
- Sessions: All 6 phases planned, executed, and verified in 2 days
- Notable: Phases 11-14 completed in a single day; phases 15-16 in a second day — functional phases moved faster than UX phases

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 5 | ~15 | Initial build — established slash command + reference file pattern |
| v1.1 | 6 | 10 | Added milestone audit loop — caught integration gaps before shipping |
| v1.2 | 4 | 8 | Evidence quality gates — advisory-not-gate pattern, origin chain as shared primitive |
| v1.3 | 6 | 12 | Claim traceability, channel diversity, retrieval provenance — JSON registry pattern proven across 3 registries |

### Recurring Issues

1. **STATE.md / ROADMAP.md documentation drift** — observed in v1.1 (Phase 3 checkbox), v1.2 (all plan checkboxes, progress table, STATE.md position), and v1.3 (STATE.md showed Phase 16 / 0% throughout). Systemic tooling gap across 3 milestones.
2. **SUMMARY frontmatter omissions** — v1.2 07-01-SUMMARY.md had empty `requirements_completed` despite implementing 3 requirements. Frontmatter bookkeeping is manual and error-prone.
3. **gsd-tools parsing bugs** — v1.3 exposed summary-extract one_liner extraction failures and audit-open crash. Adds manual overhead at milestone close.

### Top Lessons (Verified Across Milestones)

1. Reference files in `.claude/reference/` (not `.claude/commands/`) prevents phantom commands — validated in v1.0, v1.1, v1.2, and v1.3
2. Human-in-the-loop between workflow steps is a feature, not a limitation — maintained across all four milestones
3. Integration checking catches cross-phase wiring gaps that per-phase verification misses — validated in v1.1 (4 integration fixes), v1.2 (audit-claims staleness Read gap), and v1.3 (discover academic summary asymmetry)
4. Advisory-not-gate is the right default for quality signals — staleness, lopsided coverage, confidence tiers, drift warnings all warn without blocking, preserving user agency
5. JSON registry pattern (flat array, init scaffolds, non-blocking writes) is the proven data storage pattern — validated across canonical-figures.json, claim-graph.json, and retrieval-log.json in v1.3
