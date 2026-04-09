---
name: audit-claims
description: Fact-check a research draft against source notes and promote to outputs if it passes
argument-hint: "[filepath]"
---

# /research:audit-claims

Audit a research draft for unsupported claims. If the audit passes, promote the draft from `research/drafts/` to `research/outputs/`. If it fails, the draft stays in `drafts/` until issues are fixed and the audit is re-run.

## Input
The user will provide a filepath to audit (should be a file in `research/drafts/`).

## Process

1. **Read the file to audit.**
2. **Read `research/reference/source-standards.md`** for evidence rules.
3. **Read `research/reference/writing-standards.md`** for precision preservation and synthesis rules.
4. **Read `.claude/reference/evidence-failure-modes.md`** for the catalog of evidence degradation patterns. Check for each pattern type during the audit.
5. **For every factual claim in the document:**
   - Does it trace to a file in `research/notes/` or a previous phase output? If yes, note the source.
   - Is the claim accurately represented? Check against the source note — same numbers, same ranges, same qualifiers.
   - Is the confidence language appropriate given the number of supporting sources?
   - Are contradicting sources acknowledged?
   - Is dated information flagged if older than 2 years?
   - Are ranges preserved fully? (not narrowed, not midpointed)
   - Are qualifiers from the source preserved? (not dropped during compression)
   - If a number is carried from a previous phase, does it match the original exactly?
6. **Cross-document consistency check:** If other files already exist in `research/outputs/` or `research/drafts/`, check whether this draft and those documents cite the same numbers for the same claims. Flag any inconsistencies.
6a. **Canonical figures check:** Read `research/reference/canonical-figures.json`. For every number in the draft that exists in the canonical registry, verify it matches exactly. Flag any discrepancy as high-severity.
7. **Classify each issue found:**
   - **Unsupported claim** — No source note backs this up
   - **Misrepresented** — Source says something different than what's claimed
   - **Missing attribution** — Claim is supportable but citation is missing
   - **Stale data** — Information may be outdated
   - **Contradiction ignored** — Sources disagree but only one side is presented
   - **Range narrowed** — Source range was compressed or midpointed
   - **Qualifier dropped** — Source qualification was lost in compression
   - **Number drift** — Figure doesn't match the cited source
   - **Cross-document inconsistency** — Same claim, different figures across documents
8. **Generate audit scorecard:**
   - Total specific claims checked: N
   - Claims traced to source: N (X%)
   - Claims matching source value and context: N (X%)
   - Claims with appropriate qualifiers: N (X%)
   - Issues found: N mismatches, N unsourced, N drift, N range narrowed
   - Severity distribution: N high, N moderate, N low

   Section confidence tiers:
   - [Section name]: [Tier] — [brief rationale: e.g., "3 credible sources, direct evidence, no staleness"]
   - [Section name]: [Tier] — [brief rationale]

   Overall confidence: [Tier of lowest section] (weakest-link determines overall)

8a. **Compute per-section confidence tier:**

   For each section of the draft, assess four inputs and produce a named tier (High / Moderate / Low / Insufficient):

   **Four inputs:**
   1. **Source count** — How many independent sources back this section's claims? Map to pattern-recognition-guide levels: Claim (1 source), Emerging (2–3 sources), Pattern (4+ sources). Echo-level sources (dependent sources sharing a common origin as identified during cross-reference) count as one, not multiple.
   2. **Credibility tiers** — What is the highest credibility tier among the section's sources (from source-assessment-guide.md)? A mix of credibility tiers is stronger than uniform low-tier coverage.
   3. **Evidence directness** — Are sources directly addressing the claim, or are they adjacent/inferred? Direct = source explicitly states the finding. Indirect = finding is inferred from related data, extrapolated, or adjacent to the claim.
   4. **Staleness** — What proportion of the section's sources exceed the research type's staleness threshold (defined in the type template from process-source)? Majority stale = downgrade.

   **Confidence tier definitions:**
   - **High**: 4+ independent sources from credible tiers (official docs, analyst reports, peer-reviewed), majority direct evidence, no stale sources dominating
   - **Moderate**: 2–3 independent sources with at least one credible-tier source, mostly direct evidence, stale sources are minority
   - **Low**: 1–2 sources, or sources are primarily low-credibility (vendor marketing, blog posts), or evidence is mostly indirect, or stale sources dominate
   - **Insufficient**: 0–1 sources for a section's claims, or all sources are the same low credibility tier with no triangulation

   **Tier computation approach:**
   - Start at the source-count level: Claim → Low, Emerging → Moderate, Pattern → High
   - Upgrade if credibility is strong (all high-tier sources) or evidence is entirely direct
   - Downgrade if credibility is weak (no high-tier sources), evidence is mostly indirect, or stale sources dominate
   - Cap at Insufficient if fewer than 2 sources with no high-credibility source

   Record the tier and a one-sentence rationale for each section. Add to the scorecard output (step 8) after severity distribution.

