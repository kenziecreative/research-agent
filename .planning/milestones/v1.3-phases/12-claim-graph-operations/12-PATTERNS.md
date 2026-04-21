# Phase 12: Claim Graph Operations - Pattern Map

**Mapped:** 2026-04-20
**Files analyzed:** 2 modified files
**Analogs found:** 2 / 2

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.claude/commands/research/audit-claims/SKILL.md` | skill (multi-step workflow) | request-response with file I/O side-effect | `.claude/commands/research/audit-claims/SKILL.md` itself (modification) — this phase extends three sub-steps within the same file | exact — new logic grafts into existing step 6a (canonical-figures check), step 7 (issue taxonomy), step 8 (scorecard), and step 8b (graph write) |
| `.claude/agents/research-integrity.md` | agent (integrity checker) | request-response, read-only analysis | `.claude/agents/research-integrity.md` itself (modification) — check 9 (Claim Graph Consistency) already exists; Phase 12 extends it to surface active drift_warnings | role-match — extension mirrors check 5 (Cross-Phase Drift) and the advisory pattern of check 9 already in place |

---

## Pattern Assignments

### `.claude/commands/research/audit-claims/SKILL.md` (skill modification)

**Analog:** The existing file at `.claude/commands/research/audit-claims/SKILL.md` — Phase 12 modifies four distinct locations within it.

---

#### Modification 1: Drift detection grafted onto step 6a (canonical-figures check)

**Existing step 6a pattern** (line 30 — the canonical-figures read-compare-flag loop):
```markdown
6a. **Canonical figures check:** Read `research/reference/canonical-figures.json`. If the file does not
    exist, note "No canonical figures registry yet..." and continue to step 7. If the file exists but
    fails to parse as JSON, stop the audit and tell the user [...]. If the file exists and parses
    correctly, for every number in the draft that exists in the canonical registry, verify it matches
    exactly. Flag any discrepancy as high-severity.
```

**Pattern to extend:** After the existing canonical-figures comparison loop, add a drift detection pass that reads `claim-graph.json` and compares stored figure values against registry values. The read of `canonical-figures.json` already happens in step 6a — drift detection consumes the already-loaded registry to avoid a second file read.

**Drift detection addition — append to step 6a after the existing canonical-figures check:**
```markdown
   **Drift detection (claim graph):** If `research/reference/claim-graph.json` exists and parses
   correctly, walk every claim node whose `figure_ids` array is non-empty. For each figure ID listed,
   look up the current value in the canonical-figures.json registry (already read above). If the
   registry value differs from the value stored when the claim was written (detectable when the claim
   text contains a specific figure that no longer matches the canonical value), annotate the claim node
   with a `drift_warning` object:
   {
     "figure_id": "<id from figure_ids>",
     "expected_value": <value stored in claim at last audit>,
     "canonical_value": <current registry value>
   }
   Write the annotated claim-graph.json back to disk. Do not alter the claim's `confidence_tier`.
   Collect all drift warnings for reporting in the findings table (step 7) and scorecard (step 8).
   If claim-graph.json does not exist or fails to parse, skip drift detection without comment — the
   graph is supplementary infrastructure; its absence does not block the audit.

   **Transitive detection:** Drift is resolved in the same read pass — a figure ID may appear in
   multiple claim nodes. Flag all nodes referencing a revised figure; no separate traversal step is
   needed because `figure_ids` is a flat array on each node.
```

**Error handling pattern to follow** (from step 8b, line 92-98):
```markdown
   If the file does not exist, [note absence and skip].
   If it exists but fails to parse as JSON, log a warning [...] and skip — do not fail the audit.
   After writing, verify the write succeeded. Re-read the file and confirm it parses as valid JSON.
   If the read fails [...], log: "WARNING: claim-graph.json write failed..."
   Do not fail the audit or block promotion.
```

---

#### Modification 2: Add "Drift detected" as the 10th issue type in step 7

**Existing step 7 pattern** (lines 31-40 — the issue taxonomy list):
```markdown
7. **Classify each issue found:**
   - **Unsupported claim** — No source note backs this up
   - **Misrepresented** — Source says something different than what's claimed
   - **Missing attribution** — Claim is supportable but citation is missing
   - **Stale data** — Information may be outdated
   - **Contradiction ignored** — Sources disagree but only one side is presented
   - **Range narrowed** — Source range was compressed or midpointed
   - **Qualifier dropped** — Source qualification was lost in compression
   - **Number drift** — Figure doesn't match the cited source
   - **Cross-document inconsistency** — Same claim, different figures across documents
