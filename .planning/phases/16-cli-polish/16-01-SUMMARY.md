---
phase: 16-cli-polish
plan: "01"
subsystem: cli-output
tags: [cli-polish, tone-rules, prompt-templates, skill-audit]
dependency_graph:
  requires: []
  provides:
    - CLI Tone Rules in prompt-templates.md (referenced by all 10 skills)
    - Corrected skills lists (10 use / 1 excluded)
    - Audit-confirmed unicode delimiters in phase-insight, summarize-section, audit-claims
  affects:
    - .claude/reference/prompt-templates.md
    - .claude/commands/research/phase-insight/SKILL.md (audited, no change)
    - .claude/commands/research/summarize-section/SKILL.md (audited, no change)
    - .claude/commands/research/audit-claims/SKILL.md (audited, no change)
tech_stack:
  added: []
  patterns:
    - CLI tone enforcement via banned-phrase list in shared reference file
    - Skills lists as authoritative routing map for transition prompt usage
key_files:
  created: []
  modified:
    - .claude/reference/prompt-templates.md
decisions:
  - "All 10 skills use the transition template — only progress excluded (read-only dashboard per D-05)"
  - "Tone rules placed in prompt-templates.md for maximum leverage — one file read by all skills"
  - "Task 2 required no file edits — all three audited skills already had correct unicode delimiters and no banned phrases"
metrics:
  duration_minutes: 5
  completed: "2026-04-21"
  tasks_completed: 2
  tasks_total: 2
  files_changed: 1
---

# Phase 16 Plan 01: CLI Tone Rules and Skills Lists Summary

CLI tone rules added to prompt-templates.md via banned-phrase list and replacement examples; skills lists corrected to reflect all 10 skills using the template (only progress excluded); three existing transition-block skills audited and confirmed compliant with no changes needed.

## Tasks

| Task | Name | Commit | Status | Files |
|------|------|--------|--------|-------|
| 1 | Append CLI Tone Rules and update skills lists | e89631c | Complete | `.claude/reference/prompt-templates.md` |
| 2 | Audit phase-insight, summarize-section, audit-claims | — | Complete (no changes needed) | 3 files audited, 0 modified |

## What Was Done

### Task 1: prompt-templates.md

Two changes made to `.claude/reference/prompt-templates.md`:

**Skills lists updated:** The `## Skills That Use This Template` section expanded from 5 entries to 10. The `## Skills That Do NOT Use This Template` section reduced from 6 entries to 1 (`/research:progress` only). This reflects the D-05 decision that all skills except the read-only progress dashboard use the transition prompt template.

**CLI Tone Rules section appended:** A new `## CLI Tone Rules` section added after the skills lists, separated by a `---` divider. The section contains:
- Scope statement (CLI output only — not research outputs)
- `### Banned phrases` with all 8 phrases
- `### Replacement style` with 2 Banned/Correct example pairs
- The two-second readability test

Lines 1–131 of the original file were not altered.

### Task 2: Audit of three skills with existing transition blocks

All three files passed without modification:

- **phase-insight/SKILL.md** — Unicode delimiter confirmed (`───` U+2500, lines 67 and 77). No banned phrases in Output, Guardrails, or Common Failure Modes sections.
- **summarize-section/SKILL.md** — Unicode delimiters confirmed on both sides of the `▶ NEXT:` block (lines 171 and 177). No banned phrases anywhere in the file.
- **audit-claims/SKILL.md** — Unicode delimiters confirmed on both the pass-case block (lines 226 and 236) and checked debrief prose (lines 204–217). No banned phrases in any CLI-facing text.

No edits were made to any of the three skill files.

## Deviations from Plan

None — plan executed exactly as written. Task 2 resulted in no file changes, which the plan explicitly anticipated: "If all checks pass with no changes needed, note that in the summary. Do not make unnecessary edits."

## Known Stubs

None. This plan edits reference/instruction files only. No data sources, no UI components, no rendered output.

## Threat Flags

None. No new network endpoints, auth paths, file access patterns, or schema changes introduced. Files modified are documentation/instruction files with no runtime execution.

## Self-Check: PASSED

- `.claude/reference/prompt-templates.md` — modified and committed e89631c
- `## CLI Tone Rules` heading present in file: confirmed
- 8 banned phrases listed: confirmed
- 10 entries in Skills That Use: confirmed
- 1 entry in Skills That Do NOT Use: confirmed
- `grep "## CLI Tone Rules" .claude/reference/prompt-templates.md` returns match: confirmed
- All 3 audited files pass unicode delimiter + banned phrase checks: confirmed
- e89631c commit exists: confirmed
