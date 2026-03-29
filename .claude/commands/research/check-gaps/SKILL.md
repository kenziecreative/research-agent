---
name: check-gaps
description: Map research coverage and identify holes across all phases
disable-model-invocation: true
---

# /research:check-gaps

Assess research coverage against the research plan and identify what's missing.

## Process

1. **Read `research/research-plan.md`** for the full list of phases and questions.
2. **Read all files in `research/notes/`** to understand what's been covered.
3. **Read `research/outputs/`** for any completed phase outputs.
4. **Read `.claude/reference/coverage-assessment-guide.md`** for criteria on what counts as genuine coverage vs. thin coverage.
5. **For each phase in the research plan:**
   - Which questions have been addressed by processed sources?
   - Which questions remain unanswered or underserved?
   - Are there questions that need more sources for triangulation?
6. **Update `research/gaps.md`** with current coverage status per phase. Be specific — name which questions are covered and which are open. Use the coverage status definitions from the guide (Complete, Partial, Not started, Addressed but unbalanced).
7. **Update `research/STATE.md`** — set last gap check date to today.

## Guardrails

1. A question is "addressed" only when a source note contains a direct, substantive answer — not when a source merely mentions the topic in passing.
2. Do not count the same source twice for different questions unless it genuinely addresses both with distinct evidence.
3. Distinguish between breadth (many questions touched) and depth (any single question answered well enough to write about). Report both.
4. When a phase shows "partial" coverage, list exactly which questions are covered and which are open — do not summarize as a percentage.
5. Flag questions that have sources but only from one side of a debate as "covered but unbalanced."

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Declaring coverage when sources only tangentially mention a question | For each question, identify the specific claim or data point in the source note that answers it. If you cannot point to a specific passage, the question is not addressed. |
| Confusing quantity of sources with quality of coverage | Three sources that all repeat the same press release provide one data point, not three. Count independent evidence, not source count. |
| Marking a phase complete when gaps are documented but unresolved | "Documented gap" is not "acceptable gap." A gap is acceptable only when the user has explicitly acknowledged it or no public sources exist after a thorough search. |
| Missing thin coverage on critical questions | Flag any question answered by only one source. Single-source coverage on a phase's central question is a gap, not partial coverage. |

## Output
Summary table showing coverage status per phase (complete / partial / not started). List the highest-priority gaps — the unanswered questions that are most important to the research.
