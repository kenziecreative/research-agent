# Architecture Patterns: Multi-Channel Source Discovery Integration

**Domain:** Prompt-driven Claude Code research tool (no code files — SKILL.md, reference files, agents)
**Researched:** 2026-03-28
**Scope:** Subsequent milestone — integrating structured multi-channel source discovery into existing architecture

---

## Existing Architecture (Baseline)

Before documenting new components, the current system has these structural properties:

```
.claude/
├── commands/research/          ← Slash commands (each dir = one /research:* command)
│   ├── init/SKILL.md
│   ├── process-source/SKILL.md
│   ├── cross-ref/SKILL.md
│   ├── check-gaps/SKILL.md
│   ├── audit-claims/SKILL.md
│   ├── summarize-section/SKILL.md
│   ├── start-phase/SKILL.md
│   ├── phase-insight/SKILL.md
│   └── progress/SKILL.md
├── agents/
│   └── research-integrity.md   ← Subagent, invoked by summarize-section
├── reference/                  ← Reference material (NOT commands — no phantom command risk)
│   ├── tools-guide.md
│   ├── source-assessment-guide.md
│   ├── evidence-failure-modes.md
│   ├── pattern-recognition-guide.md
│   ├── coverage-assessment-guide.md
│   ├── writing-standards.md    ← (copied to project at init time)
│   └── templates/
│       ├── types/              ← One file per research type
│       └── [shared templates]
├── settings.json               ← Hooks (PreToolUse output gate, PreCompact state guard)
└── settings.local.json         ← Permissions
```

The phantom command problem: Claude Code treats every directory under `.claude/commands/` as a slash command, regardless of whether a directory contains a SKILL.md. Any subdirectory created there registers as a command (and likely fails or produces confusing behavior when invoked). Reference material that is not a command must live outside `.claude/commands/`.

---

## Question 1: Where Do Discovery Playbooks Live?

**Recommendation: `.claude/reference/discovery/`**

This follows the exact pattern used for all other non-command reference material. The `reference/` directory already holds the tools guide, assessment guides, evidence failure modes, and type templates — all content that skills read at runtime rather than content that is itself a command.

```
.claude/reference/discovery/
├── channel-playbooks/
│   ├── web-search.md           ← Tavily search patterns, query construction
│   ├── academic.md             ← Scholar, arXiv, SSRN, PubMed patterns
│   ├── regulatory.md           ← SEC EDGAR, government databases, filings
│   ├── social-signals.md       ← GitHub stars/forks, Reddit, HN, LinkedIn signals
│   ├── financial.md            ← Crunchbase, PitchBook, earnings call patterns
│   └── domain-specific.md      ← Domain-specific databases by research type
└── type-channel-maps/
    ├── company-for-profit.md   ← Which channels for which phases of this type
    ├── market-industry.md
    ├── person-research.md
    └── [one per research type]
```

**Why this structure:**

The split between `channel-playbooks/` and `type-channel-maps/` reflects the two concerns. Channel playbooks answer "how do I search this channel" (query construction, result interpretation, credibility signals, known limitations). Type-channel maps answer "which channels matter for which phases of this research type" (a company research Phase 4 — financials — needs EDGAR and Crunchbase; a curriculum research Phase 2 — practitioner reality — needs LinkedIn, Reddit, and GitHub). Keeping them separate means channel playbooks are maintained once and referenced from multiple type maps.

Do not put discovery playbooks in `.claude/commands/` (phantom command risk) or inline them into the `discover` SKILL.md (the SKILL.md would become unmaintainably large and updating one channel would require editing the skill definition itself).

---

## Question 2: How Does `/research:discover` Interact With `/research:process-source`?

**Recommendation: Discover produces a prioritized URL list; process-source consumes it unchanged.**

The data flow should be:

```
/research:discover
    → reads: research-plan.md (current phase questions)
    → reads: STATE.md (current phase, sources processed so far)
    → reads: .claude/reference/discovery/type-channel-maps/<type>.md
    → reads: .claude/reference/discovery/channel-playbooks/<channel>.md (for each relevant channel)
    → executes: multi-channel searches via Tavily + available channels
    → writes: research/discovery/<phase-slug>-candidates.md
    → outputs: prioritized candidate list with channel, URL, why-relevant, estimated credibility tier

/research:process-source <url>
    → (unchanged — consumes any URL it's given)
```

The `discover` skill does NOT call `process-source` itself. It stops at a candidate list. The user reviews the candidates and runs `process-source` on each one they want to ingest. This separation preserves:

