# Phase 13: Academic & Evidence Layer Expansion - Pattern Map

**Mapped:** 2026-04-20
**Files analyzed:** 4
**Analogs found:** 4 / 4

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.claude/reference/discovery/channel-playbooks/academic.md` | channel playbook | request-response (HTTP API, multi-API) | `.claude/reference/discovery/channel-playbooks/regulatory.md` | exact — dual-API in same channel |
| `.claude/commands/research/check-gaps/SKILL.md` | skill | transform (classification extension) | `.claude/commands/research/check-gaps/SKILL.md` §6 + guardrail 5 | self-analog — extend existing classification |
| `.claude/reference/coverage-assessment-guide.md` | reference | transform (taxonomy extension) | `.claude/reference/coverage-assessment-guide.md` §Match Classification | self-analog — extend existing match classification |
| `.claude/commands/research/discover/SKILL.md` | skill | request-response (status upgrade note) | `.claude/commands/research/discover/SKILL.md` §Step 5 | self-analog — single-sentence note within existing step |

---

## Pattern Assignments

### `.claude/reference/discovery/channel-playbooks/academic.md`

**Analog:** `.claude/reference/discovery/channel-playbooks/regulatory.md`

**Why regulatory.md is the exact analog:** It is the only other playbook in the codebase that runs two named HTTP APIs within a single channel (EDGAR + ProPublica), uses separate Tool Configuration entries per API, and keeps both under one degradation chain section. Crossref + Unpaywall extending academic.md follows this identical dual-API pattern.

---

**Section 2 dual-API Tool Configuration pattern** (regulatory.md lines 22–37):
```markdown
## 2. Tool Configuration

**Primary tool:** Bash (curl to two HTTP APIs)

**Authentication:** None required for either API.

**API 1 — SEC EDGAR Full-Text Search (EFTS):**
- Base URL: `https://efts.sec.gov/LATEST/search-index`
- Required header: `User-Agent: ResearchAgent (contact@example.com)` — SEC policy requires identification
- Response format: JSON
- Returns: Filing metadata including filing date, form type, and links to full filing documents

**API 2 — ProPublica Nonprofit Explorer:**
- Base URL: `https://projects.propublica.org/nonprofits/api/v2`
- No authentication required
- Response format: JSON
- Returns: Organization metadata and links to 990 PDF filings
```

**Copy instruction:** academic.md's Section 2 currently lists one API (OpenAlex). Extend it with two sub-entries in the same style — API 2 for Crossref, API 3 for Unpaywall. Use sub-bullets: Base URL, Authentication, Response format, Returns. No restructuring of the existing OpenAlex entry.

---

**Section 3 query template pattern — labeled by API** (regulatory.md lines 43–69):
```markdown
### Template A — EDGAR Company Filing Search
Find recent filings of any type for a named company:

```bash
curl -s -H "User-Agent: ResearchAgent (contact@example.com)" \
  "https://efts.sec.gov/LATEST/search-index?q=%22{company_name}%22&forms=10-K,10-Q,8-K&dateRange=custom&startdt={year_minus_2}-01-01&enddt={today}"
```

Substitute: `{company_name}` = ...

### Template C — ProPublica Nonprofit Lookup
Search for a nonprofit organization and retrieve 990 filing information:

```bash
curl -s "https://projects.propublica.org/nonprofits/api/v2/search.json?q={org_name}"
```
```

**Copy instruction:** academic.md's Section 3 has Templates A, B, C for OpenAlex. Add new sections — "Crossref Query Templates" and "Unpaywall Lookup" — at the same heading level, using the same bash code block + Substitute comment pattern. Do not rename or renumber the OpenAlex templates.

Crossref base URL: `https://api.crossref.org/works`
Unpaywall base URL: `https://api.unpaywall.org/v2/{doi}`

---

**Section 6 dual degradation chain pattern** (regulatory.md lines 114–147):
```markdown
## 6. Degradation Behavior

**Primary:** Bash curl to EDGAR EFTS and ProPublica APIs

**Tier 2 [Tavily fallback] for EDGAR (if unavailable):**
```bash
tvly search "{company_name} SEC filing {form_type}" ...
```
Label results: "via tvly (EDGAR fallback)"

**Tier 2 [Tavily fallback] for nonprofits (if ProPublica unavailable):**
```bash
tvly search "{org_name} 990 filing nonprofit annual report" ...
```
Label results: "via tvly (ProPublica fallback)"

**Unavailable criteria:** Trigger next tier when:
- HTTP 5xx response from API (or non-zero exit from CLI)
- Request timeout > 15 seconds
- HTTP 429 rate limit (back off and retry once after 5 seconds before falling back)
```

