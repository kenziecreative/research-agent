---
phase: 13-academic-evidence-layer-expansion
verified: 2026-04-20T00:00:00Z
status: passed
score: 8/8
overrides_applied: 0
---

# Phase 13: Academic & Evidence Layer Expansion — Verification Report

**Phase Goal:** Academic discovery queries Crossref and Unpaywall alongside OpenAlex; gap analysis distinguishes absence of evidence from evidence against
**Verified:** 2026-04-20
**Status:** passed
**Re-verification:** No — initial verification

---

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Running discover returns Crossref DOI/author/citation metadata alongside OpenAlex | VERIFIED | academic.md defines API 2 — Crossref with Templates D/E/F, example JSON with `is-referenced-by-count`, and deduplication rules in Section 8. discover/SKILL.md reads academic.md at execution time. |
| 2 | Paywalled papers are augmented with legal OA copy links from Unpaywall | VERIFIED | academic.md defines API 3 — Unpaywall with Template G, trigger condition (`is_oa=false` only), inline upgrade DISCOVERED → ACCESSIBLE, and `best_oa_location.url` extraction. |
| 3 | Gap analysis labels questions as "no sources found" or "sources contradict hypothesis" — not a single status | VERIFIED | check-gaps/SKILL.md step 6g assigns "Evidence Against" for 0 Direct + 1+ Contradicts; coverage bracket in per-question output includes `[Complete/Partial/Not Started/Evidence Against/Addressed but unbalanced]`. Dashboard adds two new counters. |
| 4 | All three academic integrations degrade gracefully when an API is unavailable | VERIFIED | academic.md documents Crossref degradation (Tier 2 Tavily → Tier 3 WebSearch) and Unpaywall degradation (skip silently, log status note, no retry, no fallback). Unavailable criteria block updated to include api.crossref.org. |
| 5 | Academic channel queries Crossref alongside OpenAlex and returns DOI/author/citation metadata that OpenAlex missed | VERIFIED | Templates D/E/F present; Section 8 data merge rules fill OpenAlex gaps from Crossref (DOI, citation count, author list); deduplication keeps OpenAlex as primary. |
| 6 | Papers with is_oa=false are looked up via Unpaywall inline during discovery and upgraded to ACCESSIBLE | VERIFIED | Template G with explicit trigger condition. discover/SKILL.md Step 5 ACCESSIBLE bullet: "Unpaywall `best_oa_location.url` present and non-null". DISCOVERED bullet documents inline upgrade path per academic.md Section 8. |
| 7 | All three academic APIs degrade gracefully when unavailable — skip silently, do not block | VERIFIED | Crossref degradation chain (Tavily → WebSearch) and Unpaywall skip-not-retry block both present. Discover skill step 2h: "If a channel fails… log the specific failure reason, continue to the next channel. Never abort discovery." |
| 8 | Crossref results are deduplicated against OpenAlex results by DOI match | VERIFIED | Section 8 Deduplication and Priority Rules: "If a paper appears in both OpenAlex and Crossref results (matched by DOI string equality after normalization to lowercase), the OpenAlex entry is kept. The Crossref entry is silently dropped." |

**Score:** 8/8 truths verified