1. **User review gate.** Discovery may surface irrelevant or duplicate sources. The user should not be forced to process everything discovered before pruning.
2. **Existing process-source guardrails.** The cross-reference cap (halt at 5 sources without running `/research:cross-ref`) lives in `process-source`. If discover were to auto-process, it would need to replicate that logic or bypass it — either is bad.
3. **Single-responsibility.** Discover = find and prioritize. Process = ingest and structure. Audit = verify. These responsibilities are already cleanly separated; don't collapse them.

**What the candidate file contains:**

```markdown
# Discovery Candidates — Phase 3: [Phase Name]

**Generated:** [date]
**Phase questions:** [list from research-plan.md]
**Channels searched:** Tavily web, SEC EDGAR, Crunchbase
**Channels skipped:** Academic (not relevant for this phase), Social signals (Tavily unavailable)

## Tier 1 — High Priority (process first)

| # | URL | Channel | Why Relevant | Estimated Credibility |
|---|-----|---------|--------------|----------------------|
| 1 | [url] | SEC EDGAR | 10-K filing — Phase question 2 (revenue) | High |
| 2 | [url] | Tavily | Independent analyst report | High |

## Tier 2 — Secondary (process if Tier 1 has gaps)

...

## Tier 3 — Low Signal (process only if coverage remains thin)

...

## Not Pursued

- [channel]: [reason] (e.g., Crunchbase — company is public, SEC filings are better)
```

This candidate file is written to `research/discovery/` (a new directory to create at init time), not to `research/notes/`. It is discovery scaffolding, not a source note. The distinction matters because `process-source`, `cross-ref`, and `check-gaps` all read from `research/notes/` — they should not encounter unprocessed candidate lists there.

---

## Question 3: Where Does Channel-Specific Search Logic Live?

**Recommendation: Channel playbooks in `.claude/reference/discovery/channel-playbooks/`, invoked by the discover skill.**

Do not put channel-specific logic in the discover SKILL.md, and do not create per-channel agents.

**Why not inline in SKILL.md:**
The discover skill would become hundreds of lines long and each channel update would require editing the skill definition itself. More practically: the skill already has to conditionally apply channel logic based on what channels are available and relevant. Separating channel logic into playbooks means the skill reads only the playbooks that apply to the current context.

**Why not per-channel agents:**
An agent is appropriate when there is a judgment-intensive review step that benefits from isolation (the integrity agent is a good example — it makes pass/fail judgments that should not be entangled with the writing process). Searching a channel is not judgment-intensive in that way — it is a structured procedure with known inputs and outputs. Agents also add round-trip overhead that is unwarranted for what is essentially a lookup + search task.

**The pattern that works:**

The discover skill reads the type-channel map to know which channels to use for the current research type and phase, then reads each relevant channel playbook for the specific query patterns and result interpretation guidance, then executes the searches. This is the same pattern process-source uses with `source-standards.md` and `source-assessment-guide.md` — read the relevant reference file at runtime, apply its guidance to the task.

Each channel playbook should document:
- What this channel is good for (and what it is not)
- Query construction patterns for this channel's search syntax
- How to interpret results (what signals indicate high vs. low relevance)
- Credibility tier for this channel's output (e.g., SEC EDGAR filings are Tier 1; social signals are Tier 3 for most claims)
- Tool to use (Tavily search, Tavily extract with known URL pattern, WebFetch direct, or "not automatable — manual only")
- Graceful degradation instruction (what to note in the candidate file if this channel is unavailable)

---

## Question 4: MCP Tool Availability Detection

**Recommendation: Prompt-level availability check with explicit graceful degradation instructions.**

There is no runtime API in Claude Code for a SKILL.md to query "which MCP tools are available." The model knows which tools are in its tool list at invocation time — tools not available simply do not appear. The practical pattern for prompt-driven graceful degradation is:

**In the discover SKILL.md, include an explicit availability check block:**

```markdown
## Tool Availability Check (mandatory — run before any searches)

Before executing searches, verify which tools are in your available tool list:

- **If `tavily_search` is available:** Use it as the primary search mechanism for all web channels.
- **If `tavily_search` is NOT available but `WebSearch` is:** Use WebSearch for web channels. Note in the candidate file: "Tavily unavailable — used WebSearch. Search depth limited to basic."
- **If neither `tavily_search` nor `WebSearch` is available:** Do not attempt web search. Write to the candidate file: "Web search unavailable — no search tools in current session." Proceed with any channels that use direct URL access (Tavily extract, WebFetch) or that are manual-only.
- **If `tavily_extract` is available:** Use it for direct URL extraction (regulatory databases, known-URL sources like SEC EDGAR filings).
- **If `tavily_extract` is NOT available:** Fall back to WebFetch for direct URL access. Note in candidate file.

List which tools were available in the "Channels searched / Channels skipped" header of the candidate file.
```

