---
phase: 13-academic-evidence-layer-expansion
plan: "01"
subsystem: discovery
tags: [academic-channel, crossref, unpaywall, api-integration, dual-api, degradation, deduplication]
dependency_graph:
  requires: []
  provides:
    - academic.md three-API configuration (OpenAlex + Crossref + Unpaywall)
    - Crossref query templates D/E/F with curl examples
    - Unpaywall OA check Template G with trigger condition
    - Crossref and Unpaywall degradation chains
    - Section 8 deduplication and priority rules
    - Unpaywall status upgrade path in discover/SKILL.md Step 5
  affects:
    - .claude/reference/discovery/channel-playbooks/academic.md
    - .claude/commands/research/discover/SKILL.md
tech_stack:
  added:
    - Crossref API (https://api.crossref.org/works) — DOI/author/citation metadata
    - Unpaywall API (https://api.unpaywall.org/v2/{doi}) — legal OA copy lookup
  patterns:
    - Dual-API channel pattern from regulatory.md (API 1/2/3 sub-entries in Section 2)
    - Skip-not-retry degradation for Unpaywall (no fallback service; papers remain DISCOVERED)
    - DOI-based deduplication (mirrors URL dedup in discover/SKILL.md Step 4)
    - Inline status upgrade: DISCOVERED → ACCESSIBLE via Unpaywall during same discovery pass
key_files:
  modified:
    - .claude/reference/discovery/channel-playbooks/academic.md
    - .claude/commands/research/discover/SKILL.md
decisions:
  - "Crossref added as API 2 within existing academic channel — not a separate channel — consistent with D-01"
  - "Unpaywall degradation is skip-not-retry (no equivalent free OA lookup service exists) — consistent with D-07"
  - "OpenAlex data has priority in all deduplication merge cases; Crossref fills gaps only — consistent with D-03"
  - "Unpaywall trigger is is_oa=false only, bounded by 8-result-per-channel cap — consistent with D-04/D-06"
metrics:
  duration: "< 5 minutes"
  completed: "2026-04-20"
  tasks_completed: 2
  tasks_total: 2
  files_modified: 2
---

# Phase 13 Plan 01: Academic Channel Crossref and Unpaywall Integration Summary

**One-liner:** Extended academic channel playbook with Crossref (DOI/citation metadata) and Unpaywall (legal OA copy lookup) as APIs 2 and 3 alongside OpenAlex, following the dual-API pattern from regulatory.md.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Extend academic.md with Crossref and Unpaywall integrations | 5ed14f1 | .claude/reference/discovery/channel-playbooks/academic.md |
| 2 | Add Unpaywall status upgrade note to discover/SKILL.md Step 5 | 0c127a6 | .claude/commands/research/discover/SKILL.md |

## What Was Built

### Task 1: academic.md Extended

The academic channel playbook now has three API integrations:

- **Section 2 (Tool Configuration):** Added API 2 — Crossref and API 3 — Unpaywall sub-entries with base URLs, authentication notes, response formats, and return descriptions. Updated description line from one to three APIs.

- **Section 3 (Query Templates):** Added four new templates after existing Template C:
  - Template D: Crossref Topic Search (relevance-sorted)
  - Template E: Crossref Author Search
  - Template F: Crossref DOI Lookup
  - Template G: Unpaywall OA Check with trigger condition (is_oa=false only)

- **Section 6 (Degradation):** Added Crossref degradation block (Tier 2 Tavily → Tier 3 WebSearch) and Unpaywall degradation block (skip silently, log channel status note, no retry, no fallback service). Updated unavailable criteria to mention api.crossref.org alongside api.openalex.org.

- **Section 7 (Rate Limits):** Added Crossref polite pool (50 req/s with mailto, ~1 req/s without) and Unpaywall (100,000 req/day with email parameter).

- **Section 8 (New — Deduplication and Priority Rules):** Specifies query order (OpenAlex first, Crossref second, Unpaywall third inline), DOI-based deduplication with OpenAlex priority, data merge rules for Crossref gap-filling, Unpaywall trigger and upgrade logic, and the channel status line format with Unpaywall upgrades counter.

- **Example Responses:** Added Crossref example JSON (with is-referenced-by-count field) and Unpaywall example JSON (with best_oa_location object) alongside the existing OpenAlex example.

### Task 2: discover/SKILL.md Step 5 Updated

Two targeted edits to Step 5 source status determination:

- **ACCESSIBLE bullet:** Added `Unpaywall \`best_oa_location.url\` present and non-null` immediately after `OpenAlex \`is_oa=true\`` in the known-open-access examples list.

- **DISCOVERED bullet:** Added sentence at end: "Academic papers with `is_oa=false` from OpenAlex or Crossref begin as DISCOVERED; Unpaywall lookup (per academic.md Section 8) may upgrade them to ACCESSIBLE inline during the same discovery pass if a legal OA copy is found."

No other sections of discover/SKILL.md were modified.

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None. Both files are reference/documentation assets with no data sources to wire.

## Threat Surface Scan

No new network endpoints, auth paths, or schema changes were introduced. The plan's threat model (T-13-01 through T-13-04) covers all surfaces touched:
- Crossref API responses are metadata-only (T-13-01: accept)
- Unpaywall URLs are presented for user review before any processing (T-13-02: accept)
- Degradation chains handle rate limiting via mailto/email params (T-13-03: mitigated in playbook)
- Email in API requests is standard academic API convention (T-13-04: accept)

## Self-Check: PASSED

- [x] `.claude/reference/discovery/channel-playbooks/academic.md` — exists, verified
- [x] `.claude/commands/research/discover/SKILL.md` — exists, verified
- [x] Commit 5ed14f1 — exists (Task 1)
- [x] Commit 0c127a6 — exists (Task 2)
- [x] `grep -c "api.crossref.org" academic.md` → 6 (>= 3 required)
- [x] `grep -c "api.unpaywall.org" academic.md` → 3 (>= 2 required)
- [x] `grep "Unpaywall" discover/SKILL.md | wc -l` → 2 (>= 2 required)
- [x] `grep "Deduplication and Priority" academic.md` → 1 match
- [x] Templates A, B, C still present in academic.md → 3 matches