**Copy instruction:** academic.md Section 6 currently has a single OpenAlex degradation chain. Retain the existing chain as-is. Add two new degradation blocks beneath it — one for Crossref, one for Unpaywall — following the same "Tier 2 [Tavily fallback] for {API name} (if unavailable)" sub-heading format. Unpaywall degradation note: if Unpaywall is unavailable, the paper remains DISCOVERED and discovery continues (per D-07); state this explicitly as "skip silently with a channel status note, do not block or retry."

---

**Section 7 rate limits pattern** (regulatory.md lines 150–161):
```markdown
## 7. Rate Limits

**EDGAR (SEC policy):** Maximum 10 requests per second.
**ProPublica Nonprofit Explorer:** No documented rate limit. Use 2 requests per second as a safe default.
```

**Copy instruction:** Add Crossref and Unpaywall rate limit entries beneath OpenAlex's rate limit entry, using the same bold-API-name format.

---

**Example Response section + Fields to extract pattern** (academic.md lines 153–203):
```markdown
## Example Response

Trimmed OpenAlex JSON response for a works query. The discover skill should extract these fields:

```json
{ "results": [ { "id": "...", "title": "...", "doi": "...", ... } ] }
```

**Fields to extract per result:**
- `title` — paper title
- `doi` — canonical identifier and link
- `open_access.is_oa` — true = ACCESSIBLE, false = DISCOVERED
```

**Copy instruction:** Add parallel "Example Response" sub-sections for Crossref and Unpaywall immediately after the OpenAlex example. Use the same trimmed JSON + **Fields to extract** bullet list format.

Crossref fields to extract: `DOI`, `title`, `author[].given`+`author[].family`, `is-referenced-by-count` (citation count), `published.date-parts`, `resource.primary.URL`.

Unpaywall fields to extract: `doi`, `is_oa`, `best_oa_location.url` (direct OA URL), `best_oa_location.license`, `oa_status` (gold/green/hybrid/bronze/closed).

---

**Deduplication note pattern** (from D-02, D-03 in CONTEXT.md — no existing analog; write inline):

