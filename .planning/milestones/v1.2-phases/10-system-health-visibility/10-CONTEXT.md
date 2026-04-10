# Phase 10: System Health Visibility - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Add infrastructure health checks to the existing `/research:progress` skill so the user can confirm the research system is intact before reviewing project status. All changes modify the existing progress skill — no new commands. Any infrastructure issue is surfaced as a named failure, not a silent omission.

Requirements: INFRA-01 (infrastructure health status at top of progress output).

</domain>

<decisions>
## Implementation Decisions

### Health check scope
- Fixed set of 5 checks, hardcoded — no extensible registry pattern. If more checks are needed later, the skill is modified directly
- **Hooks active**: Verify that specific hooks exist in `.claude/settings.json` — PreToolUse with Write matcher, PreToolUse with Edit matcher, and PreCompact hook. Checks for correct matchers, not deep command string validation
- **JSON valid**: Read `.claude/settings.json` and confirm it parses as valid JSON with expected structure
- **STATE.md structurally sound**: Confirm YAML frontmatter exists and contains required fields (milestone, status, progress) — does not validate field values, just structural presence
- **Reference files present**: Check for specific known files: coverage-assessment-guide.md, evidence-failure-modes.md, pattern-recognition-guide.md, source-assessment-guide.md, tools-guide.md, writing-standards.md, plus templates/ directory
- **Discovery strategy present**: Check for research project's discovery strategy file when a research project exists

### Failure presentation
- Each failure shows name + description of what's missing and why it matters. E.g., "PreToolUse Write hook missing from .claude/settings.json — this hook prevents unaudited writes to outputs/"
- No fix snippets — describe what should exist, not the exact config to add (avoids drift)
- Flat pass/fail — no severity tiers. With 5 checks, severity adds overhead without value
- **All-pass display**: Compact single line — "Infrastructure: 5/5 checks passed". No individual check listing when everything is fine
- **Partial-failure display**: Summary line "Infrastructure: 3/5 checks passed" then list only the failures with fix descriptions. Passing checks not listed individually

### Placement in progress output
- After project title/header, before the phase status table — natural reading order: what project → is it healthy → where are we
- Runs every time progress is called — health checks are cheap file reads, no caching
- Visually distinct: `### Infrastructure Health` section header with horizontal rule separator after, consistent with existing markdown header usage in progress

### Failure behavior
- Warn and continue — show health failures, then display full progress output below. Advisory pattern consistent with Phase 8 staleness warnings and Phase 9 lopsided coverage warnings
- **Next action affected**: If health failures exist, the "Next action" line prioritizes fixing infrastructure ("Fix infrastructure issues above before continuing") with the research next-action shown after. Nudges without blocking
- No hard block — user always sees their project status regardless of health check results

### Claude's Discretion
- Whether to add Bash to the skill's allowed-tools for more robust JSON parsing, or keep Read/Grep/Glob only
- Exact formatting of the health section (table vs. list vs. inline)
- Check execution order
- How discovery strategy presence is detected (file path pattern)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `progress/SKILL.md`: Current skill reads STATE.md, counts files, reads research-plan.md, cross-reference.md, and gaps.md — health checks add a new step before the existing process
- `.claude/settings.json`: Contains the 3 hook entries (PreToolUse Write, PreToolUse Edit, PreCompact) that need verification
- `.claude/reference/`: Contains the 6 known reference files + templates/ and discovery/ directories

### Established Patterns
- Dashboard-at-top pattern (Phase 7 cross-ref, Phase 9 gaps.md) — health section follows this pattern within progress output
- Advisory warning pattern (Phase 8 staleness, Phase 9 lopsided) — health failures warn but don't block
- Named failure pattern: requirement explicitly says "named failure, not silent omission" — each check has a name and a fix description
- Progress skill is read-only with Read/Grep/Glob tools — health checks should ideally maintain this constraint

### Integration Points
- `progress/SKILL.md`: Only file to modify — add health check step to the process, add health section to the output template
- `.claude/settings.json`: Read target for hook verification (not modified)
- `research/STATE.md`: Read target for structural validation (not modified)
- `.claude/reference/`: Glob target for file presence checks (not modified)

</code_context>

<specifics>
## Specific Ideas

- Compact all-clear line keeps progress output clean in the common case (healthy system) — verbosity only when something is wrong
- Fix descriptions explain WHY the check matters (e.g., "this hook prevents unaudited writes") not just WHAT is missing — helps the user prioritize
- The next-action nudge toward fixing infrastructure mirrors how a team lead would prioritize: fix the tooling first, then continue the work

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 10-system-health-visibility*
*Context gathered: 2026-04-03*
