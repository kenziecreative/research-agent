---
name: phase-insight
description: Analyze current phase progress — which questions are addressed, which are thin, emerging patterns
allowed-tools: Read, Grep, Glob
disable-model-invocation: true
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
4. **Read `research/gaps.md`** for current gap status.
5. **Read all files in `research/notes/`** that are relevant to the current phase.
6. **For each question in the current phase:**
   - Is it addressed by one or more source notes? Which ones?
   - Is the coverage thin (1 source) or solid (3+ sources)?
   - Are there contradictions between sources on this question?

## Output

### Phase [N] Insight: [Name]

**Questions addressed:**
| Question | Sources | Strength | Notes |
|----------|---------|----------|-------|
| [question] | [count] | Strong/Thin/Unsupported | [contradictions, gaps] |

**Emerging patterns:**
- [Patterns visible across sources for this phase]

**Contradictions to resolve:**
- [Any sources that disagree on key points]

**Thin areas needing more sources:**
- [Questions with only 1 source or no source]

**Recommendation:** [What to do next — more sources? ready for cross-ref? ready for synthesis?]

This skill is read-only — it does NOT write any files.
