# Project Research Summary

**Project:** research-agent v1.1 — Structured Multi-Channel Source Discovery
**Domain:** Prompt-driven Claude Code research tool enhancement
**Researched:** 2026-03-28
**Confidence:** MEDIUM-HIGH

## Executive Summary

This milestone adds structured multi-channel source discovery to an existing Claude Code research tool. The current system has solid source-processing infrastructure (process-source, cross-ref, audit-claims, check-gaps skills) but its discovery mechanism is limited to general Tavily web search, which cannot reliably surface SEC filings, academic papers, patent records, or government datasets. The v1.1 work adds a `/research:discover` skill that routes each research type to the channels where its highest-credibility sources actually live, then surfaces a prioritized candidate list for the researcher to review before ingesting.

The recommended implementation approach is deliberately layered. Most of the intelligence belongs in reference files (channel playbooks and type-channel maps), not in the skill itself. The skill is a thin orchestrator that reads the appropriate playbook for the current research type, executes available channels in priority order, and writes a candidate file to `research/discovery/`. This keeps the skill auditable and changes to channel behavior isolated to playbook files rather than the skill definition. Critically, integration requires no new MCP servers — Tavily's existing `include_domains` and `topic` parameters cover most channels immediately, and the remaining specialized sources (OpenAlex, SEC EDGAR, PubMed, arXiv) are all reachable via direct HTTP through Bash, with no API keys required for basic use.

The primary risk in this milestone is not technical but architectural: scope creep in the discover skill (loading it with auto-processing, relevance scoring, and deduplication logic that belongs in playbooks or user judgment) and discovery-processing mismatch (surfacing paywalled or inaccessible sources as if they are processable). Both risks are well-understood and directly preventable through design decisions made before writing any files. The build order — reference infrastructure first, then the skill, then init modifications — is non-negotiable given that the skill references playbook files by path.

---

## Key Findings

### Recommended Stack

The stack is almost entirely determined by the existing tool's architecture: this is a prompt-driven Claude Code system with no application code. All new components are Markdown files (SKILL.md, reference files). The only external services being added are HTTP APIs called via Bash or Tavily tools already in place.

Tavily is the load-bearing integration. Its `include_domains` parameter alone unlocks academic-adjacent, government, and domain-specific channel scoping without any new configuration. The `topic` parameter provides built-in news and finance channels. Direct HTTP (curl via Bash) covers the remaining high-value sources: OpenAlex (240M works, no auth), Semantic Scholar (200M papers, CS/AI strength), PubMed E-utilities (35M biomedical citations), arXiv (2M preprints), SEC EDGAR EFTS (all public company filings), and ProPublica Nonprofit Explorer (990 data). APIs requiring free registration keys — Census, BLS, PatentsView, FRED — are optional enhancements that degrade gracefully when absent.

**Core technologies:**
- Tavily MCP (already installed): Primary discovery channel — domain scoping, topic channels, extract — covers most research types immediately
- OpenAlex HTTP API: Academic paper discovery, 240M+ works, no auth, 100k req/day — use for any research type where peer-reviewed evidence matters
- SEC EDGAR EFTS HTTP API: Full-text filing search, no auth — essential for company, person, and non-profit research types
- Semantic Scholar HTTP API: Academic discovery with stronger CS/AI coverage — complements OpenAlex for technical research types
- PubMed E-utilities HTTP API: Authoritative biomedical source — use for health, medical, and life science research types
- arXiv HTTP API: Preprints in CS, AI, physics, math — important for cutting-edge technology research where papers precede publication by 6-12 months
- ProPublica Nonprofit Explorer API: 990 data, no auth — required for company-non-profit research type

**Explicitly not building:**
- Google Scholar integration (no API, blocks crawlers — OpenAlex/Semantic Scholar cover the same material)
- Google Trends integration (unofficial API, fragile, actively rate-limited — document as a manual URL step instead)
- Academic or government MCP servers (direct HTTP is simpler and more reliable than community-maintained servers)
- NewsAPI.org (24-hour delay on free tier; Tavily `topic: "news"` is superior)

### Expected Features

