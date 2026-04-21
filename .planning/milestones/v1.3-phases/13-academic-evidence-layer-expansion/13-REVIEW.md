---
phase: 13-academic-evidence-layer-expansion
reviewed: 2026-04-20T00:00:00Z
depth: quick
files_reviewed: 4
files_reviewed_list:
  - .claude/reference/discovery/channel-playbooks/academic.md
  - .claude/commands/research/discover/SKILL.md
  - .claude/reference/coverage-assessment-guide.md
  - .claude/commands/research/check-gaps/SKILL.md
findings:
  critical: 0
  warning: 2
  info: 2
  total: 4
status: issues_found
---

# Phase 13: Code Review Report

**Reviewed:** 2026-04-20
**Depth:** quick (pattern-matching + targeted content review per focus areas)
**Files Reviewed:** 4
**Status:** issues_found

## Summary

Reviewed four skill/reference files produced by Phase 13 (Crossref + Unpaywall API integration and Contradicts classification extension). No security issues or data-loss bugs. Two warnings relate to a stale API summary in discover/SKILL.md and an ambiguous Unpaywall trigger edge case in academic.md Section 8. Two info items flag a mismatched DOI in the Crossref example response and a minor terminology inconsistency in the Contradicts definition between the two files that define it.

---

## Warnings

### WR-01: discover/SKILL.md Academic channel summary still describes only OpenAlex

**File:** `.claude/commands/research/discover/SKILL.md:382-390`
**Issue:** The "Academic (channel-type: academic)" block in the "Channel Execution: HTTP API Channels" section lists "Primary: Bash curl to OpenAlex API" and documents only OpenAlex field extraction and status determination. It does not mention Crossref or Unpaywall. Any agent reading this summary block to drive academic channel execution — without reading the full academic.md playbook — will silently skip the two new APIs. The Step 5 ACCESSIBLE/DISCOVERED bullet additions (lines 132-133) were correctly updated, but the channel execution summary block was not.

The risk is inconsistency between the prose summary and the referenced playbook: an agent following only the SKILL.md summary executes one API instead of three.

**Fix:** Update the Academic channel summary block (around line 382) to acknowledge the three-API model:

```markdown
### Academic (channel-type: academic)

Primary: `Bash` curl to OpenAlex, Crossref, and Unpaywall APIs (three-API channel)

Key parameters:
- Include `mailto=research-agent@example.com` in all OpenAlex and Crossref requests
- Extract per result: title, DOI, authors, citation count, open-access status (`is_oa`), OA URL
- Status determination: `is_oa=true` → ACCESSIBLE, `is_oa=false` → DISCOVERED (Unpaywall may upgrade inline)
- Full query templates, deduplication rules, and degradation chains: read academic.md at execution time

Rate limit: OpenAlex 10 req/s with mailto, Crossref 50 req/s with mailto.
```

---

### WR-02: Unpaywall trigger condition inconsistency between Section 8 and Template G

**File:** `.claude/reference/discovery/channel-playbooks/academic.md:116` vs `academic.md:244`
**Issue:** Template G (line 116) states the trigger is: "Call only when a paper has `is_oa=false` (from OpenAlex) **or** no OA indicator (from Crossref)." Section 8 (line 244) states: "Called only when a paper has `is_oa=false` (from OpenAlex) **or** has no OA indicator (from Crossref-only results)."

These are not exactly the same condition. "From Crossref" (Template G) means any Crossref result. "From Crossref-only results" (Section 8) means results that appear only in Crossref with no OpenAlex match. The distinction matters: a paper present in both OpenAlex (is_oa=false) and Crossref would pass the Template G trigger but only the is_oa=false OpenAlex branch would apply in Section 8.

The Section 8 phrasing is more precise and correct given the deduplication rules (OpenAlex takes priority; Crossref-only papers lack an is_oa field). Template G's phrasing is slightly over-broad and could be read as triggering Unpaywall for all Crossref results, not just those without an OpenAlex is_oa signal.

**Fix:** Align Template G's trigger condition to match Section 8's phrasing:

```markdown
**Trigger condition:** Call only when a paper has `is_oa=false` (from OpenAlex) or has no OA
indicator (from Crossref-only results — papers not present in OpenAlex). Do not call for
papers already known to be open access. Bounded by the existing 8-result-per-channel cap.
```

---

## Info

### IN-01: Crossref example response DOI does not match the paper title

**File:** `.claude/reference/discovery/channel-playbooks/academic.md:314-325`
**Issue:** The Crossref example JSON uses DOI `10.1038/s41586-020-2649-2` with title "Language models show human-like content effects on reasoning". That DOI actually resolves to a Nature paper titled "Array programming with NumPy." The title in the example belongs to a 2022 Science paper with a different DOI. The mismatch is harmless for agent behavior (it is illustrative JSON, not a live reference), but could mislead a developer trying to verify the example manually.

**Fix:** Either use a consistent real DOI+title pair, or make the example clearly synthetic:

```json
"DOI": "10.XXXX/example-doi",
"title": ["Language models show human-like content effects on reasoning"],
```

---

### IN-02: Contradicts definition phrasing differs slightly between coverage-assessment-guide.md and check-gaps/SKILL.md

**File:** `.claude/reference/coverage-assessment-guide.md:31` vs `.claude/commands/research/check-gaps/SKILL.md:72`
**Issue:** coverage-assessment-guide.md defines Contradicts as: "Source actively opposes or contradicts the research question's hypothesis — **same topic as the question but arguing the opposite conclusion**." Guardrail 10 in check-gaps/SKILL.md defines it as: "A source that **actively argues against the research question's hypothesis** is Contradicts." The definitions are compatible but not verbatim-consistent. The guide version is more specific (same topic + opposite conclusion) while Guardrail 10 is looser (argues against hypothesis, without the same-topic constraint).

No behavior divergence is likely since both files are read together per step 4, but the guide version should be considered the definition site and Guardrail 10 could be made more precise for defense-in-depth against conflation with Adjacent.

**Fix:** Tighten Guardrail 10 to match the guide's phrasing:

```markdown
10. Contradicts classification is not a subcategory of Adjacent. A source that actively
    argues against the research question's hypothesis on the *same topic* is Contradicts —
    not Adjacent. Adjacent means "related but different topic." Contradicts means "same
    topic, opposing conclusion."
```

---

_Reviewed: 2026-04-20_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: quick (content review on API URLs, Contradicts consistency, and cross-references)_
