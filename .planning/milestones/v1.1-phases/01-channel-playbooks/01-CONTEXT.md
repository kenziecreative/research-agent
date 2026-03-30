# Phase 1: Channel Playbooks - Context

**Gathered:** 2026-03-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Create 6 channel playbook reference files that define query construction, credibility tiers, and graceful degradation for each discovery channel type. These playbooks are consumed by the discover skill (Phase 3) at runtime to know how to query each channel.

Channels: web-search, academic, regulatory, financial, social-signals, domain-specific.

</domain>

<decisions>
## Implementation Decisions

### File format
- Playbooks are **skill files with YAML frontmatter** (like foresight guidance files), not plain reference markdown
- Frontmatter includes metadata (name, description, allowed-tools, channel type) for contextual loading by the discover skill
- Located in `.claude/reference/discovery/channel-playbooks/`

### Section layout
- All 6 playbooks use an **identical section layout** — same headers in same order
- Channel-specific details go in the content, not the structure
- Consistent structure allows the discover skill to rely on predictable parsing

### Query construction
- **Exact templates with placeholders** — the discover skill does substitution, not interpretation
- **2-3 query variants per channel** covering different discovery angles (topic search, entity search, filtered search)
- For Tavily-based channels: **exact parameter values specified** (include_domains lists, topic values, search_depth)
- Example: `GET /works?search={topic}&filter=cited_by_count:>10&per_page=8`

### Credibility tiers
- **Channel-level tiers** (Tier 1/2/3 with descriptions) — ranking sources within each channel, separate from the cross-channel hierarchies in type templates
- **Label format only** — no numeric scores
- Each channel includes **red flag indicators** for sources that look legitimate but are commonly misleading in that channel (e.g., predatory journals, company press releases disguised as analyst coverage)

### Degradation behavior
- **Fallback chains** per channel — primary tool fails, fall back to Tavily with domain-scoped filters
- **Fallback results are labeled** with their actual source method (e.g., "via Tavily (OpenAlex fallback)")
- Playbooks define **"unavailable" criteria** (HTTP 5xx, timeout, rate limited) — the discover skill handles retry logic uniformly
- **Rate limits documented** per channel for APIs with known limits
- **Without Tavily:** Degrade gracefully to WebSearch for general discovery + direct HTTP APIs (OpenAlex, EDGAR, ProPublica) for specialized channels. Warn user that results will be less targeted. Report degraded channels explicitly.

### Domain-specific channel
- The domain-specific playbook uses a **template with type hooks** — structured placeholders per research type (e.g., "For company research: Crunchbase, PitchBook. For curriculum: educational standards databases.")
- Type-channel maps in Phase 2 fill in the type-specific routing details

### Claude's Discretion
- Example output sections — include for non-Tavily channels (OpenAlex, EDGAR, ProPublica) where response format is less obvious; skip for Tavily channels
- Exact frontmatter fields beyond the required ones (name, description, allowed-tools)
- Internal section ordering within the identical layout
- File naming convention for the 6 playbook files

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `.claude/reference/source-assessment-guide.md`: Detailed credibility assessment patterns (recency, methodology, conflict of interest) — playbook credibility tiers should complement, not duplicate
- `.claude/reference/tools-guide.md`: Existing Tavily tool documentation — playbooks extend this with channel-specific parameter usage
- `.claude/reference/templates/types/*.md`: 9 type templates with credibility hierarchies — playbook channel-level tiers rank within a channel; these rank across channels

### Established Patterns
- Reference files use markdown with clear section headers
- Type templates follow a consistent structure: finding tags, analysis sections, credibility hierarchy, boundaries, phase pattern, success criteria
- Tools guide uses table format for tool/use/don't-use mappings

### Integration Points
- Playbooks will be read by the discover skill (Phase 3) at runtime
- Type-channel maps (Phase 2) reference channel names defined in these playbooks
- Degradation fallbacks use Tavily tools already documented in tools-guide.md
- Source status taxonomy (DISCOVERED / ACCESSIBLE / PROCESSED) defined here, consumed across the discovery pipeline

</code_context>

<specifics>
## Specific Ideas

- Structure inspired by foresight project guidance files (e.g., `1.6.1-environment-conducive-to-open-thinking.md`) — skill files with YAML frontmatter and structured content
- Query templates should be concrete enough that the discover skill does substitution, not interpretation — closer to API documentation than natural language guidance

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-channel-playbooks*
*Context gathered: 2026-03-29*
