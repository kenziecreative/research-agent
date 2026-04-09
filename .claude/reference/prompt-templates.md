# Prompt Templates

Canonical formats for user-facing prompts across research skills. The goal is consistency — the user should be able to scan any skill's output and find the next action in under two seconds without reading paragraphs.

This file defines ONE template today: the **transition prompt**. More may be added if specific patterns emerge.

---

## Transition Prompt Template

Use this at the end of a skill run when the agent is handing control back to the user and pointing at a next step. The template is a structured handoff, not a question.

### Format

```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:<command>` — <one-line description of what this does and why it's the right next step>

**Also available:**
- `/research:<alt-1>` — <one-line description>
- `/research:<alt-2>` — <one-line description>

**What to expect:** <One to two sentences explaining what the next command will do, grounded in the research plan or current state. Tell the user what outputs they'll see and any gates or checkpoints they'll encounter. Substance, not time estimates.>

───────────────────────────────────────────────────────────
```

### Rules

- **`▶ NEXT:` is required and is always the first line inside the block.** Always a single command with a one-line description. Never a menu. Never a question. The user's eye lands here first and knows what to do.
- **`Also available:` is optional.** Include only when there are genuinely useful alternatives — two or three max. If the next step is a required pipeline (e.g., `summarize-section` → `audit-claims` is not a choice), omit this section entirely.
- **`What to expect:` is required.** Always included, always one or two sentences. This is where the agent grounds the recommendation in the project's current state. Never more than two sentences — the block is for scanning, not reading.
- **The horizontal rule delimiters (`───────────────────────────────────────────────────────────`) are required above and below.** They make the block findable in long outputs. Unicode box-drawing characters, not ASCII `=` or `-`.
- **Do NOT ask a question in this block.** The block is a handoff. If the agent needs a judgment call from the user, that is a different interaction — see "When NOT to use this template" below.

### When to use it

- At the end of a skill run where the agent is transitioning control to the user with a clear recommended next step.
- When the skill's purpose is to produce a result AND point at what comes after (e.g., `start-phase` briefs then recommends discover; `summarize-section` writes a draft then recommends audit-claims).
- When the end-of-phase reminder fires (phase complete → next phase briefing or context clear).

### When NOT to use it

- **Read-only status skills** — `/research:progress`, `/research:check-gaps`, `/research:cross-ref` (when purely reporting patterns), `/research:phase-insight` (when the recommendation is ambiguous). These skills inform a decision the user is about to make; they don't transition to the next one. Adding a template to them creates noise and reintroduces the drift problem.
- **Mid-skill status updates** — "processed source 12, added to notes." Those are one-line status lines, not handoffs.
- **Decision prompts** — when the agent hits a contradiction, access failure, or strategic choice and genuinely needs a judgment call from the user. Those use their own skill-specific prompts (documented in the relevant skill). The transition prompt is for *recommending* a next step, not for *asking* the user to resolve something.
- **Confirmation prompts mid-batch** — "should I continue processing?" is almost never legitimate. See `discover/SKILL.md` → "Legitimate Pause Points" for the four conditions where pausing IS legitimate during a batch. None of them use this template; they use the skill's own prompts.
- **Error prompts** — rare and context-specific. Use plain language, not the template.

### Anti-patterns this template prevents

These are the failure modes the template is designed to make impossible:

1. **"Want me to do these next three steps in order?"** — batch confirmation. The template allows only ONE NEXT action. If three steps need to happen, they happen sequentially with their own transition prompts, or the agent just does them (if approved earlier).
2. **"Should I continue?"** — accountability avoidance, the pattern named in `discover/SKILL.md`. The template has no slot for a yes/no question. The agent must formulate a concrete NEXT action or omit the block entirely.
3. **Open-ended "what should we do next?"** — handing the steering wheel back. The template requires the agent to make a recommendation, not ask the user to make one.
4. **Paragraphs with the next step buried in the middle.** The template puts the NEXT action on the first line inside the block. The user cannot miss it.
5. **Stacked questions.** If the block has multiple questions, it's not a transition prompt — it's a decision prompt or a confirmation prompt. Use the skill's own language.

### Examples

**Example 1: start-phase (phase briefing → discover)**

```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:discover` — Find candidate sources for Phase 3's questions using the type-channel map.

**Also available:**
- `/research:process-source <url-or-file>` — Skip discovery and process a specific source you already have.
- `/research:progress` — See where you are in the overall project before deciding.

**What to expect:** Discovery will surface a prioritized candidate list for Phase 3's channels. After you approve, processing runs sequentially with a mandatory cross-reference checkpoint every 5-8 sources.

───────────────────────────────────────────────────────────
```

