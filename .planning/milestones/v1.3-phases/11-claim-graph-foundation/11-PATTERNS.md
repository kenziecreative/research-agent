# Phase 11: Claim Graph Foundation - Pattern Map

**Mapped:** 2026-04-20
**Files analyzed:** 4 new/modified files
**Analogs found:** 4 / 4

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `research/reference/claim-graph.json` | data registry | batch write (append per audit run) | `.claude/reference/templates/canonical-figures.json` (copied to `research/reference/canonical-figures.json` at init) | exact — same role, same access pattern, same project-directory location convention |
| `.claude/commands/research/audit-claims/SKILL.md` | skill (multi-step workflow) | request-response with file I/O side-effect | `.claude/commands/research/audit-claims/SKILL.md` itself (modification, not net-new) — best secondary analog: `.claude/commands/research/cross-ref/SKILL.md` lines 9-10 (reads canonical-figures.json, writes JSON registry) | role-match — existing skill extended with a JSON write step |
| `.claude/commands/research/init/SKILL.md` | skill (scaffolding) | file I/O (create-once scaffolding) | `.claude/commands/research/init/SKILL.md` itself (modification) — the exact lines that copy `canonical-figures.json` to `research/reference/` are the direct pattern | exact — add one more copy/write alongside the existing canonical-figures.json scaffold |
| `.claude/agents/research-integrity.md` | agent (integrity checker) | request-response, read-only analysis | `.claude/agents/research-integrity.md` itself (modification) — check 5 (Cross-Phase Drift) is the closest existing check pattern: reads canonical-figures.json, flags mismatches | role-match — new check mirrors check 5 structure |

---

## Pattern Assignments

### `research/reference/claim-graph.json` (data registry, batch write)

**Analog:** `.claude/reference/templates/canonical-figures.json` (the template that becomes `research/reference/canonical-figures.json`)

**Schema pattern** (entire file — 3 lines):
```json
{
  "figures": []
}
```

The claim-graph.json file follows this same shell. The top-level key changes from `"figures"` to `"claims"`. The initial scaffold is an empty array. Every audit run appends claim node objects to this array.

**Claim node schema** (per D-05, modeled on the canonical-figures.json field pattern documented in `research/reference/source-standards.md` lines 18-19):
```json
{
  "id": "short-slug-string",
  "text": "The claim text as extracted from the draft.",
  "phase": 1,
  "section": "Section Name",
  "confidence_tier": "High|Moderate|Low|Insufficient",
  "source_files": ["note-filename-1.md", "note-filename-2.md"],
  "figure_ids": ["figure-slug-1"],
  "evidence_directness": "Direct|Indirect",
  "source_count": 3
}
```

**Field sourcing:** `confidence_tier`, `evidence_directness`, and `source_count` are all computed during audit-claims step 8a — they are already in agent working memory when the graph write happens. `source_files` comes from the claim trace in audit-claims step 5. `figure_ids` comes from cross-referencing claim text against the canonical-figures.json registry already read in step 6a.

**ID generation — Claude's discretion:** Use a sequential integer prefix plus a short slug derived from the first 4-5 words of the claim text (lowercase, hyphenated, non-alphanumeric stripped). Example: `"c001-market-size-exceeds-four"`. Sequential prefix guarantees uniqueness; slug makes IDs human-scannable without opening the file. On re-audit of the same draft, claims already present in claim-graph.json (matched by `phase` + `section` + `text` equality) should be overwritten, not duplicated.

**Error handling — Claude's discretion:** Graph write failure during audit-claims should surface as a warning in the audit report but must NOT prevent audit promotion. The audit gate protects research quality; a graph write failure is an infrastructure problem, not an evidence problem. Log: "WARNING: claim-graph.json write failed at [path] — graph is incomplete for this phase. Re-run `/research:audit-claims` to retry graph write without re-running the full audit." Do not fail or hold the audit.

---

### `.claude/commands/research/audit-claims/SKILL.md` (skill modification)

