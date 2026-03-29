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
3. **Identify patterns across sources:**
   - Claims confirmed by multiple sources (note which ones)
   - Claims where sources contradict each other (present both sides)
   - Emerging themes not visible in any single source
   - Gaps where multiple sources reference something but none provide evidence
4. **Update `research/cross-reference.md`** with new patterns found. Organize by theme, not by source. For each pattern, cite the source notes that contribute to it.
5. **Update `research/STATE.md`** — set last cross-reference date to today and reset "Sources since last cross-reference" to 0.

## Output
Summarize new patterns found since the last cross-reference. Highlight any contradictions that need resolution and any themes that are strengthening across sources.