9. **Write audit report to `research/audits/<original-filename>-audit.md`** with: scorecard, pass/fail determination, findings table, list of claims that need correction, and the confidence tier table (section name, tier, rationale) from step 8a.

## Pass/Fail Criteria

A draft passes when:
- Zero high-severity issues (unsupported claims, misrepresented data, number drift)
- Zero moderate-severity issues left unresolved (range narrowed, qualifier dropped, cross-document inconsistency)
- 100% of specific numerical claims trace to a source note or phase output with a matching value
- Low-severity issues (missing attribution, stale data) are acceptable if documented in the audit report

There is no percentage threshold. Every specific claim must check out. The scorecard is for visibility into the draft's quality, not for setting a "good enough" bar.

**Confidence tiers are advisory — they indicate evidence strength, not audit compliance.** A section can be High confidence and fail (misrepresented claim) or Low confidence and pass (single source but accurately cited). A Low-confidence section that passes the audit is promoted with its tier visible in the audit report. Do not use confidence tier as a reason to fail or hold a draft.

## After Audit

- **If PASS:**
  1. **Promote the draft.** Move the file from `research/drafts/` to `research/outputs/`.
  2. **Close out the phase in `research/STATE.md`.** A passing audit is the end of the current phase's cycle. STATE.md must be advanced *before* the debrief so that any subsequent `/clear` leaves the project in a correct state — the user may jump straight to `/research:discover` on resume without running `/research:start-phase`, and `discover`'s pre-check depends on "Active phase" already pointing at Phase N+1.

     Perform all of the following writes in a single STATE.md update:
     - **Check off Verify.** In `Current Phase Cycle → Phase N`, change `- [ ] **Verify** …` to `- [x] **Verify** …`. Confirm all five steps (Collect, Connect, Assess, Synthesize, Verify) are now checked. If any earlier step is still unchecked, stop and surface the discrepancy — do not silently check them.
     - **Mark the phase complete in Completed Phases.** Change `- [ ] Phase N: [Name]` to `- [x] Phase N: [Name] — COMPLETE [YYYY-MM-DD]`.
     - **Read `research/research-plan.md`** to determine Phase N+1's name. If Phase N was the final phase in the plan, skip to the "final phase" branch below.
     - **Advance `Active phase`** in `Current Position` from `N — [Phase N Name]` to `N+1 — [Phase N+1 Name]`.
     - **Reset `Cycle step`** to `Collect (1 of 5)`.
     - **Reset `Blocking on`** to `Nothing — ready to start.` (unless a real blocker carried over, in which case preserve it and note the phase transition).
     - **Replace the Current Phase Cycle block** with a fresh Phase N+1 cycle checklist, all five steps unchecked, using the same format as the Phase 1 template in `/research:init`:

       ```markdown
       ### Phase N+1: [Name]
       - [ ] **Collect** — Sources gathered for this phase's questions (start with /research:discover)
       - [ ] **Connect** — `/research:cross-ref` run, cross-reference.md current
       - [ ] **Assess** — `/research:check-gaps` run, coverage confirmed for this phase
       - [ ] **Synthesize** — `/research:summarize-section` run, draft in `drafts/`, integrity checked
       - [ ] **Verify** — `/research:audit-claims` passed, output promoted to `outputs/`
       ```

       The completed Phase N checklist is NOT preserved in `Current Phase Cycle` — its record lives in `Completed Phases`. `Current Phase Cycle` always reflects exactly one active phase.
     - **Reset `Sources Processed` counters for the new phase:**
       - `Sources for current phase: 0`
       - Leave `Total count`, `Sources since last cross-reference`, `Last cross-reference`, and `Last gap check` as-is — those are project-wide or will be reset by their respective skills.
     - **Update `Next Action`** to a specific executable command for Phase N+1. Prefer:

       ```
       Run /research:start-phase to brief Phase N+1, or /research:discover to jump straight to source collection. No sources collected yet for Phase N+1.
       ```

       `Next Action` must be a concrete command the user can execute after a fresh session load, not a phase-level description.

     **Final phase branch.** If Phase N was the final phase in the research plan:
     - Set `Active phase: — all phases complete`.
     - Set `Cycle step: — all cycles complete`.
     - Do NOT generate a new Current Phase Cycle block — remove it or replace it with `*(No active phase — all phases complete.)*`.
     - Update `Next Action` to: `Run /research:progress to review the full project dashboard. Consider running /research:check-gaps one final time to confirm no unresolved items before wrap-up.`

  3. **Present the phase debrief** (see below). The debrief runs *after* STATE.md is advanced, not before.

