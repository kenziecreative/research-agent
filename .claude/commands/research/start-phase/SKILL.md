---
name: start-phase
description: Show what's needed to begin the next research phase — questions, prior findings, and context
allowed-tools: Read, Grep, Glob
---

# /research:start-phase

Prepare to begin the next research phase by gathering all relevant context.

## Current State

!`cat research/STATE.md 2>/dev/null || echo "No STATE.md found — run /research:init first."`

## Pre-check: Source Material Reconciliation (mandatory)

Users sometimes drop files into `source-material/` mid-project. If an unprocessed drop is sitting there and you proceed to the next phase without integrating it, the phase framing will be wrong in the same way `/research:init` would have been wrong with an unread file at start.

1. **List `source-material/`** — enumerate every non-dotfile (ignore `.gitkeep`, `.DS_Store`, dotfiles).
2. **Read `research/source-material-digest.md`** if it exists. Extract the filename list from the "Files Read" table.
3. **Diff the two lists.** Before flagging any file as "new," cross-check it against the existing evidence base: search `research/sources/registry.md` for the filename and scan `research/notes/` for a source note whose URL/path field matches the file. If the file was already processed as a source in a prior phase (it has a registry row and a complete note), it is not actually new — the digest just wasn't updated when it was processed. In that case, silently add the file to the digest's "Files Read" table with read status "processed in Phase [N] — see research/notes/<note-filename>.md", do NOT prompt the user, and remove it from the "new files" list before continuing. Only files that are genuinely unprocessed (no registry entry, no note) reach the user prompt below.
   - **New files present in `source-material/` but not in the digest:** stop the phase briefing. Tell the user: "I found N new file(s) in source-material/ that weren't present when /research:init ran: [list]. Before starting Phase [N], these need to be integrated. Options: (a) run /research:process-source on each (they will be added to research/notes/ and the digest will be updated), (b) I can read them now and extend the digest without creating source notes — meaning I will read each new file in full and append any new named entities, dates, credentials, stated facts, and assumptions to the corresponding sections of `research/source-material-digest.md`. The digest's "Files Read" table gains a new row for each with read status "full". I will NOT create source notes in `research/notes/`, so these files remain raw source material — they are NOT citable in drafts until `/research:process-source` is run on them later. Contradictions with existing digest entries will be flagged explicitly rather than silently overwritten. or (c) mark them out of scope with a reason. Which do you want?" Do not present the phase briefing until the user chooses and the chosen action completes. For **option (c)**, the user must provide a concrete one-line reason in the format `Out of scope because <reason>`. The reason is recorded verbatim in the "Out of Scope" section of `research/source-material-digest.md` alongside the filename and date. If the user's reason is empty, vague ("not needed", "don't care"), or refers only to user state rather than the file ("I don't want to deal with it"), re-ask with a concrete prompt: "Tell me specifically why this file is out of scope — e.g., wrong language, duplicate of another file, superseded by a newer version, outside the research subject's scope, or not relevant to any current phase. The reason will be recorded verbatim in the digest." Do not accept the out-of-scope mark until the reason is concrete enough to explain the decision to a future reader who wasn't in this conversation. After integration, re-invoke the research-integrity agent against the updated plan and digest to confirm the new facts are reflected.
   - **Files in the digest but missing from `source-material/`:** warn but do not block. "The digest references [filename] but it is no longer in source-material/. The user may have moved or deleted it — flag if the plan still depends on it."
   - **Lists match exactly:** proceed to the Process section.
4. **If `research/source-material-digest.md` does not exist** but `source-material/` contains non-dotfiles: this is a project initialized before the digest convention existed, or init failed silently. Tell the user: "source-material/ contains files but there is no digest. I will read every file now and generate research/source-material-digest.md, then verify the existing plan against it using research-integrity. Proceed?" Wait for confirmation, then perform the same Step 2b/2c logic from `/research:init` (full read, structured digest), then run the integrity check against the existing plan.
5. **If `source-material/` is empty AND no digest exists:** this is the common case for projects that rely entirely on discovery. Skip this pre-check entirely and proceed to the Process section.

## Process

1. **Read `research/STATE.md`** to determine the current active phase.
2. **Read `research/research-plan.md`** to get the details for the next phase — its name, what needs to be validated/explored/analyzed, and the specific questions.
3. **Read `research/gaps.md`** to check if any gaps from previous phases are relevant to this phase.
4. **Read `research/cross-reference.md`** to identify any patterns from earlier phases that inform this one.
5. **Check for skipped or folded phases** in STATE.md. If any exist, report them to the user with context.
5a. **Read `research/assumptions.md`** (if it exists) and identify any Open assumptions whose "What would validate" or "What would challenge" criteria overlap with this phase's questions. An assumption is relevant if:
    - Its topic directly relates to a question this phase will investigate
    - This phase's source collection could plausibly produce evidence that validates or challenges it
    - It was logged in a prior phase (not the current one)
