---
phase: 06-discover-skill-consistency-fixes
plan: 01
subsystem: skill-documentation
tags: [gap-closure, discover-skill, init-skill, cross-phase-consistency]
dependency_graph:
  requires: []
  provides: [corrected-discover-skill, corrected-init-skill]
  affects: [discover-skill, init-skill, regulatory-channel, academic-channel]
tech_stack:
  added: []
  patterns: [thin-orchestrator, machine-readable-field, playbook-reference]
key_files:
  created: []
  modified:
    - .claude/commands/research/discover/SKILL.md
    - .claude/commands/research/init/SKILL.md
key_decisions:
  - "EDGAR User-Agent updated to match regulatory.md (ResearchAgent (contact@example.com)) — playbook is source of truth"
  - "Academic fallback chain: Semantic Scholar step removed entirely, now tavily_search then WebSearch per academic.md section 6"
  - "ProPublica URLs: {ein_no_dashes} with dash-removal note added to both URL patterns"
  - "Init CLAUDE.md template: research-type field added as item 0 before Project Purpose — machine-readable for discover pre-check"
metrics:
  duration: "2 minutes"
  completed: "2026-03-30"
  tasks_completed: 2
  files_modified: 2
---

# Phase 06 Plan 01: Discover/Init Skill Consistency Fixes Summary

**One-liner:** Fixed 4 cross-phase documentation inconsistencies in discover and init SKILL.md files — ProPublica EIN format, academic fallback chain, EDGAR User-Agent, and init research-type field.

## What Was Built

Two targeted SKILL.md fixes closing all 4 inconsistencies identified in the v1.1 milestone audit.

### Task 1: discover SKILL.md — 3 fixes

**Fix 1 (CHAN-04) — ProPublica EIN format:**
Both ProPublica URL patterns now use `{ein_no_dashes}` with explicit dash-removal note, matching the format specified in regulatory.md line 225. Zero bare `{ein}` references remain.

**Fix 2 (CHAN-02) — Academic fallback chain:**
Removed the phantom Semantic Scholar API step that appeared in the SKILL.md fallback chain but is absent from academic.md section 6. The chain is now: (1) `tavily_search` with academic domain scoping, (2) `WebSearch` with academic domain keywords — exactly matching academic.md.

**Fix 3 (CHAN-03) — EDGAR User-Agent:**
Updated all three locations where the User-Agent appeared (channel execution section, Guardrail 4, Common Failure Modes table) from the incorrect `Research Agent research-agent@example.com` to `ResearchAgent (contact@example.com)`, matching regulatory.md line 28. Guardrail 4 now points to regulatory.md as the source of truth.

### Task 2: init SKILL.md — 1 fix

**Fix (INIT-02) — CLAUDE.md template research-type field:**
Added item 0 to the Step 4 CLAUDE.md assembly instructions specifying that a `research-type: {type}` line must appear at the very top of every scaffolded CLAUDE.md. The field is machine-readable and enables discover skill pre-check step 3 to find and parse the research type without regex guessing.

## Deviations from Plan

None — plan executed exactly as written.

## Verification Results

All 4 verification checks passed:
- `grep "ein_no_dashes" discover/SKILL.md` — matched (2 occurrences)
- `grep -c "{ein}" discover/SKILL.md` — returned 0
- `grep -c "Semantic Scholar" discover/SKILL.md` — returned 0
- `grep "ResearchAgent (contact@example.com)" discover/SKILL.md` — matched (3 occurrences)
- `grep -c "Research Agent research-agent@example.com" discover/SKILL.md` — returned 0
- `grep "research-type:" init/SKILL.md` — matched

## Commits

- `7937292` — fix(06-01): fix 3 inconsistencies in discover SKILL.md
- `4b44f54` — fix(06-01): add research-type field to init CLAUDE.md template

## Self-Check: PASSED
