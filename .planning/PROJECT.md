# Research Agent

## What This Is

A Claude Code tool that scaffolds and guides structured, evidence-based research projects. Users pick a research type and topic, the system generates a phased research plan grounded in preliminary web research, then guides them through a disciplined collect-connect-assess-synthesize-verify cycle for each phase. Every claim in the final output traces to a specific source, every number is canonically tracked, and an integrity agent watches for fabrication and drift on every write. The pipeline now catches contradictions, staleness, lopsided coverage, source laundering, and false triangulation before they reach the final output.

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

Shipped in v1.2:

- ✓ Contradiction detection with forced resolution gate before synthesis (XREF-01) — v1.2
- ✓ Saturation signals showing new vs. confirmatory findings with convergence advisory (XREF-02) — v1.2
- ✓ Shared-origin cluster detection preventing false triangulation (XREF-03) — v1.2
- ✓ Source staleness warnings with domain-differentiated thresholds (PIPE-01) — v1.2
- ✓ Confidence tier scoring (High/Moderate/Low/Insufficient) in audit-claims (PIPE-02) — v1.2
- ✓ Assumption lifecycle tracking (Open/Validated/Challenged) across phases (PIPE-03) — v1.2
- ✓ Counter-evidence gate for validation research types (PIPE-04) — v1.2
- ✓ Independent source counting with Direct/Adjacent/None classification (GAP-01) — v1.2
- ✓ Adjacent-vs-direct question matching in gap analysis (GAP-02) — v1.2
- ✓ Infrastructure health checks in progress output (INFRA-01) — v1.2

### Active

## Current Milestone: v1.3 Evidence Depth & Retrieval Integrity

**Goal:** Deepen evidence traceability from individual claims through cross-phase figures, expand index diversity for honest source counting, and make discovery reproducible.

**Target features:**
- Claim graph — claims as nodes with edges to source notes and canonical figures; transitive drift detection across phases
- Crossref + Unpaywall — academic channel expansion alongside OpenAlex for metadata gaps and legal OA copies
- Exa as parallel web-search tier — neural/semantic index diversity surfacing non-SEO sources
- Per-claim confidence propagation — weakest-link rollup from claims to section tiers
- Retrieval replay logging — query, channel, and URL logging per discovery call for reproducibility

### Out of Scope

- Agent orchestration / automated phase-running — Human-in-the-loop between steps is a design choice, not a limitation
- Real-time data feeds or streaming sources — Research operates on point-in-time snapshots
- Paid API integrations that require user billing setup — All source channels must be free or use APIs the user already has configured
- Google Scholar integration — No API, blocks crawlers; OpenAlex covers the same material
- Auto-processing discovered sources — Human gate is a design choice; user must select which candidates to process

## Context

- Built on Claude Code with slash commands in `.claude/commands/research/`
- Uses Tavily MCP server for web search and content extraction
- v1.2 shipped evidence quality gates: contradiction/saturation/laundering detection in cross-ref, staleness/confidence/assumptions in the synthesis pipeline, independence-aware gap analysis, infrastructure health visibility
- Discovery channels: Tavily (web/financial/social/domain), OpenAlex (academic), EDGAR EFTS (regulatory filings), ProPublica (nonprofits), Google Patents (URL construction)
- Discover skill is a thin orchestrator — all channel intelligence lives in playbooks, not the skill
- Init generates per-project discovery strategy mapping phases to channels
- Known tech debt: audit-claims staleness input lacks explicit Read instruction for type template (INT-01, advisory-only impact)

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
| Origin chain as required structured field | Deterministic shared-origin cluster matching in cross-ref | ✓ Good |
| 75% aggregate saturation threshold | Balances signal (convergence detected) with noise (premature advisory) | ✓ Good |
| Core vs peripheral contradiction classification | Only core contradictions block synthesis; peripheral noted as open questions | ✓ Good |
| Domain-differentiated staleness thresholds | 1 year (competitive) to 5 years (curriculum) reflects domain decay rates | ✓ Good |
| Confidence tier advisory-only (no gate) | Preserves user agency; tier visible but doesn't prevent promotion | ✓ Good |
| Weakest-link rule for document confidence | Overall confidence = lowest section tier; prevents hiding weak sections | ✓ Good |
| Counter-evidence gate per-phase (not just final) | Catches missing opposition early in validation research types | ✓ Good |
| Adjacent matches excluded from coverage status | Prevents inflated coverage; 3 Adjacent + 0 Direct = Not Started | ✓ Good |
| Lopsided advisory (not gate) | Consistent with staleness advisory pattern; warns but doesn't block | ✓ Good |
| Infrastructure checks read-only (no Bash) | Consistent with progress skill's allowed-tools constraint | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-20 — Phase 11 (Claim Graph Foundation) complete*