---

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.claude/reference/discovery/channel-playbooks/academic.md` | Crossref query templates, Unpaywall lookup logic, dual-API degradation, deduplication rules | VERIFIED | Contains "API 2 — Crossref", "API 3 — Unpaywall", Templates D/E/F/G, both degradation blocks, rate limits, example JSONs, Section 8 deduplication. Existing Templates A/B/C unchanged. |
| `.claude/commands/research/discover/SKILL.md` | Unpaywall status upgrade note in Step 5 | VERIFIED | Line 132: ACCESSIBLE bullet includes `Unpaywall \`best_oa_location.url\` present and non-null`. Line 133: DISCOVERED bullet documents inline upgrade path. 2 Unpaywall references (matches plan acceptance criteria). |
| `.claude/reference/coverage-assessment-guide.md` | Contradicts classification definition and Evidence Against status definition | VERIFIED | "one of four tiers" present. Contradicts bullet with full definition. Critical rule distinguishing Contradicts from Adjacent. Evidence Against status in Coverage Status Definitions. Workflow updated to 7 steps. 5 Contradicts occurrences. |
| `.claude/commands/research/check-gaps/SKILL.md` | Four-tier classification in step 6, Evidence Against status, dashboard counters, priority list extension | VERIFIED | Step 4 ref updated to "(Direct/Adjacent/Contradicts/None)". Step 6a updated. Sub-items 6c and 6g added. Dashboard adds Evidence Against + Contradicts matches counters. Per-question bracket includes Evidence Against. Priority list extended. Note added. Guardrail 10 added. Failure mode row added. 9 Contradicts + 7 Evidence Against occurrences. |

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `academic.md` | `https://api.crossref.org/works` | curl query templates | WIRED | 6 occurrences of `api.crossref.org` in academic.md including base URL declaration and curl templates D/E/F |
| `academic.md` | `https://api.unpaywall.org/v2/` | DOI lookup template | WIRED | 3 occurrences of `api.unpaywall.org` including base URL declaration and Template G curl command |
| `discover/SKILL.md` | `academic.md` | status upgrade reference | WIRED | Line 133: "Unpaywall lookup (per academic.md Section 8) may upgrade them to ACCESSIBLE inline during the same discovery pass" |
| `check-gaps/SKILL.md` | `coverage-assessment-guide.md` | step 4 reads guide for classification criteria | WIRED | Step 4: "Read `.claude/reference/coverage-assessment-guide.md` for match classification criteria (Direct/Adjacent/Contradicts/None)" |
| `check-gaps/SKILL.md` | `research/gaps.md` | step 7 writes gaps file with Evidence Against status | WIRED | Step 7 output format includes Evidence Against in Coverage bracket and dashboard counters |

---

### Data-Flow Trace (Level 4)

Not applicable. All four artifacts are reference documentation and skill instructions — no runtime data sources to trace. These files define agent behavior at execution time rather than rendering dynamic data.

---

### Behavioral Spot-Checks

Step 7b: SKIPPED — these are documentation files with no runnable entry points. The phase delivers playbook and skill instructions that are consumed at agent runtime, not invocable standalone artifacts.

---

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| DISC-01 | 13-01-PLAN.md | Academic channel queries Crossref API alongside OpenAlex to fill metadata gaps (DOI, author, citation count) | SATISFIED | academic.md API 2 — Crossref with Templates D/E/F; Section 8 data merge rules fill DOI, citation count, author gaps from Crossref |
| DISC-02 | 13-01-PLAN.md | Academic channel queries Unpaywall to find legal open-access copies of papers discovered via OpenAlex or Crossref | SATISFIED | academic.md API 3 — Unpaywall with Template G; inline upgrade DISCOVERED → ACCESSIBLE; discover/SKILL.md Step 5 references Unpaywall for ACCESSIBLE status |
| TRACE-05 | 13-02-PLAN.md | Gap analysis distinguishes between "absence of evidence" (no sources found) and "evidence against" (sources contradicting the hypothesis) | SATISFIED | coverage-assessment-guide.md adds Contradicts tier and Evidence Against status; check-gaps/SKILL.md implements classification logic, Evidence Against assignment (step 6g), dashboard counters, and Note distinguishing discovery targets from synthesis challenges |

All three requirements mapped to this phase in REQUIREMENTS.md traceability table are satisfied. No orphaned requirements found.

---

### Anti-Patterns Found

No anti-patterns detected. All four files are documentation/skill instruction assets — no code stubs, placeholder returns, or empty handlers apply. Scanned for TODO/FIXME/placeholder comments: none found.

---

### Human Verification Required

None. All must-haves are verifiable through file content inspection. The phase delivers documentation assets — the only "behavior" to verify is content presence and internal cross-reference, both of which have been confirmed programmatically.

---

## Gaps Summary

No gaps. All 8 observable truths verified, all 4 artifacts substantive and wired, all 5 key links confirmed, all 3 requirements satisfied, 4 commits verified in git history.

---

_Verified: 2026-04-20T00:00:00Z_
_Verifier: Claude (gsd-verifier)_
