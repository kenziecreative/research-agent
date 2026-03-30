# Phase 2: Type-Channel Maps - Context

**Gathered:** 2026-03-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Create 9 type-channel map files that route each research type's phases to prioritized discovery channels. Each map derives its channel priorities from the type template's existing credibility hierarchy. Maps are consumed by the discover skill (Phase 3) to determine which channels to query for a given research type and phase.

Types: company-for-profit, company-non-profit, competitive-analysis, curriculum-research, exploratory-thesis, market-industry, person-research, prd-validation, presentation-research.

</domain>

<decisions>
## Implementation Decisions

### Map structure
- **Phase-grouped sections** — group phases by their channel needs (e.g., "Discovery Group: Financial Evidence" covering financials, market-position, funding phases)
- **Phase name keywords** for identification — use descriptive keywords from the type template's phase pattern (e.g., "financials", "leadership"), not phase numbers. The discover skill matches the current phase name against these keywords
- **Brief rationale** per discovery group — one line explaining why those channels are primary for those phases, grounded in the type's credibility hierarchy
- **Dedicated "Domain-Specific Sources" section** per map — fills in the type hooks defined in the domain-specific channel playbook with type-specific sources (e.g., Crunchbase/PitchBook for company, educational standards databases for curriculum)
- **YAML frontmatter** with `active-channels` field listing all channels used by this type — enables quick lookup by the discover skill without parsing the full document

### Priority notation
- **Primary/Secondary labels** — two-tier system. Primary channels are always executed; secondary channels execute if primaries return fewer than the cap (5-8 sources)
- **List order within primary** is Claude's discretion — the discover skill may or may not use it for execution ordering
- **No extra query hints** — phase keywords listed in the group plus the project's research questions are sufficient. Playbooks handle query construction

### Default channels
- **Web-search listed explicitly** in every discovery group where it applies — no implicit defaults. Each map is self-contained; what you see is what the discover skill executes
- **All 9 types use phase-grouped structure** — even broad types like exploratory-thesis group phases by channel needs rather than using a flat "all phases" approach
- **Synthesis/final phases omitted** from maps — phases like risks, synthesis, gaps don't need new discovery. If the discover skill finds no group match for a phase, it reports "No discovery channels mapped for this phase — this phase uses existing sources"

### Cross-type overlap
- **Fully independent maps** — each type gets its own complete, self-contained map file. No shared bases or cross-file imports. Similar content across types (e.g., company-for-profit and company-non-profit overview groups) is duplicated, not shared
- **File names match type template names exactly** — the discover skill derives the map filename directly from the project's research type (e.g., research type "company-for-profit" → `type-channel-maps/company-for-profit.md`)
- **Rationale lines provide traceability** to credibility hierarchies — no formal cross-reference syntax needed
- **Group granularity per type** is Claude's discretion — types with high channel variation across phases (competitive-analysis, market-industry) may use more granular groups

### Claude's Discretion
- List order within primary channels (whether it implies execution priority)
- Number and granularity of discovery groups per type — based on channel variation across that type's phases
- Exact phase keyword selection from type template phase patterns
- Domain-specific source categorization within the dedicated section

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.claude/reference/discovery/channel-playbooks/`: 6 playbooks (web-search, academic, regulatory, financial, social-signals, domain-specific) — define the channel names these maps reference
- `.claude/reference/templates/types/*.md`: 9 type templates with credibility hierarchies and phase patterns — the source of truth for deriving channel priorities and phase groupings
- Domain-specific playbook's type-hook template pattern — maps fill in type-specific routing details

### Established Patterns
- YAML frontmatter on reference files (established in Phase 1 playbooks)
- Phase patterns documented in type templates (e.g., "8-10 phases: overview → leadership → products → financials → market → customers → partnerships → culture → risks → synthesis")
- Credibility hierarchies rank sources by type (SEC filings highest for company financials, peer-reviewed research highest for thesis)

### Integration Points
- Maps are read by the discover skill (Phase 3) at runtime to determine channel routing
- Map filenames must be derivable from the research type string stored in the project's CLAUDE.md
- `active-channels` frontmatter field enables quick channel availability checking by the skill
- Domain-specific sources section feeds into the domain-specific channel playbook's type-hook mechanism

</code_context>

<specifics>
## Specific Ideas

- Structure mirrors Phase 1's standalone-file approach — each map is fully self-contained like each playbook is self-contained
- Phase keyword matching (not numbering) ensures maps work even when the plan-generator reorders phases for a specific project

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-type-channel-maps*
*Context gathered: 2026-03-29*
