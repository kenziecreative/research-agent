# Coverage Assessment Guide

How to distinguish real coverage from thin coverage when assessing research gaps.

## Evidence Depth vs. Breadth

- **Breadth:** How many of the phase's questions have at least one source?
- **Depth:** For each addressed question, how many independent sources provide substantive evidence?

A phase can have high breadth and low depth — every question touched but none answered well enough to write a defensible synthesis. Report both dimensions.

## What "Addressed" Actually Means

A question is **addressed** when:
- A source note contains a specific claim, data point, or argument that directly answers the question
- The evidence is substantive — enough to write about, not just a passing mention
- The source note is in `research/notes/`, not in conversation memory

A question is **NOT addressed** when:
- A source mentions the topic but provides no evidence (e.g., "market size is important" without a number)
- The answer exists only in conversation memory, not in a processed source note
- A source addresses a related but different question (adjacent is not the same as addressed)
- The only "evidence" is the source repeating a claim without its own data

## Source Diversity Requirements

Questions answered by only one source type carry coverage risk:

| Source Composition | Risk Level | Action |
|---|---|---|
| 3+ independent sources, mixed types | Low | Solid coverage |
| 2-3 sources, same type (e.g., all vendor blogs) | Moderate | Flag as "covered but source-type skewed" |
| 1 source only | High | Flag as "thin — single source" |
| Multiple sources, all citing the same original | High | Flag as "echo — one underlying data point" |

**Balance risk:** Questions answered by sources from only one perspective (e.g., all pro, all con, all from incumbents) have balance risk even if source count is adequate.

## Coverage Status Definitions

Use these labels consistently in `research/gaps.md`:

- **Complete:** 3+ independent sources with substantive evidence, no unresolved contradictions, source types are mixed
- **Partial:** 1-2 sources, or sources exist but coverage is thin, one-sided, or source-type skewed
- **Not started:** No source notes address this question
- **Addressed but unbalanced:** Sources exist but represent only one perspective or source type

## When to Accept Gaps

A gap is **acceptable** when:
- Public sources genuinely do not exist for the question (and you have searched, not just assumed)
- The user has explicitly acknowledged the gap and decided to proceed
- The question is peripheral to the phase's core objective

A gap is **NOT acceptable** just because:
- It is documented in gaps.md (documenting a gap does not resolve it)
- The phase has "enough" sources overall (coverage is per-question, not per-phase)
- Finding sources would take too long (flag the time constraint to the user, let them decide)

## Coverage Assessment Workflow

For each phase question:
1. List the source notes that address it (by filename)
2. For each source, verify the evidence is substantive (not a passing mention)
3. Check source independence (are they citing the same underlying data?)
4. Check source type diversity
5. Check perspective balance
6. Assign a coverage status using the definitions above
