---
name: summarize-section
description: Synthesize processed source notes into a draft research output section
argument-hint: "[section-name-or-phase-number]"
---

# /research:summarize-section

Synthesize research notes into a draft output section for a specific phase or topic. Drafts are written to `research/drafts/` — NOT `research/outputs/`. Only `/research:audit-claims` can promote a draft to `outputs/`.

## Input
The user will provide a section name or phase number to summarize.

## Pre-checks (mandatory)

Before writing anything, verify:
1. **`research/cross-reference.md`** has been updated within the last 5-8 sources. If it hasn't, stop and run `/research:cross-ref` first.
2. **`research/gaps.md`** has been updated for this phase. If it hasn't, stop and run `/research:check-gaps` first.
3. **`research/cross-reference.md` has no unresolved core contradictions.** Read the Contradictions section. If any contradiction classified as "core" (directly addresses a current phase question) has status "unresolved," stop and tell the user:

   ```
   Synthesis blocked — unresolved contradictions on core phase questions:

   - [Contradiction description]: [Source A claim] vs. [Source B claim]
     Suggested resolution: [Claude's suggestion from cross-ref]

   To proceed, resolve each contradiction by running /research:cross-ref and confirming or overriding the suggested resolution. Peripheral contradictions (flagged but not core) do not block synthesis.
   ```

   Do not proceed until all core contradictions are resolved. Peripheral contradictions (those not directly addressing a current phase question) should be noted in the draft but do not block synthesis.

4. **Source staleness advisory.** Read `research/research-plan.md` to identify the research type, then read the corresponding type template in `.claude/reference/templates/types/` to get the **Staleness Threshold** value. Read all source notes in `research/notes/` relevant to this section. For each source note, compare its **data year** (not publication year — a 2025 article citing 2021 data uses 2021) against `current year minus threshold`. If any sources exceed the threshold, display a staleness advisory before proceeding:

   ```
   Source staleness advisory (threshold: N years for [research type]):

   - [source-note-filename]: data year [YYYY], [M] years over threshold
   - [source-note-filename]: data year [YYYY], [M] years over threshold

   These sources will be included in synthesis with age caveats. Stale evidence is still evidence but carries reduced weight.
   ```

   This is a **warning, not a gate** — synthesis proceeds after displaying the advisory. If no sources exceed the threshold, skip the advisory silently.

5. **Counter-evidence gate (PRD Validation and Exploratory Thesis only).** Read `research/research-plan.md` to determine the research type. If the type is PRD Validation or Exploratory Thesis:
   a. Scan all processed source notes in `research/notes/` for this phase.
   b. Look for findings tagged CHALLENGED (PRD Validation) or CONTRADICTED (Exploratory Thesis) from sources with credibility tier above "blog/opinion" level (official docs, analyst reports, peer-reviewed, industry data, developer community).
   c. If at least one credible source has a CHALLENGED or CONTRADICTED finding, the gate passes — proceed.
   d. If no credible counter-evidence exists, block synthesis:

   ```
   Synthesis blocked — no counter-evidence found for [research type].

   [Research type] requires at least one credible source that challenges the central claim before synthesis can proceed. This ensures the research stress-tests its thesis rather than just confirming it.

   Current sources all [support/validate] the position. To proceed:
   1. Run /research:discover with terms like "[negating/challenging terms for the thesis]"
   2. Look for sources from [suggest specific channels: academic databases, industry analysts, competing viewpoints]
   3. Process at least one source that presents counter-evidence
   4. Then re-run /research:summarize-section

   If after genuine search no counter-evidence can be found, note this explicitly — absence of opposition is itself a finding worth documenting.
   ```

   This gate applies to every phase in PRD Validation and Exploratory Thesis types, not just the final synthesis.

If any pre-check fails, do not proceed. Tell the user which check failed and what to run.

## Process

1. **Read `research/research-plan.md`** to understand what this phase/section covers and what questions it needs to answer.
2. **Read `research/reference/writing-standards.md`** for output formatting rules.
3. **Read `research/reference/source-standards.md`** for citation and evidence rules.
4. **Read all relevant files in `research/notes/`** that pertain to this section.
5. **Read `research/cross-reference.md`** for patterns relevant to this section. Include resolved contradiction decisions in the draft — present the resolution with the reasoning, not just the winning side. The reader should see that a disagreement existed and how it was resolved. Note any peripheral unresolved contradictions in the draft as open questions that do not affect the section's core findings.
6. **Read `research/gaps.md`** — if there are unresolved gaps for this phase, note them explicitly in the draft as open questions.
7. **Read `.claude/reference/evidence-failure-modes.md`** to understand the evidence degradation patterns to avoid during synthesis.
8. **Write a draft section** to `research/drafts/<part-number>-<section-slug>.md`:
   - Lead with findings, support with evidence
   - Every finding answers "so what does this mean?"
   - Apply the project's finding tags to key conclusions
   - Cite sources inline using `[Source: <note-filename>]`
   - Use prose paragraphs, not bullet lists (except for data tables and key findings)
   - Present contradictions when sources disagree
   - No orphan claims — if it can't be cited, flag it as inference
