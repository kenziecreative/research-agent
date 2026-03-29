# Domain Pitfalls: Multi-Channel Source Discovery

**Domain:** Adding multi-channel source discovery to an existing prompt-driven research tool
**Researched:** 2026-03-28
**Context:** v1.1 milestone — adding `/research:discover` to a system that currently uses Tavily web search as its sole discovery mechanism
**Confidence note:** Web search and WebFetch were unavailable during this research session. Findings are derived from: (1) deep reading of the existing system's source files, (2) training knowledge about academic API behavior, MCP architecture, and prompt-driven system failure modes, and (3) direct analysis of the specific architecture described in the project context. Confidence is HIGH for pitfalls specific to this codebase's architecture, MEDIUM for API-specific behavior patterns where official docs could not be consulted.

---

## Critical Pitfalls

Mistakes that cause rewrites, workflow breakdowns, or significantly degraded research quality.

---

### Pitfall 1: Discovery-Processing Mismatch

**What goes wrong:** The discover skill finds sources that process-source cannot handle. Academic papers behind paywalls, interactive dashboards that require JavaScript rendering, government dataset portals returning CSV/Excel files, patent PDFs with proprietary encoding, and news archives requiring subscriptions. The user receives a list of 8 sources, runs `/research:process-source` on each one, and half fail silently or return truncated content. The research record looks complete but is built on partial extraction.

**Why it happens:** Discovery and processing have different surface areas. A database can surface a citation for something that `tavily_extract` or `WebFetch` cannot reach. Discovery APIs (OpenAlex, Semantic Scholar, PubMed) are purpose-built to return metadata and identifiers — they are not content delivery systems. The DOI they return points to a journal gate, not an open PDF.

**Consequences:**
- Source notes are created from abstracts or snippets, not full text. This is exactly what process-source's guardrails forbid ("Never work from search snippets").
- Credibility assessments are incomplete because methodology sections and caveats are in the paywalled body.
- Cross-reference and gap-check downstream operate on shallow notes, producing false coverage signals.
- The system's integrity guarantee ("every claim traces to a processed source") is technically satisfied but substantively hollow.

**Prevention:**
- Define a source status taxonomy during design: `DISCOVERED` (URL/DOI found), `ACCESSIBLE` (full text reachable), `PROCESSED` (full note written). Discover should report all three categories.
- In the discovery playbooks, include access notes per channel: "OpenAlex returns DOIs — check for open access PDF links in the `open_access` field before handing to process-source."
- The discover skill should probe accessibility before surfacing a source. For academic papers: check for open access status, PubMed Central full text, or preprint availability (arXiv, SSRN, bioRxiv) before presenting a DOI that leads to a $40 purchase.
- Instruct the discover skill to explicitly label inaccessible sources as `DISCOVERED (paywalled)` so the user can decide whether to seek access rather than attempting process-source on them.

**Detection (warning signs):**
- Process-source producing notes shorter than usual for academic sources.
- Source notes that cite the abstract language verbatim — a sign the body was never reached.
- Credibility assessments that omit methodology quality (can only be assessed from the body).
- User reporting that `tavily_extract` returned "access denied" or login prompts.

**Phase to address:** Before writing discovery playbooks — the playbook for each channel must document what the channel actually delivers and how to bridge to process-source.

---

### Pitfall 2: Channel Noise Overwhelming the Researcher

**What goes wrong:** Academic databases return hundreds of results that are technically related but substantively useless for the research question. A query for "non-profit financial sustainability" against Semantic Scholar returns papers on ecological sustainability, papers about financial instruments unrelated to non-profits, literature reviews in languages the user doesn't read, and papers from 2003 that predate modern non-profit reporting standards. The researcher is handed a list of 40 sources and must manually triage all of them.

**Why it happens:** General-purpose academic APIs do not understand research types. They return papers matching keyword semantics, not research intent. The current Tavily search returns 5-10 results with snippets that allow quick triage. An academic API query without strict filtering can return 200+ results with metadata only. The volume is an order of magnitude higher, and the quality signal is lower.

