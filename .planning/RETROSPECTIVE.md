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

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 5 | ~15 | Initial build — established slash command + reference file pattern |
| v1.1 | 6 | 10 | Added milestone audit loop — caught integration gaps before shipping |
| v1.2 | 4 | 8 | Evidence quality gates — advisory-not-gate pattern, origin chain as shared primitive |

### Recurring Issues

1. **STATE.md / ROADMAP.md documentation drift** — observed in v1.1 (Phase 3 checkbox) and v1.2 (all plan checkboxes, progress table, STATE.md position). These files are not maintained during execution and consistently lag behind actual progress.
2. **SUMMARY frontmatter omissions** — v1.2 07-01-SUMMARY.md had empty `requirements_completed` despite implementing 3 requirements. Frontmatter bookkeeping is manual and error-prone.

### Top Lessons (Verified Across Milestones)

1. Reference files in `.claude/reference/` (not `.claude/commands/`) prevents phantom commands — validated in v1.0, v1.1, and v1.2
2. Human-in-the-loop between workflow steps is a feature, not a limitation — maintained across all three milestones
3. Integration checking catches cross-phase wiring gaps that per-phase verification misses — validated in v1.1 (4 integration fixes) and v1.2 (audit-claims staleness Read gap)
4. Advisory-not-gate is the right default for quality signals — staleness, lopsided coverage, confidence tiers all warn without blocking, preserving user agency
