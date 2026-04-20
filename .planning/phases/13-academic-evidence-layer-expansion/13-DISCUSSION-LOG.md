# Phase 13: Academic & Evidence Layer Expansion - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-20
**Phase:** 13-academic-evidence-layer-expansion
**Areas discussed:** Crossref integration architecture, Unpaywall lookup trigger, Gap distinction mechanism
**Mode:** --auto (all decisions auto-selected from recommended defaults)

---

## Crossref Integration Architecture

| Option | Description | Selected |
|--------|-------------|----------|
| Extend academic.md playbook | Add Crossref as parallel query within existing academic channel | ✓ |
| Separate crossref.md playbook | Create new channel playbook for Crossref | |
| Sub-tier/enrichment layer | Make Crossref a metadata enrichment pass after OpenAlex | |

**User's choice:** [auto] Extend academic.md playbook (recommended default)
**Notes:** Follows established pattern — one playbook per channel type. Crossref fills metadata gaps (DOI, author, citation count) that OpenAlex may miss. Adding a separate channel would proliferate the channel list without meaningful routing benefit since Crossref serves the same domain as OpenAlex.

---

## Unpaywall Lookup Trigger

| Option | Description | Selected |
|--------|-------------|----------|
| Enrich all DOI results | Call Unpaywall for every result with a DOI during discovery | |
| Enrich only paywalled papers | Call Unpaywall only for is_oa=false results during discovery | ✓ |
| Post-discovery enrichment | Separate pass after user selects candidates | |

**User's choice:** [auto] Enrich only paywalled papers during discovery (recommended default)
**Notes:** Targeted — only calls Unpaywall where it can actually change status (DISCOVERED → ACCESSIBLE). Bounded by 8-result cap. Candidates arrive with correct status before user review. Graceful degradation: if Unpaywall fails, paper stays DISCOVERED and discovery continues.

---

## Gap Distinction Mechanism

| Option | Description | Selected |
|--------|-------------|----------|
| Extend classification taxonomy | Add "Contradicts" as 4th relevance value alongside Direct/Adjacent/None; add "Evidence Against" coverage status | ✓ |
| Separate contradiction pass | Run contradiction detection as a post-gap-analysis step | |

**User's choice:** [auto] Extend classification taxonomy (recommended default)
**Notes:** Fits naturally into existing step 6 relevance classification loop. The check-gaps skill already examines each source note's relationship to each question — adding a "Contradicts" classification is a one-line decision per source-question pair. Keeps gap analysis as a single-pass operation consistent with the full-regeneration pattern.

---

## Claude's Discretion

- Crossref query template design and field selection
- Unpaywall API endpoint details and response parsing
- Taxonomy interaction between "Contradicts" and "Addressed but unbalanced"
- Deduplication presentation (silent drop vs. noted in channel status)

## Deferred Ideas

None — discussion stayed within phase scope
