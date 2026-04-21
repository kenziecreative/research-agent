# Phase 16: CLI Polish - Context

**Gathered:** 2026-04-20
**Status:** Ready for planning

<domain>
## Phase Boundary

All 10 research skills present output with consistent structure, clear next-action guidance, plain language, and progressive disclosure for long responses. This phase edits existing SKILL.md files and the prompt-templates.md reference file — it does not add new skills, new commands, or new features. The 10 skills in scope: init, progress, start-phase, discover, process-source, cross-ref, check-gaps, phase-insight, summarize-section, audit-claims.

</domain>

<decisions>
## Implementation Decisions

### Output Structure Standard
- **D-01:** Heading hierarchy is tiered by output length — H2 for skill title/name heading, H3 for named sections within complex multi-section output (check-gaps, cross-ref, phase-insight, start-phase, audit-claims), bold labels (`**Label:**`) for sub-items and field names within sections
- **D-02:** Section dividers use `---` (standard markdown HR) for breaks between content sections. The unicode `───` line divider is reserved exclusively for transition prompt / next-action blocks
- **D-03:** Bullet style is `-` throughout all 10 skills (already the existing convention — never `*` or `+`)
- **D-04:** Short-output skills (progress, process-source) use bold labels without H3 sections — headings would be visual overkill for compact output

### Next-Action Block Format
- **D-05:** All 10 skills end with a next-action block using the `▶ NEXT:` pattern already established in start-phase — visually separated by the `───` unicode line divider above and below
- **D-06:** Block structure: `▶ NEXT:` names the recommended command with brief context, `Also available:` lists 1-3 alternative commands. This satisfies UX-02's requirement for "recommended next command and at least one alternative"
- **D-07:** `What to expect:` line is included only on skills where the next step requires user judgment or context (start-phase → discover, discover → process-source). Omitted on skills with unambiguous next steps (summarize-section → audit-claims) to avoid boilerplate filler
- **D-08:** The next-action block is context-sensitive — the recommended command changes based on the skill's output state (e.g., check-gaps recommends discover if gaps exist, cross-ref if coverage is adequate)

### Language Tone
- **D-09:** Tone rules are added to `.claude/reference/prompt-templates.md` — highest leverage placement since every skill reads this file when rendering transition blocks and freeform output text
- **D-10:** Specific banned phrases in CLI output (transition text, status messages, next-action context): "it should be noted that", "it is worth noting", "the evidence suggests" (in CLI text, not research output), "it may be the case that", "one might consider", "this would allow for", "in order to facilitate", "to that end"
- **D-11:** Replacement style: direct present-tense statements of what the command does and why it applies now. Example: "it is worth noting that additional sources may facilitate better coverage" → "Coverage is thin on 2 questions — run discover to find more sources"
- **D-12:** This tone standard applies to CLI skill output only — not to research output written to `research/outputs/`, which follows the existing writing-standards.md conventions

### Progressive Disclosure
- **D-13:** Skills that produce more than one screen of output lead with a summary dashboard/table above a `---` separator, with per-item detail below. This matches the existing `progress` skill pattern
- **D-14:** No interactive "show details?" prompt — always render summary + detail in a single response. The summary serves as a scannable overview; users scroll for detail when needed
- **D-15:** Skills requiring progressive disclosure: check-gaps (coverage dashboard → per-question detail), cross-ref (dashboard summary → contradictions → saturation → clusters), discover (channel summary table → per-channel candidates)
- **D-16:** Skills that are already short enough (progress, process-source, init, phase-insight) do not need progressive disclosure — they already fit in one screen or close to it

### Claude's Discretion
- Exact wording of `What to expect:` context lines where included
- Whether to add a count annotation to the summary dashboard (e.g., "3 gaps found — details below")
- Ordering of `Also available:` alternatives (by likelihood of use vs. alphabetical)
- Whether summarize-section and audit-claims need any structural changes beyond adding the next-action block (they may already be sufficiently structured)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Output Format Infrastructure
- `.claude/reference/prompt-templates.md` — Canonical transition prompt template; will be extended with tone rules (D-09). All 10 skills reference this for next-action blocks
- `.claude/reference/writing-standards.md` — Research output writing standards (not CLI tone — kept separate per D-12)

### All 10 Skill Files (primary edit targets)
- `.claude/commands/research/init/SKILL.md` — Project scaffolding skill
- `.claude/commands/research/progress/SKILL.md` — Progress dashboard skill (reference pattern for summary format)
- `.claude/commands/research/start-phase/SKILL.md` — Phase briefing skill (reference pattern for `▶ NEXT:` block)
- `.claude/commands/research/discover/SKILL.md` — Source discovery skill (needs progressive disclosure + next-action)
- `.claude/commands/research/process-source/SKILL.md` — Source processing skill (needs next-action block)
- `.claude/commands/research/cross-ref/SKILL.md` — Cross-reference skill (needs progressive disclosure + next-action)
- `.claude/commands/research/check-gaps/SKILL.md` — Gap analysis skill (needs progressive disclosure + next-action)
- `.claude/commands/research/phase-insight/SKILL.md` — Phase insight skill (needs next-action block)
- `.claude/commands/research/summarize-section/SKILL.md` — Synthesis skill (needs next-action block)
- `.claude/commands/research/audit-claims/SKILL.md` — Audit skill (needs next-action block)

### Requirements
- `.planning/REQUIREMENTS.md` UX-01 — Consistent section dividers, headings, and bullet formatting
- `.planning/REQUIREMENTS.md` UX-02 — Next-action block with recommended command and alternatives
- `.planning/REQUIREMENTS.md` UX-03 — Plain, direct language with no academic hedging
- `.planning/REQUIREMENTS.md` UX-04 — Progressive disclosure for long output

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `start-phase/SKILL.md` transition prompt block — The `▶ NEXT:` / `Also available:` / `What to expect:` pattern to standardize across all skills
- `progress/SKILL.md` dashboard format — The compact table + infrastructure health pattern to use as progressive disclosure reference
- `prompt-templates.md` — Already defines the transition prompt visual structure; extending with tone rules keeps all CLI format guidance in one place

### Established Patterns
- H2/H3 heading hierarchy already used by check-gaps, cross-ref, phase-insight, start-phase
- `---` dividers already used in cross-reference.md and gaps.md templates
- `───` unicode dividers already reserved for transition prompt blocks in start-phase
- `-` bullet style used consistently across all 10 skills
- Bold labels (`**Label:**`) used for sub-items in progress and process-source

### Integration Points
- Each SKILL.md's `## Output` section — Primary edit target for structure, next-action, and progressive disclosure changes
- Each SKILL.md's `## Guardrails` section — May need tone-related guardrail additions
- `prompt-templates.md` — Single file edit for tone rules that cascade to all skills
- Existing `## Common Failure Modes` tables — Language in these tables should also follow the tone standard

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 16-cli-polish*
*Context gathered: 2026-04-20*
