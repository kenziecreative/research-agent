# Phase 16: CLI Polish - Pattern Map

**Mapped:** 2026-04-20
**Files analyzed:** 11 (10 SKILL.md files + 1 prompt-templates.md)
**Analogs found:** 11 / 11

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `.claude/reference/prompt-templates.md` | config/reference | request-response | itself (extension only) | self |
| `.claude/commands/research/init/SKILL.md` | skill | multi-step conversational | `start-phase/SKILL.md` | role-match |
| `.claude/commands/research/progress/SKILL.md` | skill | request-response (dashboard) | itself (reference pattern) | self |
| `.claude/commands/research/start-phase/SKILL.md` | skill | request-response | itself (canonical source) | self |
| `.claude/commands/research/discover/SKILL.md` | skill | batch/event-driven | `start-phase/SKILL.md` | role-match |
| `.claude/commands/research/process-source/SKILL.md` | skill | request-response | `start-phase/SKILL.md` | role-match |
| `.claude/commands/research/cross-ref/SKILL.md` | skill | batch/transform | `check-gaps/SKILL.md` | exact |
| `.claude/commands/research/check-gaps/SKILL.md` | skill | batch/transform | itself (reference pattern) | self |
| `.claude/commands/research/phase-insight/SKILL.md` | skill | request-response | `start-phase/SKILL.md` | role-match |
| `.claude/commands/research/summarize-section/SKILL.md` | skill | transform | `audit-claims/SKILL.md` | exact |
| `.claude/commands/research/audit-claims/SKILL.md` | skill | transform | `summarize-section/SKILL.md` | exact |

---

## Pattern Assignments

### `.claude/reference/prompt-templates.md` (config/reference, extension only)

**Change:** Add tone rules section (D-09 through D-12) after the existing content.

**Analog:** itself — extend, do not restructure.

**Existing structure to preserve** (lines 1-150 are complete and must not be altered):
- The `## Transition Prompt Template` section with its `### Format`, `### Rules`, `### When to use it`, `### When NOT to use it`, `### Anti-patterns`, `### Examples` subsections
- The `## Skills That Use This Template` and `## Skills That Do NOT Use This Template` sections at the end

**New section to append after line 150:**

```markdown
---

## CLI Tone Rules

These rules apply to all CLI skill output: transition text, status messages, next-action context, and `## Output` section content. They do NOT apply to research output written to `research/outputs/`, which follows `writing-standards.md`.

### Banned phrases

Never use these phrases in CLI skill output:

- "it should be noted that"
- "it is worth noting"
- "the evidence suggests" (in CLI status/transition text — permitted in research outputs)
- "it may be the case that"
- "one might consider"
- "this would allow for"
- "in order to facilitate"
- "to that end"

### Replacement style

Write direct present-tense statements of what the command does and why it applies now.

**Banned:** "It is worth noting that additional sources may facilitate better coverage."
**Correct:** "Coverage is thin on 2 questions — run discover to find more sources."

**Banned:** "One might consider running cross-ref at this point in order to facilitate pattern detection."
**Correct:** "Cross-reference is overdue — 6 sources processed since the last run."

The test: could a developer with no context understand the sentence in under two seconds? If not, rewrite it.
```

---

### `.claude/commands/research/init/SKILL.md` (skill, multi-step conversational)

**Change:** Add `▶ NEXT:` block to `## Step 7: Report`. The init skill ends in a multi-step conversational flow, not a standard skill run — no structural changes needed to Output section. The `▶ NEXT:` block replaces the existing prose "Next steps: review the research plan..." line.

**Analog:** `start-phase/SKILL.md` — uses the transition prompt after completing its output section.

**Pattern to copy — next-action block placement** (`start-phase/SKILL.md` lines 82-107):
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:discover` — Find candidate sources for Phase [N]'s questions using the type-channel map.

**Also available:**
- `/research:process-source <url-or-file>` — Skip discovery and process a specific source you already have.
- `/research:progress` — See where you are in the overall project before deciding.

**What to expect:** Discovery will surface a prioritized candidate list for this phase's channels. After you approve, processing runs sequentially with a mandatory cross-reference checkpoint every 5-8 sources.

───────────────────────────────────────────────────────────
```