**Must have (table stakes):**
- Discovery playbooks per research type — without type-aware routing, discovery is generic and misses the sources that matter most for each type's credibility hierarchy
- `/research:discover` skill — the entry point that reads the playbook, executes available channels, and returns a prioritized candidate list
- Channel-specific query construction — SEC EDGAR, OpenAlex, and Tavily require fundamentally different query syntax; one format misses most of what each channel can find
- Graceful degradation when channels are unavailable — must degrade to Tavily-only if no other tools are configured, with explicit reporting of which channels were skipped
- Candidate file output to `research/discovery/` — not to `research/notes/` (which other skills read); discovery scaffolding must be kept separate from processed source notes
- Hand-off to existing process-source pipeline — discover stops at a URL list; user selects which to process; existing pipeline is unchanged

**Should have (differentiators):**
- EDGAR EFTS integration — dramatically improves company, person, and non-profit research; no key required; high value, low friction
- OpenAlex integration — unlocks academic discovery for thesis, curriculum, market, and presentation types
- Source status taxonomy (DISCOVERED / ACCESSIBLE / PROCESSED) — prevents process-source from being called on paywalled sources that silently return partial content
- ProPublica Nonprofit Explorer integration — structured 990 data, faster than EDGAR for non-profit type
- Google Patents URL construction pattern — no API; construct search URLs and use Tavily extract; useful for company, person, and PRD validation types
- Discovery strategy generated at init time — subagent maps each phase to its highest-value channels during project initialization
- Channel result count caps (5-8 per channel) — prevents academic API noise from overwhelming the researcher

