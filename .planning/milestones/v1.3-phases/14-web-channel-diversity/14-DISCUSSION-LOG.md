# Phase 14: Web Channel Diversity - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-20
**Phase:** 14-web-channel-diversity
**Areas discussed:** Exa integration point, Deduplication strategy, Source attribution, Exa API configuration
**Mode:** --auto (all decisions auto-selected from advisor recommendations)

---

## Exa Integration Point

| Option | Description | Selected |
|--------|-------------|----------|
| Extend web-search.md | Follow Phase 13 pattern — add Exa inside existing web-search playbook since it serves same domain (general web). Dedup co-located. No routing changes. | :white_check_mark: |
| Separate exa.md playbook | Isolated, easy to toggle. But proliferates channel list for same domain; requires discover skill and all type-channel map updates. |  |

**User's choice:** [auto] Extend web-search.md (recommended — follows Phase 13 Crossref-into-academic.md precedent)
**Notes:** Phase 13 set the precedent: Crossref went inside academic.md because it serves the same domain as OpenAlex. Exa and Tavily both return general web URLs — same case.

---

## Deduplication Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Exact URL match | Zero new logic; matches discover Step 4 contract; consistent for re-runs and cross-engine dedup. | :white_check_mark: |
| URL normalization (strip params + trailing slash) | Catches UTM/tracking param variants. Low complexity but risk of over-dedup on meaningful params (pagination, DOI resolvers). |  |

**User's choice:** [auto] Exact URL match (recommended — matches existing contract; overlap is on canonical URLs)
**Notes:** Exa neural search and Tavily keyword search use different retrieval models, so overlap is most likely on the same canonical URL for high-authority pages — not tracking-param variants.

---

## Source Attribution

| Option | Description | Selected |
|--------|-------------|----------|
| Inline tag per candidate | `[Tavily]`/`[Exa]`/`[Tavily+Exa]` tag on each line. Extends existing tag pattern. Satisfies SC#3 literally. | :white_check_mark: |
| Combined status line only | Mirrors academic channel pattern. Aggregate counts but no per-entry attribution. May not satisfy SC#3 literally. |  |

**User's choice:** [auto] Inline tag per candidate (recommended — SC#3 requires per-entry visibility; combined status line added as supplement)
**Notes:** Both approaches are composable. Inline tag is load-bearing for SC#3; combined status line at section header provides aggregate counts.

---

## Exa API Configuration

| Option | Description | Selected |
|--------|-------------|----------|
| Auto mode (Exa default) | Exa's recommended default. Routes neural vs keyword per query via internal categorization. Durable across query types. | :white_check_mark: |
| Hardcode neural | Guarantees semantic behavior always. Underperforms on exact-match queries (error codes, jargon, proper nouns). |  |

**User's choice:** [auto] Auto mode (recommended — handles both semantic and exact-match queries; still uses neural for broad queries that motivated adding Exa)
**Notes:** Exa's `auto` mode is their recommended default. Real-world research queries span both semantic and exact-match needs.

---

## Claude's Discretion

- Exa query template parameter details (num_results, date filters, content type filters)
- Whether Exa's `autopromptString` response field should be logged
- Exact positioning of Exa templates in web-search.md
- Whether to add Exa-specific credibility tier notes

## Deferred Ideas

None — discussion stayed within phase scope