```

**New entry to append** (10th bullet, same format as the nine above):
```markdown
   - **Drift detected** — A canonical figure this claim references has changed since the claim was
     written; `drift_warning` field has been set on the claim node in claim-graph.json
```

**Severity classification:** Moderate (consistent with D-04 and D-05 — advisory-not-gate, same as stale data and cross-document inconsistency). Not high-severity because drift is evidence weakness over time, not accuracy failure at time of writing.

---

#### Modification 3: Extend step 8 scorecard to surface drift warnings and add weakest-link rollup

**Existing step 8 scorecard pattern** (lines 41-53):
```markdown
8. **Generate audit scorecard:**
   - Total specific claims checked: N
   - Claims traced to source: N (X%)
   - Claims matching source value and context: N (X%)
   - Claims with appropriate qualifiers: N (X%)
   - Issues found: N mismatches, N unsourced, N drift, N range narrowed
   - Severity distribution: N high, N moderate, N low

   Section confidence tiers:
   - [Section name]: [Tier] — [brief rationale]
   - [Section name]: [Tier] — [brief rationale]

   Overall confidence: [Tier of lowest section] (weakest-link determines overall)
```

**Scorecard additions (Claude's discretion on exact position — insert before "Section confidence tiers"):**
```markdown
   - Drift warnings: N claims referencing figures that have changed since last audit
     (claim IDs: [id1, id2, ...] — review canonical-figures.json for current values)
```

**Weakest-link rollup:** Already partially satisfied by the existing `Overall confidence: [Tier of lowest section]` line in step 8. The extension is to make the per-section tier display in step 8 explicitly source each section's tier from the claim nodes in claim-graph.json rather than recomputing from the sources. Tier ordering for the rollup: Insufficient < Low < Moderate < High. The minimum tier per section group becomes that section's displayed tier.

**Step 8 display extension for weakest-link (replace existing "Section confidence tiers" block):**
```markdown
   Section confidence tiers (weakest-link per section from claim graph):
   - [Section name]: [minimum tier among claims in this section] — weakest claim: [claim id], [rationale]
   - [Section name]: [minimum tier] — [weakest claim id], [rationale]

   Overall confidence: [minimum tier across all sections] (weakest-link determines overall)
```

**Tier read pattern:** Read `claim-graph.json` already loaded in step 6a drift pass. Group nodes by `section` field. For each group, take the minimum `confidence_tier` value using ordering: Insufficient=0, Low=1, Moderate=2, High=3. The node with the lowest score is the weakest link for that section.

---

#### Modification 4: Extend step 8b to clear or preserve drift_warning on re-audit

**Existing step 8b pattern** (lines 79-98 — the claim node upsert):
```markdown
   For claims already present in the graph (matched by `phase` + `section` + `text` equality),
   overwrite the existing node with the new data. For new claims, append to the `claims` array.
```

**Extension:** On re-audit, when overwriting an existing claim node, the drift detection pass in step 6a will have already evaluated all figure_ids against the current registry. If the figure values now match (drift resolved), write the node without a `drift_warning` field. If drift persists, the `drift_warning` field written in step 6a's drift pass will be included in the overwrite. This means step 8b does not need additional logic — the drift_warning is set or absent based on the step 6a pass that precedes it.

**Stated pattern (D-11):** The `drift_warning` field persists until re-audit clears it (re-audit overwrites the node via step 8b with fresh data from the current source state).

---

### `.claude/agents/research-integrity.md` (agent modification)

**Analog:** The existing file at `.claude/agents/research-integrity.md`, specifically:
- Check 5 "Cross-Phase Drift" (lines 40-43) — read-then-compare-then-flag structure
- Check 9 "Claim Graph Consistency" (lines 63-68 in the current file) — already reads claim-graph.json, advisory pattern

**Check 9 currently reads** (lines 63-68):
```markdown
### 9. Claim Graph Consistency
- This check applies only when `research/reference/claim-graph.json` exists and the file under review
  is a phase output (`research/outputs/`) or draft (`research/drafts/`).
- Read `research/reference/claim-graph.json`. If the file does not exist, skip this check without
  comment (the graph is scaffolded at init but populated only after the first audit-claims run).
- For each claim node in the graph whose `phase` matches the current phase under review: verify the
  `confidence_tier` in the graph matches the tier shown for that section in the audit report (if an
  audit report exists in `research/audits/`).