**Specific block for init** (after the phase table in Step 7):
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:discover` — Find candidate sources for Phase 1's questions using the type-channel map.

**Also available:**
- `/research:start-phase` — Get the full Phase 1 briefing before starting discovery.
- `/research:process-source <url-or-file>` — Process a specific source you already have.

**What to expect:** Discovery will surface a prioritized candidate list for Phase 1's channels based on the research type and questions just generated. After you approve, processing runs sequentially with a cross-reference checkpoint every 5-8 sources.

───────────────────────────────────────────────────────────
```

**Note:** `What to expect:` is included here because the next step (discover) benefits from user context about what to expect after init. Per D-07, omit `What to expect:` only on skills with unambiguous next steps.

**No progressive disclosure needed** — init output is already structured as a sequential report with the phase table as its summary artifact (D-16: init does not need progressive disclosure).

---

### `.claude/commands/research/progress/SKILL.md` (skill, dashboard — reference pattern)

**Change:** No structural changes. Progress is the reference pattern for progressive disclosure (D-13). Its existing `## Output` section already demonstrates the canonical format: compact summary line (or failure list) above `---`, then the `### Research Progress` table detail below.

**Analog:** itself — it IS the progressive disclosure reference.

**Progressive disclosure pattern to copy for other skills** (`progress/SKILL.md` lines 56-92):
```markdown
### Infrastructure Health

Infrastructure: 5/5 checks passed
---
```
When items fail:
```markdown
### Infrastructure Health
Infrastructure: [N]/5 checks passed

- **PreToolUse Write hook missing** — this hook prevents unaudited writes to outputs/
- **settings.json invalid or missing** — the settings file must be valid JSON...

---
```
Then the full detail table:
```markdown
### Research Progress

| Phase | Status | Sources | Draft | Audit | Output |
|-------|--------|---------|-------|-------|--------|
```

**No next-action block** — progress is a read-only status skill. Confirmed in `prompt-templates.md` lines 145-146: "Skills That Do NOT Use This Template: `/research:progress` — read-only dashboard."

**No changes needed to this file.**

---

### `.claude/commands/research/start-phase/SKILL.md` (skill, request-response — canonical source)

**Change:** No structural changes. This file IS the canonical source for the `▶ NEXT:` pattern. Its `## Output` section already contains both the full briefing output structure and two complete next-action blocks (discovery phase variant and synthesis phase variant).

**Analog:** itself — canonical reference for next-action blocks across all skills.

**Next-action block pattern (lines 82-107):**
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:discover` — Find candidate sources for Phase [N]'s questions using the type-channel map.

**Also available:**
- `/research:process-source <url-or-file>` — Skip discovery and process a specific source you already have.
- `/research:progress` — See where you are in the overall project before deciding.

**What to expect:** Discovery will surface a prioritized candidate list for this phase's channels. After you approve, processing runs sequentially with a mandatory cross-reference checkpoint every 5-8 sources.

───────────────────────────────────────────────────────────
```

**H2/H3 heading hierarchy pattern (lines 50-78):**
The `## Output` section uses `### Phase [N]: [Name]` as the H3 title, then bold labels (`**Questions to answer:**`, `**Relevant prior findings:**`) for sub-items — this is the model for all complex-output skills.

**No changes needed to this file.**

---

### `.claude/commands/research/discover/SKILL.md` (skill, batch/event-driven)

**Change:** Add progressive disclosure to `## Output` section (D-15) and add `▶ NEXT:` block.

**Analog (progressive disclosure):** `progress/SKILL.md` — summary table above `---`, detail below.

**Analog (next-action block):** `start-phase/SKILL.md` — `▶ NEXT:` with `Also available:` and conditional `What to expect:`.