- **If FAIL:** Leave the file in `research/drafts/`. List every issue with line-level specifics and what needs to change. The user or agent must fix the issues in the draft, then run `/research:audit-claims` again on the same file. Do not promote until it passes. **Do not touch STATE.md on a failed audit** — the phase is still in the Verify step until the audit passes.

## Phase Debrief (after pass)

When a phase's audit passes, do NOT just say "Audit passed" and recommend clearing context. Present a comprehensive debrief of what the phase established. Read the promoted output file and present:

1. **Key findings** — The substantive things this phase established, with specifics (numbers, comparisons, named entities). Not a one-line summary — cover all the major findings, not just the headline.
2. **Surprises or counterintuitive results** — Anything that challenges assumptions or conventional wisdom.
3. **Gaps that remain** — What this phase couldn't answer and why (data doesn't exist, sources conflict, needs internal verification).
4. **Implications for upcoming phases** — How these findings shape what to look for next.

After presenting the debrief, pause and invite the user to react:

```
That's what Phase {N} established. Anything you want to capture, question, or dig into before we move on?
```

Wait for the user to respond. They may:
- Ask follow-up questions about specific findings
- Want to capture a note for later (`research/notes-to-self.md`)
- Challenge or comment on something the research surfaced
- Say they're good to move on

Only after the user is done reacting to the debrief, render the transition prompt (format defined in `.claude/reference/prompt-templates.md`):

───────────────────────────────────────────────────────────

**▶ NEXT:** `/clear` then `/research:start-phase` — Start Phase [N+1] with a fresh context window.

**Also available:**
- `/research:progress` — See the overall project dashboard before clearing.
- `/research:check-gaps` — Confirm no unresolved gaps from Phase [N] should be carried forward.

**What to expect:** A fresh context window gives sharper analysis for the new phase. STATE.md and commonplace.md carry everything forward — no context is lost. Start-phase will read the research plan, gaps, commonplace entries, and open assumptions, and brief you on what Phase [N+1] needs.

───────────────────────────────────────────────────────────

## Non-Negotiable Rules

