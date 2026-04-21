# Phase 16: CLI Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-20
**Phase:** 16-cli-polish
**Areas discussed:** Output structure standard, Next-action block design, Language tone calibration, Progressive disclosure approach
**Mode:** --auto (all areas auto-selected, recommended options auto-chosen)

---

## Output Structure Standard

| Option | Description | Selected |
|--------|-------------|----------|
| H2/H3 tiered by output length | H2 for skill title, H3 for named sections in complex output, bold labels for sub-items. `---` for section breaks, `───` for transition blocks. `-` bullets throughout. Codifies existing organic pattern. | ✓ |
| Bold-label flat sections (no headings) | All sections use `**Label:**` without headings. Lower visual weight but degrades scanability in long outputs like phase-insight and check-gaps. | |

**User's choice:** [auto] H2/H3 tiered by output length (recommended default)
**Notes:** Advisor research confirmed the codebase has already converged on this pattern organically. Phase 16 codifies rather than replaces.

---

## Next-Action Block Design

| Option | Description | Selected |
|--------|-------------|----------|
| `▶ NEXT:` with unicode dividers + `Also available:` + conditional `What to expect:` | Visually distinct, surfaces alternatives (required by UX-02), provides context where next step requires judgment. Already established in start-phase. | ✓ |
| `**Next action:**` inline | Compact single line. No alternatives surfaced, easy to miss in dense output. Cannot satisfy UX-02's "at least one alternative" requirement. | |

**User's choice:** [auto] `▶ NEXT:` pattern (recommended default)
**Notes:** UX-02 structurally requires alternatives, which eliminates the inline option. `What to expect:` is conditional — included only where the next step requires user judgment.

---

## Language Tone Calibration

| Option | Description | Selected |
|--------|-------------|----------|
| Extend `prompt-templates.md` with tone section | Highest leverage — every skill reads this file for transition blocks. Banned phrases list + replacement examples at the definition site. | ✓ |
| Extend `writing-standards.md` with CLI tone section | Single existing reference file, but scoped to research output quality. Skills that don't write research outputs may not read it. Lower discoverability. | |

**User's choice:** [auto] Extend prompt-templates.md (recommended default)
**Notes:** Advisor research found the actual hedging risk is in freeform text Claude generates at runtime, not static template text. Placing tone rules at the template definition site catches this at the highest leverage point.

---

## Progressive Disclosure Approach

| Option | Description | Selected |
|--------|-------------|----------|
| Summary dashboard above `---` separator, detail below | No interaction required, matches existing progress skill pattern, consistent with terminal markdown rendering. User scrolls for detail. | ✓ |
| Explicit "show details?" prompt | Keeps initial output short but adds round-trip friction. Breaks single-command usability. Conflicts with power users who routinely read full output. | |

**User's choice:** [auto] Summary then separator then detail (recommended default)
**Notes:** Terminal constraint eliminates collapsible sections. The progress skill already establishes this pattern. Zero new interaction mechanisms needed.

---

## Claude's Discretion

- Exact wording of `What to expect:` context lines
- Count annotations in summary dashboards
- Ordering of `Also available:` alternatives
- Whether summarize-section and audit-claims need structural changes beyond next-action blocks

## Deferred Ideas

None — discussion stayed within phase scope
