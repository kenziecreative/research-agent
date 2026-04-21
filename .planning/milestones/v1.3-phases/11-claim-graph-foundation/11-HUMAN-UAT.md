---
status: partial
phase: 11-claim-graph-foundation
source: [11-VERIFICATION.md]
started: 2026-04-20T09:30:00Z
updated: 2026-04-20T09:30:00Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. Init scaffolds claim-graph.json at runtime
expected: Running `/research:init` on a new project creates `research/reference/claim-graph.json` with `{"claims": []}` content
result: [pending]

### 2. Audit-claims writes and deduplicates claim nodes
expected: Running `/research:audit-claims` on a draft populates `claim-graph.json` with nodes containing all 9 schema fields (id, text, phase, section, confidence_tier, source_files, figure_ids, evidence_directness, source_count). Re-running produces no duplicates (dedup by phase+section+text equality).
result: [pending]

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
