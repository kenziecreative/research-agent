---
phase: 16-cli-polish
plan: "02"
subsystem: cli-output
tags: [cli-polish, next-action-blocks, progressive-disclosure, skill-output]
dependency_graph:
  requires:
    - 16-01 (CLI Tone Rules in prompt-templates.md — read by all skills)
  provides:
    - Next-action blocks in init, discover, process-source, cross-ref, check-gaps
    - Progressive disclosure dashboards in discover and cross-ref Output sections
    - Context-sensitive dual next-action blocks in check-gaps and cross-ref
  affects:
    - .claude/commands/research/init/SKILL.md
    - .claude/commands/research/discover/SKILL.md
    - .claude/commands/research/process-source/SKILL.md
    - .claude/commands/research/cross-ref/SKILL.md
    - .claude/commands/research/check-gaps/SKILL.md
tech_stack:
  added: []
  patterns:
    - Context-sensitive next-action blocks using ▶ NEXT: canonical format from prompt-templates.md
    - Progressive disclosure via summary dashboard + --- separator + detail (discover, cross-ref)
    - Bold-label compact output format for short-output skills (process-source per D-04)
    - Dual context-sensitive blocks (D-08): two ▶ NEXT: variants per skill based on output state
key_files:
  created: []
  modified:
    - .claude/commands/research/init/SKILL.md
    - .claude/commands/research/discover/SKILL.md
    - .claude/commands/research/process-source/SKILL.md
    - .claude/commands/research/cross-ref/SKILL.md
    - .claude/commands/research/check-gaps/SKILL.md
decisions:
  - "What to expect: included only in init (D-07 exception — discover needs context after init); omitted in all other 4 skills"
  - "Meta-commentary lines referencing What to expect removed from SKILL.md files to satisfy acceptance criteria"
  - "process-source Output: cross-ref reminder preserved as If N >= 4 conditional (same behavior, structured form)"
metrics:
  duration_minutes: 8
  completed: "2026-04-21"
  tasks_completed: 2
  tasks_total: 2
  files_changed: 5
---

# Phase 16 Plan 02: Next-Action Blocks and Progressive Disclosure Summary

Next-action blocks added to all 5 remaining skills using the canonical ▶ NEXT: format; discover and cross-ref gained progressive disclosure dashboards; check-gaps and cross-ref got context-sensitive dual blocks based on output state.

## Tasks

| Task | Name | Commit | Status | Files |
|------|------|--------|--------|-------|
| 1 | Add next-action block to init and restructure process-source Output | 9146779 | Complete | `init/SKILL.md`, `process-source/SKILL.md` |
| 2 | Add progressive disclosure and next-action blocks to discover, cross-ref, check-gaps | 29f65de | Complete | `discover/SKILL.md`, `cross-ref/SKILL.md`, `check-gaps/SKILL.md` |

## What Was Done

### Task 1: init/SKILL.md and process-source/SKILL.md

**init/SKILL.md:** The final two prose lines in Step 7 ("Next steps: review the research plan..." and "Reminder to clear context...") were replaced with the canonical `▶ NEXT:` block. The block recommends `/research:discover` as the primary next action, lists `/research:start-phase` and `/research:process-source` as alternatives, and includes a `What to expect:` line (D-07 exception — init is a user-judgment step where context about discovery is valuable). Unicode `───` delimiters added above and below. The `Do NOT tell the user to cd anywhere` guardrail line was retained.

**process-source/SKILL.md:** The single-sentence `## Output` section was replaced with a structured bold-label summary format (Source, Credibility, Key findings, Contradictions, Sources since last cross-ref), followed by the cross-ref conditional (`If N >= 4`), then the `▶ NEXT:` block. No H3 headings used per D-04 (short-output skill). `What to expect:` omitted — next step is unambiguous. The cross-ref reminder behavior from the original prose is preserved as the `If N >= 4` conditional line.

### Task 2: discover/SKILL.md, cross-ref/SKILL.md, check-gaps/SKILL.md

**discover/SKILL.md:** `## Output` section replaced with a channel summary dashboard table (Channel/Status/Found columns) above a `---` separator, followed by per-channel candidate detail. Two context-sensitive `▶ NEXT:` blocks added: one for post-discovery (recommends process-source, shown after user approves candidates), one for post-batch (recommends cross-ref, shown after all approved sources processed). The existing synthesis-phase block at lines 39-49 was not touched.

**cross-ref/SKILL.md:** `## Output` section replaced with a signals dashboard table (Signal/Count columns) with `### Cross-Reference: Phase [N]` H3 heading and `---` separator. Two context-sensitive `▶ NEXT:` blocks: contradictions path (recommends resolving before synthesis) and clean path (recommends check-gaps). Summary prose from the original Output section preserved as the detail section below the `---`.

**check-gaps/SKILL.md:** The existing Output section (already had progressive disclosure per D-13) was preserved intact. Two context-sensitive `▶ NEXT:` blocks appended: gaps path (recommends discover when Not Started/Lopsided/Evidence Against questions exist) and adequate path (recommends summarize-section when all questions have >= 2 independent Direct sources).

## Deviations from Plan

**Minor: meta-commentary lines removed**

- **Found during:** Task 2 verification
- **Issue:** The plan instructed adding `` `What to expect:` is omitted on both paths per D-07 `` lines as explanatory text. These lines contain the phrase "What to expect:" which triggered the acceptance criteria check that no `What to expect:` should appear in the Output section.
- **Fix:** Removed the meta-commentary lines from all three Task 2 files. The intent (documenting D-07 compliance) is captured in this SUMMARY instead.
- **Files modified:** `discover/SKILL.md`, `cross-ref/SKILL.md`, `check-gaps/SKILL.md`
- **Impact:** None — these were explanatory notes, not user-facing output instructions.

## Known Stubs

None. This plan edits instruction/reference files only. No data sources, no UI components, no rendered output.

## Threat Flags

None. No new network endpoints, auth paths, file access patterns, or schema changes introduced. Files modified are documentation/instruction files with no runtime execution.

## Self-Check: PASSED

- `.claude/commands/research/init/SKILL.md` — modified and committed 9146779
- `.claude/commands/research/process-source/SKILL.md` — modified and committed 9146779
- `.claude/commands/research/discover/SKILL.md` — modified and committed 29f65de
- `.claude/commands/research/cross-ref/SKILL.md` — modified and committed 29f65de
- `.claude/commands/research/check-gaps/SKILL.md` — modified and committed 29f65de
- All 5 files contain `▶ NEXT:` in their Output sections: confirmed
- discover and cross-ref have progressive disclosure dashboard tables: confirmed
- check-gaps and cross-ref have context-sensitive dual blocks: confirmed
- process-source uses bold labels only (no H3 in Output): confirmed
- init Step 7 includes `What to expect:` (D-07 exception): confirmed
- Zero banned phrases in any modified file: confirmed
- Unicode `───` delimiters used throughout (no ASCII hyphens): confirmed
- Both commits exist in git log: confirmed