- Flag: "CLAIM GRAPH INCONSISTENCY: claim [id] in claim-graph.json has confidence_tier [A], but the
  audit report for [phase output] shows [B] for section [section]..."
- This check is advisory — it surfaces drift between the graph and the audit record, but does not
  block promotion.
```

**Extension to add to check 9** (append to the existing check, same advisory pattern):
```markdown
- Additionally, for any claim node with a `drift_warning` field, surface the warning:
  "DRIFT WARNING ACTIVE: claim [id] references figure [figure_id]. Expected value: [expected_value],
  current canonical value: [canonical_value]. The claim has not been re-audited since this figure
  changed. Run `/research:audit-claims` on the relevant draft to clear or confirm this warning."
- Drift warnings are advisory — they do not block promotion. Surface them so the human is prompted
  to act; do not silently pass over nodes with a `drift_warning` field set.
```

**Pattern to follow — check 5 flag format** (lines 42-43):
```markdown
- Flag: "CROSS-PHASE DRIFT: Line [N] says [value], but canonical-figures.json (or [phase output
  file]) says [different value] for the same finding."
```

The drift_warning surface flag follows the same ALL_CAPS_PREFIX: [detail] structure. The prefix becomes `DRIFT WARNING ACTIVE:`.

---

## Shared Patterns

### Advisory-Not-Gate Pattern
**Source:** `.claude/commands/research/audit-claims/SKILL.md` — Pass/Fail Criteria section (lines 104-114)
**Apply to:** All Phase 12 additions (drift warnings, weakest-link rollup display)

```markdown
**Confidence tiers are advisory — they indicate evidence strength, not audit compliance.** A section
can be High confidence and fail (misrepresented claim) or Low confidence and pass (single source but
accurately cited). [...] Do not use confidence tier as a reason to fail or hold a draft.
```

Drift warnings follow the same design: a drift-heavy draft fails only through the existing moderate-severity gate, not through a special drift path. Drift detected as moderate-severity items can accumulate to failure, but there is no new blocking mechanism.

### JSON Registry Read-Then-Write Pattern
**Source:** `.claude/commands/research/audit-claims/SKILL.md` step 8b (lines 92-98)
**Apply to:** The drift detection addition to step 6a (reads claim-graph.json, writes drift_warning fields back)

The established pattern:
1. Read the registry file
2. If it does not exist — note absence, skip gracefully (do not fail)
3. If it exists but fails to parse — log warning, skip (do not fail)
4. If it parses — operate on the data
5. Write back
6. Re-read to verify the write succeeded before reporting success

For the step 6a drift pass, step 3 failure is non-blocking (warn + skip, same as step 8b). The write-verify loop from step 8b applies to any claim-graph.json write initiated during drift detection.

### Integrity Check Flag Format
**Source:** `.claude/agents/research-integrity.md` check 5 (lines 40-43)
**Apply to:** The drift_warning surface step in check 9 extension

All integrity check flags follow: `ALL_CAPS_CHECK_TYPE: [file/claim reference] [what was found] [what was expected] [what needs to change]`. No exceptions. The new drift surface uses `DRIFT WARNING ACTIVE:` as the prefix.

### Issue Taxonomy Extension Pattern
**Source:** `.claude/commands/research/audit-claims/SKILL.md` step 7 (lines 31-40)
**Apply to:** Adding "Drift detected" as issue type 10

Each issue type is a single bullet with format `**Name** — one-sentence definition`. Severity is not stated inline — it is implied by audit pass/fail criteria. The new type follows the same format; severity classification (moderate) lives in the Pass/Fail Criteria section reasoning, not in the taxonomy list itself.

---

## No Analog Found

All modified files have clear analogs. No entries needed here.

The closest thing to a "no analog" is the `drift_warning` field schema — this is a new field on an existing node schema. The three required core fields from D-10 (`figure_id`, `expected_value`, `canonical_value`) are specified. Additional fields are Claude's discretion; the canonical-figures.json field conventions (string IDs, exact numeric values, qualifier strings) provide the style guide.

---

## Metadata

**Analog search scope:** `.claude/commands/research/`, `.claude/agents/`, `.planning/phases/11-claim-graph-foundation/`
**Files scanned:** 6 (audit-claims/SKILL.md full, research-integrity.md full, cross-ref/SKILL.md lines 1-60, 11-PATTERNS.md, 11-CONTEXT.md, REQUIREMENTS.md)
**Pattern extraction date:** 2026-04-20
