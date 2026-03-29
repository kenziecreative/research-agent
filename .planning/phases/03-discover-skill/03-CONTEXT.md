# Phase 3: Discover Skill - Context

**Gathered:** 2026-03-29
**Status:** Ready for planning

<domain>
## Phase Boundary

The `/research:discover` slash command that orchestrates type-aware, multi-channel source discovery. Reads the type-channel map for the project's research type, executes available channels in priority order, and outputs a reviewable candidate list. Discovery never auto-feeds into process-source — the user reviews and selects which candidates to process.

</domain>

<decisions>
## Implementation Decisions

### Invocation & input
- Auto-detect current phase from `research/STATE.md` — consistent with start-phase, process-source, cross-ref conventions
- If no phase is active in STATE.md, error with guidance: "No active phase. Run `/research:start-phase` first."
- If a candidates file already exists for the phase, append new results with a timestamp separator — preserves prior discovery work
- Deduplicate against existing candidates by URL before appending — skip duplicates, note "N duplicates skipped" in summary

### Candidate output format
- Output file at `research/discovery/<phase>-candidates.md` (per DISC-03)
- Summary table at top with per-channel counts and statuses (found N / skipped / error / degraded)
- Candidates grouped by channel (## Web Search, ## Academic, etc.)
- Each candidate entry includes: title, URL, status (DISCOVERED / ACCESSIBLE / PROCESSED), and a 1-2 sentence snippet describing what the source contains
- Degraded-channel results labeled inline: "via Tavily (OpenAlex fallback)" or "via WebSearch fallback"

### Channel execution & status reporting
- Per-channel status printed as it runs — real-time feedback: "Web Search: querying... found 6", "Academic: skipped (not configured)"
- On channel failure (rate limit, timeout, API error): log failure, continue with remaining channels, report in summary
- Degradation labeled inline on affected results (decided in Phase 1, confirmed here)
- After completion: suggest next steps — "Review candidates in research/discovery/<phase>-candidates.md. Process with `/research:process-source <url>`."

### Channel availability detection
- No pre-checks or introspection — the attempt is the check. Try the tool/API, handle failure inline
- Tavily: attempt call, if fails switch to WebSearch-only mode with prominent warning
- HTTP APIs (OpenAlex, EDGAR, ProPublica): run the query directly, treat errors as channel failure
- When Tavily unavailable: warn and continue automatically with WebSearch fallback. Label all fallback results. Don't pause to ask — consistent with "continue on failure" philosophy
- Absolute floor: WebSearch with domain-scoped queries from playbooks. If even WebSearch fails, produce empty candidates file with all-channels-failed status report

### Claude's Discretion
- Whether to support an optional channel filter argument (e.g., `--channel academic` for targeted re-runs)
- Query construction details — how to substitute research questions into playbook templates
- Exact status line formatting during execution
- How to determine ACCESSIBLE vs DISCOVERED status for each candidate
- File naming for the timestamp separator on re-runs

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.claude/reference/discovery/channel-playbooks/`: 6 playbooks with exact query templates, credibility tiers, degradation chains, and rate limits — the skill reads and executes these
- `.claude/reference/discovery/type-channel-maps/`: 9 maps with `active-channels` frontmatter and phase-keyword-grouped channel priorities — the skill reads these to determine which channels to query
- `.claude/reference/source-assessment-guide.md`: Credibility assessment patterns — not directly used by discover skill but relevant context
- `.claude/reference/tools-guide.md`: Existing Tavily tool documentation — skill follows these patterns for Tavily calls
- `.claude/commands/research/process-source/SKILL.md`: Established pattern for skill file structure with YAML frontmatter, pre-checks, guardrails, failure modes table

### Established Patterns
- Skills use YAML frontmatter (name, description, argument-hint, disable-model-invocation)
- Pre-checks are mandatory steps before main execution (process-source checks cross-ref count)
- STATE.md is the source of truth for active phase
- Guardrails section with numbered rules
- Common Failure Modes table with prevention columns
- Source registry at `research/sources/registry.md` — discover skill does NOT write here (that's process-source's job)

### Integration Points
- Reads `research/STATE.md` for active phase
- Reads `research/research-plan.md` for research questions (used in query construction)
- Reads type-channel map based on research type stored in project's CLAUDE.md
- Reads channel playbooks for query templates and degradation instructions
- Writes to `research/discovery/<phase>-candidates.md` — new directory, not existing notes/ or sources/
- Does NOT write to source registry or notes — that boundary belongs to process-source
- Uses Tavily MCP tools (tavily_search) and Bash HTTP (curl for OpenAlex, EDGAR, ProPublica)
- Falls back to WebSearch when Tavily unavailable

</code_context>

<specifics>
## Specific Ideas

- Execution feel should be like a build log — per-channel status lines appearing as channels execute, not a big dump at the end
- The skill is a "thin orchestrator" — channel intelligence lives in the playbooks, not the skill. The skill substitutes, executes, and formats
- Re-run behavior (append + dedup) supports iterative discovery across sessions without losing prior work

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-discover-skill*
*Context gathered: 2026-03-29*
