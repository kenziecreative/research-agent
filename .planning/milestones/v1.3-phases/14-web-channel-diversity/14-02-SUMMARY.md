---
phase: 14-web-channel-diversity
plan: "02"
subsystem: discovery
tags: [exa, web-search, skill, dual-tool, deduplication, parallel-execution]
dependency_graph:
  requires:
    - ".claude/reference/discovery/channel-playbooks/web-search.md (plan 01 output with Section 8)"
    - ".claude/commands/research/discover/SKILL.md (existing Web Search subsection)"
  provides:
    - "discover/SKILL.md Web Search subsection with dual-tool (Tavily + Exa) execution documentation"
    - "Execution order, dedup rules, combined status line, independent degradation paths in skill"
  affects:
    - "discover skill orchestrator — now knows to run Exa after Tavily and report combined results"
tech_stack:
  added: []
  patterns:
    - "Skill references playbook for dedup rules (cross-tool deduplication per web-search.md Section 8)"
    - "Independent degradation documentation in skill matches playbook pattern"
key_files:
  modified:
    - path: ".claude/commands/research/discover/SKILL.md"
      change: "Web Search subsection expanded from 12 lines to 34 lines with dual-tool execution, Exa params, cross-tool dedup, combined status line, and independent degradation"
decisions:
  - "Kept Tavily fallback chain label as 'unchanged' to signal it is deliberately untouched by Exa addition"
  - "Referenced web-search.md Section 8 directly in skill rather than duplicating dedup rules inline"
metrics:
  duration: "3m"
  completed_date: "2026-04-20"
  tasks_completed: 1
  tasks_total: 1
  files_modified: 1
---

# Phase 14 Plan 02: Discover SKILL.md Exa Integration Summary

**One-liner:** Extended discover/SKILL.md Web Search subsection with Exa as parallel secondary tool — execution order, EXA_API_KEY auth, cross-tool dedup reference, combined status line format, and independent degradation documented.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Extend discover/SKILL.md Web Search subsection with Exa parallel execution | 4feaafb | SKILL.md (+24 lines net, -2 lines replaced) |

## What Was Built

Replaced the 12-line Web Search subsection in `discover/SKILL.md` (lines 314–324) with an expanded 34-line version documenting:

- **Secondary tool declaration:** `Exa Search API (via Bash curl to https://api.exa.ai/search)` added after the primary tool line
- **Execution order:** Explicit Tavily-first/Exa-second order, 8-result cap per tool, maximum 16 pre-dedup candidates from web search
- **Tavily execution parameters:** Unchanged from original, relabeled under `**Tavily execution parameters**` heading
- **Exa execution parameters:** EXA_API_KEY auth, `auto` search type, numResults 8, useAutoprompt true, optional startPublishedDate and category
- **Cross-tool deduplication:** References web-search.md Section 8, exact URL equality dedup key, Tavily priority, [Tavily+Exa]/[Tavily]/[Exa] attribution tags
- **Combined status line:** `Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3}) [degraded: {list}]`
- **Tavily fallback chain:** Retained unchanged (Firecrawl → WebSearch), labeled "(unchanged)"
- **Exa degradation:** Skip silently on absent key or error, log one-line note, independent from Tavily fallbacks

All other subsections (Financial, Social Signals, Domain-Specific, Academic, Regulatory) are unchanged.

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None. All content is complete documentation. Template placeholder labels (e.g., `{N}`, `{n1}`) are intentional status-line format markers, not implementation stubs.

## Threat Flags

None. This plan modifies orchestration documentation only (per plan threat model). The EXA_API_KEY reference follows the same documentation-only pattern already used for TAVILY_API_KEY elsewhere in the file. No new trust boundary surface introduced.

## Self-Check: PASSED

- `.claude/commands/research/discover/SKILL.md` exists and contains all required content
- Commit 4feaafb exists (Task 1)
- `grep "Secondary tool: Exa Search API"` — 1 match
- `grep "Execution order:"` — 1 match (with "Tavily first" and "Exa second")
- `grep "EXA_API_KEY"` — 2 matches (params + degradation)
- `grep "Cross-tool deduplication"` — 1 match
- `grep "Web Search:.*Tavily:.*Exa-only:.*deduped:"` — 1 match
- `grep "Exa degradation:"` — 1 match with "skip silently"
- `grep "Tavily fallback chain"` — 1 match referencing Firecrawl and WebSearch
- `grep "### Financial"` — 1 match (no collateral damage)
- `grep -c "### Web Search"` — 1 (no duplication)
- `grep -c "Exa"` — 9 (well above the 5 minimum threshold)