**Analog:** The existing file at `.claude/commands/research/audit-claims/SKILL.md`, specifically step 6a (lines 30-30) which reads canonical-figures.json and step 9 (line 79) which writes the audit report — both are existing JSON read/write steps in the same skill.

**Insertion point:** After step 8a (confidence tier computation, lines 55-77) and before step 9 (write audit report, line 79). The new step is numbered 8b.

**Step 8b — write claim graph nodes pattern** (modeled on step 6a's canonical-figures.json read pattern and step 9's write-then-verify pattern):

```markdown
8b. **Write claim graph nodes to `research/reference/claim-graph.json`.**

   For every factual claim traced in step 5, construct a claim node using the data already in context:
   - `id` — sequential prefix (c001, c002, ...) + slug from first 4-5 words of claim text
   - `text` — the claim text as traced in step 5
   - `phase` — current phase number (read from STATE.md `Active phase` field)
   - `section` — section name from the audit pass
   - `confidence_tier` — tier computed in step 8a for this claim's section
   - `source_files` — array of note filenames traced in step 5
   - `figure_ids` — array of figure IDs from canonical-figures.json that appear in this claim (empty array if none)
   - `evidence_directness` — Direct/Indirect classification from step 8a
   - `source_count` — integer count of independent sources from step 8a

   Read `research/reference/claim-graph.json`. If the file does not exist, create it with `{"claims": []}`. If it exists but fails to parse as JSON, log a warning in the audit report and skip the graph write — do not fail the audit.

   For claims already present (matched by phase + section + text), overwrite. For new claims, append.

   Write the updated JSON back to `research/reference/claim-graph.json`.

   **After writing, verify the write succeeded.** Re-read the file and confirm it parses as valid JSON with a `claims` array. If the read fails or the array is missing, log: "WARNING: claim-graph.json write failed — graph incomplete for this phase." Do not fail the audit or block promotion.
```

**Positioning rule:** This step captures all claims regardless of audit pass/fail outcome (D-04). The graph write step must execute before the pass/fail branch in `## Pass/Fail Criteria`, so that both pass and fail paths see a complete graph.

**Pass/Fail criteria unchanged:** The graph write result does not affect pass/fail determination. Only evidence issues affect the gate.

---

### `.claude/commands/research/init/SKILL.md` (skill modification)

**Analog:** The existing init SKILL.md, specifically Step 5 "Other Files" section (lines 647-683) which copies `canonical-figures.json` to `research/reference/canonical-figures.json`.

**Insertion point:** Immediately after the canonical-figures.json copy, within the same "Other Files" block.

**Pattern to copy from** (init SKILL.md line 683):
```
- Copy `.claude/reference/templates/canonical-figures.json` to `research/reference/canonical-figures.json`
```

**New line to add** (same bullet format, immediately after):
```
- Write `research/reference/claim-graph.json` with initial content `{"claims": []}` — this is the claim graph registry, populated by `/research:audit-claims` during each phase's Verify step.
```

**Verification step update** (init SKILL.md Step 6, lines 715-733): The verification checklist at step 6 checks that `reference/canonical-figures.json` exists. Add `reference/claim-graph.json` to that same checklist item.

**Directory structure reference update** (init SKILL.md lines 399-415, the CLAUDE.md directory tree): Add a line for `claim-graph.json` alongside `canonical-figures.json`:
```
│   ├── canonical-figures.json # Single source of truth for cross-phase numbers
│   └── claim-graph.json       # Claim graph registry, written by /research:audit-claims
```

---

### `.claude/agents/research-integrity.md` (agent modification)

**Analog:** The existing `research-integrity.md`, specifically check 5 "Cross-Phase Drift" (lines 40-43), which reads `research/reference/canonical-figures.json` and flags mismatches. The new check follows the identical read-then-compare-then-flag structure.

