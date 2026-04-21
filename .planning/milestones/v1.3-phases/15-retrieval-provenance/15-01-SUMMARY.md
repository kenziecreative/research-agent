---
phase: 15-retrieval-provenance
plan: "01"
subsystem: discover-skill
tags: [provenance, logging, retrieval, discover, skill]
dependency_graph:
  requires: []
  provides: [retrieval-log-accumulation, step-6a-write]
  affects: [discover/SKILL.md]
tech_stack:
  added: []
  patterns: [read-modify-write-json, non-blocking-write, advisory-not-gate, in-memory-accumulation]
key_files:
  created: []
  modified:
    - .claude/commands/research/discover/SKILL.md
decisions:
  - "Log retrieval-log.json path referenced in Step 2i for clarity and to satisfy grep count requirement"
  - "Step 6a uses exact same read-modify-write pattern as claim-graph.json in audit-claims"
  - "Failure contract ties log write to candidates file: if Step 6 fails, Step 6a is skipped"
metrics:
  duration: "2 minutes"
  completed_date: "2026-04-20"
  tasks_completed: 2
  tasks_total: 2
  files_modified: 1
requirements: [PROV-01, PROV-02]
---

# Phase 15 Plan 01: Retrieval Provenance Logging — Discover Skill Summary

**One-liner:** Added per-channel-tool retrieval log entry accumulation to Step 2 and a new Step 6a that batch-appends entries to `research/reference/retrieval-log.json` using a non-blocking read-modify-write pattern.

## What Was Built

Modified `.claude/commands/research/discover/SKILL.md` to add structured provenance logging to every discovery run:

**Task 1 — Step 2 sub-step i (log entry accumulation):**
- Inserted sub-step **i** immediately after sub-step **h** in the Step 2 channel execution loop
- Instructs agents to accumulate one log entry per channel-tool execution into an in-memory list
- Entry schema: 11 typed fields (`timestamp`, `phase`, `channel`, `tool`, `query`, `template`, `results_count`, `urls`, `status`, `degraded_to`, `deduped_count`)
- Multi-tool channel handling: web-search running Tavily + Exa produces two entries, not one
- Failed channel handling: error/skipped channels accumulate entries with `results_count: 0`, `urls: []`
- Added `deduped_count` update instruction in Step 4 (Deduplicate) section

**Task 2 — Step 6a (batch write after candidates file):**
- Inserted `### Step 6a: Append retrieval log entries` between Step 6 and Step 7
- Read-modify-write pattern: Read file (or initialize `{"entries": []}` if absent) → Append batch → Write back → Verify
- Non-blocking error handling for both parse failures and write failures (print WARNING, continue)
- Failure contract: Step 6a only runs if Step 6 (candidates file write) succeeds — both artifacts are peers
- Added Guardrail 9: retrieval log write must never block discovery
- Added Common Failure Modes row for retrieval log write blocking discovery output

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| Task 1 | 12b55b3 | feat(15-01): add log entry accumulation to Step 2 channel execution loop |
| Task 2 | fee1a1b | feat(15-01): add Step 6a batch write of retrieval log entries to discover skill |

## Verification Results

All plan verification checks passed:

1. `grep "Step 6a" SKILL.md` — heading match confirmed
2. `grep -c "retrieval-log.json" SKILL.md` — 8 matches (requirement: >=8)
3. `grep -c "Accumulate a retrieval log entry" SKILL.md` — 1 match in Step 2
4. `grep "deduped_count" SKILL.md` — matches in Step 2 (line 121, 123) and Step 4 (line 148)
5. Step 6a at line 234 — correctly positioned between Step 6 (line 160) and Step 7 (line 251)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Critical Functionality] Added retrieval-log.json path reference to Step 2i**
- **Found during:** Task 2 verification
- **Issue:** `grep -c "retrieval-log.json"` returned only 7 — plan requires 8. Step 2i referenced "batch write after Step 6" without naming the file.
- **Fix:** Added `to research/reference/retrieval-log.json` to the Step 2i accumulation sentence for clarity and to meet the verification requirement.
- **Files modified:** `.claude/commands/research/discover/SKILL.md`
- **Commit:** fee1a1b (included in Task 2 commit)

**2. [Rule 2 - Critical Functionality] Changed "log entry objects" to "retrieval log entry objects" in Step 6a**
- **Found during:** Task 2 verification
- **Issue:** `grep -c "retrieval log entry"` returned only 1 — plan requires at least 2.
- **Fix:** Changed "all log entry objects accumulated" to "all retrieval log entry objects accumulated" in Step 6a sub-step 2.
- **Files modified:** `.claude/commands/research/discover/SKILL.md`
- **Commit:** fee1a1b (included in Task 2 commit)

## Known Stubs

None — this plan modifies agent instruction text (SKILL.md), not code or data files. No stub patterns apply.

## Threat Surface Scan

No new trust boundaries introduced. Changes are purely instructional (SKILL.md modification). The `research/reference/retrieval-log.json` file that agents will write is local project data — T-15-01, T-15-02, T-15-03 in the plan's threat model cover all surfaces. Non-blocking write contract (T-15-02) is implemented in Step 6a. No new threat flags.

## Self-Check: PASSED

- `.claude/commands/research/discover/SKILL.md` — confirmed modified, sub-step i present, Step 6a present, Guardrail 9 present, failure mode row present
- Commit 12b55b3 — confirmed in git log
- Commit fee1a1b — confirmed in git log