- **No bypassing.** If the user asks to skip the audit or move a failed draft to outputs manually, refuse. Explain that the audit gate exists to protect research quality and that fixing the issues is faster than dealing with unreliable findings downstream.
- **No soft passes.** Do not downgrade a high-severity issue to moderate to make the draft pass. If a claim doesn't trace to a source, it's unsupported regardless of whether the claim "feels right."
- **Re-audit after fixes.** When a draft is fixed after a failed audit, run the full audit again — do not spot-check only the previously flagged issues. Fixes can introduce new problems.
- **No confidence tier inflation.** Do not inflate confidence tiers. If a section relies on a single source, it is Low confidence regardless of how authoritative that source is. Single-source High confidence does not exist — triangulation requires multiple independent sources.
- **A passing audit must advance STATE.md before the debrief.** Promotion, phase closeout (check off Verify, mark Phase N complete, advance Active phase to N+1, generate the new cycle checklist, reset Next Action) all happen in one atomic step before you present findings to the user. The debrief is for the user; the STATE.md advance is for the next session. The next session may start with `/clear` immediately followed by `/research:discover` (skipping `/research:start-phase` entirely) — if STATE.md still points at Phase N when that happens, discover will either error or silently re-discover a completed phase. If you cannot advance STATE.md cleanly — e.g., `research/research-plan.md` is missing Phase N+1 and Phase N was not marked as final, or the cycle checklist has unchecked steps you did not expect — stop, surface the discrepancy to the user, and do NOT leave STATE.md half-updated. Either the full closeout happens or none of it does.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Soft passes — downgrading severity to make a draft pass | Every severity classification must cite the specific rule it violates. If a claim lacks a source, it is high-severity regardless of how plausible it sounds. |
| Scope narrowing — auditing only "important" claims while skipping minor ones | Audit every factual claim, including numbers in passing references and claims inherited from prior phases. Minor claims are where drift hides. |
| Treating audit as formality — skimming rather than tracing each claim to its source | For each claim, open the cited source note and verify the value. Do not rely on memory of what the source said. |
| Post-fix spot-checking — only re-checking flagged issues after a fix | Re-run the full audit after fixes. Edits can introduce new mismatches, especially when adjusting ranges or qualifiers. |
| Consistency blind spot — auditing the draft in isolation without checking other outputs | Always run the cross-document consistency check and canonical figures check. Same claim, different numbers across documents is high-severity. |
| Conflating confidence with audit pass/fail — treating low confidence as a failure | Confidence tier measures evidence strength (how well-supported). Audit pass/fail measures evidence accuracy (how truthfully represented). A section with one source, accurately cited, passes the audit with Low confidence. Do not fail it for having thin evidence — flag the tier and let the user decide whether to add sources. |
| Silent phase closeout — promoting the draft and presenting the debrief but leaving STATE.md pointing at the completed phase | On PASS, execute the full closeout sequence in `After Audit / If PASS` step 2 before presenting the debrief. Every write — check off Verify, mark Phase N complete, advance Active phase to N+1, reset Cycle step, replace Current Phase Cycle with a fresh Phase N+1 checklist, reset per-phase source counters, rewrite Next Action — must land in STATE.md atomically. If any part cannot be completed (e.g., research-plan.md has no Phase N+1), stop and surface the discrepancy instead of partially updating. The next session may skip `/research:start-phase` and run `/research:discover` directly — STATE.md must be correct before the debrief, not after. |
| Leaving the completed phase's cycle checklist in Current Phase Cycle alongside the new one | `Current Phase Cycle` always reflects exactly one active phase. When advancing to Phase N+1, replace the Phase N checklist entirely — the completed record lives in `Completed Phases`, not in `Current Phase Cycle`. Two checklists in `Current Phase Cycle` is a bug, not a history feature. |

## Output
Scorecard summary and pass/fail status.

**If failed:** list every issue with its location and what needs to change. Do NOT render a transition prompt — a failed audit is a loop, not a transition. The user fixes the draft and re-runs `/research:audit-claims` on the same file.

**If passed:** confirm the promotion to `outputs/`, present the phase debrief (see above), wait for the user to react, and then render the transition prompt (format defined in `.claude/reference/prompt-templates.md`). The transition prompt appears only after the user is done reacting to the debrief — not before.
