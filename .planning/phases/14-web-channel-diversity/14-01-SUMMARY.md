---
phase: 14-web-channel-diversity
plan: "01"
subsystem: discovery
tags: [exa, web-search, multi-api, deduplication, playbook]
dependency_graph:
  requires:
    - ".claude/reference/discovery/channel-playbooks/web-search.md (existing)"
    - ".claude/reference/discovery/channel-playbooks/academic.md (pattern reference)"
  provides:
    - "Exa neural search as parallel API 2 in web-search channel"
    - "URL-based deduplication rules for Tavily + Exa combined results"
    - "Source attribution tags [Tavily], [Exa], [Tavily+Exa]"
  affects:
    - ".claude/commands/research/discover/SKILL.md (status line format — Phase 14 plan 02 scope)"
tech_stack:
  added:
    - "Exa Search API (https://api.exa.ai/search) via Bash curl"
    - "EXA_API_KEY environment variable authentication"
  patterns:
    - "Multi-API parallel execution within single channel playbook (follows academic.md pattern)"
    - "Per-API independent degradation (skip silently on failure, do not cross-trigger)"
    - "URL exact-match dedup with primary-API priority (Tavily priority over Exa)"
    - "Inline source attribution tags following existing [Firecrawl fallback] idiom"
key_files:
  modified:
    - path: ".claude/reference/discovery/channel-playbooks/web-search.md"
      change: "Added Exa API 2 config (Section 2), Templates D/E/F (Section 3), Exa degradation (Section 6), Exa rate limits (Section 7), and new Section 8 dedup/attribution rules"
decisions:
  - "Exact URL match only — no normalization, no title similarity. Simple contract, consistent with discover skill Step 4."
  - "Tavily priority in dedup — Exa metadata discarded on collision, pure collapse (no enrichment unlike academic.md Crossref fill)."
  - "Independent degradation paths — Exa failure does not trigger Tavily fallbacks and vice versa (D-13)."
  - "useAutoprompt: true in all Exa templates — lets Exa refine semantically, maximizes neural search value."
metrics:
  duration: "2m 9s"
  completed_date: "2026-04-20"
  tasks_completed: 2
  tasks_total: 2
  files_modified: 1
---

# Phase 14 Plan 01: Web-Search Channel Exa Integration Summary

**One-liner:** Extended web-search.md with Exa neural search as API 2 alongside Tavily, including tool config, three query templates (D/E/F), independent degradation, rate limits, and a new Section 8 with URL-based dedup rules and [Tavily]/[Exa]/[Tavily+Exa] source attribution tags.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Add Exa tool config, templates, degradation, rate limits | 90bb663 | web-search.md (+112 lines) |
| 2 | Add Section 8 deduplication and source attribution | f6c6e84 | web-search.md (+44 lines) |

## What Was Built

### Task 1 Changes
- **Frontmatter & Section 1:** Updated `description` field and channel overview description to reference "Exa neural search" alongside Tavily.
- **Section 2 (Tool Configuration):** Added `API 2 — Exa (Secondary, Neural Search)` block with base URL, `EXA_API_KEY` auth, and parameter table (`query`, `numResults: 8`, `type: auto`, `useAutoprompt: true`, `startPublishedDate`, `category`).
- **Section 3 (Query Templates):** Added three Exa curl-based templates:
  - Template D: Topic Search (neural, broad coverage)
  - Template E: Entity Search (with optional `category` bias)
  - Template F: Recent Search (with `startPublishedDate` and `"news"` category)
- **Section 6 (Degradation):** Added independent Exa degradation subsection — skip silently on API key absent / HTTP 5xx / timeout > 15s / HTTP 429 / non-zero curl exit. Does not trigger Tavily fallbacks.
- **Section 7 (Rate Limits):** Added Exa entry (1,000 searches/month free tier, 429 → degradation).

### Task 2 Changes
- **Section 8 (New):** URL-based dedup rules following academic.md Section 8 pattern:
  - Query order: Tavily first, Exa second
  - Dedup key: exact URL string equality (no normalization)
  - Tavily priority: winning entry keeps Tavily metadata; Exa match silently dropped and tagged `[Tavily+Exa]`
  - No data merge (simpler than academic.md's Crossref enrichment)
  - Source attribution tags: `[Tavily]`, `[Exa]`, `[Tavily+Exa]` — appear after status tag, before title
  - Combined status line: `Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3}) [degraded: {list}]`
  - Exa-only mode and Tavily-only mode degradation scenarios documented

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None. All content is complete and functional documentation. Template placeholder labels (e.g., `{topic}`, `{entity_name}`) are intentional substitution markers in query templates, not implementation stubs.

## Threat Flags

The Exa API endpoint and EXA_API_KEY are new trust boundary additions. Both are covered by the plan's threat model (T-14-01 through T-14-04) and mitigation notes are documented inline in the playbook. No unplanned threat surface introduced.

## Self-Check: PASSED

- `.claude/reference/discovery/channel-playbooks/web-search.md` exists and contains all required content
- Commit 90bb663 exists (Task 1)
- Commit f6c6e84 exists (Task 2)
- `grep "API 2 — Exa" web-search.md` — 1 match
- `grep -c "Template [DEF]"` — 3 matches
- `grep "Deduplication and Priority" web-search.md` — 1 match
- `grep "[Tavily+Exa]" web-search.md` — 4 matches
- `grep "Exa degradation" web-search.md` — 2 matches
- `grep -c "Template [ABC]"` — 3 matches (existing templates untouched)