This is the correct pattern because:

1. The model is told to check its own tool list before acting — this is something the model can reliably do.
2. Fallback instructions are explicit and ordered. The model does not have to improvise when a preferred tool is absent.
3. The candidate file records what was available, making the search reproducible (the user knows if results were limited).
4. No tool actually fails — the skill adjusts its behavior based on what it finds available, rather than attempting an unavailable tool and producing an error.

**For non-MCP channels (regulatory databases, academic databases accessed via known URLs):**

These are handled by Tavily extract or WebFetch against specific URLs, not by a dedicated MCP server. The availability check for these is simpler: if direct URL access tools are available, they work; if not, flag the channel as "manual only for this session."

**One important pattern to avoid:** Do not write conditional logic that tries to call a tool and catches the failure. Claude Code does not support try/catch at the prompt level. State-machine-style instructions ("check if available, then proceed or skip") are what works in SKILL.md files.

---

## Question 5: Updating Init for Type-Aware Discovery Strategies

**Recommendation: Extend the existing plan generator subagent to also produce a discovery strategy, written to `research/discovery/discovery-strategy.md`.**

The init skill already launches a subagent (model: sonnet) to generate the research plan. That subagent has the research type, topic, and type template. It is the right place to also produce the discovery strategy because it already has all the context needed.

**What the discovery strategy contains:**

```markdown
# Discovery Strategy: [Project Title]

## Channel Priority by Phase

| Phase | Primary Channels | Secondary Channels | Manual-Only Channels |
|-------|-----------------|-------------------|---------------------|
| 1. [name] | Tavily web, SEC EDGAR | Crunchbase | PitchBook (requires subscription) |
| 2. [name] | Academic, Tavily web | LinkedIn | Private databases |
...

## Channel Rationale

**Why SEC EDGAR for Phases 1, 3, 5:**
[specific rationale tied to phase questions]

**Why academic for Phase 6:**
[specific rationale tied to phase questions]

## Known Source Gaps

Sources likely to be important but limited for this topic/type:
- [source type]: [why limited]

## Discovery Cadence

Recommended: Run `/research:discover` at the start of each phase before collecting any sources. Use the candidate list to guide process-source calls for that phase only. Do not run discovery for future phases.
```

**Why not a separate init step or new question:** Adding a fifth init question about discovery channels would add friction without value — the user does not know which channels are optimal for their research type. The plan generator subagent can derive the right channel priorities from the type template's Source Credibility Hierarchy (which already specifies source types in priority order) and the specific phase questions. This is a generation task, not a user input task.

**What needs to change in init's Step 3 (Plan Generator Instructions):**

Add to the subagent's instructions:

```
After generating the research plan, also generate a discovery strategy using the channel
priority information from the type template's Source Credibility Hierarchy. Map each phase
to its highest-value channels based on what that phase is trying to answer.
Write the discovery strategy to `<project-root>/research/discovery/discovery-strategy.md`.
Create the `research/discovery/` directory if it does not exist.
```

**What needs to change in init's Step 2 (Directory Structure):**

Add `discovery/` to the directory tree:

```
research/
├── discovery/
│   ├── discovery-strategy.md   ← Generated at init time
│   └── [phase]-candidates.md   ← Generated by /research:discover per phase
```

**What needs to change in init's Step 4 (CLAUDE.md assembly):**

Add the discover skill to the Skills table in CLAUDE.md:

```
| Discover | `/research:discover` | Multi-channel source discovery for the current phase |
```

**What needs to change in init's Step 4 (Workflow):**

Update the phase cycle description to mention discovery as the first step within Collect:

```
1. **Collect** — Run `/research:discover` to generate a candidate list for the current phase.
   Review candidates, then use `/research:process-source` for each URL you want to ingest.
```

**What needs to change in init's Step 5 (Verify):**

Add to the verification checklist:
- `discovery/discovery-strategy.md` exists and contains a phase-to-channel mapping

---

## Question 6: Build Order

The components divide into three categories: new reference files, a new command, and modifications to existing commands/files. Dependencies determine order.

