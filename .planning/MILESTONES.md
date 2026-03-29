# Milestones

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
