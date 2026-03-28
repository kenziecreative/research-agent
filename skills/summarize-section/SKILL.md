---
name: summarize-section
description: Synthesize processed source notes into a draft research output section
argument-hint: "[section-name-or-phase-number]"
disable-model-invocation: true
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
7. **Write a draft section** to `research/drafts/<part-number>-<section-slug>.md`:
   - Lead with findings, support with evidence
   - Every finding answers "so what does this mean?"
   - Apply the project's finding tags to key conclusions
   - Cite sources inline using `[Source: <note-filename>]`
   - Use prose paragraphs, not bullet lists (except for data tables and key findings)
   - Present contradictions when sources disagree
   - No orphan claims — if it can't be cited, flag it as inference
8. **Run the research-integrity agent** on the draft. Pass the filepath. If the agent finds issues, fix them in the draft before proceeding. Do not move to audit with known integrity issues — fix them now while the source context is fresh.
9. **Update `research/STATE.md`** — note the draft was written, integrity-checked, and is pending audit.

## Output
Confirm the draft was written to `research/drafts/`, integrity-checked, and summarize the key findings. Then tell the user: "This draft needs to pass `/research:audit-claims` before it moves to `outputs/`. Run `/research:audit-claims research/drafts/<filename>` now."