```
Phase 1 — Reference infrastructure (no dependencies, build first)
  1. .claude/reference/discovery/channel-playbooks/web-search.md
  2. .claude/reference/discovery/channel-playbooks/academic.md
  3. .claude/reference/discovery/channel-playbooks/regulatory.md
  4. .claude/reference/discovery/channel-playbooks/financial.md
  5. .claude/reference/discovery/channel-playbooks/social-signals.md
  6. .claude/reference/discovery/channel-playbooks/domain-specific.md

Phase 2 — Type-channel maps (depends on channel playbooks being written — you need to know
          what channels exist before mapping research types to them)
  7. .claude/reference/discovery/type-channel-maps/company-for-profit.md
  8. .claude/reference/discovery/type-channel-maps/market-industry.md
  9. .claude/reference/discovery/type-channel-maps/person-research.md
  10. .claude/reference/discovery/type-channel-maps/competitive-analysis.md
  11. .claude/reference/discovery/type-channel-maps/prd-validation.md
  12. .claude/reference/discovery/type-channel-maps/exploratory-thesis.md
  13. .claude/reference/discovery/type-channel-maps/presentation-research.md
  14. .claude/reference/discovery/type-channel-maps/curriculum-research.md
  15. .claude/reference/discovery/type-channel-maps/company-non-profit.md

Phase 3 — New discover skill (depends on playbooks and type-channel maps being in place
          because SKILL.md references them by path)
  16. .claude/commands/research/discover/SKILL.md

Phase 4 — Init modifications (depends on discover SKILL.md existing, because init now
          references it in CLAUDE.md and the workflow instructions)
  17. .claude/commands/research/init/SKILL.md  (modified)
       — Add discovery/ to directory structure (Step 2)
       — Add discovery strategy generation to subagent instructions (Step 3)
       — Add discover to Skills table in CLAUDE.md assembly (Step 4)
       — Add /research:discover to phase cycle in Workflow (Step 4)
       — Add discovery-strategy.md to verification checklist (Step 5)
       — Add discover skill to the skill list in Step 6 (Report)

Phase 5 — Tools guide update (minor, low risk, do last)
  18. .claude/reference/tools-guide.md  (modified)
       — Add channel-specific tool usage patterns relevant to discovery
       — Document when to use tavily_search vs. tavily_extract for discovery vs. extraction
```

**Build order rationale:**

- Channel playbooks before type-channel maps: maps reference channels by name; the channel definitions need to exist first or the maps will be speculative.
- Type-channel maps before the discover SKILL.md: the skill reads from these files by path; the paths need to be defined before the skill is written.
- Discover SKILL.md before init modifications: init's CLAUDE.md assembly will reference the skill by name; the skill should exist before init is updated to advertise it.
- Init modifications before tools guide: the tools guide is self-contained reference; it does not gate anything else.

---

## Component Summary: New vs. Modified

### New Components (16 files)

| Component | Path | Type |
|-----------|------|------|
| Web search playbook | `.claude/reference/discovery/channel-playbooks/web-search.md` | Reference file |
| Academic playbook | `.claude/reference/discovery/channel-playbooks/academic.md` | Reference file |
| Regulatory playbook | `.claude/reference/discovery/channel-playbooks/regulatory.md` | Reference file |
| Financial playbook | `.claude/reference/discovery/channel-playbooks/financial.md` | Reference file |
| Social signals playbook | `.claude/reference/discovery/channel-playbooks/social-signals.md` | Reference file |
| Domain-specific playbook | `.claude/reference/discovery/channel-playbooks/domain-specific.md` | Reference file |
| Type-channel map: company-for-profit | `.claude/reference/discovery/type-channel-maps/company-for-profit.md` | Reference file |
| Type-channel map: market-industry | `.claude/reference/discovery/type-channel-maps/market-industry.md` | Reference file |
| Type-channel map: person-research | `.claude/reference/discovery/type-channel-maps/person-research.md` | Reference file |
| Type-channel map: competitive-analysis | `.claude/reference/discovery/type-channel-maps/competitive-analysis.md` | Reference file |
| Type-channel map: prd-validation | `.claude/reference/discovery/type-channel-maps/prd-validation.md` | Reference file |
| Type-channel map: exploratory-thesis | `.claude/reference/discovery/type-channel-maps/exploratory-thesis.md` | Reference file |
| Type-channel map: presentation-research | `.claude/reference/discovery/type-channel-maps/presentation-research.md` | Reference file |
| Type-channel map: curriculum-research | `.claude/reference/discovery/type-channel-maps/curriculum-research.md` | Reference file |
| Type-channel map: company-non-profit | `.claude/reference/discovery/type-channel-maps/company-non-profit.md` | Reference file |
| Discover skill | `.claude/commands/research/discover/SKILL.md` | Command (new slash command) |

### Modified Components (2 files)

