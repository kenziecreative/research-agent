---
phase: 14-web-channel-diversity
verified: 2026-04-20T00:00:00Z
status: human_needed
score: 10/10
overrides_applied: 0
human_verification:
  - test: "Run a web-search phase discovery with both TAVILY_API_KEY and EXA_API_KEY set"
    expected: "Candidates list contains entries tagged [Tavily], [Exa], or [Tavily+Exa]; combined status line appears at end"
    why_human: "Requires live API calls and a running research session to observe dual-tool execution in practice"
  - test: "Run a web-search phase discovery with EXA_API_KEY unset"
    expected: "Discovery completes using Tavily results only; log line 'Exa: unavailable — web search results from Tavily only' appears; no error or block"
    why_human: "Requires live API call attempt to verify silent degradation behavior"
---

# Phase 14: Web Channel Diversity — Verification Report

**Phase Goal:** Web search runs Exa neural search as a parallel tier, and duplicate URLs are removed before candidates are presented
**Verified:** 2026-04-20
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (Plan 01 — web-search.md)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Web-search playbook documents Exa as API 2 alongside Tavily | VERIFIED | `"API 2 — Exa (Secondary, Neural Search)"` heading confirmed in web-search.md Section 2 (grep: 1 match) |
| 2 | Exa query templates exist with the same structure as Tavily templates | VERIFIED | Templates D (Topic), E (Entity), F (Recent) confirmed in Section 3; grep for `Template [DEF]` returns 3 |
| 3 | Exa has its own degradation path independent of Tavily's 3-tier chain | VERIFIED | `"Exa degradation (if api.exa.ai unavailable):"` confirmed in Section 6 with all 5 unavailability criteria; grep returns 2 matches |
| 4 | Section 8 dedup rules define URL-based deduplication with Tavily priority | VERIFIED | `"## 8. Deduplication and Priority Rules"` heading confirmed; `"Deduplication by URL:"` paragraph confirmed; Tavily-priority semantics explicit |
| 5 | Inline source attribution tags [Tavily], [Exa], [Tavily+Exa] are documented | VERIFIED | All three tags present in attribution table in Section 8; grep confirms each individually |
| 6 | Combined status line format is specified | VERIFIED | `"Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3}) [degraded: {list}]"` confirmed in Section 8 |

### Observable Truths (Plan 02 — discover/SKILL.md)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 7 | Discover skill documents Exa as secondary tool in Web Search channel execution | VERIFIED | `"Secondary tool: Exa Search API (via Bash curl to https://api.exa.ai/search)"` confirmed at line 317 |
| 8 | Execution order (Tavily first, Exa second) is explicit in the skill | VERIFIED | `"**Execution order:** Tavily first (up to 8 results), then Exa second (up to 8 results)"` confirmed at line 319 |
| 9 | Combined status line format is documented in the skill | VERIFIED | Status line format `Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3})` confirmed at line 341 |
| 10 | Exa degradation behavior is referenced from the skill | VERIFIED | `"**Exa degradation:**"` paragraph with "skip silently" confirmed at line 346 |

**Score:** 10/10 truths verified

### Roadmap Success Criteria

