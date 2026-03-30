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

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 5 | ~15 | Initial build — established slash command + reference file pattern |
| v1.1 | 6 | 10 | Added milestone audit loop — caught integration gaps before shipping |

### Top Lessons (Verified Across Milestones)

1. Reference files in `.claude/reference/` (not `.claude/commands/`) prevents phantom commands — validated in both v1.0 and v1.1
2. Human-in-the-loop between workflow steps is a feature, not a limitation — maintained across both milestones
