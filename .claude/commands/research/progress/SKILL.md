---
name: progress
description: Show research project dashboard — phase status, source counts, and next action
allowed-tools: Read, Grep, Glob
model: sonnet
---

# /research:progress

Show the current state of the research project as a dashboard.

## Current State

!`cat research/STATE.md 2>/dev/null || echo "No STATE.md found — run /research:init first."`

## Process

1. **Run infrastructure health checks** — collect all check results into a failures list (empty list = all pass):

   **1a. Hooks active** — Read `.claude/settings.json` and verify the JSON contains:
   - A `PreToolUse` entry with `matcher: "Write"` — failure name: "PreToolUse Write hook missing" — failure description: "this hook prevents unaudited writes to outputs/"
   - A `PreToolUse` entry with `matcher: "Edit"` — failure name: "PreToolUse Edit hook missing" — failure description: "this hook prevents unaudited edits to outputs/"
   - A `PreCompact` entry (any matcher) — failure name: "PreCompact hook missing" — failure description: "this hook ensures STATE.md is updated before context compacts"

   **1b. JSON valid** — Read `.claude/settings.json` and confirm it parses as valid JSON with a `hooks` key containing `PreToolUse` and `PreCompact` arrays.
   - Failure name: "settings.json invalid or missing"
   - Failure description: "the settings file must be valid JSON with hooks.PreToolUse and hooks.PreCompact arrays — without it, no audit gates are active"

   **1c. STATE.md structurally sound** — Read `research/STATE.md` and confirm YAML frontmatter exists (delimited by `---`) containing the keys `milestone`, `status`, and `progress`.
   - Failure name: "STATE.md missing required frontmatter"
   - Failure description: "STATE.md must have YAML frontmatter with milestone, status, and progress fields — these drive the progress dashboard"
   - If `research/STATE.md` does not exist, this check passes silently (no active research project)

   **1d. Reference files present** — Glob `.claude/reference/` for these specific items: `coverage-assessment-guide.md`, `evidence-failure-modes.md`, `pattern-recognition-guide.md`, `source-assessment-guide.md`, `tools-guide.md`, `writing-standards.md`, `templates/` directory.
   - Failure name: "[filename] missing from .claude/reference/"
   - Failure description: "reference files guide source assessment, evidence evaluation, and output formatting — missing files degrade research quality"

   **1e. Discovery strategy present** — When `research/` directory exists (active research project), check for a file matching `research/discovery-strategy*.md` or `research/discovery/*.md`.
   - Failure name: "discovery strategy missing"
   - Failure description: "a discovery strategy guides source finding — without one, source selection is ad-hoc"
   - If no `research/` directory exists, this check passes silently

2. **Read `research/STATE.md`** for current position, active phase, and completed phases.
3. **Count files:**
   - `research/notes/` — total source notes
   - `research/drafts/` — drafts pending audit
   - `research/outputs/` — audited outputs
   - `research/audits/` — audit reports
4. **Read `research/research-plan.md`** to get the full phase list.
5. **Read `research/cross-reference.md`** and count the number of identified patterns.
6. **Read `research/gaps.md`** to identify any blocking gaps.

## Output

### Infrastructure Health

When all 5 checks pass, output a single compact line:
```
### Infrastructure Health
Infrastructure: 5/5 checks passed
---
```

When any checks fail, output a summary line plus only the failures (do not enumerate passing checks):
```
### Infrastructure Health
Infrastructure: [N]/5 checks passed

- **PreToolUse Write hook missing** — this hook prevents unaudited writes to outputs/
- **settings.json invalid or missing** — the settings file must be valid JSON with hooks.PreToolUse and hooks.PreCompact arrays — without it, no audit gates are active

---
```

### Research Progress

| Phase | Status | Sources | Draft | Audit | Output |
|-------|--------|---------|-------|-------|--------|
| 1. [Name] | Complete/Active/Pending | [N] | [Yes/No] | [Pass/Fail/Pending/—] | [Yes/No] |
| 2. [Name] | ... | ... | ... | ... | ... |
| ... | | | | | |

**Audit column values:**
- **Pass** — `/research:audit-claims` ran and passed; draft was promoted to `outputs/`.
- **Fail** — `/research:audit-claims` ran and returned failures; draft is still in `drafts/` awaiting fixes.
- **Pending** — a draft exists in `drafts/` for this phase but `/research:audit-claims` has not been run on it yet.
- **—** — no draft exists for this phase yet (phase not yet at Synthesize step, or not started).

**Source notes:** [N] total
**Cross-reference patterns:** [N] identified
**Blocking issues:** [Any gaps or issues preventing progress, or "None"]

**Next action:** [If health failures exist: "Fix infrastructure issues above before continuing — " then the original next action from STATE.md. If no health failures, show the original next action from STATE.md unchanged.]

## Guardrails

1. Report exactly what STATE.md and the files say. Do not editorialize on progress quality.
2. If STATE.md and the actual file counts disagree (e.g., STATE.md says 5 sources but there are 7 files in notes/), report the discrepancy.
3. Do not recommend skipping phases or batching work to "speed things up."
4. Show blocking issues prominently — a stale cross-reference or undone gap check is a blocker, not a footnote.
5. Report all infrastructure check results honestly. Do not skip checks or suppress failures to make the dashboard look clean.

This skill is read-only — it does NOT write any files.