5b. **Read `research/gaps.md`** (if it exists) and extract the Coverage Dashboard for the current phase. If gaps.md has been generated for any prior phases, show a coverage snapshot so the user can see existing coverage status and lopsided flags before deciding what to collect.
5c. **Read `research/commonplace.md`** (if it exists) and scan it for entries from prior phases whose subject or observation overlaps with this phase's questions. Surface up to 3 most relevant entries as part of the briefing. Entries are indexed by date and phase in the H2 headers — use those plus the body text to judge relevance. An entry is relevant if its subject matches a question in the current phase, if it flagged a cross-cutting issue that affects the current phase, or if the user explicitly asked to remember something that connects to current work. If the file is empty or no entries are relevant, surface nothing — do not mention the commonplace book at all.

## Output

Present a briefing for the phase:

### Phase [N]: [Name]

**Questions to answer:**
- [List each question from the research plan for this phase]

**Relevant prior findings:**
- [Any findings from completed phases that connect to this phase's questions]
- [Any cross-reference patterns that are relevant]

**Gaps carried forward:**
- [Any unresolved gaps from previous phases that overlap with this phase]

**Coverage snapshot** (from last gap check):
- Total questions: N | Direct coverage: N | Lopsided: N | Adjacent-only: N
- [If lopsided flags exist] Questions with only 1 independent source: [list question text]
- [If adjacent-only matches exist] Questions with only adjacent matches (not counted as covered): [list question text]
- [If gaps.md does not exist] No gap check has been run yet. Run `/research:check-gaps` after processing sources.

**Open assumptions to revisit:**
- [Assumption description] (from Phase [N]): [basis]. Look for evidence that [what would validate/challenge].
- [If none] No open assumptions from prior phases relate to this phase's questions.

**Relevant commonplace entries:**
- [Date] — Phase [N] — [one-line hook from the H2 header]: [1-2 line summary of why it matters for this phase]
- [Only include this section if there are actually relevant entries. If commonplace.md is empty, does not exist, or has no entries relevant to this phase's questions, omit the section entirely — do not print a placeholder.]

**Skipped/Folded phases:** [List any, or "None"]

Then render the transition prompt (format defined in `.claude/reference/prompt-templates.md`):

───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:discover` — Find candidate sources for Phase [N]'s questions using the type-channel map.

**Also available:**
- `/research:process-source <url-or-file>` — Skip discovery and process a specific source you already have.
- `/research:progress` — See where you are in the overall project before deciding.

**What to expect:** Discovery will surface a prioritized candidate list for this phase's channels. After you approve, processing runs sequentially with a mandatory cross-reference checkpoint every 5-8 sources.

───────────────────────────────────────────────────────────

## Guardrails

1. Do not present a phase briefing if the previous phase's cycle is incomplete. Check STATE.md first — all five steps must be checked.
2. If STATE.md records skipped or folded phases, surface them explicitly before presenting the next phase's briefing.
3. Do not pre-collect sources or begin research as part of the briefing. This skill prepares context; source collection is a separate step.
4. Carry forward only documented gaps and cross-reference patterns — do not carry forward interpretations or conclusions from conversation history.
5. Do not silently skip `assumptions.md`. If the file exists and has Open entries, evaluate each against this phase's questions. Missing a relevant assumption means the user won't know to look for validating or challenging evidence.
6. If gaps.md exists, always show the coverage snapshot. Do not skip it even if coverage looks adequate — lopsided flags and adjacent-only matches are not obvious from source counts alone.
7. Do not silently skip `commonplace.md`. If the file exists and has entries from prior phases, scan them for relevance to the current phase. Missing a relevant entry means losing context the agent captured specifically so it would survive to this moment. If no entries are relevant, omit the section from the briefing — do not announce "no entries."

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Starting a phase before the previous one is complete | Read STATE.md's cycle checklist. If any step is unchecked, tell the user what remains before presenting the next phase. |
| Presenting stale prior findings from conversation memory instead of files | Read cross-reference.md and gaps.md fresh. Do not rely on what was discussed earlier in the session. |
| Overwhelming the briefing with prior-phase detail that obscures the current phase's questions | Keep prior findings to bullet points directly relevant to the new phase's questions. The full prior output is in research/outputs/ if needed. |
| Missing carried-forward gaps that affect the new phase | Always check gaps.md for unresolved items from prior phases. An unresolved gap about market size from Phase 2 matters if Phase 5 asks about revenue projections. |
| Ignoring prior assumptions that this phase could resolve | Always read `assumptions.md` if it exists. For each Open assumption, check whether this phase's questions could produce evidence that validates or challenges it. An assumption about market size from Phase 2 is relevant if Phase 5 asks about revenue projections. |
| Ignoring prior commonplace entries at phase start | Always read `commonplace.md` if it exists. Prior observations may flag cross-cutting issues, strategic context, or user-requested reminders that apply to this phase. The file exists specifically so these survive context clears — using it is the whole point. Surface up to 3 relevant entries; omit the section entirely if none apply. |
| Skipping coverage snapshot when gaps.md exists | Always read and display gaps.md coverage data if the file exists. Lopsided coverage and adjacent-only matches are invisible without it — the user needs this to decide what sources to pursue. |
| Skipping source-material reconciliation and starting a phase with an unprocessed user drop | Always diff `source-material/` against `source-material-digest.md` before presenting the phase briefing. A new file is a blocker, not a warning — the phase framing depends on its contents being integrated first. |

This skill is read-only — it does NOT write any files.