| # | Success Criterion | Status | Evidence |
|---|------------------|--------|----------|
| 1 | A discover run for a web-search phase returns candidates from both Tavily and Exa | HUMAN NEEDED | SKILL.md documents execution order and dual-tool parameters; actual discover execution requires live test |
| 2 | URLs that appear in both Exa and Tavily results are collapsed to a single candidate entry | VERIFIED | web-search.md Section 8 specifies exact URL string equality dedup with Tavily priority; SKILL.md Cross-tool deduplication section references Section 8 directly |
| 3 | The source of each candidate (Tavily, Exa, or both) is visible in the candidate list | VERIFIED | `[Tavily]`, `[Exa]`, `[Tavily+Exa]` attribution tags defined in Section 8 with explicit candidate format examples |
| 4 | Exa integration degrades gracefully when the API key is absent or the call fails | HUMAN NEEDED | Degradation behavior fully documented in both web-search.md Section 6 and SKILL.md; silent-skip contract requires live API failure test to confirm |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.claude/reference/discovery/channel-playbooks/web-search.md` | Full Exa integration: tool config, query templates, degradation, rate limits, Section 8 dedup and attribution | VERIFIED | File exists; contains `"API 2 — Exa"` (1 match), Templates D/E/F (3 matches), Section 8 (confirmed), all attribution tags, EXA_API_KEY (5 occurrences), rate limits in Section 7 |
| `.claude/commands/research/discover/SKILL.md` | Web Search subsection extended with Exa parallel execution documentation | VERIFIED | File exists; Web Search subsection expanded ~12→34 lines; `"Exa"` appears 9 times (above 5-minimum threshold) |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `web-search.md Section 8` | `discover/SKILL.md Step 4` | URL dedup contract (exact match) | VERIFIED | SKILL.md line 334-337: `"Cross-tool deduplication (per web-search.md Section 8):"` with exact URL equality and Tavily priority — explicit cross-reference confirmed |
| `discover/SKILL.md Web Search subsection` | `web-search.md Section 8` | references playbook dedup rules | VERIFIED | Pattern `"web-search.md"` confirmed in SKILL.md Web Search subsection at lines 321, 327, 334 — three direct references |

### Data-Flow Trace (Level 4)

Not applicable. Phase 14 produces documentation artifacts (markdown playbooks and skill files), not executable code with data flows. No state variables, no render paths, no API calls to trace.

### Behavioral Spot-Checks

Step 7b: SKIPPED — documentation-only phase. Both modified files are markdown reference documents read by Claude agents at runtime; there is no runnable entry point to test without executing a live research session.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| DISC-03 | 14-01, 14-02 | Web-search channel includes Exa neural search as a parallel tier surfacing semantically relevant non-SEO sources | SATISFIED | web-search.md Section 2 (Exa tool config), Section 3 (Templates D/E/F), Section 6 (degradation), Section 7 (rate limits); SKILL.md Web Search subsection documents parallel execution order |
| DISC-04 | 14-01, 14-02 | Discovery results from Exa are deduplicated against Tavily results before adding to candidates | SATISFIED | web-search.md Section 8 defines URL-based dedup with Tavily priority; SKILL.md references Section 8 directly with dedup key and attribution tags documented |

No orphaned requirements — REQUIREMENTS.md maps DISC-03 and DISC-04 to Phase 14; both claimed by plans 14-01 and 14-02 and satisfied.

### Anti-Patterns Found

| File | Pattern | Severity | Impact |
|------|---------|----------|--------|
| web-search.md (multiple lines) | `**Placeholder substitution:**` | INFO | Intentional query template markers (`{topic}`, `{entity_name}`, `{iso_date}`) — not stubs. Confirmed by SUMMARY: "Template placeholder labels are intentional substitution markers in query templates." No data flows through these; they are documentation constructs. |

No blockers. No warnings.

### Human Verification Required

#### 1. Dual-Tool Execution in Live Discover Run

**Test:** Execute a research discover command for a web-search phase with both `TAVILY_API_KEY` and `EXA_API_KEY` set in the environment. Observe the candidate output.
**Expected:** Candidates list contains entries tagged `[Tavily]`, `[Exa]`, or `[Tavily+Exa]`; the combined status line `Web Search: {N} results (Tavily: {n1}, Exa-only: {n2}, deduped: {n3})` appears at the end of the channel run.
**Why human:** Requires live API calls to both Tavily and Exa, and an active Claude research session to observe. Cannot verify dual-tool execution from static code inspection alone.

#### 2. Exa Silent Degradation

**Test:** Execute a research discover command for a web-search phase with `EXA_API_KEY` unset (or set to an invalid value).
**Expected:** Discovery completes normally using Tavily results only. Log line `Exa: unavailable — web search results from Tavily only` appears. No error, no block, no Tavily fallback trigger.
**Why human:** Requires a live API failure condition to verify that the degradation path executes as documented — silent skip, no retry, no cross-trigger of Tavily fallbacks. Static inspection confirms the contract is documented correctly but cannot verify runtime behavior.

### Gaps Summary

No gaps found. All 10 plan must-haves verified. Both roadmap success criteria that are statically verifiable (URL dedup contract, source attribution visibility) are confirmed in code. Two criteria require live execution testing and are routed to human verification above.

Commit history confirms all three documented commits exist: `90bb663` (Exa config/templates/degradation/rate limits), `f6c6e84` (Section 8 dedup/attribution), `4feaafb` (SKILL.md dual-tool extension).

---

_Verified: 2026-04-20_
_Verifier: Claude (gsd-verifier)_
