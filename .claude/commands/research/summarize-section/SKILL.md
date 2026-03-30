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

If either pre-check fails, do not proceed. Tell the user which check failed and what to run.

## Process

1. **Read `research/research-plan.md`** to understand what this phase/section covers and what questions it needs to answer.
2. **Read `research/reference/writing-standards.md`** for output formatting rules.
3. **Read `research/reference/source-standards.md`** for citation and evidence rules.
4. **Read all relevant files in `research/notes/`** that pertain to this section.
5. **Read `research/cross-reference.md`** for patterns relevant to this section.
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
9. **Run the research-integrity agent** on the draft. Pass the filepath. If the agent finds issues, fix them in the draft before proceeding. Do not move to audit with known integrity issues — fix them now while the source context is fresh.
10. **Update `research/STATE.md`** — note the draft was written, integrity-checked, and is pending audit.

## Guardrails

1. Write only from source notes in `research/notes/`. If a fact is not in a source note, it does not go in the draft.
2. Preserve every qualifier from the source. "Primarily in enterprise deployments" does not become "broadly adopted."
3. When sources disagree, present the disagreement. Do not smooth contradictions into a consensus that does not exist.
4. Preserve the full range from source notes. If the source says "$2M–$8M," the draft says "$2M–$8M," not "$4M–$8M" or "approximately $5M."
5. Flag any finding supported by only one source with "single source suggests" language. Do not present single-source findings as established facts.
6. Run the research-integrity agent before declaring the draft ready for audit. Do not skip this step.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Synthesizing from memory instead of source notes | For every claim in the draft, find the corresponding source note and verify the value. If you wrote the source notes earlier in the session, re-read them anyway — memory drifts. |
| Dropping qualifiers during compression | Compare the draft's language against each cited source note. If a qualifier was present in the note, it must be present in the draft or the simplification must be noted explicitly. |
| Smoothing contradictions into false consensus | When two sources disagree, present both positions with citations. "Source A reports X; Source B reports Y" is correct. "Evidence suggests approximately Z" (splitting the difference) is fabrication. |
| Range narrowing — presenting the favorable end of a range | Every range in the draft must match the source note's range exactly. Check endpoints. If the source says "5–25%" and the draft says "15–25%," the lower bound was dropped. |
| False precision — converting ranges to point estimates | "The market is $4.7B" when the source says "$3–6B" is false precision. Preserve the range. |

## Output
Confirm the draft was written to `research/drafts/`, integrity-checked, and summarize the key findings. Then tell the user: "This draft needs to pass `/research:audit-claims` before it moves to `outputs/`. Run `/research:audit-claims research/drafts/<filename>` now."
