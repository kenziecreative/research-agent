# Phase 9: Gap Analysis Depth - Context

**Gathered:** 2026-04-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Enhance `/research:check-gaps` so it reports per-question independent source counts with lopsided coverage flagging, and distinguishes genuine coverage from adjacent-but-not-direct matches. All changes are behavior modifications to existing skills — no new commands.

Requirements: GAP-01 (independent source counting + lopsided flagging), GAP-02 (close-enough match detection).

</domain>

<decisions>
## Implementation Decisions

### Independence counting (GAP-01)
- Reuse the origin_chain field from process-source notes (added in Phase 7) to determine source independence — sources sharing the same origin collapse to one independent data point
- Lopsided coverage flag triggers when a question has only 1 independent source (absolute threshold, not relative ratio) — consistent with coverage guide's "thin — single source" risk level and Phase 8's rule that single-source can't be High confidence
- Non-independent sources presented via collapse + footnote: main count shows independent sources only, footnote lists the non-independent sources and their shared origin
- Coverage status (Partial/Complete/Not Started) calculated using independent source count only — 3 sources sharing one origin = 1 independent = Partial, not Complete

### Close-enough detection (GAP-02)
- Three-tier match classification: Direct (source substantively answers the question), Adjacent (source addresses a related topic but not the specific question), None
- Adjacent matches do NOT count toward coverage status — a question with 3 adjacent sources and 0 direct is still "Not Started"
- Adjacent matches displayed under each question's direct source list, with a brief one-line explanation: "Addresses [actual topic] rather than [phase question]" — helps user judge the gap
- Coverage assessment guide updated to reflect the three-tier system (Direct/Adjacent/None) as the single source of truth

### Coverage output format
- Brief dashboard at top of gaps.md: total questions, questions with direct coverage, lopsided flags count, adjacent-only matches count — consistent with cross-ref dashboard pattern from Phase 7
- Per-question detail: question heading + coverage status + independent source count, then list of direct sources (with citations), then adjacent sources (with explanation)
- Full regeneration each run — read all notes and rebuild gaps.md, consistent with Phase 7 cross-ref pattern. No incremental updates, no stale entries

### Pipeline integration
- phase-insight reads enhanced gaps.md to surface independent source counts and adjacent matches in its analysis — richer output with no new data collection
- summarize-section warns (but does not block) when synthesizing a section with lopsided coverage — consistent with Phase 8's advisory pattern for staleness
- start-phase shows the phase's coverage snapshot from gaps.md (if it exists) — coverage status + lopsided flags visible before collecting
- Adjacent matches are advisory only — no automatic coupling to discover skill. User reads them and decides whether to adjust discovery terms

### Claude's Discretion
- Exact format of the dashboard summary
- How the footnote for non-independent sources is structured
- Per-question heading/section formatting details
- How phase-insight integrates gaps.md data into its existing output format
- How start-phase presents the coverage snapshot alongside its current output

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `check-gaps/SKILL.md`: Current gap analysis skill — already reads research plan, source notes, and outputs; produces gaps.md with per-phase coverage status
- `coverage-assessment-guide.md`: Defines coverage status labels (Complete/Partial/Not Started/Addressed but unbalanced) and source diversity requirements — will be updated with Direct/Adjacent/None classification
- `pattern-recognition-guide.md`: Echo level already handles same-origin collapse — check-gaps independence counting follows the same logic
- `source-assessment-guide.md`: Primary/secondary source chain tracking — basis for origin chain field

### Established Patterns
- Origin chain field in process-source notes (Phase 7) — check-gaps reads this for independence determination
- Full regeneration pattern (Phase 7 cross-ref) — check-gaps follows the same read-all-notes-and-rebuild approach
- Dashboard-at-top pattern (Phase 7 cross-ref) — gaps.md gets the same quick-summary header
- Advisory warning pattern (Phase 8 staleness) — summarize-section warns on lopsided coverage without blocking

### Integration Points
- `check-gaps/SKILL.md`: Main skill to enhance — new independence counting, three-tier matching, dashboard, per-question detail format
- `coverage-assessment-guide.md`: Update with Direct/Adjacent/None classification
- `phase-insight/SKILL.md`: Reads gaps.md for coverage quality data
- `summarize-section/SKILL.md`: New pre-check — warn on lopsided coverage
- `start-phase/SKILL.md`: Show coverage snapshot from gaps.md when starting a phase

</code_context>

<specifics>
## Specific Ideas

- Independence counting reuses the exact same origin chain data that cross-ref uses for laundering detection — no new data model, just a different consumer of the same field
- Adjacent matches serve as research leads — they tell the user "you're close, but this source doesn't quite answer your question" rather than silently inflating coverage
- The advisory-not-blocking pattern is consistent across the milestone: staleness warns (Phase 8), lopsided coverage warns (Phase 9), only contradictions and counter-evidence hard-block

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 09-gap-analysis-depth*
*Context gathered: 2026-04-03*