**Consequences:**
- Discovery becomes slower and more cognitively taxing than just running a Tavily search.
- The researcher loses the time-to-useful-source advantage that multi-channel discovery is supposed to provide.
- If the discover skill tries to auto-filter without explicit guidance, it will make poor triage decisions and silently drop relevant sources.
- The phase-sequential workflow breaks down because the collect step becomes a triage marathon before any notes are written.

**Prevention:**
- Apply strict result count caps per channel in the discovery playbooks. "Return no more than 5-8 sources per channel per query" is a concrete constraint to embed in the discover skill's instructions.
- Define tiering: "Return results ranked by: (1) open access availability, (2) citation count as proxy for field relevance, (3) recency. Present the top 5 with enough metadata for the user to triage in 30 seconds per source."
- Per-research-type query templates that include field narrowing, date range defaults (e.g., last 5 years for market research types), and exclusion patterns (e.g., exclude non-English results unless the user's topic is international).
- Force a human decision point after discovery: discover presents a prioritized shortlist, the user selects which sources to process, then process-source runs. Do not auto-queue all discovered sources for processing.

**Detection (warning signs):**
- Discovery returning more than 10 sources per channel per query.
- User asking "which of these should I process?" — means the skill failed to do its triage job.
- Time-to-first-processed-source growing longer after adding channels.
- Discover skill output lists growing longer than one screen.

**Phase to address:** When designing the query templates in discovery playbooks. Hard caps belong in the playbook, not improvised at runtime.

---

### Pitfall 3: API Fragility and Silent Degradation

**What goes wrong:** A channel that worked during development stops working in production. An API introduces rate limits that weren't documented. A service changes its URL structure. An MCP server for a specialized database silently returns empty results when a query fails validation. The user runs `/research:discover` on a curriculum research project expecting academic coverage, gets no academic results, and doesn't know why.

**Why it happens:** This is a prompt-driven system — there is no error handling code, no retry logic, no circuit breaker. When an MCP tool fails, the model sees an error string or empty response. A well-instructed skill will surface this; a poorly-instructed skill will silently continue as if the channel produced no relevant results. The distinction between "no relevant sources exist" and "the channel failed" is lost.

**Specific fragility patterns to anticipate:**
- **Rate limiting:** OpenAlex anonymous tier allows ~10 requests/second and has daily quotas. Semantic Scholar's unauthenticated tier rate-limits aggressively. A discovery run across 3-4 channels in sequence will likely hit limits within a session.
- **Query validation failures:** Many academic APIs reject queries with special characters, very long queries, or queries that don't match their field schema. The API returns a 400 or an empty result set. Without explicit error checking in the skill, this is invisible.
- **MCP server downtime:** Community-maintained MCP servers for academic sources may have availability issues. The user's configured MCP stack is not under this project's control.
- **Schema changes:** A third-party API that returns `open_access_url` today might change the field name to `oa_url` tomorrow. The skill's instructions that reference the old field name will silently fail.

**Consequences:**
- The researcher has incomplete source coverage without knowing it — the worst outcome for an evidence-based research system.
- Trust in the discover skill erodes. After one or two failed discovery runs, users route around it and return to manual search.
- Gap analysis downstream can't distinguish "gap because no sources exist" from "gap because discovery failed."

**Prevention:**
- Instruct the discover skill to report channel status explicitly, not just results: "OpenAlex: 4 sources found. Semantic Scholar: rate limit reached — 0 sources this run. Tavily web: 6 sources found." Make every channel's outcome visible.
- Build graceful degradation into the discover skill's instructions: "If a channel returns an error or empty result that might indicate a configuration or rate-limit issue rather than genuine zero results, flag it as 'CHANNEL ERROR — verify configuration' rather than treating it as no results."
- Use a conservative result limit per query (3-5 results rather than 20) to stay well under rate limits during normal use.
- Document each channel's known limits in the discovery playbook: rate limits, authentication requirements, query length constraints. This is reference material the skill can read.

**Detection (warning signs):**
- Discovery run returning results from some channels but not others without explanation.
- Results that look like they should have returned academic coverage but only show web results.
- User reporting that the same query returned results last week but not today.

**Phase to address:** When writing channel-specific instructions and channel availability documentation. The "report channel status explicitly" instruction is the single most important safeguard.

---

### Pitfall 4: Scope Creep in the Discover Skill

**What goes wrong:** The discover skill grows to include source quality pre-assessment, deduplication logic across channels, relevance scoring, automatic channel selection based on research type, and progressive disclosure of results. Each addition is individually defensible. Collectively, they make the skill too complex to debug, too slow to run, and too brittle when any one component misbehaves. The skill that should take 30 seconds to produce a source shortlist now takes 5 minutes and returns inconsistent results.

**Why it happens:** Prompt-driven systems have no natural complexity ceiling on a skill. Code has compile errors, test failures, and cognitive overhead from complexity. A SKILL.md file with 200 lines looks much the same as one with 600 lines — it just runs longer and fails in more subtle ways. The temptation is to move complexity into the skill rather than into the playbooks or user judgment.

**Specific scope creep vectors to watch:**
- Auto-selecting channels based on research type (moves judgment from the playbook into the skill's runtime behavior — harder to audit).
- Automatically filtering results by relevance score before presenting to the user (model may filter incorrectly; better to present and let the user triage).
- Deduplication across channels (legitimate but complex — URLs don't deduplicate DOIs, and the same paper may appear in multiple databases with different identifiers).
- Combining discovery with preliminary process-source calls to "pre-assess" quality (blurs the boundary between discover and process-source; breaks the existing pipeline structure).

**Consequences:**
- The skill becomes harder to troubleshoot when results are poor. "Which part of the skill made this judgment?" is unanswerable.
- Onboarding new research types requires understanding the full complexity of the skill, not just the playbook.
- The skill's value proposition — "tells you where to look" — dilutes into "does the research for you," which conflicts with the human-in-the-loop design principle.

**Prevention:**
- Define the discover skill's job narrowly before writing it: "Discover finds candidate source URLs and metadata. It does not assess quality, does not process content, and does not make decisions the user should make." Write this definition into the skill's header.
- Put per-research-type intelligence into the playbooks, not the skill's logic. The skill reads a playbook; the playbook provides channel priorities and query templates. Changing a research type's discovery behavior means editing a playbook, not re-engineering the skill.
- Resist adding features to the skill during the first implementation. Get a working single-channel discover first, then extend to multi-channel, then evaluate whether more features are needed.
- Use the complexity test: "Can I describe what this skill does in one sentence?" If not, it's too complex.

**Detection (warning signs):**
- SKILL.md growing past 150 lines.
- The skill making decisions that the user or the playbook should make.
- Discovery runs taking noticeably longer than expected.
- Users reporting that the skill "did something I didn't expect."

**Phase to address:** During initial skill design. The architecture decision (skill = thin orchestrator, playbooks = intelligence) must be made before writing the skill.

---

## Moderate Pitfalls

---

### Pitfall 5: Over-Engineering API Integrations

**What goes wrong:** Time is invested building (or configuring) elaborate multi-tool integrations for channels that rarely produce useful results for most research types. Example: a Google Patents MCP integration built for completeness, used in 1 of 9 research types (PRD validation), and only when the PRD involves patentable technology. The integration adds cognitive overhead (yet another MCP server to configure), adds brittleness (patents API schema changes), and adds maintenance burden — for coverage that Tavily's web index often provides through patent databases' public-facing sites anyway.

**Why it happens:** Multi-channel discovery sounds comprehensive. There's a natural pull toward "and we could also add patents, and government regulations, and social media, and..." The AI Anthropology Toolkit (referenced in PROJECT.md) integrates YouTube, podcast RSS, Google Patents, Google Trends, etc. That pattern is appropriate for a domain-specific research tool with known, narrow discovery needs. A general 9-type research system has very different ROI curves per channel per type.

**Prevention:**
- Map channels to research types before implementing any integration. For each channel, count how many of the 9 research types regularly benefit from it. Channels that benefit 1-2 types are candidates for deferral.
- Prefer Tavily's advanced search depth as the first escalation path before adding new channels. Tavily with `search_depth: "advanced"` and targeted queries can surface many academic and government sources through their public web presence.
- Implement the channel availability model first: document which channels exist and what they're good for, before wiring up any integrations. This makes it easy to add channels incrementally rather than all at once.
- Set a concrete bar: "A channel integration is worth building if it surfaces sources that Tavily cannot reach AND those sources are high-credibility for at least 3 research types." Apply this bar explicitly.

**Detection (warning signs):**
- Spending more than 1-2 hours configuring an integration before testing whether it surfaces useful sources for real research questions.
- MCP server configuration requirements growing to more than 2-3 servers for standard use.
- Channels added "for completeness" rather than "because a real research type needs it."

**Phase to address:** During discovery playbook design, before any integrations are wired up. Channel selection is a design decision, not an implementation one.

---

### Pitfall 6: Configuration Burden Gatekeeping Basic Use

**What goes wrong:** The discover skill requires 4-5 MCP servers to be configured before it functions at full capability. New users see a list of required setup steps before they can run their first discovery. Users with only Tavily configured get degraded results with no clear explanation of why. The tool becomes for "serious researchers who've done the setup" rather than for anyone doing research.

**Why it happens:** Each specialized channel typically requires its own MCP server or API key. If the skill is designed assuming all channels are available, configuration drift (some users have some servers) produces unpredictable results. This is especially acute because this is a prompt-driven system — there's no build step where missing dependencies fail loudly.

**The existing system's constraint is explicit:** "All source channels must be free or use APIs the user already has configured." This is a sound constraint that scope creep can quietly violate.

**Prevention:**
- Design the discover skill to degrade to Tavily-only if no other MCP tools are available. Tavily is already configured by all users. Every other channel is additive, not required.
- Tier the channel additions: Tier 1 (works with Tavily only), Tier 2 (works with free-to-configure additions like OpenAlex which is no-auth), Tier 3 (requires additional API keys). Document the tiers explicitly.
- Test the Tavily-only experience before adding other channels. If the Tavily-only discover skill is already useful, it ships first. Channels are added based on demonstrated user need, not anticipated completeness.
- The channel availability documentation in the playbooks should include: "If this channel's MCP server is not configured, skip it and note 'CHANNEL NOT CONFIGURED' in the discovery report."

**Detection (warning signs):**
- Discovery skill documentation beginning with a setup checklist longer than 3 steps.
- A user's first interaction with the skill producing errors about unconfigured tools.
- The skill assuming specific MCP tools are available without checking.

**Phase to address:** When writing the first version of the discover skill. The Tavily-first degradation model must be in the initial design.

---

### Pitfall 7: Discover Becoming a Replacement for Tavily Web Search

**What goes wrong:** The discover skill is designed so comprehensively that users start running it for every source collection session, even for research types where plain Tavily search was already sufficient. The skill adds latency and complexity for no benefit. Worse, the discover skill's structured output (channel reports, source shortlists, metadata) may be less useful than Tavily's search snippets for quick triage on general web sources.

**Why it happens:** A new skill is a new tool, and new tools attract use. If the discover skill is positioned as "the right way to find sources," users will route all discovery through it even when `/research:process-source` with a Tavily search was a faster path.

**Prevention:**
- Position the discover skill for specific scenarios, not as a universal replacement for manual search. In the CLAUDE.md skills table, the discover skill's description should be specific: "Use when you need to find sources across specialized channels (academic, government, news archives) for a research phase. For general web sources, Tavily search directly."
- The discover skill should reference its own ideal use cases in its header: "Best for: academic paper discovery, government document discovery, news archive search. Not needed for: general web research, known-URL processing, quick fact checks."

**Detection (warning signs):**
- Users running discover for every source collection session regardless of research type.
- Discover producing mostly web results that Tavily would have found anyway.
- The skill being slower than direct Tavily search for general research questions.

**Phase to address:** When writing the skill's description and the documentation in CLAUDE.md's skills table.

---

## Pitfalls Specific to Prompt-Driven Architecture (No Code)

This system is entirely prompt-driven — the "discover" skill is a SKILL.md file, not code. The following pitfalls are specific to this architecture and do not exist in traditional software integrations.

---

### Pitfall 8: SKILL.md Phantom Command Risk

**What goes wrong:** Discovery playbook files (per-research-type search templates) are accidentally placed inside `.claude/commands/research/` instead of `.claude/reference/`. Any `.md` file in that directory becomes a slash command. A file named `academic-discovery-playbook.md` placed in the wrong directory will appear as `/research:academic-discovery-playbook` — a non-functional phantom command that pollutes the command namespace and confuses users.

**This is documented in PROJECT.md as an existing constraint:** "Reference files, templates, and discovery playbooks must NOT live inside `.claude/commands/research/`."

**Prevention:**
- All discovery playbooks go in `.claude/reference/playbooks/` (or similar path under reference, not commands).
- Add a pre-implementation note in the discovery architecture design: "Playbooks are reference files, not commands. They live in `.claude/reference/`, not `.claude/commands/`."
- When verifying the implementation, explicitly check that `.claude/commands/research/` contains only `SKILL.md` files intended as commands.

**Detection:** Running `/research:` in Claude Code and seeing unexpected command names in autocomplete.

**Phase to address:** Architecture decision before writing any files.

---

### Pitfall 9: Instructions Drift Between Skill and Playbooks

**What goes wrong:** The discover skill's SKILL.md says "read the discovery playbook for this research type." The playbook says "for academic sources, return 5-8 results sorted by citation count." Six months later, the playbook is updated to use a different sorting criterion, but the skill's instructions still reference the old behavior. Because there's no contract enforcement between files (no function signatures, no type checking, no tests), the drift is invisible until it produces unexpected results.

**Why it happens:** In code, a function signature change that breaks a caller fails at compile time or test time. In a prompt-driven system, there's no equivalent mechanism. A reference to "the academic query template in the playbook" will attempt to follow whatever the playbook now says — but if the playbook structure changed significantly, the skill may misread it.

**Prevention:**
- Define a stable interface contract for playbooks in the discover skill: "The playbook must contain the following sections in this order: [section names]." The skill reads those specific sections; the playbook author knows not to rename them.
- Keep the skill's reference to playbooks structural, not behavioral: the skill reads "Channel Priority" and "Query Templates" sections. It does not rely on behavioral instructions in the playbook that might drift.
- When updating a playbook, review the discover skill's expectations to confirm the playbook still satisfies them.

**Detection:** Discovery runs producing unexpected channel ordering or query formats that don't match the intended playbook design.

**Phase to address:** When designing the playbook schema. Define and document the stable interface contract before writing the first playbook.

---

### Pitfall 10: Model Judgment Substituting for Missing Instructions

**What goes wrong:** The discover skill's instructions have a gap — they don't specify what to do when a research type doesn't have a matching playbook, or when a channel returns an ambiguous result. The model fills the gap with judgment. Sometimes that judgment is good. Sometimes it invents a channel that doesn't exist, prioritizes sources in an unexpected order, or decides a result is "not relevant" using criteria the skill never specified. In a prompt-driven system, gaps in instructions are filled by model heuristics, not by fallthrough logic.

**Why it happens:** In code, a gap in logic produces a null pointer exception or a branch that's never reached. In a prompt-driven skill, the model always produces *something* — it never simply "fails to execute." This means instruction gaps produce plausible-looking but wrong behavior rather than explicit errors.

**Prevention:**
- Write explicit handling for every edge case that can be anticipated: no playbook found, channel returns empty results, channel returns an error, results look irrelevant. For each case, specify exactly what to do ("report CHANNEL ERROR" vs. "skip and continue").
- End the discover skill's instructions with a "When in doubt" clause: "If the instructions don't clearly cover a situation, surface the ambiguity to the user rather than resolving it silently."
- During skill review, look for unstated assumptions: anywhere the skill says "find relevant sources" or "prioritize the best results" without specifying what relevant or best means for this context.

**Detection:** Discovery results that seem reasonable but don't match what the skill should have done according to the playbook. Requires comparing output against intent, which is why clear playbooks are essential.

**Phase to address:** Final skill review pass before shipping, focused specifically on finding and closing instruction gaps.

---

### Pitfall 11: Context Window Bloat from Discovery Results

**What goes wrong:** The discover skill returns detailed results from 4-5 channels, each with metadata fields (title, authors, abstract snippet, DOI, open access status, citation count, publication date). For a discovery run that surfaces 30-40 candidate sources across channels, this output can consume significant context. The researcher then runs process-source for each selected source in the same context window. By the time 3-4 sources are processed, context is saturated with discovery output that's no longer needed, leaving less room for the source notes that matter.

**Why it happens:** The existing system already manages this with a "clear context between phases" recommendation. Discovery adds a new context-heavy step at the start of each collect phase, which accelerates context saturation.

**Prevention:**
- Keep discovery output compact. The skill should produce a numbered list with just enough information to make a triage decision: title, source type, access status, one-sentence relevance note. No full abstracts, no long metadata.
- Explicitly recommend a context clear between the discovery run and the process-source session: "After selecting sources from the discovery results, clear context and begin processing. The discovery output does not need to be in context during source processing."
- Add this recommendation to the discover skill's output section: always end with "Clear context before starting process-source. Your selected source URLs are the only thing you need to carry forward."

**Detection:**
- Context saturation warnings appearing earlier in the collect phase than in pre-discovery sessions.
- User running multiple process-source calls in the same context window as a discovery run and experiencing context-related truncation.

**Phase to address:** When writing the discover skill's output format specification.

---

## Phase-Specific Warnings

| Implementation Phase | Likely Pitfall | Mitigation |
|---------------------|---------------|------------|
| Architecture design | Phantom command placement (Pitfall 8) | Decide playbook location before writing any files |
| Playbook schema design | Instructions drift contract (Pitfall 9) | Define stable section names as an interface contract |
| Channel selection decisions | Over-engineering integrations (Pitfall 5) | Apply the "3+ research types benefit" test before building |
| First discover skill draft | Scope creep into processing logic (Pitfall 4) | One-sentence job definition as a design constraint |
| Writing channel instructions | API fragility / silent failure (Pitfall 3) | Channel status reporting is mandatory, not optional |
| Academic channel integration | Channel noise (Pitfall 2) | Hard cap at 5-8 results per channel, built into playbook |
| Academic channel integration | Discovery-processing mismatch (Pitfall 1) | Source status taxonomy (DISCOVERED / ACCESSIBLE / PROCESSED) before surfacing to user |
| Initial deployment | Configuration burden (Pitfall 6) | Tavily-only path must work fully before adding channels |
| Skill positioning | Replacing Tavily search (Pitfall 7) | Narrow use-case description in CLAUDE.md skills table |
| Instruction review | Model filling gaps with judgment (Pitfall 10) | Explicit handling for every edge case, "when in doubt" clause |
| Context management | Context window bloat (Pitfall 11) | Compact output format + context-clear recommendation in skill output |

---

## Sources and Confidence

**HIGH confidence** (derived from direct analysis of this codebase's documented architecture, constraints, and existing patterns):
- Pitfall 1 (Discovery-Processing Mismatch) — The process-source skill explicitly forbids working from snippets; discovery-to-processing bridging is a documented design requirement.
- Pitfall 4 (Scope Creep) — The project's design philosophy and existing skill structure make the thin-orchestrator / thick-playbook architecture the clear right answer.
- Pitfall 6 (Configuration Burden) — The "no paid APIs, graceful degradation" constraint is explicitly documented in PROJECT.md.
- Pitfall 8 (Phantom Commands) — This specific constraint is explicitly documented in PROJECT.md as a known gotcha from v1.0.
- Pitfall 9 (Instructions Drift) — Specific to prompt-driven architecture with no contract enforcement mechanisms.
- Pitfall 10 (Model Judgment Substituting for Instructions) — Specific to prompt-driven architecture.
- Pitfall 11 (Context Window Bloat) — Derivable from existing context management design in the init skill.

**MEDIUM confidence** (derived from training knowledge about API behavior; official docs not consulted during this session due to tool restrictions):
- Pitfall 2 (Channel Noise) — Academic API return volumes are well-documented in training data but specific current limits and default result counts may have changed.
- Pitfall 3 (API Fragility) — Rate limit patterns are consistent across training data but specific current tiers (OpenAlex, Semantic Scholar) should be verified against current official documentation before the implementation phase.
- Pitfall 5 (Over-Engineering) — ROI analysis is judgment-based; validation would require testing against actual research use cases.
- Pitfall 7 (Replacing Tavily Search) — Behavioral prediction about user routing; validate with actual user testing.