**Current `## Output` section** (`discover/SKILL.md` lines 533-544) is a prose description without progressive structure. The file already has a per-channel summary table and a candidate list in Step 7 — these become the progressive disclosure structure.

**Progressive disclosure pattern to apply** (modeled on `progress/SKILL.md` lines 56-72):

```markdown
## Output

Print the completion summary (Step 7 format):

### Discovery: Phase [N] — [Phase Name]

| Channel | Status | Found |
|---------|--------|-------|
| Web Search | found | 6 |
| Academic | found | 4 |
| Regulatory | skipped | 0 |
| Financial | error (timeout) | 0 |

**Total candidates:** N | **Duplicates skipped:** N | Saved to: `research/discovery/{phase}-candidates.md`

---

[Per-channel candidate detail and prioritized list follow below]
```

**Next-action block for discover** (context-sensitive per D-08 — after user approves and batch completes):

```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:cross-ref` — Cross-reference the [N] sources processed so far before continuing.

**Also available:**
- `/research:check-gaps` — Check coverage against the phase's questions before collecting more sources.
- `/research:process-source <url>` — Process a specific source not in the candidates list.

───────────────────────────────────────────────────────────
```

**Note:** `What to expect:` is omitted here per D-07 — after discover, the next step (cross-ref) is unambiguous. The synthesis-phase block already in discover (lines 39-49) already has the correct `▶ NEXT:` format and does not need to change.

---

### `.claude/commands/research/process-source/SKILL.md` (skill, request-response)

**Change:** Add `▶ NEXT:` block to `## Output` section. Currently the output section (lines 107-108) is a single prose sentence with no structure.

**Analog:** `start-phase/SKILL.md` next-action block pattern.

**Current `## Output`** (`process-source/SKILL.md` lines 106-108):
```markdown
## Output
Summarize the key findings for the user. Note which research phases this source is relevant to and any contradictions with existing sources. If "Sources since last cross-reference" is now 4 or 5, remind the user: "Cross-reference is due soon (N/5 sources). Run `/research:cross-ref` after the next source or two."
```

**Replace with this structure** — bold labels (no H3 — short output per D-04), then next-action block:

```markdown
## Output

**Source:** [title]
**Credibility:** [tier]
**Key findings:** [N] findings tagged for Phase [N]
**Contradictions:** [N found / none]
**Sources since last cross-ref:** [N]/5

If N ≥ 4: "Cross-reference is due — run `/research:cross-ref` after the next source."

───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:process-source <next-url>` — Continue processing the approved candidate list.

**Also available:**
- `/research:cross-ref` — Run cross-reference now if 5+ sources have been processed.
- `/research:check-gaps` — Check coverage before processing more sources.

───────────────────────────────────────────────────────────
```

**Note:** `What to expect:` is omitted per D-07 — process-source's next step is unambiguous (continue the batch or cross-ref). D-04 applies: this is a short-output skill; bold labels without H3 sections is correct.

---

### `.claude/commands/research/cross-ref/SKILL.md` (skill, batch/transform)

**Changes:** Add progressive disclosure to `## Output` section (D-15) and add `▶ NEXT:` block.

**Analog (progressive disclosure):** `check-gaps/SKILL.md` — which already has a dashboard structure above `---` and per-question detail below (lines 28-56 of check-gaps show the template).

**Analog (next-action block):** `start-phase/SKILL.md`.

**Current `## Output`** (`cross-ref/SKILL.md` lines 68-71) is a short prose summary. The file's step 9 already defines the full regenerated cross-reference.md structure (Dashboard → Contradictions → Saturation Summary → Shared-Origin Clusters) — the Output section should mirror that same hierarchy as a summary dashboard.

**Progressive disclosure output structure** (modeled on `check-gaps/SKILL.md` lines 28-38):

