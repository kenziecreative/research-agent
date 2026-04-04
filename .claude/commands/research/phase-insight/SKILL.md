---
name: phase-insight
description: Analyze current phase progress — which questions are addressed, which are thin, emerging patterns
allowed-tools: Read, Grep, Glob
---

# /research:phase-insight

Analyze the current phase's research progress and identify what's strong and what needs more work.

## Current Context

!`cat research/STATE.md 2>/dev/null || echo "No STATE.md found — run /research:init first."`

!`cat research/research-plan.md 2>/dev/null | head -5`

## Process

1. **Read `research/STATE.md`** to determine the active phase and cycle step.
2. **Read `research/research-plan.md`** to get the questions for the current phase.
3. **Read `research/cross-reference.md`** for current cross-reference patterns.
4. **Read `research/gaps.md`** for current gap status, including per-question independent source counts, lopsided coverage flags, and adjacent-but-not-direct matches.
5. **Read all files in `research/notes/`** that are relevant to the current phase.
6. **For each question in the current phase:**
   - Is it addressed by one or more source notes? Which ones?
   - Is the coverage thin (1 source) or solid (3+ sources)?
   - Are there contradictions between sources on this question?

## Output

### Phase [N] Insight: [Name]

**Questions addressed:**
| Question | Direct Sources | Independent | Adjacent | Strength | Notes |
|----------|---------------|-------------|----------|----------|-------|
| [question] | [count] | [independent count] | [adjacent count] | Strong/Thin/Unsupported | [contradictions, gaps; "LOPSIDED — single independent source" if applicable] |

**Emerging patterns:**
- [Patterns visible across sources for this phase]

**Contradictions to resolve:**
- [Any sources that disagree on key points]

**Thin areas needing more sources:**
- [Questions with only 1 source or no source]

**Adjacent-only matches (not counted as coverage):**
- [Question]: [N] adjacent sources — [brief explanation of what they address instead]

Only include this subsection if any questions have adjacent-only matches.

**Recommendation:** [What to do next — more sources? ready for cross-ref? ready for synthesis?]

## Guardrails

1. Report only what the source notes actually say. Do not interpret, extend, or strengthen findings based on general knowledge.
2. "Thin" means one **independent Direct** source. "Unsupported" means zero **Direct** sources. Adjacent sources do not count toward strength.
3. When reporting contradictions, cite both source notes by filename. Do not characterize a contradiction without showing both sides.
4. Distinguish between "no sources found" and "sources found but they do not answer this question." The remedies are different.
5. Do not recommend "ready for synthesis" if any central question has only one source.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Inflating coverage strength by counting tangential mentions as evidence | A source "addresses" a question only if it provides a specific claim, data point, or argument that answers it. Mentioning the topic is not addressing it. |
| Recommending synthesis prematurely to move the phase forward | Check the strength column: if any core question has Thin or Unsupported status, the recommendation must be "collect more sources," not "ready for synthesis." |
| Missing contradictions because sources are read in isolation | Compare sources pairwise on each question. Two sources can both seem reasonable individually while contradicting each other on specifics. |
| Generating insights from general knowledge instead of source notes | Every claim in the insight output must trace to a filename in `research/notes/`. If you cannot name the file, do not include the insight. |
| Counting adjacent sources toward coverage strength | Adjacent sources address related topics, not the specific question. Read gaps.md match classifications — only Direct matches count. A question with 3 Adjacent and 0 Direct sources is Unsupported, not Strong. |

This skill is read-only — it does NOT write any files.