**Example 2: summarize-section (draft written → audit-claims, no alternatives)**

```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:audit-claims research/drafts/03-programs-and-service-delivery.md` — Fact-check the draft against source notes before it moves to `outputs/`.

**What to expect:** Audit-claims traces every factual claim to its source note, checks for range narrowing and qualifier stripping, and either promotes the draft to `outputs/` or lists specific issues to fix. This is a hard gate — nothing reaches `outputs/` without passing.

───────────────────────────────────────────────────────────
```

**Example 3: audit-claims pass → phase debrief complete → next phase**

```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/clear` then `/research:start-phase` — Start Phase 4 with a fresh context window.

**Also available:**
- `/research:progress` — See the overall project dashboard before clearing.
- `/research:check-gaps` — Confirm no unresolved gaps from Phase 3 should be carried forward.

**What to expect:** A fresh context window gives sharper analysis for the new phase. STATE.md and commonplace.md carry everything forward. Start-phase will read the research plan, gaps, commonplace entries, and open assumptions, and brief you on what Phase 4 needs.

───────────────────────────────────────────────────────────
```

**Example 4: Heavy Collect step → intra-phase clear → cross-ref**

Use this pattern when the current step consumed significant context (primary documents, large PDFs, structured data files) and the next step would benefit from a fresh window. The phase cycle continues from the same position after the clear — intra-phase clears are a legitimate transition, not a phase end.

```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/clear` then `/research:cross-ref` — Run cross-reference for Phase 4 in a fresh context window.

**Also available:**
- `/research:cross-ref` — Run cross-ref without clearing if you want to preserve the current conversation.
- `/research:progress` — See where you are before deciding.

**What to expect:** Collect for Phase 4 processed 6 sources including three 990 XML filings, a 31-page PDF, and a canonical figures correction cascade. Context is ~55% used. Cross-ref reads `research/notes/` directly and doesn't need the current conversation — a fresh window gives sharper pattern detection. STATE.md's Next Action field is updated so the next session can resume with one command.

───────────────────────────────────────────────────────────
```

**Important — intra-phase clear rules:**

- **Only at step boundaries, never mid-step.** Finish the current step (write all source notes, update STATE.md, complete pending file writes) before rendering this prompt. Clearing mid-step loses work.
- **Only when the step is heavy.** After Collect with 5+ sources including primary regulatory documents (990 XMLs, SEC filings, court records), large PDFs (>15 pages), or structured data files (XML/CSV/JSON >50KB), or when context is estimated >50% used. After Synthesize when the draft is long (>3000 words) or the source notes are unusually rich.
- **Never between Verify and phase-end.** The phase-level clear already handles that case — do not double-clear. If you just finished Verify and the phase audit passed, render the phase-level transition prompt (Example 3), not this one.
- **STATE.md must be updated before rendering.** The Next Action field must read like a specific command (e.g., "Run /research:cross-ref for Phase 4 — 6 sources ready in research/notes/") so the next session can resume without needing the current conversation.

---

## Skills That Use This Template

- `/research:start-phase` — at end of phase briefing
- `/research:summarize-section` — after draft is written
- `/research:audit-claims` — after phase debrief, on pass only
- `/research:phase-insight` — conditionally, only when the recommendation is unambiguous
- End-of-phase reminder (defined in the assembled CLAUDE.md Section 8)

## Skills That Do NOT Use This Template

- `/research:progress` — read-only dashboard
- `/research:check-gaps` — informational gap analysis
- `/research:cross-ref` — pattern report, advisory only
- `/research:process-source` — runs in batches, status line between sources
- `/research:discover` — uses its own "Legitimate Pause Points" logic
- `/research:init` — multi-step conversational setup, no transition point at the end in the template sense