**Defer to later milestone:**
- YouTube Data API integration — requires API key config; graceful skip if absent; useful for curriculum and person research but adds configuration friction
- Podcast RSS discovery — requires transcription infrastructure; high complexity, limited incremental value over YouTube + web search
- Semantic Scholar (full integration) — somewhat redundant with OpenAlex for non-biomedical fields; OpenAlex has better general coverage; add as enhancement after OpenAlex is working
- PACER court records — requires account, complex authentication, niche use case for person research
- Cross-channel deduplication — legitimate but complex (URLs don't deduplicate DOIs); defer until the basic multi-channel experience is validated

### Architecture Approach

The architecture follows the existing pattern precisely: reference files hold intelligence, skills are thin orchestrators that read those files at runtime. Discovery playbooks live in `.claude/reference/discovery/channel-playbooks/` (not in `.claude/commands/` — the phantom command risk is explicitly documented as a known constraint). Type-channel maps live in `.claude/reference/discovery/type-channel-maps/`. The discover skill reads both at runtime based on the current project's research type. Output goes to `research/discovery/<phase-slug>-candidates.md`, which is distinct from `research/notes/` where process-source writes. The init skill is modified to create the `research/discovery/` directory and generate a discovery strategy as part of project setup.

**Major components:**
1. Channel playbooks (6 files) — document query construction, result interpretation, credibility tier, tool to use, and graceful degradation instruction per channel type (web, academic, regulatory, financial, social signals, domain-specific)
2. Type-channel maps (9 files, one per research type) — map each phase of each research type to its highest-value channels; derived from existing credibility hierarchies in type templates
3. `/research:discover` SKILL.md — thin orchestrator; checks tool availability, reads type-channel map, reads relevant channel playbooks, executes searches, writes candidate file; must stay under ~150 lines
4. Init skill modifications — add `discovery/` directory to project structure, extend plan-generator subagent to produce a discovery strategy, update CLAUDE.md template and workflow description

### Critical Pitfalls

1. **Discovery-processing mismatch** — Academic APIs return DOIs that often point to paywalled journal gates, not open PDFs. Prevention: implement a source status taxonomy (DISCOVERED / ACCESSIBLE / PROCESSED) in discovery playbooks; check open-access status before surfacing a source to the user; label paywalled sources explicitly so the user is not surprised when process-source fails.

2. **Channel noise overwhelming the researcher** — Academic databases can return 200+ results for a keyword query. Prevention: hard cap at 5-8 sources per channel per query, embedded in the channel playbooks rather than improvised at runtime; rank by open-access availability, citation count, and recency; present enough metadata for 30-second triage per source.

3. **API fragility and silent degradation** — Rate limits, schema changes, and MCP server downtime produce empty or error results that look like "no sources found." Prevention: the discover skill must report channel status explicitly for every channel (found N / rate limited / error / skipped), making the distinction between "no sources exist" and "channel failed" visible.

4. **Scope creep in the discover skill** — Adding relevance scoring, auto-processing, deduplication, and automatic channel selection to the skill makes it unmaintainable and slow. Prevention: define the skill's job in one sentence before writing it; put all per-type intelligence into playbooks; resist adding features during first implementation; use the 150-line size limit as a forcing function.

5. **Phantom command placement** — Placing discovery playbooks inside `.claude/commands/research/` instead of `.claude/reference/` registers them as non-functional slash commands. Prevention: this is an architecture decision, not an implementation one — decide file locations before writing any files; verify by checking `.claude/commands/research/` contains only intended commands.

---

## Implications for Roadmap

Based on the research, the build order is deterministic from dependencies: reference infrastructure must exist before the skill references it by path; the skill must exist before init is updated to advertise it.

### Phase 1: Reference Infrastructure — Channel Playbooks
**Rationale:** Everything else depends on these files existing. The discover skill references them by path. The type-channel maps reference channel names. Writing playbooks first surfaces any gaps in channel knowledge before the skill is written.
**Delivers:** 6 channel playbooks in `.claude/reference/discovery/channel-playbooks/` — web-search, academic, regulatory, financial, social-signals, domain-specific. Each documents query construction, credibility tier, tool to use, and graceful degradation.
**Addresses:** Channel-specific query construction (table stakes), graceful degradation (table stakes), API fragility prevention (Pitfall 3), source status taxonomy for academic channels (Pitfall 1)
**Avoids:** Instructions drift (Pitfall 9) — establish stable section name contracts in this phase before the skill references them

### Phase 2: Reference Infrastructure — Type-Channel Maps
**Rationale:** Maps must reference channels by name; channel playbooks must exist first. 9 maps, one per research type. The intellectual work here is deriving channel priorities from the credibility hierarchies already documented in existing type templates — this is largely a translation exercise.
**Delivers:** 9 type-channel maps in `.claude/reference/discovery/type-channel-maps/` — one per research type, mapping each phase to primary and secondary channels
**Addresses:** Discovery playbooks per research type (table stakes)
**Avoids:** Over-engineering integrations (Pitfall 5) — apply "3+ research types benefit" test here; channels that only appear in 1-2 maps are deferral candidates

### Phase 3: The Discover Skill
**Rationale:** Depends on all playbooks and type-channel maps being in place. The skill reads these files by path — they must exist before the skill is finalized.
**Delivers:** `.claude/commands/research/discover/SKILL.md` — the new `/research:discover` slash command
**Addresses:** All table-stakes features — skill orchestration, tool availability check, channel execution, candidate file output, hand-off to process-source
**Avoids:** Scope creep (Pitfall 4) — write the one-sentence job definition first; keep under 150 lines; configuration burden (Pitfall 6) — Tavily-only path must work fully before any other channels are tested; context window bloat (Pitfall 11) — specify compact output format in this phase

### Phase 4: Init Modifications
**Rationale:** Init is modified last because it references the discover skill by name in the CLAUDE.md template and workflow description. The skill must exist before init advertises it.
**Delivers:** Updated `init/SKILL.md` with: `research/discovery/` in directory structure, discovery strategy generation in plan-generator subagent instructions, discover skill in CLAUDE.md skills table, discovery step in phase cycle workflow, discovery-strategy.md in verification checklist
**Addresses:** Discovery strategy at init time (differentiator), coherent new-project setup for users who will use discovery from day one
**Avoids:** Discovery for synthesis phases (architecture gap) — add explicit logic to skip discovery when invoked during a synthesis phase

### Phase 5: Tools Guide Update
**Rationale:** Self-contained reference update; does not gate anything else. Low risk, do last.
**Delivers:** Updated `tools-guide.md` with discovery-specific patterns — when to use tavily_search vs. tavily_extract for discovery vs. extraction, channel-specific tool recommendations
**Addresses:** Operational guidance for users and agents using the discovery system

### Phase Ordering Rationale

- Reference files before skill: the skill references playbook and type-channel map files by path; they must exist before the skill is written (otherwise the skill is written speculatively against files that may be structured differently).
- Channel playbooks before type-channel maps: maps reference channels by name; channel definitions must exist first to avoid speculative mapping.
- Skill before init modifications: init's CLAUDE.md assembly will advertise the discover command; the command should exist before it is advertised to users.
- Init before tools guide: the tools guide is standalone reference with no downstream dependencies; it can be updated at any point without risk.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3 (Discover Skill):** MCP tool availability detection pattern is MEDIUM confidence — verify whether Anthropic has added a formal availability API since August 2025 before finalizing the skill's availability-check block. Check current Claude Code documentation.
- **Phase 3 (Discover Skill):** Rate limits for OpenAlex, Semantic Scholar, and PubMed should be re-verified against current official documentation before the skill's instructions specify default result counts and per-session query budgets.
- **Phase 1 (Channel Playbooks):** The Tavily `include_domains` wildcard behavior (e.g., whether `*.gov` works as a subdomain wildcard) is unconfirmed — verify in implementation before documenting in the web-search playbook.

Phases with standard patterns (research-phase not needed):
- **Phase 2 (Type-Channel Maps):** Translation of existing credibility hierarchies into channel priority lists. The source material (type templates) is already written; this is a derivation task, not a research task.
- **Phase 4 (Init Modifications):** Well-defined scope derived from direct reading of the existing init SKILL.md structure. No unknowns.
- **Phase 5 (Tools Guide):** Reference update to an existing document; no new patterns to research.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Tavily parameters verified against official docs. Academic and government HTTP APIs are stable, well-documented open infrastructure. Explicit decision to avoid unstable integrations (Google Trends, Scholar, social media). |
| Features | HIGH | Channel-to-research-type mappings derived directly from existing credibility hierarchies already in the project. Table stakes features are structural requirements derivable from the current architecture's gaps. |
| Architecture | HIGH | File location decisions based on direct reading of existing code and the explicit phantom-command constraint. Discover/process-source separation is structural, not inferred. Build order follows hard file path dependencies. |
| Pitfalls | HIGH (architecture-specific), MEDIUM (API behavior) | Pitfalls derived from direct analysis of this codebase and the prompt-driven architecture. API rate limits and schema behavior are MEDIUM — based on training data; should be verified against current documentation before implementation. |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **Tavily wildcard domain behavior** — Whether `*.gov` works as a domain pattern in `include_domains` is unconfirmed. Test in implementation before documenting in playbooks; fall back to explicit domain lists if wildcards are not supported.
- **MCP tool availability detection** — The recommended pattern (state-machine-style tool-list check before acting) is based on training knowledge of Claude Code behavior. Verify against current official documentation before finalizing the discover SKILL.md. If Anthropic has added a formal availability API, prefer it.
- **Academic API current rate limits** — OpenAlex, Semantic Scholar, and PubMed rate limits documented in STACK.md are MEDIUM confidence. Verify current limits before the discover skill specifies per-session query budgets and result count defaults.
- **Stale candidate deduplication logic** — When discover is run partway through a phase (after some sources already processed), the candidate list may surface already-ingested sources. The deduplication logic (read registry before searching) needs to be specified in the SKILL.md; this design detail is not fully resolved in the research.
- **Discovery for synthesis phases** — The discover skill needs explicit logic to skip or warn when invoked during a synthesis phase. This edge case is identified but not designed in the research phase; address during skill writing.

---

## Sources

### Primary (HIGH confidence)
- Tavily docs (docs.tavily.com) — `include_domains`, `topic`, `time_range`, `search_depth` parameters; rate limit tiers; extract endpoint behavior
- Existing codebase (`.claude/commands/research/`, `.claude/reference/`) — architecture constraints, phantom command risk, skill separation of concerns, init structure
- FEATURES.md channel-to-type mappings — derived from existing type template credibility hierarchies (already in project)

### Secondary (MEDIUM confidence)
- OpenAlex API (training data, stable open API) — `api.openalex.org`, `/works` endpoint, filter syntax, rate limits
- Semantic Scholar API (training data) — `/graph/v1/paper/search`, citation fields, rate tiers
- PubMed E-utilities (training data, government API) — `esearch.fcgi`, `efetch.fcgi`, rate limits
- arXiv API (training data, stable) — `export.arxiv.org/api/query`, Atom/XML response, query syntax
- SEC EDGAR EFTS (training data, stable government API) — `efts.sec.gov/LATEST/search-index`, form type filters, free access
- ProPublica Nonprofit Explorer API (training data) — `/nonprofits/api/v2/organizations.json`, EIN lookups, 990 PDF links
- Census, BLS, PatentsView, FRED APIs (training data) — free-with-registration APIs for market/industry research types
- Google Patents URL construction pattern (training data) — no official API; URL parameter patterns

### Tertiary (LOW confidence)
- MCP server ecosystem (training data, August 2025 cutoff) — rapidly evolving; community academic/government MCP servers explicitly not recommended due to quality uncertainty; verify at modelcontextprotocol.io/servers before any MCP server additions
- Claude Code MCP tool availability detection pattern — verify against current Anthropic documentation; the state-machine-style check pattern reflects training knowledge, not verified current documentation

---
*Research completed: 2026-03-28*
*Ready for roadmap: yes*
