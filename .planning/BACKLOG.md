# Backlog

Ideas and improvements captured for future milestones. Not committed to a roadmap yet.

## Behavior Changes (no new commands)

### Prior-phase note surfacing in start-phase
When starting a new phase, start-phase should scan `research/notes/` for notes from prior phases that are relevant to the current phase's questions and surface them. Currently start-phase shows open assumptions and coverage snapshots but doesn't tell the agent "these existing notes are relevant to what you're about to research." Without this, the agent won't consult prior work unless the user points it out — which defeats the purpose of carrying context forward across phases.

### audit-claims staleness Read gap (INT-01 from v1.2 audit)
audit-claims step 8a references staleness threshold as a confidence tier input but lacks Read instructions for research-plan.md and the type template. Needs the same Read pattern summarize-section pre-check 4 uses. Advisory-only impact — confidence tier for staleness-heavy sections may be inaccurate.

## New Capabilities

### Analyst Report / Vendor Evaluation research type
Forrester Wave / Gartner Magic Quadrant-style output. Multi-layered research structure — not a single linear pass like current types. Likely phases:

**Layer 1 — Landscape:** Market definition, segmentation, trends, market sizing. Essentially Market/Industry Research scoped to set the stage.

**Layer 2 — Vendor deep-dives:** Individual research passes per vendor (could leverage Company Research mechanics). Needs to handle N vendors without the phase count exploding — possibly a repeating sub-cycle rather than fixed phases.

**Layer 3 — Comparative scoring:** Weighted evaluation criteria applied consistently across all vendors. Scored matrix output. This is the signature deliverable — requires defining criteria up front, then scoring each vendor against them with sourced evidence for every score.

**Layer 4 — Buyer guidance:** Synthesis that maps vendor strengths to buyer profiles/use cases. "If you need X, choose Y because Z."

Design questions to resolve:
- How does the phase cycle work when Layer 2 repeats per vendor? Sub-phases? A vendor loop within a single phase?
- Who defines the evaluation criteria and weights — the user during init, or the plan generator from the landscape findings?
- How to handle the scoring matrix — structured data (JSON) or markdown table? Needs to be auditable like everything else.
- Should this type support a "short form" (3-5 vendors, lighter landscape) and "full form" (10+ vendors, deep landscape)?

### Custom research types
Let users define their own research types beyond the built-in ones. A custom type would need its own phase structure, finding tags, credibility hierarchy, and validation standards. The type system is already template-driven — adding a new type is creating a template file. Could include guided scaffolding (answer questions about the domain, system generates the template) or manual template creation.

## Deferred from v1.1

### Additional channels (from REQUIREMENTS.md v1.2)
- **CHAN-06**: YouTube Data API integration for video/transcript discovery (curriculum, person research)
- **CHAN-07**: Semantic Scholar full integration (redundant with OpenAlex for most types; add as enhancement)
- **CHAN-08**: Podcast RSS discovery (requires transcription infrastructure)

### Discovery enhancements
- **DSKL-08**: Cross-channel deduplication (URLs don't deduplicate DOIs; complex to implement correctly)
- **DSKL-09**: Re-discovery mid-phase deduplication against already-processed sources in registry

## Paid Channel Integrations

Investigated 2026-03-31. Only viable if user has their own account/API key.

### Crunchbase Pro API (most viable)
Self-serve API key ($49-99/mo), standard HTTP/curl, same integration pattern as OpenAlex/EDGAR. Fills the startup/company intelligence gap — funding rounds, acquisitions, investor details, employee counts, growth signals. Free tier is very limited; Pro gives real API access.

### LexisNexis API (enterprise only)
API exists, HTTP/curl compatible, but requires enterprise contract — no self-serve signup. Would be high-value for deep background research (litigation, historical news, public records). Revisit if a user with an existing LexisNexis account wants it.

### Factiva / Dow Jones API (enterprise only)
API exists, HTTP/curl compatible, but requires enterprise license. Deep news archive across thousands of publications — fills the historical coverage gap Tavily can't touch. Same access barrier as LexisNexis.

### LinkedIn Sales Navigator API (blocked)
SNAP partner program paused since Aug 2025, not accepting new applications. Would have been the biggest win for person research. Dead end until LinkedIn reopens the program.

## Step-Change Model Version

When a significantly more capable model (Mythos-class or equivalent) becomes available, audit the research agent for simplification. The principle: prescriptive scaffolding may become a constraint, but methodology is not scaffolding. Test empirically before removing anything.

### Candidates to simplify
- **Channel playbook query templates** — Shrink to API constraints and rate limits only, let model figure out query construction instead of step-by-step recipes
- **Type-channel map matching logic** — Let model infer relevant channels from phase questions instead of keyword-matching phase names to discovery groups
- **Process-source extraction structure** — Less prescription on how to parse sources into findings/limitations/credibility ratings

### Keep deterministic regardless of model capability
- 5-step phase cycle (Collect → Connect → Assess → Synthesize → Verify) — this is methodology, not scaffolding
- Source registry and structured note format — the audit trail
- Human gates (post-discovery review, cross-ref pauses) — smarter models make these more important, not less
- Audit-before-promotion to outputs
- Integrity agent watchlist (fabrication, range narrowing, qualifier stripping)

### Watch but don't change yet
- Cross-ref and gap analysis prompting — test empirically before loosening
- Integrity agent failure mode checks — low cost to keep, catches regressions

### How to test
Relax prescriptive parts, compare output quality and consistency against current baseline across multiple research types. If consistency drops, keep the playbooks. If outputs improve with no consistency loss, simplify.

## Watch For (not committed — waiting for real-world signal)

### Cross-project knowledge accumulation
Inspired by Karpathy's LLM knowledge base concept — a living wiki that compounds across projects rather than starting fresh each time. Research Agent currently scopes knowledge to a single project; each `/research:init` starts from zero. If two projects share a domain (e.g., competitive analysis followed by PRD validation in the same market), findings from the first don't carry forward. The question is whether this is a real problem or a theoretical one. Within-project compounding (prior-phase note surfacing, the backlog item above) is the proven gap. Cross-project accumulation adds trust problems (staleness, relevance decay) and complexity. **Watch for:** a concrete case where a previous project's findings would have saved meaningful re-work. If that happens, the shape of the feature will be obvious. If it doesn't happen after several projects, this stays parked.

## Out of Scope (decided, with reasons)

Carried from v1.1 — revisit only if circumstances change.

| Feature | Reason |
|---------|--------|
| Google Scholar integration | No API, blocks crawlers — OpenAlex covers the same material |
| Google Trends integration | Unofficial API, fragile, rate-limited — document as manual URL step |
| Google News integration | No API — Tavily `topic: "news"` covers this use case |
| Auto-processing discovered sources | Human gate is a design choice |
| MCP servers for academic/government sources | Direct HTTP is simpler and more reliable |