**Check 5 pattern to mirror** (lines 40-43):
```markdown
### 5. Cross-Phase Drift
- If the file references findings from previous phases, read those phase outputs and compare. Every carried-forward number must match exactly.
- Read `research/reference/canonical-figures.json`. If the number is already registered, verify it matches the canonical value. If it doesn't match, flag it.
- If the number is not yet registered and this is a cross-phase citation, register it in `canonical-figures.json` with all required fields (id, value, unit, qualifier, source_phase, source_file, confidence, registered_when, referenced_by).
- Flag: "CROSS-PHASE DRIFT: Line [N] says [value], but canonical-figures.json (or [phase output file]) says [different value] for the same finding."
```

**New check 9 — Claim Graph Consistency** (insert after check 8, before "## How to Use This Agent"):

```markdown
### 9. Claim Graph Consistency
- This check applies only when `research/reference/claim-graph.json` exists and the file under review is a phase output (`research/outputs/`) or draft (`research/drafts/`).
- Read `research/reference/claim-graph.json`. If the file does not exist, skip this check without comment (the graph is scaffolded at init but populated only after the first audit-claims run).
- For each claim node in the graph whose `phase` matches the current phase under review: verify the `confidence_tier` in the graph matches the tier shown for that section in the audit report (if an audit report exists in `research/audits/`).
- Flag: "CLAIM GRAPH INCONSISTENCY: claim [id] in claim-graph.json has confidence_tier [A], but the audit report for [phase output] shows [B] for section [section]. The graph may have been written from a stale audit pass."
- This check is advisory — it surfaces drift between the graph and the audit record, but does not block promotion.
```

**"How to Use This Agent" section update** (lines 63-73): Add claim-graph.json to the invocation trigger list:
```
- After `/research:audit-claims` writes claim nodes to claim-graph.json (check 9 catches graph-audit consistency drift)
```

---

## Shared Patterns

### JSON Registry Read-Then-Write Pattern
**Source:** `audit-claims/SKILL.md` lines 30 (read canonical-figures.json), and step 9's write-then-verify sequence (lines 79-81)
**Apply to:** The new step 8b in audit-claims; the init scaffolding line for claim-graph.json

The established pattern is:
1. Read the registry file
2. Check if it exists — if not, note the absence and handle gracefully (skip or create)
3. Check if it parses — if not, stop with a specific error message
4. If it parses, operate on the data
5. Write back
6. Re-read to verify the write succeeded before reporting success

For claim-graph.json, step 3 failure is non-blocking (warn + skip, not halt), because the graph is supplementary to the audit gate. For canonical-figures.json, step 3 failure is blocking (D-04 in audit-claims: "stop the audit and tell the user").

### Scaffolding Copy/Write Pattern
**Source:** `init/SKILL.md` "Other Files" section (lines 648-683)
**Apply to:** The claim-graph.json scaffolding addition in init

All registry files are created at init using either:
- `Copy .claude/reference/templates/X` to `research/reference/X` (for files with a template)
- `Write research/reference/X with initial content [...]` (for files with no template, like the new claim-graph.json)

claim-graph.json uses the second form — there is no `.claude/reference/templates/claim-graph.json` template needed since the scaffold is trivially small (`{"claims": []}`).

### Integrity Check Structure
**Source:** `research-integrity.md` check 5 (lines 40-43) and check 8 (lines 54-61)
**Apply to:** New check 9 in research-integrity.md

All integrity checks follow this structure:
- Precondition (when does this check apply / when to skip)
- Read the reference file
- For each relevant item, compare against expected value
- Flag with a structured prefix (ALL_CAPS_CHECK_TYPE: ...) including file, line, what-the-file-says, what-source-says

Check 9 is advisory (does not block), following the same advisory pattern as check 7 (Confidence Inflation) — flags are reported but do not stop promotion.

---

## No Analog Found

All four files have clear analogs. No entries needed here.

---

## Metadata

**Analog search scope:** `.claude/commands/research/`, `.claude/agents/`, `.claude/reference/templates/`
**Files scanned:** 7 (audit-claims/SKILL.md, init/SKILL.md, cross-ref/SKILL.md, research-integrity.md, canonical-figures.json template, source-standards.md template, cross-reference.md template)
**Pattern extraction date:** 2026-04-20
