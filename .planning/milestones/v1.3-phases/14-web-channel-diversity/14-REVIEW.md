---
phase: 14-web-channel-diversity
reviewed: 2026-04-20T00:00:00Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - .claude/commands/research/discover/SKILL.md
  - .claude/reference/discovery/channel-playbooks/web-search.md
findings:
  critical: 0
  warning: 4
  info: 1
  total: 5
status: issues_found
---

# Phase 14: Code Review Report

**Reviewed:** 2026-04-20
**Depth:** standard
**Files Reviewed:** 2
**Status:** issues_found

## Summary

Two source files were reviewed: the `discover` command SKILL.md and the `web-search` channel playbook. Both are command/playbook scripts that agents execute at runtime — they are authoritative instruction sources, not documentation.

The primary concern is a cluster of inconsistencies between SKILL.md and the playbook that an agent executor would encounter and have to resolve without a clear rule. Two of these involve contradictory output formats (fallback labels, candidate status tags) that would produce malformed or ambiguous candidates files. A third is an invalid CLI parameter annotation that would cause a silent or hard failure at query time. One latent bug in the Exa template could send an invalid API field on entity searches.

No security issues were found. No critical issues. Four warnings require fixes before this phase's work lands in production.

---

## Warnings

### WR-01: `days=90` annotation in SKILL.md Step 2c is not a valid Tavily CLI parameter

**File:** `.claude/commands/research/discover/SKILL.md:89`
**Issue:** Step 2c instructs the executor: "Recent developments or time-sensitive phases: use Template C (recent news, add `days=90`)". The `days=90` notation is not a Tavily CLI flag. The actual parameter is `--time-range` with accepted string values `week`, `month`, or `year`. An executor following this instruction would either pass `days=90` as a literal argument (malformed command, likely ignored or errored) or attempt to construct a flag from it. The web-search.md Template C at line 103 shows the correct form: `--time-range month`.

**Fix:** Replace the parenthetical with the correct flag reference:
```
- Recent developments or time-sensitive phases: use Template C (recent news, use --time-range month or --time-range year)
```

---

### WR-02: Fallback result label is inconsistent between SKILL.md and web-search.md

**File:** `.claude/commands/research/discover/SKILL.md:114` and `.claude/reference/discovery/channel-playbooks/web-search.md:258`
**Issue:** SKILL.md uses bracket notation `[Firecrawl fallback]` throughout (lines 114, 344, 452). The web-search.md playbook Section 6 uses inline prose format `"via Firecrawl (tvly fallback)"` (line 258). When an executor reaches Tier 2 fallback during web-search discovery, the two sources disagree on how to tag the result. This produces candidates files with mixed tag formats, breaking any downstream consumer that parses tags by pattern match.

**Fix:** Standardize to bracket notation in web-search.md Section 6 to match the SKILL.md convention and the existing `[Firecrawl fallback]` / `[WebSearch fallback]` tags used in the candidates file format:
```
3. Label results: `[Firecrawl fallback]`
...
5. Label results: `[WebSearch fallback]`
```

---

### WR-03: Exa Template E always includes `category` field, but prose says to omit it when inapplicable

**File:** `.claude/reference/discovery/channel-playbooks/web-search.md:148-156`
**Issue:** Template E (Exa Entity Search) includes `"category": "{category}"` as a JSON field unconditionally. The placeholder substitution note says "Omit the field entirely if no category applies." An executor that substitutes `{category}` with an empty string sends `"category": ""` to the Exa API, which is an invalid value. The API will either return an error or degrade results silently. The template and the prose instruction are in direct conflict.

**Fix:** Show the conditional omission explicitly in the template with a comment, or provide two template variants:
```json
// Option A — with category biasing:
{
  "query": "{entity_name} {entity_type}",
  "numResults": 8,
  "type": "auto",
  "useAutoprompt": true,
  "category": "company"
}

// Option B — without category (omit field entirely):
{
  "query": "{entity_name} {entity_type}",
  "numResults": 8,
  "type": "auto",
  "useAutoprompt": true
}
```

---

### WR-04: Guardrail 3's "8 sources per channel per query" cap is ambiguous for the dual-tool web-search channel

**File:** `.claude/commands/research/discover/SKILL.md:319-320` and `.claude/commands/research/discover/SKILL.md:447`
**Issue:** SKILL.md lines 319–320 describe the web-search channel as running Tavily (up to 8) then Exa (up to 8), with "Maximum pre-dedup output: 16 candidates from web search." Guardrail 3 at line 447 states "Cap results at 8 sources maximum per channel per query." These two statements contradict each other. "Per channel" would mean 8 total from web-search; "per tool" would allow 16 pre-dedup. An executor reading both will be uncertain whether to truncate to 8 total (losing Exa results) or allow 16 and rely on dedup.

**Fix:** Carve out an explicit exception for dual-tool channels in Guardrail 3, matching the intent described in the channel execution block:
```
3. **Cap results at 8 sources maximum per tool per channel query.** For single-tool channels,
   this is 8 total. For the web-search channel (Tavily + Exa), each tool is capped at 8,
   yielding up to 16 pre-dedup candidates. After deduplication, the combined result set
   is presented as-is.
```

---

## Info

### IN-01: `[PROCESSED]` status shown as a valid example in web-search.md Section 5

**File:** `.claude/reference/discovery/channel-playbooks/web-search.md:235`
**Issue:** Section 5 (Source Status Taxonomy) shows a recording format example that includes a `[PROCESSED]` candidate:
```
- [PROCESSED] https://example.com/filing — integrated into §3 financials
```
SKILL.md Guardrail 8 and Step 5 both explicitly state that `PROCESSED` status must not be assigned during discovery — it is reserved for `process-source`. Showing it as a valid format example in the discovery playbook is misleading and may cause an agent to assign `PROCESSED` inline when it should not.

**Fix:** Remove the `[PROCESSED]` example line from Section 5, or add a note that this status is shown for reference only and must not be assigned during discovery. The DISCOVERED / ACCESSIBLE examples are sufficient.

---

_Reviewed: 2026-04-20_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