```markdown
## Output

### Cross-Reference: Phase [N]

| Signal | Count |
|--------|-------|
| Contradictions (unresolved) | N |
| Contradictions (total) | N |
| Shared-origin clusters | N |
| Saturation advisory | triggered / not triggered |
| Patterns identified | N |

**Aggregate saturation:** [N%] confirmatory — [converging / still building]

---

[Contradictions detail, saturation per-question, cluster list, pattern list follow below]
```

**Next-action block for cross-ref** (context-sensitive per D-08):

If contradictions are unresolved:
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** Resolve the [N] unresolved contradiction(s) above — synthesis is blocked until core contradictions are confirmed.

**Also available:**
- `/research:check-gaps` — Check coverage after resolving contradictions.
- `/research:phase-insight` — Get a full picture of phase strength before deciding next steps.

───────────────────────────────────────────────────────────
```

If no blocking contradictions and coverage converging:
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:check-gaps` — Confirm coverage for [Phase N] before synthesis.

**Also available:**
- `/research:process-source <url>` — Process additional sources if any questions remain under-covered.
- `/research:phase-insight` — Analyze phase strength in detail before deciding.

───────────────────────────────────────────────────────────
```

**Note:** `What to expect:` omitted on the standard path (check-gaps is unambiguous). Per D-07, `What to expect:` would only be added if the user needs to make a judgment call — for example when aggregate saturation is ambiguous.

---

### `.claude/commands/research/check-gaps/SKILL.md` (skill, batch/transform — reference pattern)

**Changes:** Add `▶ NEXT:` block to `## Output` section (D-05). Progressive disclosure is ALREADY present — the file's step 7 defines the Dashboard at top and per-question detail below, matching D-13 exactly.

**Analog:** itself for progressive disclosure; `start-phase/SKILL.md` for next-action block.

**Current `## Output`** (`check-gaps/SKILL.md` lines 87-113) has the dashboard and highest-priority gaps list but no transition prompt.

**Context-sensitive next-action block to append** (D-08 — recommend discover if gaps exist, cross-ref if coverage adequate):

If gaps exist (Not Started or Lopsided questions):
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:discover` — [N] questions have no Direct coverage — find sources to fill them.

**Also available:**
- `/research:phase-insight` — Review which questions are thin vs. strong before deciding.
- `/research:cross-ref` — Re-run cross-reference if sources have been added since the last run.

───────────────────────────────────────────────────────────
```

If all questions have Direct coverage (≥2 independent sources per question):
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:summarize-section` — Coverage is adequate — draft the phase output.

**Also available:**
- `/research:phase-insight` — Review phase strength in detail before drafting.
- `/research:cross-ref` — Confirm patterns are current before synthesis.

───────────────────────────────────────────────────────────
```

**Note:** `What to expect:` omitted on both paths — next steps are unambiguous. Progressive disclosure is already correct in this file; the dashboard/`---`/detail structure (check-gaps step 7 lines 28-56) is the reference pattern for cross-ref and discover.

---

### `.claude/commands/research/phase-insight/SKILL.md` (skill, request-response)

**Changes:** Add `▶ NEXT:` block when recommendation is unambiguous. The `## Output` section (lines 29-79) already instructs: "If the recommendation is unambiguous... render the transition prompt." The current inline template (lines 66-78) uses the correct format but includes the full raw template text rather than a concrete example.

**Analog:** `start-phase/SKILL.md` — both use conditional transition prompt rendering.

**Current inline template** (`phase-insight/SKILL.md` lines 66-78) is already correct format. The change is to verify the existing text matches `prompt-templates.md` rules — specifically that the `───` delimiters are unicode box-drawing characters (not `---`).