8a. **Log assumptions to `research/assumptions.md`.** While writing the draft, identify any judgment or finding that meets these criteria:
    - Based on a single source (already flagged with "single source suggests" per guardrail 5)
    - Inferred from indirect evidence rather than directly stated
    - Extrapolated beyond what the source data strictly supports
    - Based on sources that exceed the staleness threshold

    For each assumption identified, append an entry to `research/assumptions.md` (create the file if it does not exist). Entry format:

    ```markdown
    ### [Short assumption description]
    - **Status:** Open
    - **Phase:** [phase number and name]
    - **Section:** [draft section name]
    - **Basis:** [What evidence exists and why it is thin — e.g., "single source (vendor whitepaper)", "inferred from adjacent market data", "based on 2021 data exceeding 2-year threshold"]
    - **What would validate:** [What kind of evidence would confirm this]
    - **What would challenge:** [What kind of evidence would overturn this]
    - **Added:** [date]
    ```

    The file header (create only if file does not exist):
    ```markdown
    # Research Assumptions Record

    Judgments synthesized from weak, thin, or indirect evidence. Revisit when new phases add evidence.

    **Statuses:** Open (still assumed) | Validated (later evidence confirmed) | Challenged (later evidence contradicts)

    ---
    ```

    When adding new assumptions, also scan existing assumptions in the file. If new evidence from current synthesis validates or challenges a prior assumption, update its status from Open to Validated or Challenged and add a note with the evidence that changed it.

9. **Run the research-integrity agent** on the draft. Pass the filepath. If the agent finds issues, fix them in the draft before proceeding. Do not move to audit with known integrity issues — fix them now while the source context is fresh.
10. **Update `research/STATE.md`** — note the draft was written, integrity-checked, and is pending audit.

## Guardrails

1. Write only from source notes in `research/notes/`. If a fact is not in a source note, it does not go in the draft.
2. Preserve every qualifier from the source. "Primarily in enterprise deployments" does not become "broadly adopted."
3. When sources disagree, present the disagreement. Do not smooth contradictions into a consensus that does not exist.
4. Preserve the full range from source notes. If the source says "$2M–$8M," the draft says "$2M–$8M," not "$4M–$8M" or "approximately $5M."
5. Flag any finding supported by only one source with "single source suggests" language. Do not present single-source findings as established facts.
6. Run the research-integrity agent before declaring the draft ready for audit. Do not skip this step.
7. Never synthesize past an unresolved core contradiction. If cross-reference.md shows unresolved contradictions on questions this section addresses, the pre-check should have caught it. If you reach synthesis and notice a contradiction that was not in cross-reference.md, stop and flag it — do not smooth it into consensus.
8. When a source exceeds the staleness threshold, include its findings in the draft but add an explicit age caveat noting the data year. Do not silently present stale data as current.
9. Every "single source suggests" finding in the draft must have a corresponding entry in `research/assumptions.md`. If you wrote "single source suggests" but did not log the assumption, go back and add it.
10. Do not bypass the counter-evidence gate by re-tagging a supporting source as CHALLENGED. The gate requires genuinely opposing evidence from a credible source, not relabeled confirmatory evidence.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Synthesizing from memory instead of source notes | For every claim in the draft, find the corresponding source note and verify the value. If you wrote the source notes earlier in the session, re-read them anyway — memory drifts. |
| Dropping qualifiers during compression | Compare the draft's language against each cited source note. If a qualifier was present in the note, it must be present in the draft or the simplification must be noted explicitly. |
| Smoothing contradictions into false consensus | When two sources disagree, present both positions with citations. "Source A reports X; Source B reports Y" is correct. "Evidence suggests approximately Z" (splitting the difference) is fabrication. |
| Range narrowing — presenting the favorable end of a range | Every range in the draft must match the source note's range exactly. Check endpoints. If the source says "5–25%" and the draft says "15–25%," the lower bound was dropped. |
| False precision — converting ranges to point estimates | "The market is $4.7B" when the source says "$3–6B" is false precision. Preserve the range. |
| Synthesizing past unresolved contradictions — smoothing disagreements into false consensus | Check cross-reference.md Contradictions section before writing. If any core contradiction is unresolved, stop. Do not proceed by picking the "more likely" side — the user must explicitly decide. |
| Treating stale sources as equally current — using old data without age caveat | Check each source's data year against the type's staleness threshold. If stale, include the finding but add an age caveat: "Based on [YYYY] data..." so the reader knows the evidence may not reflect current conditions. |
| Silent assumptions — presenting thin-evidence judgments as established findings without logging them | Before finalizing the draft, re-read it and check every finding: is it supported by 2+ independent credible sources with direct evidence? If not, it is an assumption and must be logged to `research/assumptions.md`. |
| Counter-evidence theater — processing a weak source just to satisfy the gate | The counter-evidence gate requires a credible source (not blog/opinion tier) with a genuine CHALLENGED or CONTRADICTED finding. Processing a low-quality source and tagging it as challenging does not satisfy the gate — the source must genuinely present opposing evidence. |

## Output
Confirm the draft was written to `research/drafts/`, integrity-checked, and summarize the key findings. Then tell the user: "This draft needs to pass `/research:audit-claims` before it moves to `outputs/`. Run `/research:audit-claims research/drafts/<filename>` now."
