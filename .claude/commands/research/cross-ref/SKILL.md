---
name: cross-ref
description: Find patterns and connections across all processed research notes
disable-model-invocation: true
---

# /research:cross-ref

Analyze all processed source notes for cross-cutting patterns.

## Process

1. **Read all files in `research/notes/`.**
2. **Read `research/cross-reference.md`** for previously identified patterns.
3. **Read `.claude/reference/pattern-recognition-guide.md`** for the types of patterns worth surfacing and how to assess pattern strength.
4. **Identify patterns across sources:**
   - Claims confirmed by multiple sources (note which ones)
   - Claims where sources contradict each other (present both sides)
   - Emerging themes not visible in any single source
   - Gaps where multiple sources reference something but none provide evidence
5. **Update `research/cross-reference.md`** with new patterns found. Organize by theme, not by source. For each pattern, cite the source notes that contribute to it.
6. **Update `research/STATE.md`** — set last cross-reference date to today and reset "Sources since last cross-reference" to 0.

## Guardrails

1. Report patterns only when two or more independent sources support them. A pattern from one source is a claim, not a pattern.
2. When sources contradict each other, present both sides with source citations. Do not resolve the contradiction by picking the more recent or more authoritative source.
3. Do not force thematic connections. If sources cover different aspects of the topic without overlapping, say "no cross-cutting patterns found for [theme]" rather than inventing a connection.
4. Weight patterns by source independence. Three blog posts citing the same original study are one data point, not convergence.
5. Date-stamp patterns. A pattern supported by sources from 2019 and contradicted by a 2024 source is a temporal shift, not a contradiction.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Forcing patterns that do not exist — connecting unrelated sources to show "insight" | Each pattern must cite at least two independent sources. If you cannot name them, the pattern is not real. |
| Missing contradictions between sources | Actively compare sources that address the same question. Check whether Source A's numbers match Source B's for the same metric. |
| Recency bias — treating newer sources as automatically more reliable | Note the date of each source contributing to a pattern. Recent is not synonymous with correct, especially for historical or structural claims. |
| Overlooking absence patterns — gaps visible only when comparing across sources | Look for questions that multiple sources reference but none answer with evidence. These are significant gaps, not irrelevant omissions. |
| Echo-chamber patterns — multiple sources tracing to the same original | Trace claims to their origin. If three articles cite the same study, that is one source, not convergence. |

## Output
Summarize new patterns found since the last cross-reference. Highlight any contradictions that need resolution and any themes that are strengthening across sources.