**No structural changes needed** — verify delimiter characters only. The Output section correctly omits `What to expect:` when the block fires (it's in the template placeholder but conditional per the existing instruction at lines 73-75).

**The conditional rendering rule to confirm is correct** (`phase-insight/SKILL.md` lines 65-80):
```markdown
If the recommendation is unambiguous (clear next step with high confidence...),
render the transition prompt...

If the recommendation is ambiguous (multiple valid paths depending on user priorities...),
do NOT render the transition prompt. The Recommendation line alone is enough.
```
This matches D-08 and should be preserved as-is.

---

### `.claude/commands/research/summarize-section/SKILL.md` (skill, transform)

**Change:** `## Output` section already has a complete `▶ NEXT:` block (lines 169-179). Verify it matches the current `prompt-templates.md` format and D-05/D-06 rules. No structural change may be needed — audit the existing block.

**Analog:** `audit-claims/SKILL.md` — both are pipeline skills with mandatory next steps.

**Existing next-action block** (`summarize-section/SKILL.md` lines 169-179):
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:audit-claims research/drafts/<filename>` — Fact-check the draft against source notes before it moves to `outputs/`.

**What to expect:** Audit-claims traces every factual claim to its source note, checks for range narrowing and qualifier stripping, and either promotes the draft to `outputs/` or lists specific issues to fix. This is a hard gate — nothing reaches `outputs/` without passing.

───────────────────────────────────────────────────────────
```

The block omits `Also available:` because summarize-section → audit-claims is a required pipeline. This matches D-06 (the `Also available:` section lists 1-3 alternatives) and the `prompt-templates.md` rules ("`Also available:` is optional — include only when there are genuinely useful alternatives").

**This block is already correct.** Confirm the `───` delimiters are unicode (not ASCII hyphens) and the tone follows D-09 through D-12. No structural change needed.

---

### `.claude/commands/research/audit-claims/SKILL.md` (skill, transform)

**Change:** `## Output` section (lines 262-268) already has `▶ NEXT:` block embedded in the prose, plus the inline next-action block for the pass case (lines 224-235). Verify both match D-05/D-06 format and tone rules.

**Analog:** `summarize-section/SKILL.md` — same pipeline role, matching structure.

**Existing pass-case next-action block** (`audit-claims/SKILL.md` lines 224-235):
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/clear` then `/research:start-phase` — Start Phase [N+1] with a fresh context window.

**Also available:**
- `/research:progress` — See the overall project dashboard before clearing.
- `/research:check-gaps` — Confirm no unresolved gaps from Phase [N] should be carried forward.

**What to expect:** A fresh context window gives sharper analysis for the new phase. STATE.md and commonplace.md carry everything forward — no context is lost. Start-phase will read the research plan, gaps, commonplace entries, and open assumptions, and brief you on what Phase [N+1] needs.

───────────────────────────────────────────────────────────
```

**`What to expect:` is correctly included here** — the `/clear` step requires user judgment (they may prefer not to clear), satisfying D-07's condition. The block is correct.

The fail-case output (lines 262-266) correctly states: "Do NOT render a transition prompt — a failed audit is a loop, not a transition." This matches `prompt-templates.md` "When NOT to use it" rules and must be preserved.

**This skill needs no structural changes.** Audit for banned phrases (D-10) in the debrief prose at lines 204-217 only.

---

## Shared Patterns

### `▶ NEXT:` Block Format
**Source:** `.claude/reference/prompt-templates.md` lines 15-27 and `.claude/commands/research/start-phase/SKILL.md` lines 82-107
**Apply to:** all 10 skill files that lack or need this block
**The canonical block:**
```markdown
───────────────────────────────────────────────────────────

**▶ NEXT:** `/research:<command>` — <one-line: what this does and why it's the right next step now>

**Also available:**
- `/research:<alt-1>` — <one-line>
- `/research:<alt-2>` — <one-line>

**What to expect:** <1-2 sentences: what the next command will do grounded in current state. Include only when next step requires user judgment. Omit on unambiguous transitions.>

───────────────────────────────────────────────────────────
```
Rules: `▶ NEXT:` is required and always first. `Also available:` is optional — omit when the next step is a required pipeline. `What to expect:` is conditional per D-07. The `───` line is unicode `U+2500`, not ASCII `-`.

### Progressive Disclosure Format
**Source:** `.claude/commands/research/progress/SKILL.md` lines 56-92 and `.claude/commands/research/check-gaps/SKILL.md` step 7 lines 28-56
**Apply to:** discover, cross-ref (already present in check-gaps and progress)
**Pattern:** summary table/dashboard above a `---` separator, per-item detail below. The summary is scannable; users scroll for detail. Never add an interactive "show more?" — render both in a single response (D-14).

### Section Dividers
**Source:** `.claude/commands/research/start-phase/SKILL.md` transition blocks; `.claude/commands/research/check-gaps/SKILL.md` step 7 output template
**Apply to:** all 10 skills
- `---` (standard markdown HR): content section breaks within skill output
- `───────────────────────────────────────────────────────────` (unicode `U+2500`): exclusively surrounds `▶ NEXT:` blocks — above and below, never used elsewhere

### Heading Hierarchy
**Source:** `.claude/commands/research/start-phase/SKILL.md` lines 50-78; `.claude/commands/research/phase-insight/SKILL.md` lines 31-60
**Apply to:** check-gaps, cross-ref, phase-insight, start-phase, audit-claims (complex multi-section output)
- H2: skill title/name (the `## Output` section heading — already present in all files)
- H3: named sections within complex multi-section output (e.g., `### Phase [N]: [Name]`, `### Infrastructure Health`)
- Bold labels (`**Label:**`): sub-items and field names within sections
- No H3 for short-output skills (progress, process-source): bold labels only (D-04)

### Bullet Style
**Source:** all 10 SKILL.md files
**Apply to:** all 10 skills
`-` bullets throughout. Never `*` or `+`. Already consistent — verify during edits that no changes introduce `*` bullets.

### Banned Phrase Enforcement
**Source:** D-10 through D-12; to be codified in `.claude/reference/prompt-templates.md` new section
**Apply to:** all 10 skills — specifically the `## Output` section, `## Common Failure Modes` tables, and any inline `▶ NEXT:` block text
**Scan these phrases in every edited file:**
- "it should be noted that"
- "it is worth noting"
- "the evidence suggests" (in CLI status text — not research output)
- "it may be the case that"
- "one might consider"
- "this would allow for"
- "in order to facilitate"
- "to that end"

---

## No Analog Found

All 11 files have clear analogs. No files in this phase require patterns from RESEARCH.md.

---

## Edit Scope Summary

| File | Edit Type | Key Change |
|---|---|---|
| `prompt-templates.md` | Extend | Append new `## CLI Tone Rules` section with banned phrases and replacement examples |
| `init/SKILL.md` | Output section | Replace final prose "Next steps" line in Step 7 with `▶ NEXT:` block |
| `progress/SKILL.md` | None | Reference pattern only — no changes |
| `start-phase/SKILL.md` | None | Canonical source — no changes |
| `discover/SKILL.md` | Output section | Add channel summary dashboard above `---`; add `▶ NEXT:` block at end of Output section |
| `process-source/SKILL.md` | Output section | Replace single-sentence output with bold-label summary + `▶ NEXT:` block |
| `cross-ref/SKILL.md` | Output section | Add signals dashboard above `---`; add context-sensitive `▶ NEXT:` block |
| `check-gaps/SKILL.md` | Output section | Add context-sensitive `▶ NEXT:` block after existing gaps list |
| `phase-insight/SKILL.md` | Delimiter audit | Verify `───` delimiters are unicode (not ASCII) in existing inline block |
| `summarize-section/SKILL.md` | Delimiter + tone audit | Verify existing `▶ NEXT:` block delimiters and scan for banned phrases |
| `audit-claims/SKILL.md` | Tone audit only | Scan debrief prose for banned phrases; no structural changes |

## Metadata

**Analog search scope:** `.claude/commands/research/*/SKILL.md`, `.claude/reference/prompt-templates.md`
**Files read:** 11 skill/reference files
**Pattern extraction date:** 2026-04-20
