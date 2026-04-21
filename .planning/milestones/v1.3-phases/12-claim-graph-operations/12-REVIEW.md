---
phase: 12-claim-graph-operations
reviewed: 2026-04-20T00:00:00Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - .claude/agents/research-integrity.md
  - .claude/commands/research/audit-claims/SKILL.md
findings:
  critical: 0
  warning: 3
  info: 2
  total: 5
status: issues_found
---

# Phase 12: Code Review Report

**Reviewed:** 2026-04-20
**Depth:** standard
**Files Reviewed:** 2
**Status:** issues_found

## Summary

Both files define tightly coupled components: `research-integrity.md` is an agent that performs post-hoc integrity checks, and `audit-claims/SKILL.md` is the primary audit command that drives claim graph writes. Phase 12 added claim graph consistency (check 9) to the integrity agent and the drift detection + `drift_warning` annotation lifecycle to audit-claims.

The logic is mostly coherent. Three warning-level issues were found: an ambiguous skip boundary in audit-claims step 6a that could cause an agent to attempt drift detection without canonical-figures.json in memory; an underspecified detection mechanism for `expected_value` in drift warnings (no stored last-audit value exists in the claim node schema); and a missing path-derivation instruction in the integrity agent's check 9 for locating audit reports. Two info-level items round out the findings.

---

## Warnings

### WR-01: Drift detection runs inside a skip branch that never loaded its dependency

**File:** `.claude/commands/research/audit-claims/SKILL.md:30-44`

**Issue:** When `canonical-figures.json` does not exist, step 6a instructs the agent to "continue to step 7." However, the Drift detection sub-section immediately below (same step, same indentation block) contains the phrase "look up the current value in the canonical-figures.json registry **(already read above)**." An agent that reads "continue to step 7" as terminating only the canonical-figures check — not the entire 6a block including drift detection — would then attempt drift detection while referencing a registry that was never loaded. This is an instruction boundary ambiguity that a language model may resolve incorrectly.

**Fix:** Make the skip scope explicit. Change the skip instruction to:

```
If the file does not exist, note "No canonical figures registry yet..." and skip the remainder
of step 6a entirely (including drift detection below), then continue to step 7.
```

Or, restructure drift detection as step 6b so it is visually and semantically separate from the canonical-figures check, with its own dependency guard: "If canonical-figures.json was not read in step 6a (file absent), skip this step."

---

### WR-02: `expected_value` in drift_warning has no persisted source in the claim node schema

**File:** `.claude/commands/research/audit-claims/SKILL.md:32-37`

**Issue:** The drift detection mechanism describes the comparison as "detectable when the claim text contains a specific figure that no longer matches the canonical value." The `drift_warning` object it writes includes `"expected_value": "<value stored in claim at last audit>"` — but the claim node schema (step 8b, lines 103-111) defines no field that stores the value as it was at last audit. The only candidate is the free-text `text` field, which the agent must parse to extract the figure. This is brittle: if the claim text is narrative prose containing the figure embedded in a sentence, the agent must perform ad-hoc extraction with no format guarantee. A structured `audited_value` field per figure reference would make detection unambiguous and `expected_value` directly readable without text parsing.

**Fix:** Add a `figure_snapshots` field to the claim node schema in step 8b:

```json
"figure_snapshots": {
  "<figure_id>": "<value at time of this audit>"
}
```

Then in drift detection, compare `figure_snapshots[figure_id]` against the current canonical value. `expected_value` in the drift_warning is then populated directly from `figure_snapshots[figure_id]`, not extracted from prose.

---

### WR-03: Check 9 in the integrity agent provides no path-derivation logic for locating audit reports

**File:** `.claude/agents/research-integrity.md:64-68`

**Issue:** Check 9 instructs the agent to "verify the `confidence_tier` in the graph matches the tier shown for that section in the audit report (if an audit report exists in `research/audits/`)." No instruction is given for how to derive the audit report filename from the file under review. The audit-claims skill writes reports to `research/audits/<original-filename>-audit.md`. When the integrity agent is reviewing `research/outputs/phase-3-vendors.md`, it must infer that the corresponding audit report is `research/audits/phase-3-vendors-audit.md`. This derivation is implicit. An agent that does not make this connection correctly will either skip the audit report lookup silently (check 9 produces no finding) or error.

**Fix:** Add an explicit path-derivation instruction to check 9:

```
To locate the audit report: take the filename of the file under review (without directory),
strip the extension, append -audit.md, and look for that file in research/audits/.
Example: reviewing research/outputs/phase-3-vendors.md → look for
research/audits/phase-3-vendors-audit.md. If no matching audit report exists, skip the
tier comparison silently (the graph may predate the audit report or the audit ran before
check 9 was introduced).
```

---

## Info

### IN-01: Step numbering uses a non-standard `6a` / `8a` / `8b` scheme alongside sequential integers

**File:** `.claude/commands/research/audit-claims/SKILL.md:29-100`

**Issue:** The process steps use a mixed numbering scheme: steps 1-6 are integers, then step 6a and (later) 8, 8a, 8b before jumping to 9. There is no step 7 in the numbered list — step 7 is referenced as a "continue to step 7" target from within step 6a, but the step labeled `7.` is the "Classify each issue found" step at line 46. The numbering is internally consistent once traced, but the `6a` label creates a visual gap where an agent might treat `6a` as a sub-step of `6` rather than a peer step in sequence. This is the same root ambiguity that feeds WR-01.

**Fix:** Renumber the sequence cleanly: 1 through N with no alphabetic suffixes, or use alphabetic suffixes consistently and document that they are peer steps (e.g., "6 and 6a are both required; 6a runs after 6 completes").

---

### IN-02: Integrity agent check 9 scope condition silently narrows to "phase" match, which requires STATE.md awareness the agent lacks

**File:** `.claude/agents/research-integrity.md:64-67`

**Issue:** Check 9 says "for each claim node in the graph whose `phase` matches the current phase under review." But the integrity agent's instructions never tell it to read `research/STATE.md` to know the current phase number. It must infer the current phase from the file path or the frontmatter of the file under review. If the file path or frontmatter does not contain the phase number explicitly, the agent cannot filter claim nodes by phase — it would either compare all claim nodes or compare none. This could produce false negatives (missing real inconsistencies) or false positives (flagging nodes from other phases).

**Fix:** Add an instruction to check 9 directing the agent how to determine the current phase: "Determine the phase number from the `phase:` field in the file under review's frontmatter, or from the numeric segment of the filename (e.g., `phase-3-vendors.md` → phase 3). If phase cannot be determined, compare all claim nodes against the audit report rather than filtering by phase."

---

_Reviewed: 2026-04-20_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
