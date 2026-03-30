# Milestones

## v1.1 Structured Source Discovery (Shipped: 2026-03-30)

**Phases completed:** 6 phases, 10 plans, 2 tasks

**Key accomplishments:**
- 6 channel playbooks with query templates, credibility tiers, and degradation chains (web-search, academic, regulatory, financial, social-signals, domain-specific)
- 9 type-channel maps routing each research type's phases to prioritized discovery channels
- `/research:discover` skill — thin orchestrator for type-aware multi-channel source discovery
- Init scaffolds discovery infrastructure (directory, strategy.md, CLAUDE.md integration)
- Tools guide expanded with search-vs-extract workflow and channel-tool mapping
- 4 cross-phase integration fixes (EIN format, academic fallback, User-Agent, research-type field)

---

## v1.0 — Core Research System

**Shipped:** 2026-03-29
**Phases:** 1-5 (initial build through restructure)

**What shipped:**
- 9 slash commands: init, process-source, cross-ref, check-gaps, summarize-section, audit-claims, start-phase, phase-insight, progress
- 1 agent: research-integrity (post-write drift detection)
- 9 research type templates with type-specific credibility hierarchies and finding tags
- Phase-sequential workflow with PreToolUse and PreCompact hooks
- Audience & evidence standard calibration
- Guardrails and failure mode tables for all skills
- 4 reference files: evidence failure modes, pattern recognition, source assessment, coverage assessment
- Canonical figures registry for cross-phase number tracking

**Key decisions:**
- Commands in .claude/commands/research/ (not plugin structure)
- Reference files in .claude/reference/ (outside commands tree)
- Human-in-the-loop between all workflow steps (no agent orchestration)
