---
phase: 07-cross-reference-rigor
plan: "01"
subsystem: research-skills
tags: [cross-ref, process-source, contradiction-detection, saturation-signals, source-laundering, origin-chain]
dependency_graph:
  requires: []
  provides: [XREF-01, XREF-02, XREF-03]
  affects: [cross-ref, process-source, cross-reference-template]
tech_stack:
  added: []
  patterns: [origin-chain-capture, contradiction-tracking, saturation-advisory, shared-origin-collapse]
key_files:
  created: []
  modified:
    - .claude/commands/research/process-source/SKILL.md
    - .claude/commands/research/cross-ref/SKILL.md
    - .claude/reference/templates/cross-reference.md
decisions:
  - "Origin chain captured as a required structured field in process-source notes (not just a narrative element) so cross-ref can perform deterministic cluster matching"
  - "75% aggregate saturation threshold used for advisory trigger; 80% per-question for 'saturated', 40% for 'under-covered'"
  - "Contradiction resolution carries forward across regenerations — only dropped when the underlying contradiction is gone from re-analyzed data"
  - "Shared-origin cluster collapse is retroactive — applies to all existing patterns when clusters are first detected"
metrics:
  duration_minutes: 2
  completed_date: "2026-04-03"
  tasks_completed: 2
  tasks_total: 2
  files_modified: 3
---

# Phase 1 Plan 1: Cross-Reference Rigor Enhancement Summary

Cross-ref skill enhanced with structured contradiction detection (suggested resolution + user confirmation gate), per-question saturation signals with threshold advisory, and shared-origin cluster detection that collapses dependent sources to Echo level; process-source now captures a required origin chain field for downstream laundering detection.

## What Was Built

**Task 1: process-source origin chain + cross-reference template restructure**

Added origin chain as a required structured field in the process-source note schema (step 5). The field captures whether a source is primary (original data/research) or secondary (reports on others' findings), and for secondary sources records the cited originals with enough detail (title, author, date) for cross-ref to match origins across notes. Added guardrail 6 making the field mandatory on every note, and a failure mode row for missing origin chain.

Replaced the minimal cross-reference.md template with a sectioned structure: Dashboard (unresolved contradiction count, aggregate saturation %, shared-origin cluster count) -> Contradictions -> Saturation Summary (per-question table) -> Shared-Origin Clusters -> existing pattern types (Convergence, Gap Clusters, Temporal Trends, Source-Type Skew, Outliers).

**Task 2: cross-ref skill logic enhancement**

Rewrote the Process section to incorporate all three signal types while preserving the existing skill architecture. New steps:
- Step 4: Read and preserve existing contradiction resolutions before any regeneration
- Step 5 (XREF-01): Contradiction detection — compare source pairs, record both sides with citations, generate a suggested resolution with explicit reasoning (recency, methodology, credibility tier), set status as "unresolved" (new) or carry forward "resolved: [decision]", classify as core vs. peripheral
- Step 6 (XREF-03): Shared-origin cluster detection — read origin chain fields, group by shared original source, apply Echo level from pattern-recognition-guide.md to any pattern relying on a single cluster
- Step 7 (XREF-02): Saturation calculation — per-question new vs. confirmatory classification, 75% aggregate advisory, per-question directional flags (>80% = saturated, <40% = under-covered)
- Step 8: Cross-cutting pattern analysis with shared-origin adjustments applied to pattern strength
- Step 9: Full regeneration using new template structure, carrying forward only resolved contradictions

Added guardrails 6-9 for: contradiction user-confirmation requirement, shared-origin collapse retroactivity, saturation as informational (not blocking), regeneration consistency. Added 4 new failure mode rows covering the most common mistakes for each new signal type.

## Deviations from Plan

None - plan executed exactly as written.

## Success Criteria Verification

- [x] process-source skill requires structured origin chain field in source notes — field added in step 5 note structure and guardrail 6
- [x] cross-ref skill detects contradictions — step 5 with both sides, suggested resolution, status tracking, core/peripheral classification
- [x] cross-ref skill computes saturation — step 7 with per-question ratios, 75% aggregate advisory, per-question directional guidance
- [x] cross-ref skill identifies shared-origin clusters — step 6 using origin chain fields, Echo-level collapse
- [x] cross-reference template carries dashboard and all new signal sections — Dashboard, Contradictions, Saturation Summary, Shared-Origin Clusters in correct order
- [x] All three XREF requirements addressed in the analysis engine

## Key Links Verified

- process-source SKILL.md -> cross-ref SKILL.md: origin chain field (step 5 note structure) is read by cross-ref step 6 for cluster detection
- cross-ref SKILL.md -> cross-reference.md template: step 9 regenerates using the new template structure
- pattern-recognition-guide.md -> cross-ref SKILL.md: Echo level referenced in step 6 and guardrail 7 for shared-origin collapse

## Self-Check: PASSED

Files exist:
- .claude/commands/research/process-source/SKILL.md: FOUND
- .claude/commands/research/cross-ref/SKILL.md: FOUND
- .claude/reference/templates/cross-reference.md: FOUND

Commits:
- 680e30e: feat(07-01): add origin chain capture to process-source and restructure cross-reference template
- ca9d8c3: feat(07-01): enhance cross-ref skill with contradiction flagging, saturation signals, and laundering detection
