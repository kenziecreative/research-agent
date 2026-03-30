# Research Agent

## What This Is

A Claude Code tool that scaffolds and guides structured, evidence-based research projects. Users pick a research type and topic, the system generates a phased research plan grounded in preliminary web research, then guides them through a disciplined collect-connect-assess-synthesize-verify cycle for each phase. Every claim in the final output traces back to a specific source, every number is canonically tracked, and an integrity agent watches for fabrication and drift on every write.

## Core Value

Every claim in the research output must trace to a specific, credibility-assessed source. If it can't be traced, it doesn't ship.

## Requirements

### Validated

Shipped in v1.0:

- ✓ Project scaffolding with type-aware research plans (9 research types) — v1.0
- ✓ Source processing with credibility assessment and author verification — v1.0
- ✓ Cross-referencing with pattern strength assessment — v1.0
- ✓ Gap analysis with coverage status definitions — v1.0
- ✓ Summarize-to-audit-to-promote pipeline with hard gates — v1.0
- ✓ Phase navigation (start-phase, phase-insight, progress) — v1.0
- ✓ Audience & evidence standard calibration — v1.0
- ✓ Canonical figures registry for cross-phase number tracking — v1.0
- ✓ Research integrity agent (post-write drift detection) — v1.0
- ✓ Guardrails and failure mode tables for all 9 skills — v1.0
- ✓ Reference files for evidence failure modes, pattern recognition, source assessment, coverage assessment — v1.0
- ✓ PreToolUse hooks blocking unaudited writes to outputs/ — v1.0
- ✓ PreCompact hook enforcing STATE.md freshness — v1.0

Shipped in v1.1:

- ✓ Channel playbooks for 6 channel types with query construction, credibility tiers, degradation chains — v1.1
- ✓ Type-channel maps for all 9 research types routing phases to prioritized channels — v1.1
- ✓ `/research:discover` skill for type-aware multi-channel source discovery — v1.1
- ✓ Discovery strategy generated at init time mapping phases to channels — v1.1
- ✓ Init scaffolds discovery infrastructure (directory, strategy.md, CLAUDE.md) — v1.1
- ✓ Tools guide with discovery-specific patterns and channel-tool mapping — v1.1
- ✓ OpenAlex, EDGAR EFTS, ProPublica, Google Patents channel integrations — v1.1
- ✓ Graceful degradation when channels unavailable with explicit status reporting — v1.1

### Active

(None — define in next milestone via `/gsd:new-milestone`)

### Out of Scope

- Agent orchestration / automated phase-running — Human-in-the-loop between steps is a design choice, not a limitation
- Real-time data feeds or streaming sources — Research operates on point-in-time snapshots
- Paid API integrations that require user billing setup — All source channels must be free or use APIs the user already has configured
- Google Scholar integration — No API, blocks crawlers; OpenAlex covers the same material
- Auto-processing discovered sources — Human gate is a design choice; user must select which candidates to process

## Context

- Built on Claude Code with slash commands in `.claude/commands/research/`
- Uses Tavily MCP server for web search and content extraction
- v1.1 shipped structured multi-channel discovery: 6 channel playbooks, 9 type-channel maps, `/research:discover` skill
- Discovery channels: Tavily (web/financial/social/domain), OpenAlex (academic), EDGAR EFTS (regulatory filings), ProPublica (nonprofits), Google Patents (URL construction)
- Discover skill is a thin orchestrator — all channel intelligence lives in playbooks, not the skill
- Init generates per-project discovery strategy mapping phases to channels

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
| Audience calibration as 4th init question | Different audiences need different evidence standards | ✓ Good |
| Thin orchestrator pattern for discover skill | Channel intelligence in playbooks, not skill — easier to update channels independently | ✓ Good |
| Strategy.md express lane in discover | Pre-matched channels from init skip keyword guessing at discovery time | ✓ Good |
| Source status taxonomy in web-search.md | Canonical definition referenced by all playbooks prevents drift | ✓ Good |
| OpenAlex over Google Scholar for academic | Free API, no auth, no crawler blocks — same material covered | ✓ Good |
| Discovery as substep of Collect (soft rule) | Keeps 5-step cycle intact while advertising discover skill | ✓ Good |

---
*Last updated: 2026-03-30 after v1.1 milestone completion*
