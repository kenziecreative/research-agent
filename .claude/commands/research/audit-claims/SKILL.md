---
name: audit-claims
description: Fact-check a research draft against source notes and promote to outputs if it passes
argument-hint: "[filepath]"
---

# /research:audit-claims

Audit a research draft for unsupported claims. If the audit passes, promote the draft from `research/drafts/` to `research/outputs/`. If it fails, the draft stays in `drafts/` until issues are fixed and the audit is re-run.

## Input
The user will provide a filepath to audit (should be a file in `research/drafts/`).

## Process

1. **Read the file to audit.**
2. **Read `research/reference/source-standards.md`** for evidence rules.
3. **Read `research/reference/writing-standards.md`** for precision preservation and synthesis rules.
4. **Read `.claude/reference/evidence-failure-modes.md`** for the catalog of evidence degradation patterns. Check for each pattern type during the audit.
5. **For every factual claim in the document:**
   - Does it trace to a file in `research/notes/` or a previous phase output? If yes, note the source.
   - Is the claim accurately represented? Check against the source note — same numbers, same ranges, same qualifiers.
   - Is the confidence language appropriate given the number of supporting sources?
   - Are contradicting sources acknowledged?
   - Is dated information flagged if older than 2 years?
   - Are ranges preserved fully? (not narrowed, not midpointed)
   - Are qualifiers from the source preserved? (not dropped during compression)
   - If a number is carried from a previous phase, does it match the original exactly?
6. **Cross-document consistency check:** If other files already exist in `research/outputs/` or `research/drafts/`, check whether this draft and those documents cite the same numbers for the same claims. Flag any inconsistencies.
6a. **Canonical figures check:** Read `research/reference/canonical-figures.json`. For every number in the draft that exists in the canonical registry, verify it matches exactly. Flag any discrepancy as high-severity.
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
8. **Generate audit scorecard:**
   - Total specific claims checked: N
   - Claims traced to source: N (X%)
   - Claims matching source value and context: N (X%)
   - Claims with appropriate qualifiers: N (X%)
   - Issues found: N mismatches, N unsourced, N drift, N range narrowed
   - Severity distribution: N high, N moderate, N low
9. **Write audit report to `research/audits/<original-filename>-audit.md`** with: scorecard, pass/fail determination, findings table, and list of claims that need correction.

## Pass/Fail Criteria

A draft passes when:
- Zero high-severity issues (unsupported claims, misrepresented data, number drift)
- Zero moderate-severity issues left unresolved (range narrowed, qualifier dropped, cross-document inconsistency)
- 100% of specific numerical claims trace to a source note or phase output with a matching value
- Low-severity issues (missing attribution, stale data) are acceptable if documented in the audit report

There is no percentage threshold. Every specific claim must check out. The scorecard is for visibility into the draft's quality, not for setting a "good enough" bar.

## After Audit

- **If PASS:** Move the file from `research/drafts/` to `research/outputs/`. Update `research/STATE.md` to reflect the output is finalized. Tell the user: "Audit passed. Promoted to `research/outputs/<filename>`."
- **If FAIL:** Leave the file in `research/drafts/`. List every issue with line-level specifics and what needs to change. The user or agent must fix the issues in the draft, then run `/research:audit-claims` again on the same file. Do not promote until it passes.

## Non-Negotiable Rules

- **No bypassing.** If the user asks to skip the audit or move a failed draft to outputs manually, refuse. Explain that the audit gate exists to protect research quality and that fixing the issues is faster than dealing with unreliable findings downstream.
- **No soft passes.** Do not downgrade a high-severity issue to moderate to make the draft pass. If a claim doesn't trace to a source, it's unsupported regardless of whether the claim "feels right."
- **Re-audit after fixes.** When a draft is fixed after a failed audit, run the full audit again — do not spot-check only the previously flagged issues. Fixes can introduce new problems.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Soft passes — downgrading severity to make a draft pass | Every severity classification must cite the specific rule it violates. If a claim lacks a source, it is high-severity regardless of how plausible it sounds. |
| Scope narrowing — auditing only "important" claims while skipping minor ones | Audit every factual claim, including numbers in passing references and claims inherited from prior phases. Minor claims are where drift hides. |
| Treating audit as formality — skimming rather than tracing each claim to its source | For each claim, open the cited source note and verify the value. Do not rely on memory of what the source said. |
| Post-fix spot-checking — only re-checking flagged issues after a fix | Re-run the full audit after fixes. Edits can introduce new mismatches, especially when adjusting ranges or qualifiers. |
| Consistency blind spot — auditing the draft in isolation without checking other outputs | Always run the cross-document consistency check and canonical figures check. Same claim, different numbers across documents is high-severity. |

## Output
Scorecard summary and pass/fail status. If failed, list every issue with its location and what needs to change. If passed, confirm the promotion to `outputs/`.
