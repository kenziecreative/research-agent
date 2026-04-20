---
phase: 11-claim-graph-foundation
plan: "02"
subsystem: init-skill, research-integrity-agent
tags: [claim-graph, scaffolding, integrity-check, advisory]
dependency_graph:
  requires: []
  provides: [claim-graph-scaffolding, claim-graph-integrity-check]
  affects: [init-skill, research-integrity-agent]
tech_stack:
  added: []
  patterns: [json-registry-write-pattern, integrity-check-structure]
key_files:
  created: []
  modified:
    - .claude/commands/research/init/SKILL.md
    - .claude/agents/research-integrity.md
decisions: []
metrics:
  duration: "~5 minutes"
  completed: "2026-04-20"
  tasks_completed: 2
  files_modified: 2
requirements: [TRACE-01]
---

# Phase 11 Plan 02: Claim Graph Scaffolding & Integrity Check Summary

**One-liner:** Init now scaffolds claim-graph.json with `{"claims": []}` and research-integrity agent gains advisory check 9 for graph-audit confidence tier consistency.

## What Was Built

Two files were modified to integrate claim-graph.json into the research workflow foundation:

### .claude/commands/research/init/SKILL.md (3 insertions)

1. **Step 5 Other Files** — Added a Write step for `research/reference/claim-graph.json` with initial content `{"claims": []}` immediately after the canonical-figures.json copy. The comment explains it is populated by `/research:audit-claims` during each phase's Verify step.

2. **Directory tree in CLAUDE.md template** — Changed `canonical-figures.json` from `└──` to `├──` (no longer the last reference/ item) and added `claim-graph.json` as the new `└──` final entry with a comment noting it is written by `/research:audit-claims`.

3. **Step 6 verification checklist** — Added `reference/claim-graph.json` to the ls-verified file list immediately after `reference/canonical-figures.json`.

### .claude/agents/research-integrity.md (2 insertions)

1. **Check 9 — Claim Graph Consistency** — New check inserted after check 8 and before `## How to Use This Agent`. Applies only when claim-graph.json exists and the file under review is a phase output or draft. Reads claim-graph.json, compares `confidence_tier` per claim node against the corresponding audit report section tier. Flags drift with `CLAIM GRAPH INCONSISTENCY:` prefix. Advisory only — does not block promotion. Skips gracefully (without comment) if claim-graph.json does not exist.

2. **How to Use trigger** — Added bullet before "Any time something feels like it might have drifted": "After `/research:audit-claims` writes claim nodes to claim-graph.json (check 9 catches graph-audit consistency drift)"

## Verification Results

| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| `grep -c "claim-graph.json" init/SKILL.md` | 3 | 3 | PASS |
| `grep -c "claim-graph.json" research-integrity.md` | >= 3 | 4 | PASS |
| Check 9 heading exists | `### 9. Claim Graph Consistency` | found line 63 | PASS |
| Init verification checklist | `reference/claim-graph.json` | found line 732 | PASS |
| Directory tree ├── canonical / └── claim-graph | both correct | lines 409-410 | PASS |
| CLAIM GRAPH INCONSISTENCY flag text | present | found line 67 | PASS |
| `skip this check without comment` | present | found | PASS |
| `This check is advisory` | present | found line 68 | PASS |

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| Task 1 | 9639ea2 | feat(11-02): scaffold claim-graph.json in init SKILL.md |
| Task 2 | cd5875d | feat(11-02): add check 9 (Claim Graph Consistency) to research-integrity agent |

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None. Both modifications are behavioral instructions to agents; no data files were created (claim-graph.json is created at `/research:init` runtime, not at development time). No placeholder text or wired-but-empty data sources exist.

## Threat Surface Scan

No new network endpoints, auth paths, file access patterns, or schema changes introduced beyond those modeled in the plan's threat register (T-11-03: trivial empty-struct write at init; T-11-04: read-only advisory check in integrity agent). No additional threat flags.

## Self-Check: PASSED

- `.claude/commands/research/init/SKILL.md` — modified (git confirms 5 insertions)
- `.claude/agents/research-integrity.md` — modified (git confirms 8 insertions)
- Commit 9639ea2 — exists (`git log --oneline | grep 9639ea2`)
- Commit cd5875d — exists (`git log --oneline | grep cd5875d`)
