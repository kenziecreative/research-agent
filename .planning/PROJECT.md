# Research Agent

## What This Is

A Claude Code tool that scaffolds and guides structured, evidence-based research projects. Users pick a research type and topic, the system generates a phased research plan grounded in preliminary web research, then guides them through a disciplined collect-connect-assess-synthesize-verify cycle for each phase. Every claim in the final output traces back to a specific source, every number is canonically tracked, and an integrity agent watches for fabrication and drift on every write.

## Core Value

Every claim in the research output must trace to a specific, credibility-assessed source. If it can't be traced, it doesn't ship.

## Current Milestone: v1.1 — Structured Source Discovery

**Goal:** Make the Collect step type-aware and multi-channel so the agent knows where to look for sources, not just how to process them once found.

**Target features:**
- Discovery playbooks per research type (mapping types to source channels)
- Structured multi-channel search sequences (web, academic, news, government, domain-specific)
- MCP/API integrations for specialized sources beyond web search
- `/research:discover` skill that orchestrates type-aware source discovery

## Requirements

### Validated

Shipped in v1.0:

- Project scaffolding with type-aware research plans (9 research types)
- Source processing with credibility assessment and author verification
- Cross-referencing with pattern strength assessment
- Gap analysis with coverage status definitions
- Summarize-to-audit-to-promote pipeline with hard gates
- Phase navigation (start-phase, phase-insight, progress)
- Audience & evidence standard calibration
- Canonical figures registry for cross-phase number tracking
- Research integrity agent (post-write drift detection)
- Guardrails and failure mode tables for all 9 skills
- Reference files for evidence failure modes, pattern recognition, source assessment, coverage assessment
- PreToolUse hooks blocking unaudited writes to outputs/
- PreCompact hook enforcing STATE.md freshness

### Active

(Defined in REQUIREMENTS.md)

### Out of Scope

- Agent orchestration / automated phase-running — Human-in-the-loop between steps is a design choice, not a limitation
- Real-time data feeds or streaming sources — Research operates on point-in-time snapshots
- Paid API integrations that require user billing setup — All source channels must be free or use APIs the user already has configured

## Context

- Built on Claude Code with slash commands in `.claude/commands/research/`
- Uses Tavily MCP server for web search and content extraction
- Currently, source discovery is limited to `tavily_search` (general web) — the agent has no structured way to search academic databases, government sources, news archives, patent databases, or other specialized channels
- The type-specific credibility hierarchies rank specialized sources (analyst reports, 990 filings, academic papers) higher than general web results, but the discovery mechanism can't find them
- The AI Anthropology Toolkit demonstrates the pattern we're building toward — separate discovery mechanisms per source type (OpenAlex, PubMed, Google Scholar, Google Patents, Google News, Google Trends, YouTube, podcast RSS)

## Constraints

- **No phantom commands:** Reference files, templates, and discovery playbooks must NOT live inside `.claude/commands/research/` — anything with `.md` there becomes a slash command
- **Channel availability:** Not all users will have all MCP servers or API keys configured. Discovery must degrade gracefully — skip unavailable channels, don't error
- **Existing workflow integration:** The discover skill feeds into the existing `/research:process-source` pipeline. It finds URLs; process-source does the structured extraction and note creation

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Commands in .claude/commands/research/ | Plugin structure didn't surface in autocomplete | ✓ Good |
| Reference files in .claude/reference/ | Avoids phantom commands, keeps domain knowledge accessible | ✓ Good |
| Hooks in .claude/settings.json | Merged from standalone hooks.json during restructure | ✓ Good |
| Audience calibration as 4th init question | Different audiences need different evidence standards | — Pending |
| All four discovery components together | Playbooks, sequences, integrations, and skill form a complete system | — Pending |

---
*Last updated: 2026-03-29 after v1.1 milestone start*