Add a new section **"8. Deduplication and Priority Rules"** after Section 7. It documents:
- Query order: OpenAlex first, Crossref second, Unpaywall third (inline during same pass)
- Deduplication by DOI: if a paper appears in both OpenAlex and Crossref results, the OpenAlex entry is kept; the Crossref entry is silently dropped (same pattern as discover skill's URL dedup in Step 4)
- Data merge: Crossref enriches missing fields on OpenAlex entries (DOI resolution, author disambiguation, citation count) — OpenAlex data has priority, Crossref fills gaps only
- Unpaywall trigger: called only when `is_oa=false`; result upgrades status from DISCOVERED to ACCESSIBLE using `best_oa_location.url`; capped by the existing 8-result-per-channel limit (D-06)

---

### `.claude/commands/research/check-gaps/SKILL.md`

**Analog:** Self — extend existing Direct/Adjacent/None classification in Process step 6 and Guardrail 5, and extend the priority list in the Output section.

---

**Process step 6 classification pattern** (check-gaps/SKILL.md lines 19–24):
```markdown
6. **For each phase in the research plan, for each question:**
   a. Classify each source note's relevance to this question as Direct, Adjacent, or None using the criteria from the coverage assessment guide.
   b. For Direct matches: count independent sources (using the independence map from step 5).
   c. For Adjacent matches: note with a one-line explanation: "Addresses [actual topic] rather than [phase question]"
   d. Assign coverage status using the coverage assessment guide definitions...
   e. Flag lopsided coverage...
```

**Copy instruction:** In step 6a, extend the classification list from `Direct, Adjacent, or None` to `Direct, Adjacent, Contradicts, or None`. Add a new sub-item 6b-contradict (between 6b and 6c, or as a new 6c with existing 6c–6e re-lettered):

```
   b2. For Contradicts matches: note with a one-line explanation of what the source opposes.
       Do not count Contradicts sources toward Direct coverage. Do not collapse with Adjacent.
```

Add step 6f (after existing 6e):
```
   f. If a question has 0 Direct sources and at least 1 Contradicts source, assign coverage status
      "Evidence Against" (not "Not Started"). Evidence Against means the question has active
      counter-evidence, not an absence of evidence.
```

---

**Gaps.md per-question detail format pattern** (check-gaps/SKILL.md lines 38–50):
```markdown
   **Coverage:** [Complete/Partial/Not Started/Addressed but unbalanced] | **Independent sources:** N [LOPSIDED if 1]

   **Direct sources:**
   - [source-note-filename] [Source: citation] — [brief evidence summary]

   **Adjacent sources:** ← section only if adjacent matches exist
   - [source-note-filename]: Addresses [actual topic] rather than [phase question]
```

**Copy instruction:** Add a **Contradicts sources** section to the per-question format block, immediately after **Adjacent sources**, using the same conditional "section only if..." convention:

```
   **Contradicts sources:** ← section only if Contradicts matches exist
   - [source-note-filename]: Contradicts [phase question] by [brief description of what it opposes]
```

---

**Dashboard format pattern** (check-gaps/SKILL.md lines 27–34):
```markdown
   ## Coverage Dashboard
   - **Total questions:** N
   - **Direct coverage:** N questions (N%)
   - **Lopsided (single independent source):** N questions
   - **Adjacent-only matches:** N questions
```

**Copy instruction:** Add two new dashboard counters:
```
   - **Evidence Against:** N questions (active counter-evidence, no Direct sources)
   - **Contradicts matches:** N total (across all questions)
```

---

**Highest-priority gaps list pattern** (check-gaps/SKILL.md lines 87–100):
```markdown
1. Phase [P] Q: '[question text]' — Status: [Not Started | Lopsided | Adjacent-only] — Blocking: [what a draft for this phase cannot claim without this gap filled]

Criticality order for the list:
1. Not Started questions on phases whose Verify step is the *next* cycle step
2. Lopsided (Thin) questions on any active or upcoming phase.
3. Not Started questions on upcoming phases (beyond the next Verify).
4. Adjacent-only questions on any phase.
```

**Copy instruction:** Extend the status bracket in the list format: `[Not Started | Lopsided | Adjacent-only | Evidence Against]`. Add a new criticality level between items 1 and 2 (current items 2–4 shift down):

```
2. Evidence Against questions on phases whose Verify step is the next cycle step
   (synthesis is imminent; the user must address the contradiction before drafting).
```

Add a note distinguishing the two high-priority categories:
```
Note: "Not Started" questions are discovery targets — run /research:discover to fill them.
"Evidence Against" questions are synthesis challenges — the user must address the contradiction
in the draft, not find more sources.
```

---

**Guardrail 5 pattern** (check-gaps/SKILL.md lines 63):
```
5. Flag questions that have sources but only from one side of a debate as "covered but unbalanced."
```

**Copy instruction:** Guardrail 5 stays as written. Add a new Guardrail 9 (after existing Guardrail 8):

```
9. Contradicts classification is not a subcategory of Adjacent. A source that actively opposes
   the research question's hypothesis is Contradicts — not Adjacent. Adjacent means "related but
   different topic." Contradicts means "same topic, opposing conclusion." Do not collapse the two.
   A question with 1 Direct and 1 Contradicts source is "Addressed but unbalanced" (D-08 intent:
   the contradiction is surfaced, not hidden in Adjacent).
```

---

**Common Failure Modes table pattern** (check-gaps/SKILL.md lines 68–76):
```markdown
| Failure Mode | Prevention |
|---|---|
| Declaring coverage when sources only tangentially mention a question | ... |
```

**Copy instruction:** Add one new row:

```
| Collapsing Contradicts into Adjacent or None | Contradicts is a distinct fourth classification.
  A source that actively argues against the research question's hypothesis is Contradicts.
  It must appear in the "Contradicts sources" section of the per-question detail and trigger
  "Evidence Against" status when no Direct sources exist. Dropping it to Adjacent or None
  hides active counter-evidence from the user. |
```

---

### `.claude/reference/coverage-assessment-guide.md`

**Analog:** Self — extend the Match Classification section (lines 25–33) and Coverage Status Definitions section (lines 48–57).

---

**Match Classification three-tier pattern** (coverage-assessment-guide.md lines 25–33):
```markdown
## Match Classification

Every source note's relevance to a given question is classified into one of three tiers:

- **Direct:** Source contains a specific claim, data point, or argument that substantively answers the question. ... Direct matches count toward coverage status.
- **Adjacent:** Source addresses a related topic but does not answer the specific question. ... Display with explanation: "Addresses [actual topic] rather than [phase question]". Adjacent matches do **not** count toward coverage status.
- **None:** Source does not address the question or any related topic. Not listed in per-question detail.

**Critical rule:** Adjacent matches do not contribute to coverage status. A question with 3 Adjacent sources and 0 Direct sources is **Not Started**, not Partial or Complete.
```

**Copy instruction:** Change the heading to "one of four tiers" and insert the Contradicts entry between Adjacent and None, following the same bold-name + definition + display instruction + counting rule format:

```
- **Contradicts:** Source actively opposes or contradicts the research question's hypothesis —
  same topic as the question but arguing the opposite conclusion. Distinguished from Adjacent
  (which is a different topic) and from Direct (which supports the question). Display with
  explanation: "Contradicts [phase question] by [brief description]". Contradicts matches do
  **not** count toward Direct coverage status, but do trigger "Evidence Against" status
  when no Direct sources exist.
```

Add a new critical rule beneath the existing one:
```
**Critical rule:** Contradicts ≠ Adjacent. A source arguing against the hypothesis is
Contradicts. A source about a related-but-different topic is Adjacent. Never use Adjacent
as a catch-all for inconvenient sources — the distinction is load-bearing for Evidence Against detection.
```

---

**Coverage Status Definitions pattern** (coverage-assessment-guide.md lines 48–57):
```markdown
## Coverage Status Definitions

Use these labels consistently in `research/gaps.md`. All statuses are calculated using **independent Direct source count only** ...

- **Complete:** 3+ **independent** sources with **Direct** matches, no unresolved contradictions, source types are mixed
- **Partial:** 1-2 **independent** sources with Direct matches, or sources exist but coverage is thin, one-sided, or source-type skewed
- **Not started:** No source notes have a **Direct** match for this question (including questions with only Adjacent matches)
- **Addressed but unbalanced:** **Direct** sources exist but represent only one perspective or source type
```

**Copy instruction:** Insert "Evidence Against" as a fifth status after "Not started," using the same bold-name + condition format. Keep the parenthetical note style matching "Not started":

```
- **Evidence Against:** No source notes have a **Direct** match for this question, but at least
  one source note is classified **Contradicts** — meaning active counter-evidence exists.
  Distinguished from "Not started" (which means no sources at all, for or against).
  An Evidence Against question is a synthesis challenge: the user must address the contradiction,
  not find more sources. Discovery will not resolve it.
```

---

**Coverage Assessment Workflow pattern** (coverage-assessment-guide.md lines 82–90):
```markdown
## Coverage Assessment Workflow

For each phase question:
1. List source notes that address the question — classify each as Direct, Adjacent, or None
2. For Direct sources, verify the evidence is substantive (not a passing mention)
3. Check source independence using origin_chain — collapse shared-origin sources to one independent data point
4. Check source type diversity
5. Check perspective balance
6. Assign a coverage status using the definitions above — based on independent Direct source count only
```

**Copy instruction:** Update step 1 to include Contradicts: "classify each as Direct, Adjacent, Contradicts, or None." Add a new step between 1 and 2 (shift existing 2–6 to 3–7):

```
2. For Contradicts classifications: verify the source actively argues against the hypothesis
   (not merely presenting a different facet). If in doubt, use Adjacent — only use Contradicts
   when the source's conclusion directly opposes the research question.
```

---

### `.claude/commands/research/discover/SKILL.md`

**Analog:** Self — single-sentence clarification within Step 5 (lines 128–135).

---

**Step 5 source status determination pattern** (discover/SKILL.md lines 128–135):
```markdown
### Step 5: Determine source status for each candidate

Apply the canonical status taxonomy (DISCOVERED / ACCESSIBLE / PROCESSED) to each result:

- **ACCESSIBLE**: Search tool returned full content snippets, OR source is known open-access
  (e.g., OpenAlex `is_oa=true`, Wikipedia, government data portals, arxiv.org, SEC EDGAR filings)
- **DISCOVERED**: URL returned but content not verified — applies to URL-only results, paywalled domains
  (wsj.com, ft.com, bloomberg.com, economist.com, hbr.org), ...
- **PROCESSED**: Reserved — do not assign PROCESSED status during discovery.

When uncertain, default to DISCOVERED.
```

**Copy instruction:** In the ACCESSIBLE bullet, add Unpaywall as a named source of ACCESSIBLE status immediately after the OpenAlex `is_oa=true` example:

```
(e.g., OpenAlex `is_oa=true`, Unpaywall `best_oa_location.url` present and non-null,
Wikipedia, government data portals, arxiv.org, SEC EDGAR filings)
```

Add a one-sentence note at the end of the DISCOVERED bullet:
```
Academic papers with `is_oa=false` from OpenAlex or Crossref begin as DISCOVERED;
Unpaywall lookup (per academic.md §8) may upgrade them to ACCESSIBLE inline during the same
discovery pass if a legal OA copy is found.
```

No other changes to discover/SKILL.md are needed. The Unpaywall execution logic lives in academic.md, not in the orchestrator.

---

## Shared Patterns

### Dual-API within a Single Channel
**Source:** `.claude/reference/discovery/channel-playbooks/regulatory.md`
**Apply to:** `academic.md` Sections 2, 3, 6, 7, and new Section 8

The regulatory playbook is the canonical model for running two independent HTTP APIs under one channel name. Key structural conventions:
- Section 2 names each API as "API 1 — {Name}" and "API 2 — {Name}" sub-entries
- Section 3 groups templates by API with clear headings ("Template A — EDGAR ...", "Template C — ProPublica ...")
- Section 6 has one degradation block per API, each independently labeled
- Section 7 has one rate limit entry per API
- Both APIs share the same channel status reporting line in the discover skill's summary table

### Status Upgrade Pattern (DISCOVERED → ACCESSIBLE)
**Source:** `academic.md` lines 98–103, `discover/SKILL.md` lines 128–135
**Apply to:** academic.md new Unpaywall section, discover/SKILL.md Step 5

Existing pattern: OpenAlex `is_oa=true` sets ACCESSIBLE during discovery. Unpaywall follows this same inline-during-discovery upgrade path — not a post-processing step. The trigger condition is `is_oa=false` (the paper starts DISCOVERED) and the outcome condition is Unpaywall returns `best_oa_location.url` non-null (upgrades to ACCESSIBLE).

### Graceful Degradation: Skip-Not-Retry
**Source:** `academic.md` lines 130–133, `discover/SKILL.md` lines 107–108
**Apply to:** academic.md new Unpaywall degradation block

Existing pattern from academic.md: "HTTP 5xx response from api.openalex.org → trigger next tier." Unpaywall degradation is different — it is not a tier cascade to a search engine. Per D-07, on Unpaywall failure the paper stays DISCOVERED and discovery continues. The playbook must make this explicit: "If Unpaywall is unavailable (timeout, HTTP 5xx, HTTP 429), the paper remains DISCOVERED. Skip silently. Log a one-line channel status note: `Unpaywall: unavailable — N papers remain DISCOVERED`. Do not retry. Do not block."

### Fourth Classification Value: Contradicts
**Source:** `coverage-assessment-guide.md` lines 25–33, `check-gaps/SKILL.md` lines 19–24
**Apply to:** Both files simultaneously — they must stay in sync

The existing three-tier classification (Direct/Adjacent/None) is defined in coverage-assessment-guide.md and referenced by check-gaps/SKILL.md ("using the criteria from the coverage assessment guide"). Adding Contradicts requires updating both files. The coverage-assessment-guide.md is the definition site; check-gaps/SKILL.md references it for the classification algorithm and format rules. Update coverage-assessment-guide.md first, then check-gaps/SKILL.md to confirm it references the updated four-tier taxonomy.

### Advisory-Not-Gate Principle
**Source:** `check-gaps/SKILL.md` lines 58–59 (guardrails), `CONTEXT.md` §Established Patterns
**Apply to:** Evidence Against status definition in both check-gaps and coverage-assessment-guide

Evidence Against is informational, same as all coverage flags. It must not block or prevent research from proceeding. The language in both files should mirror the existing "Addressed but unbalanced" framing: descriptive, not prescriptive. No guardrail should say "must be resolved before synthesis" — say "the user must address the contradiction in the draft."

---

## No Analog Found

None. All four modifications have direct analogs or self-analogs in the codebase.

---

## Metadata

**Analog search scope:** `.claude/reference/discovery/channel-playbooks/`, `.claude/commands/research/`, `.claude/reference/`
**Files scanned:** 8 (academic.md, regulatory.md, web-search.md, discover/SKILL.md, check-gaps/SKILL.md, coverage-assessment-guide.md, financial.md via Glob, REQUIREMENTS.md)
**Pattern extraction date:** 2026-04-20