| Component | Path | What Changes |
|-----------|------|-------------|
| Init skill | `.claude/commands/research/init/SKILL.md` | Step 2 (dir structure), Step 3 (subagent instructions), Step 4 (CLAUDE.md, workflow), Step 5 (verify checklist), Step 6 (skill list) |
| Tools guide | `.claude/reference/tools-guide.md` | Add discovery-specific tool usage patterns |

### Unmodified Components

Everything else stays unchanged. In particular:
- `process-source` SKILL.md — unchanged. It consumes URLs; where those URLs come from is irrelevant to it.
- `research-integrity.md` agent — unchanged. It reviews notes and drafts; discovery candidates are not source notes.
- `settings.json` hooks — unchanged. The output gate and state guard hooks apply to all Write/Edit calls already.
- All type template files in `.claude/reference/templates/types/` — unchanged. They feed init; init now also generates a discovery strategy from them, but the templates themselves do not change.

---

## Data Flow: Discover to Process-Source

```
User: /research:discover

discover SKILL.md reads:
  ├── research/research-plan.md          (current phase questions)
  ├── research/STATE.md                  (active phase, which sources already processed)
  ├── research/sources/registry.md       (what sources already ingested — avoid duplicates)
  ├── research/discovery/discovery-strategy.md  (which channels to use for this type/phase)
  ├── .claude/reference/discovery/type-channel-maps/<type>.md  (phase-to-channel map)
  └── .claude/reference/discovery/channel-playbooks/<channel>.md  (per channel used)

discover executes:
  ├── Availability check (what tools are present in tool list)
  ├── For each available channel: run channel-specific searches
  └── Score and tier results (relevance to phase questions, estimated credibility)

discover writes:
  └── research/discovery/<phase-slug>-candidates.md

User reviews candidates, selects URLs to process.

User: /research:process-source <url-from-candidate-list>

process-source reads:
  ├── research/STATE.md  (cross-ref cap check — still enforced)
  ├── research/reference/source-standards.md
  └── .claude/reference/source-assessment-guide.md

process-source writes:
  ├── research/notes/<slug>.md
  └── research/sources/registry.md (updated)
```

The candidate file is an intermediate artifact, not a source note. It is written to `research/discovery/` to keep it out of the `research/notes/` directory that other skills read. The cross-ref cap (halt at 5 sources) continues to be enforced by `process-source` — `discover` does not touch that counter because it does not ingest sources.

---

## Confidence Assessment

| Area | Confidence | Basis |
|------|------------|-------|
| File location decisions | HIGH | Based on direct reading of existing code and the phantom command constraint, which is structural (not inferred) |
| discover ↔ process-source data flow | HIGH | Based on direct reading of all skill definitions and their existing separation of concerns |
| Channel logic in reference files vs. inline vs. agents | HIGH | Based on existing pattern (skills read reference files at runtime) applied consistently |
| MCP availability detection pattern | MEDIUM | Based on how Claude Code tool lists work (tools not in list simply aren't available) — no official documentation verified due to tool access restrictions in this session |
| Init modification scope | HIGH | Based on direct reading of init SKILL.md's five-step structure |
| Build order | HIGH | Dependencies are explicit and follow from which files reference which other files |

**Note on MCP availability detection (MEDIUM confidence):** The recommended pattern — "check your tool list before acting, state-machine-style instructions for fallback" — reflects how Claude Code operates from training knowledge and direct observation of how the existing tools-guide.md works. It cannot be verified against current official documentation in this session. If Anthropic has added a formal MCP availability API since August 2025, the pattern may have a better alternative. Validate against current docs before finalizing the discover SKILL.md.

---

## Gaps Not Resolved by This Research

1. **Candidate file promotion.** Should `research/discovery/<phase>-candidates.md` ever be referenced in `check-gaps` or `phase-insight`? The current design leaves those skills unchanged and does not surface discovery gaps (sources found but not processed). This may be a gap worth addressing in a follow-on milestone.

2. **Stale candidates.** If the user runs `/research:discover` partway through a phase (after some sources already processed), the candidate list may suggest sources already ingested. The design currently handles this by having discover read the registry before searching, but the deduplication logic needs to be specified in the SKILL.md.

3. **Discovery for synthesis phases.** Synthesis phases typically do not need new source discovery — they pull from existing notes. The discover skill needs explicit logic to skip or warn when invoked during a synthesis phase, rather than generating an irrelevant candidate list.

4. **Channel playbook maintenance strategy.** Channel-specific databases and search APIs change over time. There is currently no mechanism for flagging a channel playbook as stale or for notifying the user when a channel's URL patterns have changed (e.g., SEC EDGAR restructuring). This is low priority for the initial build but should be on the backlog.
