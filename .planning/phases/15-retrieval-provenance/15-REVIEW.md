---
phase: 15-retrieval-provenance
reviewed: 2026-04-20T22:00:00Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - .claude/commands/research/discover/SKILL.md
  - .claude/commands/research/init/SKILL.md
findings:
  critical: 0
  warning: 2
  info: 2
  total: 4
status: issues_found
---

# Phase 15: Code Review Report

**Reviewed:** 2026-04-20T22:00:00Z
**Depth:** standard
**Files Reviewed:** 2
**Status:** issues_found

## Summary

Phase 15 adds retrieval provenance infrastructure: a `retrieval-log.json` registry initialized by `init/SKILL.md` and populated by `discover/SKILL.md` after each discovery run. The implementation follows established patterns (read-modify-write, non-blocking failure contract, flat JSON array) correctly in both files. The init scaffolding is clean — the write statement and verify checklist additions are in the right locations and match the canonical pattern exactly.

Two warnings are present in `discover/SKILL.md`: a sequencing ambiguity where Step 6a claims to run "after verification succeeds" but the candidates file verification is textually inside Step 7 (which runs after Step 6a), and an incomplete `deduped_count` field description that omits the re-run update scenario. Two info items address a missing field value specification for skipped channels and an unused `template` enum example in the failure table.

## Warnings

### WR-01: Step 6a precondition references a verification that hasn't happened yet

**File:** `.claude/commands/research/discover/SKILL.md:236`
**Issue:** Step 6a opens with "After the candidates file write and verification succeed, write the accumulated log entries..." but the candidates file verification occurs inside Step 7 (line 253: "Before printing the summary, verify the write succeeded. Re-read `research/discovery/{phase}-candidates.md`..."). The steps execute in order: Step 6 (write) → Step 6a (log write) → Step 7 (verify + summary). Step 6a's precondition states a dependency on verification that is satisfied only by the subsequent step. An agent following this literally would need to verify the candidates file before executing Step 6a, but the verification instruction lives in Step 7. This could lead to: (a) an agent skipping Step 6a until after Step 7's verify, disrupting the Failure Contract on line 249 (which says "If Step 6 fails (candidates file not written), do not attempt Step 6a"), or (b) an agent double-verifying, first before Step 6a and again inside Step 7.

**Fix:** Separate the candidates file verification from Step 7 into its own discrete gate between Step 6 and Step 6a. Move the verify instruction to a Step 6 sub-step:

```markdown
### Step 6: Write candidates file

...

**After writing, verify the write succeeded:** Re-read `research/discovery/{phase}-candidates.md`
and confirm it exists and contains the Summary table plus at least one channel section. If the
read fails or the file is missing the Summary table, do not proceed to Step 6a — surface the
write failure to the user with the target path, preserve the in-memory candidate list so the
user can direct a retry, and stop.

### Step 6a: Append retrieval log entries

After the candidates file write and verification above succeed, write the accumulated log
entries to `research/reference/retrieval-log.json`.
...

### Step 7: Print completion summary and offer to process
```

Remove the duplicate verification preamble from Step 7 (line 253). The failure contract on line 249 then has a clean enforcement point — Step 6's verify is the gate, Step 6a is conditional on that gate passing.

---

### WR-02: `deduped_count` field description understates when it is non-zero

**File:** `.claude/commands/research/discover/SKILL.md:121`
**Issue:** The Step 2i field table describes `deduped_count` as "Set to 0 here; updated after Step 4 dedup for multi-tool channels." The phrase "multi-tool channels" implies `deduped_count` is only updated for web-search (the multi-tool channel). But Step 4 (line 148) also updates `deduped_count` for single-tool channels during re-runs: "For dedup against an existing candidates file (re-run), set `deduped_count` on each affected entry to the number of that entry's URLs that were already present." A single-tool channel like `academic` or `financial` can have a non-zero `deduped_count` on a re-run. An agent following only the field table description would leave `deduped_count` at 0 for single-tool channels, producing incorrect log entries for all re-run scenarios.

**Fix:** Update the field table description to cover both update scenarios:

```markdown
| `deduped_count` | integer | Set to 0 here; updated after Step 4 in two cases: (1) cross-tool
dedup within a multi-tool channel (e.g., Exa URLs that matched Tavily URLs — set on the later
tool's entry); (2) re-run dedup against the existing candidates file — set on each affected
entry to the number of that entry's URLs already present in the file. |
```

---

## Info

### IN-01: `query` and `template` field values undefined for "skipped" channel entries

**File:** `.claude/commands/research/discover/SKILL.md:125`
**Issue:** Line 125 specifies that for failed/skipped channels, an entry is accumulated with `results_count: 0` and `urls: []`. But `query` and `template` are required fields in the schema (lines 115–116), and for a "skipped" channel (not mapped for this phase), no query is ever constructed or executed — so there is no natural value. The spec does not say what to write for these fields in the skipped case. An agent must guess: empty string `""`, `null`, or omit the field. This inconsistency creates non-uniform log entries that break field-equality filtering for skipped channels.

**Fix:** Add explicit guidance adjacent to line 125:

```markdown
**Skipped channels:** Set `query: ""`, `template: ""` (no query was constructed),
`results_count: 0`, `urls: []`, `status: "skipped"`, `degraded_to: null`,
`deduped_count: 0`.
```

---

### IN-02: Failure modes table not updated to reflect new retrieval log failure mode

**File:** `.claude/commands/research/discover/SKILL.md:513-529`
**Issue:** The Common Failure Modes table (lines 513–529) documents known failure patterns. Phase 15 introduces a new one — "retrieval-log.json write failure blocking discovery output" — which is already addressed by Guardrail 9 (line 492). However, the Failure Modes table is not updated to include this pattern. Guardrail 9 and Step 6a's failure contract are consistent, but the failure modes table is the canonical reference during incident review. Omitting it from the table means an agent doing a post-incident review of a log write failure won't find a documented resolution path in the table.

**Fix:** Add a row to the Common Failure Modes table:

```markdown
| Retrieval log write failure blocking discovery output | Step 6a non-blocking contract: if
retrieval-log.json cannot be read, parsed, or written, print WARNING and proceed. The
candidates file is the primary artifact. Never abort, retry, or ask the user to resolve
before continuing. |
```

---

_Reviewed: 2026-04-20T22:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
