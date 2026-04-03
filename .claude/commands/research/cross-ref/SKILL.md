---
name: cross-ref
description: Find patterns and connections across all processed research notes
---

# /research:cross-ref

Analyze all processed source notes for cross-cutting patterns.

## Process

1. **Read all files in `research/notes/`.**
2. **Read `research/cross-reference.md`** for previously identified patterns.
3. **Read `.claude/reference/pattern-recognition-guide.md`** for the types of patterns worth surfacing and how to assess pattern strength.
4. **Check for existing contradiction resolutions.** If cross-reference.md contains previously resolved contradictions, record them. These will be carried forward if the contradiction still exists after re-analysis.
5. **Identify contradictions (XREF-01).** For each pair of sources that address the same claim or question, compare their assertions. A contradiction exists when sources make incompatible claims about the same fact — not when they cover different aspects or use different terminology. For each contradiction found:
   - Record both sides with specific source citations and the exact claims
   - Assess which side is stronger based on recency, methodology quality, and source credibility tier (reference source-assessment-guide.md criteria)
   - Write Claude's suggested resolution with the reasoning (e.g., "Source B's methodology is stronger because it discloses sample size and selection criteria, while Source A's is proprietary")
   - Set resolution status: "unresolved" for new contradictions, carry forward "resolved: [decision]" for previously resolved ones that still exist in the data
   - Classify as "core" (directly addresses a current phase question) or "peripheral" (relevant but not blocking)
6. **Detect shared-origin clusters (XREF-03).** Read the origin chain field from each source note. Group sources that cite the same original study, dataset, report, or primary source. For each cluster:
   - Name the shared origin (original study/report title, author, date)
   - List the processed sources that trace to it
   - Note that this cluster counts as ONE data point for pattern strength assessment, not independent corroboration
   - Apply Echo level from pattern-recognition-guide.md to any pattern that relies solely on sources within the same cluster
7. **Calculate saturation signals (XREF-02).** For each phase question (from research-plan.md):
   - Count how many sources address it
   - For each source's findings on that question, classify as "new" (adds information not present in previously processed sources) or "confirmatory" (repeats or confirms existing findings)
   - Calculate saturation percentage: confirmatory / total findings for that question
   - Set advisory: when aggregate saturation exceeds threshold (use 75% as default — if 75% or more of findings across all questions are confirmatory, trigger the advisory), display "Evidence is converging — additional sources are unlikely to shift the picture. Consider moving to synthesis for saturated questions."
   - Per-question advisory: flag individual questions above 80% saturation as "saturated" and questions below 40% as "under-covered — prioritize discovery here"
8. **Identify cross-cutting patterns** (convergence, gap clusters, temporal trends, source-type skew, outliers). When assessing pattern strength, apply shared-origin cluster adjustments: sources in the same cluster count as one data point.
9. **Regenerate `research/cross-reference.md`** using the template structure (Dashboard -> Contradictions -> Saturation Summary -> Shared-Origin Clusters -> pattern types). Carry forward existing contradiction resolutions if the contradiction still exists. Drop resolutions for contradictions that no longer exist in the data. Update the dashboard counts.
10. **Update `research/STATE.md`** — set last cross-reference date to today and reset "Sources since last cross-reference" to 0.

## Guardrails

1. Report patterns only when two or more independent sources support them. A pattern from one source is a claim, not a pattern.
2. When sources contradict each other, present both sides with source citations. Do not resolve the contradiction by picking the more recent or more authoritative source.
3. Do not force thematic connections. If sources cover different aspects of the topic without overlapping, say "no cross-cutting patterns found for [theme]" rather than inventing a connection.
4. Weight patterns by source independence. Three blog posts citing the same original study are one data point, not convergence.
5. Date-stamp patterns. A pattern supported by sources from 2019 and contradicted by a 2024 source is a temporal shift, not a contradiction.
6. When logging contradictions, present both sides with specific source citations. Include Claude's suggested resolution with explicit reasoning (recency, methodology, credibility tier), but mark it as a suggestion — the user must confirm resolution before synthesis can proceed on affected questions.
7. Shared-origin clusters collapse to one data point for pattern strength. Three blog posts citing the same study are Echo level, not Convergence. This applies retroactively to all existing patterns when shared-origin clusters are detected.
8. Saturation signals are informational, not blocking. Display the signal and suggest focusing discovery on under-covered questions, but do not prevent the user from processing more sources.
9. Regenerate cross-reference.md from scratch on every run for consistency. The only state carried forward is resolved contradiction decisions.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Forcing patterns that do not exist — connecting unrelated sources to show "insight" | Each pattern must cite at least two independent sources. If you cannot name them, the pattern is not real. |
| Missing contradictions between sources | Actively compare sources that address the same question. Check whether Source A's numbers match Source B's for the same metric. |
| Recency bias — treating newer sources as automatically more reliable | Note the date of each source contributing to a pattern. Recent is not synonymous with correct, especially for historical or structural claims. |
| Overlooking absence patterns — gaps visible only when comparing across sources | Look for questions that multiple sources reference but none answer with evidence. These are significant gaps, not irrelevant omissions. |
| Echo-chamber patterns — multiple sources tracing to the same original | Trace claims to their origin. If three articles cite the same study, that is one source, not convergence. |
| Treating shared-origin sources as independent corroboration | Check origin chain fields. If two sources cite the same study, they are one data point. Label as Echo in pattern strength. |
| Resolving contradictions without user confirmation | Log contradictions with a suggested resolution, but mark as "unresolved" until the user explicitly confirms. Synthesis is blocked on unresolved core contradictions. |
| Reporting raw saturation % without actionable guidance | Every saturation signal must include direction: "saturated — consider synthesis" or "under-covered — prioritize discovery here." A number alone is not useful. |
| Dropping previous contradiction resolutions on regeneration | Before regenerating, read existing cross-reference.md and extract resolved contradictions. Carry them forward if the contradiction still exists in re-analyzed data. |

## Output

Summarize new patterns found since the last cross-reference. Report: number of contradictions found (unresolved/total), saturation status (aggregate % and any per-question advisories), shared-origin clusters detected. Highlight any contradictions that block synthesis and any questions that are under-covered. If aggregate saturation advisory is triggered, suggest the user consider moving saturated questions to synthesis.
