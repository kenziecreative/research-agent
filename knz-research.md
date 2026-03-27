---
description: Scaffold a structured research project with state management, evidence standards, and agent-driven workflows
---

# /knz-research — Initialize a Structured Research Project

You are scaffolding a new research project. This command creates the full research infrastructure: directory structure, CLAUDE.md, STATE.md, reference protocols, source registry, gap tracker, cross-reference file, and a research plan tailored to the project's topic and type.

## Step 1: Gather Project Information

Ask the user three questions. Ask them **one at a time** — don't stack them.

**Question 1 — Research Type:**

Ask the user which type of research they want to conduct:

- **PRD Validation** — Pressure-test a Product Requirements Document against external evidence before engineering begins. Tests assumptions, technical choices, timeline estimates, market claims.
- **Exploratory Thesis** — Build the evidence base for a thesis, concept, or vision. Validate core claims, map the landscape, identify opportunities and risks.
- **Competitive Analysis** — Map a competitive landscape for a product, market, or space. Identify players, compare features, find white space, assess positioning.
- **Company Research (For-Profit)** — Deep research on a specific for-profit company. Financials, products, market position, leadership, technology, risks.
- **Company Research (Non-Profit)** — Deep research on a specific non-profit organization. Mission, programs, impact, financials (990s), funding, governance, effectiveness.
- **Person Research** — Deep research on a specific individual. Career trajectory, expertise validation, published work, public positions, reputation, network, and red flags. Works best for public figures or professionals with a meaningful public footprint.
- **Market/Industry Research** — Map the current state of a market, technology, or trend. Adoption patterns, key players, growth data, barriers, accelerators, and where things are heading. Use this when you want to understand a landscape, not validate a specific claim.
- **Presentation Research** — Build the evidence base and through line for a presentation. Start with your existing points and topic, research to validate claims, find supporting data, identify counterpoints, and discover the narrative thread that connects everything. Produces a presentation brief, not a report.
- **Curriculum Research** — Research a subject domain to build a curriculum from scratch. Verify subject matter accuracy, map practitioner reality, identify common misconceptions, assess field currency, and produce a subject matter foundation that feeds into curriculum design.

**Question 2 — Topic:**

Ask: "What's the topic, company, or document you're researching? Provide as much context as you have — a description, a URL, a document path, or paste the content directly."

**Question 3 — Project Directory:**

Ask: "Where should this project live? Provide the full directory path."

Wait for all three answers before proceeding.

## Step 2: Create Directory Structure

Create the following directories at the target path:

```
<project-root>/
├── .claude/
│   ├── commands/
│   └── agents/
├── research/
│   ├── sources/
│   ├── notes/
│   ├── drafts/
│   ├── outputs/
│   ├── audits/
│   └── reference/
└── source-material/
```

## Step 3: Generate the Research Plan

Launch an agent (use `subagent_type: "general-purpose"`, model: `sonnet`) to generate the research plan. Provide the agent with:
- The research type
- The topic description / source material the user provided
- The type-specific template (copied below in the Templates section) so the agent knows the finding tags, validation standards, and phase structure patterns

Give the agent these instructions:

---

### Plan Generator Instructions

You generate research plans for structured AI-assisted research projects. Your output is the content for a `research-plan.md` file that defines the entire research arc for a project.

**Your job:** Generate a complete research plan with:

1. **A Core Question** — One paragraph framing what this research needs to answer
2. **Source Material Location** — Where to find the document/topic being researched
3. **Research Phases** — Each with:
   - A clear name
   - What the source material assumes (or what needs to be understood)
   - 4-7 specific validation/research questions
   - The output filename
4. **A Synthesis Phase** — Final phase pulling everything together
5. **Source Priority** — What kinds of sources are most valuable and what to be skeptical of
6. **Success Criteria** — When the research is done

**Phase Generation Rules:**

- **PRD Validation (8-10 phases):** Derive phases from the major assumption clusters in the PRD. Each phase tests a distinct category (technical architecture, market claims, user behavior, competitive position, cost projections, timeline feasibility). End with synthesis producing executive summary, full validation report, and recommended changes.
- **Exploratory Thesis (8-12 phases):** Start with theoretical foundations, then evidence for/against core claims, then landscape mapping, then practical questions (audience, market, feasibility). Each phase answers "what does the evidence actually say about [claim]?"
- **Competitive Analysis (6-8 phases):** Market definition → player identification → feature comparison → positioning → pricing/business models → trends → white space → synthesis with strategic recommendations.
- **Company For-Profit (8-10 phases):** Overview/history → leadership → products/technology → financials → market position → customers/traction → partnerships → culture/talent → risks → synthesis with SWOT analysis.
- **Company Non-Profit (8-10 phases):** Mission/theory of change → leadership/governance → programs → impact measurement → financials (990 analysis) → funding landscape → partnerships → organizational capacity → risks → synthesis with effectiveness assessment.
- **Person Research (6-10 phases):** Career arc → expertise validation → track record deep dive → public positions/thought leadership → reputation/peer perception → network/affiliations → financial/legal footprint (if applicable) → red flags/risk assessment → synthesis with comprehensive profile and credibility assessment. Adapt phase count to the person's public footprint — collapse phases where sources won't exist, deepen phases where material is rich.
- **Market/Industry Research (8-12 phases):** Market definition and scope → current state and maturity assessment → adoption data and growth patterns → key players and ecosystem mapping → technology/capability landscape → barriers and accelerators → segment or regional variations → emerging trends and inflection points → future direction and projections → synthesis with landscape report and strategic implications. Adapt phases to the topic — a mature market needs more segmentation analysis; an emerging technology needs more feasibility and adoption barrier analysis.
- **Presentation Research (5-8 phases):** Nugget inventory and claim mapping → audience and context research → evidence gathering and claim validation (one phase per major claim cluster) → counterpoint and objection research → through line discovery and narrative gap analysis → synthesis with presentation brief, narrative arc, evidence map, and talking points. The plan generator should examine the user's existing points and organize phases around the major claim clusters that need evidence, not around a generic research structure.
- **Curriculum Research (6-10 phases):** Domain landscape → practitioner reality → skill decomposition → common misconceptions and failure patterns → current best practice → field trajectory → competing approaches → existing program landscape → synthesis with subject matter foundation, practitioner workflow map, skill decomposition, misconception inventory, field currency assessment, and curriculum scope recommendation. Adapt phase count to the topic — collapse early phases when the designer has substantial existing knowledge, deepen misconception and practitioner reality phases in those cases. For entirely new domains, keep the full structure.

**Output format:**

```markdown
# Research Plan: [Project Title]

## The Core Question

[One paragraph framing what this research needs to answer]

## Source Material Location

[Where to find the primary document/subject]

---

## Phase 1: [Phase Name]

**What [the PRD assumes / the thesis claims / needs to be understood]:** [Description]

**What needs [validation / exploration / analysis]:**

1. [Specific question]
2. [Specific question]
...

**Output:** `[##-phase-slug].md`

**Phase cycle:** Complete all steps before proceeding to Phase 2: Collect sources → /cross-ref → /check-gaps → /summarize-section → /audit-claims. Do not start Phase 2 until this phase's audit passes.

---

[Repeat for each phase — every phase must include the "Phase cycle" reminder with the next phase number]

---

## Phase N: Synthesis

**Goal:** [What the synthesis produces]

**Outputs:**
- `00-executive-summary.md`
- `[final-report].md`
- `[recommendations].md`

---

## Source Priority

**Highest value sources:**
- [Source type and why]

**Be skeptical of:**
- [Source type and why]

## Success Criteria

This research is done when:
1. [Criterion]
...
```

**Subject Identity Rules — Non-Negotiable:**

These rules exist because agents can confabulate a subject when the provided description is ambiguous. If you get the subject wrong, every subsequent phase, source, and output will be wrong. There is no recovery from this error downstream.

- **Use only what the user explicitly provided.** The subject of this research is exactly what the user described — no more. Do not infer, assume, or substitute a subject based on partial matches, similar names, or what "seems most likely."
- **If the topic is ambiguous, stop and ask — do not guess.** If the user says "research the Stripe plugin" but there are multiple Stripe plugins or it's unclear which one, ask for clarification before proceeding. Do not resolve the ambiguity yourself. A wrong guess wastes the entire research effort.
- **If a URL or document was provided, that is the subject.** Do not pivot to a different URL, repository, or document you find during preliminary research, even if it seems more authoritative, more recent, or "closer" to what you think the user wants.
- **Do not expand the subject scope based on preliminary research.** If the user provided a narrow topic, keep it narrow. Preliminary research is to understand the topic, not to redefine it.
- **State the subject explicitly at the top of the research plan.** Before the Core Question, write: "**Research Subject:** [exact subject as provided by the user]". This makes the grounding visible and auditable.

**Quality Standards:**
- Every question must be specific enough that a researcher knows what to search for
- Questions must be answerable with publicly available sources (flag any that require internal access)
- Phase names must be descriptive and scannable
- Output filenames follow the pattern: `##-slug.md`
- Synthesis phase always produces at minimum an executive summary and a full report
- Be specific in "be skeptical of" — name source types that tend to mislead for this topic

You have access to WebSearch and WebFetch — use them to understand the topic before generating the plan. Do preliminary research so the phases and questions are grounded, not generic. **Preliminary research is for context only — it does not change the subject you were given.**

Write the final research plan to `<project-root>/research/research-plan.md`.

---

Wait for the agent to complete before proceeding.

## Step 4: Assemble and Write Files

### CLAUDE.md

Assemble a slim CLAUDE.md by combining:

1. **Project Purpose** — Generated from the research type and topic. One paragraph describing what this research project does and why.

2. **Directory Structure:**

```
research/
├── research-plan.md          # Master research prompt (the assignment)
├── STATE.md                  # Persistent research state
├── sources/
│   └── registry.md           # Index of all processed sources
├── notes/                    # Structured notes per source
├── drafts/                   # Unaudited synthesis (written by /summarize-section)
├── outputs/                  # Audited, final sections (promoted by /audit-claims only)
├── audits/                   # Claim audit reports
├── reference/                # Protocol and standards reference files
│   └── canonical-figures.json # Single source of truth for cross-phase numbers
├── cross-reference.md        # Cross-source patterns
└── gaps.md                   # Coverage tracker
```

Do not create files outside this structure for research artifacts. Working files go in `research/`. Synthesized sections go to `research/drafts/` first. Only `/audit-claims` promotes a draft to `research/outputs/`. Nothing in `outputs/` should exist without a corresponding audit report in `audits/`.

**Project boundary rule:** All file writes during a research session must stay within the current research project directory. Do not write to other projects, system directories, or external paths — even when responding to a user request that could be handled by a skill designed for a different context (e.g., a note-capture skill pointed at another project). If the user wants to capture a note or action item, write it to `research/notes-to-self.md` within this project. Never invoke a skill that writes outside the current project directory.

3. **Agents:**

| Agent | Trigger | Job | Speed |
|-------|---------|-----|-------|
| `source-processor` | `/process-source <url-or-file>` | Processes raw source into structured note | Medium (sonnet) |
| `cross-referencer` | `/cross-ref` | Finds patterns across all processed notes | Medium (sonnet) |
| `claim-auditor` | `/audit-claims <filepath>` | Fact-checks a draft against source notes | Medium (sonnet) |
| `gap-tracker` | `/check-gaps` | Maps research coverage, identifies holes | Fast (haiku) |
| `research-summarizer` | `/summarize-section <name>`, `/summarize-all` | Synthesizes notes into polished draft sections | Medium (sonnet) |
| `research-integrity` | After writing any source note, draft, or synthesis | Watches for fabricated data, range narrowing, qualifier stripping, cross-phase drift, unsourced claims | Medium (sonnet) |

4. **Workflow:**

**Research is phase-sequential.** You work one phase at a time, in order. Each phase completes its full cycle before the next phase begins. Do not collect sources for Phase 3 while working on Phase 1. Do not batch source collection across multiple phases. Do not invent phase groupings or reorder phases.

The cycle for each phase:

1. **Collect** — Use `/process-source` for each URL, PDF, or document relevant to the *current phase only*.
2. **Connect** — Run `/cross-ref` after every 5-8 new sources to find patterns. This is mandatory, not optional.
3. **Assess** — Run `/check-gaps` to confirm coverage for this phase. Fill gaps with more sources if needed.
4. **Synthesize** — Use `/summarize-section` to produce a draft in `research/drafts/`. This is NOT a final output.
5. **Verify** — Run `/audit-claims` on the draft. This is what promotes it from `drafts/` to `outputs/`. No exceptions.
6. **Transition** — Update STATE.md, mark the phase complete, recommend context clear, and only then begin the next phase.

Read the research plan in `research/research-plan.md` before starting. It defines the phases and their order.

**Enforcement rules — these are structural, not guidelines:**

- **Phases are sequential.** Complete Phase N's full cycle (collect → connect → assess → synthesize → verify) before starting Phase N+1. Do not collect sources for future phases. Do not batch work across phases. Do not group or reorder phases. The research plan defines the order — follow it.
- **Nothing reaches `research/outputs/` without passing `/audit-claims`.** `/summarize-section` writes to `research/drafts/`. `/audit-claims` checks the draft against source notes and, if it passes, moves it to `research/outputs/`. If it fails, the draft stays in `drafts/` with an audit report listing what needs fixing.
- **`/cross-ref` is mandatory after every 5-8 new sources.** Before processing a 9th source without a cross-reference, stop and run `/cross-ref` first. `research/cross-reference.md` must reflect current patterns at all times.
- **`/check-gaps` is mandatory before starting a new phase.** Do not begin Phase N+1 until `/check-gaps` has confirmed coverage status for Phase N. If gaps remain, fill them or document them explicitly in `research/gaps.md` with a reason they're acceptable.
- **Phase completion requires all five steps.** A phase is not complete until: sources collected for this phase, cross-reference is current, gaps are assessed, draft is written, and audit has passed. STATE.md should not mark a phase complete until all five are done.
- **Canonical figures registry is the source of truth for cross-phase numbers.** When citing a number from a previous phase, check `research/reference/canonical-figures.json` first. If registered, use the canonical value. If not registered and this is a cross-phase citation, register it before using it. Never copy numbers from STATE.md summaries or conversation memory.
- **Never skip, fold, reorder, or merge phases without explicit user approval.** If `/check-gaps` reveals a phase has insufficient source coverage, tell the user and present options: (1) collect more sources to fill the gaps, (2) skip the phase with the user's explicit approval, or (3) fold the phase's questions into another phase with the user's explicit approval. Do not make this decision yourself. Do not record a phase-skip in STATE.md without the user confirming it on screen first.

**Clear context between phases.** Each phase should start with a fresh context window. STATE.md and your research files carry everything forward — nothing critical lives in conversation history. A fresh context for each phase produces sharper analysis than a saturated one. Before clearing, ensure STATE.md is fully up to date with current position, completed work, and next action. After clearing, read STATE.md first before resuming work.

**At the end of every phase, remind the user:** "Phase [N] is complete and STATE.md is updated. I'd recommend clearing context before starting Phase [N+1] — you'll get sharper results with a fresh window, and nothing is lost because STATE.md has everything."

5. **[Type] Standards** — Include from the matching type template below:
   - The "What to Validate/Explore/Analyze" section
   - The "Finding Tags" section

6. **State Management:**

Research state lives in `research/STATE.md`. It is the source of truth for project position — not memory, not conversation history, not file timestamps.

On every new session or after context clear: Read `research/STATE.md` first. Don't start working until you know where you are. The "Current Phase Cycle" section tells you exactly which step you're on — pick up there. **If STATE.md records any skipped, folded, or deferred phases, report this to the user before resuming work.** The user may not have been present when that decision was made — surface it explicitly so they can confirm or reverse it.

During work: Update state at every transition — phase start/end, meaningful task completion, user decisions. Check off cycle steps as they complete. Write state BEFORE doing anything expensive in case of compaction. A PreCompact hook will warn you if STATE.md is stale, but don't rely on it — update proactively.

The "Active phase" field in STATE.md tells you which phase to work on. Do not work on any other phase. When the current phase's cycle checklist is fully checked, mark it complete, generate the next phase's cycle checklist, and update "Active phase."

7. **Context Management:**

This is a long-running project. Clear context between research phases — each phase gets a fresh window for sharper analysis. STATE.md is the source of truth that carries everything forward. Before clearing context, always update STATE.md with current position, completed work, key decisions, and next action. After clearing or starting a new session: read `research/STATE.md` first. If unsure what's been done, run `/check-gaps` before starting new work.

8. **Boundaries** — From the type-specific template.

9. **Reference Protocols:**

Detailed protocols are in `research/reference/`. Read the relevant file when you need the full protocol:

| Protocol | File | Read When |
|----------|------|-----------|
| Source & Evidence Standards | `research/reference/source-standards.md` | Processing sources, citing evidence, assessing credibility |
| Writing & File Standards | `research/reference/writing-standards.md` | Writing output sections, naming files |
| Tools Guide (Tavily) | `research/reference/tools-guide.md` | Using Tavily search, extract, map, or crawl |

Write the assembled CLAUDE.md to `<project-root>/CLAUDE.md`.

### Reference Files

Write the following to `<project-root>/research/reference/`:

**`source-standards.md`:**

```markdown
# Source & Evidence Standards

Reference standards for processing sources, citing evidence, and assessing credibility.

## Evidence Rules

- Every factual claim must trace to a file in `research/notes/`.
- Use confidence language: "confirmed by multiple sources" vs. "single source suggests" vs. "inferred from available data."
- When sources contradict each other, present both. Do not silently pick a winner.
- When a single source contains contradictory figures for the same metric, flag both in the note and resolve which is more reliable before carrying either into an output. Do not silently pick one.
- Date-stamp all data points. Information goes stale — flag anything older than 2 years as potentially outdated.
- Do not interpolate or fabricate midpoints between two data ranges to create a new estimate. If Source A says 5% and Source B says 25%, the answer is not "15%" unless a third source independently reports that figure. Present the range with both endpoints cited.

## Cross-Phase Citation Rules

- When citing a finding from a previous phase, reference the phase output file directly — do not rely on STATE.md summaries for specific numbers. STATE.md carries position and context; phase outputs carry evidence.
- When a number is carried forward from a previous phase, cite the specific phase output.
- When a number appears for the first time in a phase output, it must trace to a source note.
- When referencing a specific number from a previous phase, check `research/reference/canonical-figures.json` first. If the number is registered there, use the canonical value. If it's not registered and this is a cross-phase citation, register it before using it with: `id` (short slug), `value` (exact number or range), `unit`, `qualifier` (domain/context from source), `source_phase`, `source_file`, `confidence` (triangulation level), `registered_when` (which phase first cited it cross-phase), `referenced_by` (array of referencing documents). Never copy numbers from STATE.md summaries or conversation memory — always verify against the canonical file or original phase output.

## Citation Format

- Inline: `[Source: <note-filename>]`
- All sources must appear in `research/sources/registry.md`.

## Source Credibility Hierarchy

[INSERT THE SOURCE CREDIBILITY HIERARCHY FROM THE MATCHING TYPE TEMPLATE]

## Source Processing Rule

Every URL that informs a finding must be processed as a source first.

The workflow is: search finds it → extract full content → structure it into a research note → reference the note in outputs. No shortcuts. Don't cite search snippets directly in outputs — they're discovery tools, not sources.
```

**`writing-standards.md`:**

```markdown
# Writing & File Standards

Reference standards for writing research outputs and naming files.

## Writing Standards

- Lead with the finding, support with evidence. Not the reverse.
- Every finding must answer "so what does this mean for the project?"
- Be specific: not vague hedging, but "The [document/thesis/company] assumes X, but evidence shows Y."
- No orphan claims. If you can't cite it, flag it as inference or cut it.
- Use prose paragraphs in outputs. Reserve bullet lists for data tables and key findings sections only.
- Use people's names, not titles. "Carolyn" not "the CEO." "Elizabeth" not "the co-founder." Establish the name-title mapping once in the first phase output, then use names throughout.

## Precision Preservation

- When summarizing a range from source notes, preserve the full range. Do not midpoint. Do not drop the unfavorable end. If a range is too wide to be useful, say so — do not narrow it silently.
- Qualifiers present in phase outputs must be carried into downstream documents. If compression requires dropping a qualifier, note the simplification explicitly.
- Editorial judgments (e.g., "X is right about Y") must be explicitly supported by findings, not inferred from the overall direction of the research.

## Source Triangulation

For each major finding in an output, note how many independent sources support it:
- **1 source** — Flag as preliminary. Use language: "single source suggests."
- **2 sources** — Moderate confidence. Use language: "supported by limited evidence."
- **3+ sources** — Converged. Use language: "confirmed by multiple sources."

This makes evidence strength visible at a glance and prevents single-source findings from being presented with unearned confidence.

## Synthesis-Specific Rules

These apply when writing synthesis documents that pull from multiple phase outputs:
- Every specific number in a synthesis must appear in the phase output it cites, with the same value. Do not round, adjust, or "improve" numbers during synthesis.
- Ranges must be preserved from source. Do not narrow, midpoint, or round favorably.
- When citing a finding from a previous phase, reference the phase output file directly — do not rely on STATE.md summaries for specific numbers.
- When a number is carried forward from a previous phase, cite the specific phase output.
- When math is performed in the synthesis (e.g., calculating a remainder), show the work and cite the inputs.
- If multiple synthesis documents reference the same underlying finding, they must use the same figure. Cross-check before finalizing.

## File Naming

- Source notes: `research/notes/<slugified-source-title>.md`
- Draft sections: `research/drafts/<part-number>-<section-slug>.md`
- Audited outputs: `research/outputs/<part-number>-<section-slug>.md`
- Audit reports: `research/audits/<original-filename>-audit.md`

Slugs are lowercase, hyphens instead of spaces, no special characters. Keep them short but identifiable.
```

**`tools-guide.md`:**

```markdown
# Tools Guide — Tavily MCP

Reference guide for using Tavily tools in the research workflow.

## Tool Reference

| Tool | Use For | Don't Use For |
|------|---------|---------------|
| `tavily_search` | Finding sources, data, comparisons, documentation | Getting full content from a known URL |
| `tavily_extract` | Pulling full content from a specific URL you already have | Discovery — use search first |
| `tavily_map` | Understanding a site's structure before crawling or extracting | General research questions |
| `tavily_crawl` | Systematically exploring a domain | Quick lookups — too slow |

## Search Patterns

Use `search_depth: "advanced"` for technical research, academic sources, and anything that needs more than surface results. Use `search_depth: "basic"` for quick fact checks and known-item lookups.

## Crawl Discipline

Crawling is powerful but slow. Use it deliberately. Map first, then crawl specific sections. Do not crawl entire domains without purpose.
```

### STATE.md

Use this template, customized with data from the generated research plan:

```markdown
# Research State

**Phases are sequential. Complete the current phase's full cycle before starting the next. Do not batch work across phases.**

## Current Position
- Active phase: 1 — [Phase 1 Name]
- Cycle step: Collect (1 of 5)
- Blocking on: Nothing — ready to start.

## Current Phase Cycle

Each phase must complete all five steps in order. Check off each step as it is completed. Do not skip steps. Do not mark a phase complete until all five are checked.

### Phase 1: [Name]
- [ ] **Collect** — Sources gathered for this phase's questions
- [ ] **Connect** — `/cross-ref` run, cross-reference.md current
- [ ] **Assess** — `/check-gaps` run, coverage confirmed for this phase
- [ ] **Synthesize** — `/summarize-section` run, draft in `drafts/`, integrity checked
- [ ] **Verify** — `/audit-claims` passed, output promoted to `outputs/`

When all five are checked, mark this phase complete below, update "Active phase" to the next phase, and generate a new cycle checklist for that phase.

## Completed Phases
[Generate a checklist from the research plan phases, e.g.:]
- [ ] Phase 1: [Name]
- [ ] Phase 2: [Name]
...
- [ ] Phase N: Synthesis

## Key Decisions
- Project initialized [TODAY'S DATE]
- Research type: [TYPE]
- Research plan structured around [N] phases
- Finding tags: [TAGS FROM TYPE TEMPLATE]
- Canonical figures registry active at `research/reference/canonical-figures.json`

## Sources Processed
- Total count: 0
- Sources for current phase: 0
- Sources since last cross-reference: 0
- Last cross-reference: N/A
- Last gap check: N/A

**Cross-ref is due when "Sources since last cross-reference" reaches 5.** Do not process a 6th source without running `/cross-ref` first. `/cross-ref` resets this counter to 0.

## Next Action
Begin Phase 1: Collect sources relevant to Phase 1 questions only.
```

Write to `<project-root>/research/STATE.md`.

### Other Files

- Write `research/sources/registry.md`:

```markdown
# Source Registry

All processed sources indexed here. Each entry includes the source, type, credibility assessment, date accessed, and corresponding note file.

| # | Source | Type | Credibility | Date Accessed | Note File |
|---|--------|------|-------------|---------------|-----------|
| | | | | | |
```

- Write `research/gaps.md` — use phase names from the generated research plan:

```markdown
# Research Coverage Gaps

Tracks what's been covered and what's still missing across all research phases.

[Generate a section for each phase, e.g.:]

## Phase 1: [Name]
- Coverage: Not started
- Gaps: All questions open

## Phase 2: [Name]
- Coverage: Not started
- Gaps: All questions open

[...etc for all phases]
```

- Write `research/cross-reference.md`:

```markdown
# Cross-Reference Analysis

Patterns and connections found across processed source notes. Updated after every 5-8 new sources.

---

*No sources processed yet.*
```

- Write `research/reference/canonical-figures.json`:

```json
{
  "figures": []
}
```

### Research Integrity Agent

Create `<project-root>/.claude/agents/research-integrity.md`:

```markdown
---
name: research-integrity
description: Watches research output for integrity issues — fabricated data, range narrowing, qualifier stripping, cross-phase drift, and internal inconsistencies. Invoke after writing any phase output, source note, or synthesis draft.
model: sonnet
tools:
  - Read
  - Write
  - Grep
  - Glob
---

# Research Integrity Agent

You are a seasoned research methodologist reviewing work for integrity issues. You do not do the research — you watch the research being done and flag problems before they propagate.

You are not here to be helpful or encouraging. You are here to be precise. If something is wrong, say so directly. If something is fine, say nothing about it. Your silence is approval.

## What You Check

When given a file to review (a source note, a draft, or a synthesis document), perform all applicable checks:

### 1. Fabricated Data
- Every specific number, percentage, or statistic in the file must trace to a source note in `research/notes/`.
- If a number appears that doesn't exist in any source note, flag it: "NUMBER NOT IN SOURCES: [the number] on line [N] does not appear in any source note."
- If a number appears to be interpolated from two other numbers (e.g., Source A says 5%, Source B says 25%, and the file says 15%), flag it: "POSSIBLE INTERPOLATION: [the number] on line [N] may be a midpoint of [source values]. No source independently reports this figure."

### 2. Range Narrowing
- Compare every range in the file against its source. If the source says "1-3x" and the file says "2-3x", that's range narrowing.
- Flag: "RANGE NARROWED: Line [N] says [narrowed range], but [source note] says [original range]. The unfavorable end was dropped."

### 3. Qualifier Stripping
- Compare qualifiers in the file against their source. If the source says "in customer service domains" and the file says "in constrained domains", the specificity was stripped.
- Flag: "QUALIFIER STRIPPED: Line [N] says [generalized version], but [source note] says [specific version]. The original qualifier was more precise."

### 4. Internal Inconsistency
- Check whether the same metric appears more than once in the file with different values.
- Flag: "INTERNAL INCONSISTENCY: [metric] appears as [value A] on line [N] and [value B] on line [M]."

### 5. Cross-Phase Drift
- If the file references findings from previous phases, read those phase outputs and compare. Every carried-forward number must match exactly.
- Read `research/reference/canonical-figures.json`. If the number is already registered, verify it matches the canonical value. If it doesn't match, flag it.
- If the number is not yet registered and this is a cross-phase citation, register it in `canonical-figures.json` with all required fields (id, value, unit, qualifier, source_phase, source_file, confidence, registered_when, referenced_by).
- Flag: "CROSS-PHASE DRIFT: Line [N] says [value], but canonical-figures.json (or [phase output file]) says [different value] for the same finding."

### 6. Unsourced Claims
- Every factual claim (not opinion or analysis) must have an inline citation `[Source: <filename>]`.
- Flag: "UNSOURCED CLAIM: Line [N] makes a factual assertion with no source citation."

### 7. Confidence Inflation
- A finding backed by one source should use "single source suggests" language. A finding backed by 3+ should use "confirmed by multiple sources." Check for mismatches.
- Flag: "CONFIDENCE INFLATED: Line [N] uses [strong language] but the finding traces to only [N] source(s)."

## How to Use This Agent

Invoke this agent after:
- Writing a source note (check for internal inconsistencies)
- Writing a draft via `/summarize-section` (check everything before running `/audit-claims`)
- Writing a synthesis document (check everything, especially cross-phase drift)
- Any time something feels like it might have drifted

Pass the filepath to review. The agent will read the file, read the relevant source notes, and report only issues found. If no issues are found, it will say: "No integrity issues found in [filename]."

## Output Format

Report only issues. Group by check type. For each issue, include:
- Check type (e.g., RANGE NARROWED)
- File and line number
- What the file says
- What the source says
- What needs to change

If zero issues: "No integrity issues found in [filename]."
```

### Research Workflow Hooks

Create `<project-root>/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "FILE_PATH=$(echo \"$TOOL_INPUT\" | jq -r '.file_path // empty'); if [ -z \"$FILE_PATH\" ]; then echo '{\"ok\": true}'; exit 0; fi; if echo \"$FILE_PATH\" | grep -q 'research/outputs/'; then BASENAME=$(basename \"$FILE_PATH\"); AUDIT_FILE=\"research/audits/${BASENAME%.md}-audit.md\"; DRAFT_FILE=\"research/drafts/$BASENAME\"; if [ ! -f \"$DRAFT_FILE\" ]; then echo \"{\\\"ok\\\": false, \\\"reason\\\": \\\"BLOCKED: No draft exists at $DRAFT_FILE. Outputs must go through /summarize-section first, then /audit-claims. You cannot write directly to outputs/.\\\"}\"; elif [ ! -f \"$AUDIT_FILE\" ]; then echo \"{\\\"ok\\\": false, \\\"reason\\\": \\\"BLOCKED: No audit report found at $AUDIT_FILE. Run /audit-claims on the draft before promoting to outputs/.\\\"}\"; else echo '{\"ok\": true}'; fi; else echo '{\"ok\": true}'; fi",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "FILE_PATH=$(echo \"$TOOL_INPUT\" | jq -r '.file_path // empty'); if [ -z \"$FILE_PATH\" ]; then echo '{\"ok\": true}'; exit 0; fi; if echo \"$FILE_PATH\" | grep -q 'research/outputs/'; then BASENAME=$(basename \"$FILE_PATH\"); AUDIT_FILE=\"research/audits/${BASENAME%.md}-audit.md\"; if [ ! -f \"$AUDIT_FILE\" ]; then echo \"{\\\"ok\\\": false, \\\"reason\\\": \\\"BLOCKED: Cannot edit files in outputs/ without a passing audit report. Run /audit-claims first.\\\"}\"; else echo '{\"ok\": true}'; fi; else echo '{\"ok\": true}'; fi",
            "timeout": 5
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f research/STATE.md ]; then STATE_MOD=$(stat -f %m research/STATE.md 2>/dev/null || stat -c %Y research/STATE.md 2>/dev/null); NOW=$(date +%s); AGE=$(( NOW - STATE_MOD )); if [ $AGE -gt 300 ]; then echo '{\"ok\": false, \"reason\": \"WARNING: STATE.md has not been updated in over 5 minutes. Update STATE.md with current position, completed work, and next action BEFORE context compacts. State that is not written down will be lost.\"}'; else echo '{\"ok\": true}'; fi; else echo '{\"ok\": true}'; fi",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

These hooks enforce two rules that agents have been observed ignoring:

1. **Output gate (PreToolUse: Write/Edit)** — Nothing can be written to `research/outputs/` unless both a draft in `research/drafts/` and an audit report in `research/audits/` already exist. This makes it mechanically impossible to skip `/summarize-section` or `/audit-claims`.

2. **State preservation (PreCompact)** — Before context compacts, checks that STATE.md was updated recently. If it's stale, warns that state will be lost. This catches the case where an agent does work but doesn't persist its position before compaction wipes the context.

### Research Commands

Create the following project-level commands in `<project-root>/.claude/commands/`:

**`process-source.md`:**

```markdown
---
description: Process a URL, PDF, or document into a structured research note
---

# /process-source

Process a source into a structured research note.

## Input
The user will provide a URL, file path, or pasted content.

## Pre-check (mandatory)

1. **Read `research/STATE.md`** and check "Sources since last cross-reference."
2. **If the count is 5 or higher, stop.** Tell the user: "Cross-reference is overdue (N sources since last `/cross-ref`). Run `/cross-ref` before processing more sources." Do not proceed until cross-ref is run.

## Process

1. **Fetch the content.** For URLs, use Tavily extract (preferred) or WebFetch to get the full content. For files, read them directly. Do not work from search snippets.
2. **Read `research/reference/source-standards.md`** for credibility assessment criteria.
3. **Verify this source is about the research subject.** Before writing anything, confirm the fetched content is actually about the subject defined in `research/research-plan.md` (the "Research Subject" line at the top). If the content is about a similarly-named but different thing (different company, product, plugin, person, etc.), stop and tell the user: "This source appears to be about [what you found], not [the research subject]. Please confirm whether this is the correct source before I process it." Do not process a mismatched source.
4. **Determine the author.** Only use an author name that appears explicitly as a byline in the extracted content. Do not infer an author name from the site name, domain, URL slug, or any other source. If no byline is present in the extracted text, record the author as "Unknown — no byline in extracted content." A human would either already know whose site it is or look for an about page — never treat the site name as the author name.
5. **Create a structured note** at `research/notes/<slugified-source-title>.md` with:
   - Source title, URL/path, date accessed, source type
   - Author (verified byline only — see step 3)
   - Credibility assessment based on the project's source credibility hierarchy
   - Key findings — the important claims, data points, and arguments from this source
   - Relevance — which research plan phases this source informs
   - Finding tags applied to key claims (use the project's tag set from CLAUDE.md)
   - Direct quotes for important claims (with context)
   - Contradictions or tensions with previously processed sources (if any)
4. **Add the source to `research/sources/registry.md`** — new row with source number, name, type, credibility rating, date, and note filename.
5. **Update `research/STATE.md`** — increment both "Total count" and "Sources since last cross-reference."

## Output
Summarize the key findings for the user. Note which research phases this source is relevant to and any contradictions with existing sources. If "Sources since last cross-reference" is now 4 or 5, remind the user: "Cross-reference is due soon (N/5 sources). Run `/cross-ref` after the next source or two."
```

**`cross-ref.md`:**

```markdown
---
description: Find patterns and connections across all processed research notes
---

# /cross-ref

Analyze all processed source notes for cross-cutting patterns.

## Process

1. **Read all files in `research/notes/`.**
2. **Read `research/cross-reference.md`** for previously identified patterns.
3. **Identify patterns across sources:**
   - Claims confirmed by multiple sources (note which ones)
   - Claims where sources contradict each other (present both sides)
   - Emerging themes not visible in any single source
   - Gaps where multiple sources reference something but none provide evidence
4. **Update `research/cross-reference.md`** with new patterns found. Organize by theme, not by source. For each pattern, cite the source notes that contribute to it.
5. **Update `research/STATE.md`** — set last cross-reference date to today and reset "Sources since last cross-reference" to 0.

## Output
Summarize new patterns found since the last cross-reference. Highlight any contradictions that need resolution and any themes that are strengthening across sources.
```

**`check-gaps.md`:**

```markdown
---
description: Map research coverage and identify holes across all phases
---

# /check-gaps

Assess research coverage against the research plan and identify what's missing.

## Process

1. **Read `research/research-plan.md`** for the full list of phases and questions.
2. **Read all files in `research/notes/`** to understand what's been covered.
3. **Read `research/outputs/`** for any completed phase outputs.
4. **For each phase in the research plan:**
   - Which questions have been addressed by processed sources?
   - Which questions remain unanswered or underserved?
   - Are there questions that need more sources for triangulation?
5. **Update `research/gaps.md`** with current coverage status per phase. Be specific — name which questions are covered and which are open.
6. **Update `research/STATE.md`** — set last gap check date to today.

## Output
Summary table showing coverage status per phase (complete / partial / not started). List the highest-priority gaps — the unanswered questions that are most important to the research.
```

**`audit-claims.md`:**

```markdown
---
description: Fact-check a research draft against source notes and promote to outputs if it passes
---

# /audit-claims

Audit a research draft for unsupported claims. If the audit passes, promote the draft from `research/drafts/` to `research/outputs/`. If it fails, the draft stays in `drafts/` until issues are fixed and the audit is re-run.

## Input
The user will provide a filepath to audit (should be a file in `research/drafts/`).

## Process

1. **Read the file to audit.**
2. **Read `research/reference/source-standards.md`** for evidence rules.
3. **Read `research/reference/writing-standards.md`** for precision preservation and synthesis rules.
4. **For every factual claim in the document:**
   - Does it trace to a file in `research/notes/` or a previous phase output? If yes, note the source.
   - Is the claim accurately represented? Check against the source note — same numbers, same ranges, same qualifiers.
   - Is the confidence language appropriate given the number of supporting sources?
   - Are contradicting sources acknowledged?
   - Is dated information flagged if older than 2 years?
   - Are ranges preserved fully? (not narrowed, not midpointed)
   - Are qualifiers from the source preserved? (not dropped during compression)
   - If a number is carried from a previous phase, does it match the original exactly?
5. **Cross-document consistency check:** If other files already exist in `research/outputs/` or `research/drafts/`, check whether this draft and those documents cite the same numbers for the same claims. Flag any inconsistencies.
5a. **Canonical figures check:** Read `research/reference/canonical-figures.json`. For every number in the draft that exists in the canonical registry, verify it matches exactly. Flag any discrepancy as high-severity.
6. **Classify each issue found:**
   - **Unsupported claim** — No source note backs this up
   - **Misrepresented** — Source says something different than what's claimed
   - **Missing attribution** — Claim is supportable but citation is missing
   - **Stale data** — Information may be outdated
   - **Contradiction ignored** — Sources disagree but only one side is presented
   - **Range narrowed** — Source range was compressed or midpointed
   - **Qualifier dropped** — Source qualification was lost in compression
   - **Number drift** — Figure doesn't match the cited source
   - **Cross-document inconsistency** — Same claim, different figures across documents
7. **Generate audit scorecard:**
   - Total specific claims checked: N
   - Claims traced to source: N (X%)
   - Claims matching source value and context: N (X%)
   - Claims with appropriate qualifiers: N (X%)
   - Issues found: N mismatches, N unsourced, N drift, N range narrowed
   - Severity distribution: N high, N moderate, N low
8. **Write audit report to `research/audits/<original-filename>-audit.md`** with: scorecard, pass/fail determination, findings table, and list of claims that need correction.

## Pass/Fail Criteria

A draft passes when:
- Zero high-severity issues (unsupported claims, misrepresented data, number drift)
- Zero moderate-severity issues left unresolved (range narrowed, qualifier dropped, cross-document inconsistency)
- 100% of specific numerical claims trace to a source note or phase output with a matching value
- Low-severity issues (missing attribution, stale data) are acceptable if documented in the audit report

There is no percentage threshold. Every specific claim must check out. The scorecard is for visibility into the draft's quality, not for setting a "good enough" bar.

## After Audit

- **If PASS:** Move the file from `research/drafts/` to `research/outputs/`. Update `research/STATE.md` to reflect the output is finalized. Tell the user: "Audit passed. Promoted to `research/outputs/<filename>`."
- **If FAIL:** Leave the file in `research/drafts/`. List every issue with line-level specifics and what needs to change. The user or agent must fix the issues in the draft, then run `/audit-claims` again on the same file. Do not promote until it passes.

## Non-Negotiable Rules

- **No bypassing.** If the user asks to skip the audit or move a failed draft to outputs manually, refuse. Explain that the audit gate exists to protect research quality and that fixing the issues is faster than dealing with unreliable findings downstream.
- **No soft passes.** Do not downgrade a high-severity issue to moderate to make the draft pass. If a claim doesn't trace to a source, it's unsupported regardless of whether the claim "feels right."
- **Re-audit after fixes.** When a draft is fixed after a failed audit, run the full audit again — do not spot-check only the previously flagged issues. Fixes can introduce new problems.

## Output
Scorecard summary and pass/fail status. If failed, list every issue with its location and what needs to change. If passed, confirm the promotion to `outputs/`.
```

**`summarize-section.md`:**

```markdown
---
description: Synthesize processed source notes into a draft research output section
---

# /summarize-section

Synthesize research notes into a draft output section for a specific phase or topic. Drafts are written to `research/drafts/` — NOT `research/outputs/`. Only `/audit-claims` can promote a draft to `outputs/`.

## Input
The user will provide a section name or phase number to summarize.

## Pre-checks (mandatory)

Before writing anything, verify:
1. **`research/cross-reference.md`** has been updated within the last 5-8 sources. If it hasn't, stop and run `/cross-ref` first.
2. **`research/gaps.md`** has been updated for this phase. If it hasn't, stop and run `/check-gaps` first.

If either pre-check fails, do not proceed. Tell the user which check failed and what to run.

## Process

1. **Read `research/research-plan.md`** to understand what this phase/section covers and what questions it needs to answer.
2. **Read `research/reference/writing-standards.md`** for output formatting rules.
3. **Read `research/reference/source-standards.md`** for citation and evidence rules.
4. **Read all relevant files in `research/notes/`** that pertain to this section.
5. **Read `research/cross-reference.md`** for patterns relevant to this section.
6. **Read `research/gaps.md`** — if there are unresolved gaps for this phase, note them explicitly in the draft as open questions.
7. **Write a draft section** to `research/drafts/<part-number>-<section-slug>.md`:
   - Lead with findings, support with evidence
   - Every finding answers "so what does this mean?"
   - Apply the project's finding tags to key conclusions
   - Cite sources inline using `[Source: <note-filename>]`
   - Use prose paragraphs, not bullet lists (except for data tables and key findings)
   - Present contradictions when sources disagree
   - No orphan claims — if it can't be cited, flag it as inference
8. **Run the research-integrity agent** on the draft. Pass the filepath. If the agent finds issues, fix them in the draft before proceeding. Do not move to audit with known integrity issues — fix them now while the source context is fresh.
9. **Update `research/STATE.md`** — note the draft was written, integrity-checked, and is pending audit.

## Output
Confirm the draft was written to `research/drafts/`, integrity-checked, and summarize the key findings. Then tell the user: "This draft needs to pass `/audit-claims` before it moves to `outputs/`. Run `/audit-claims research/drafts/<filename>` now."
```

### Source Material

If the user provided a document path, URL, or pasted content as part of the topic description, save it to `source-material/` with an appropriate filename.

## Step 5: Verify

Before reporting to the user, verify the scaffolding is complete:

1. **Run `ls <project-root>/.claude/commands/`** — confirm all five command files exist:
   - `process-source.md`
   - `cross-ref.md`
   - `check-gaps.md`
   - `audit-claims.md`
   - `summarize-section.md`
   **Run `ls <project-root>/.claude/agents/`** — confirm the agent file exists:
   - `research-integrity.md`
   **Confirm `<project-root>/.claude/settings.json` exists** and contains the PreToolUse and PreCompact hooks.
2. **Run `ls <project-root>/research/`** — confirm all expected files and directories exist:
   - `research-plan.md`
   - `STATE.md`
   - `gaps.md`
   - `cross-reference.md`
   - `sources/registry.md`
   - `drafts/` (directory exists)
   - `outputs/` (directory exists)
   - `audits/` (directory exists)
   - `reference/source-standards.md`
   - `reference/writing-standards.md`
   - `reference/tools-guide.md`
   - `reference/canonical-figures.json`
3. **Read `<project-root>/CLAUDE.md`** — confirm it references the five commands and the correct finding tags for the selected research type.
4. **Read `<project-root>/research/STATE.md`** — confirm the phase checklist matches the research plan and the Phase 1 cycle checklist is present with all five steps unchecked.

If anything is missing, create it before proceeding. If the CLAUDE.md references commands that don't exist or has mismatched finding tags, fix it.

## Step 6: Report

Tell the user what was created. Include:
- The full directory path
- The research type selected
- The number of phases in the research plan
- The finding tags for this project type
- The five research commands available: `/process-source`, `/cross-ref`, `/check-gaps`, `/audit-claims`, `/summarize-section`
- Next steps: open a session in the project directory, read STATE.md, and start with Phase 1
- Reminder to review the research plan in `research/research-plan.md` before starting work
- Reminder to clear context between phases for sharper analysis

Do NOT initialize a git repo — the user will handle version control separately.

---

## Type Templates

These templates define the type-specific standards, finding tags, credibility hierarchies, boundaries, and phase patterns for each research type. Use the matching template when assembling CLAUDE.md, source-standards.md, and when instructing the plan-generator agent.

### PRD Validation

**Finding Tags:**
- **VALIDATED** — External evidence supports the PRD's claim or assumption
- **CHALLENGED** — External evidence contradicts or complicates the PRD's position
- **UNVERIFIABLE** — Can't confirm or deny with available sources; flag for internal validation
- **MISSING** — The PRD doesn't address something it should
- **OUTDATED** — The PRD references something that has changed since it was written

**What to Validate:**
- Technical architecture choices — are they current best practice or already outdated?
- Timeline estimates — are they realistic given comparable projects?
- Market assumptions — do the numbers hold up against external data?
- Competitive claims — has anyone already built what the PRD describes?
- Integration dependencies — are the assumed APIs, protocols, and platforms stable?
- Cost projections — are the unit economics realistic?
- User behavior assumptions — does external research support how users are expected to engage?

**Source Credibility Hierarchy:**
- Official documentation (AWS, API docs, protocol specs) → high credibility
- Industry reports, analyst research → high credibility
- Benchmark studies, performance comparisons → high if methodology is sound
- Developer community discussion (Stack Overflow, GitHub issues) → high for implementation reality
- News coverage → moderate, check for primary source
- Company websites and marketing → low credibility for claims, useful for feature comparison
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project is research and validation, not implementation. Do not write product code, deploy anything, or modify systems outside `research/`.
- Do not fabricate sources or data. If information isn't findable, log it as a gap.
- Do not over-index on any single source. Triangulate.
- If a research question can't be answered with available tools and public sources, say so in `gaps.md` and flag it as needing internal validation.

**Phase Pattern:** 8-10 phases from PRD assumption clusters + synthesis.

**Success Criteria:**
1. Every major PRD assumption has been tagged
2. All outputs have been audited for unsupported claims
3. The executive summary gives clear go/no-go/modify per PRD section
4. Technical risks are specific enough for engineering to plan around
5. Every factual claim traces to a processed source

---

### Exploratory Thesis

**Finding Tags:**
- **SUPPORTED** — Evidence supports this thesis claim or assumption
- **COMPLICATED** — Evidence adds nuance, conditions, or limitations to the position
- **CONTRADICTED** — Evidence challenges or undermines this position
- **EMERGING** — New or developing trend with limited but promising evidence
- **GAP** — Area needs more research or isn't answerable with available sources

**What to Explore:**
- Theoretical foundations — is the academic/intellectual base solid, or cherry-picked?
- Core claims — does the evidence support the thesis, complicate it, or contradict it?
- Cultural and behavioral dynamics — do the assumed patterns hold up against data?
- Landscape — who's already working on this, and what's the white space?
- Audience and market — is there a viable audience, and what do they actually need?
- Feasibility — can this be built/executed, and what are the real constraints?
- The core provocation — does the central question or insight survive scrutiny?

**Source Credibility Hierarchy:**
- Academic research (sociology, psychology, economics, relevant domain) → high credibility
- Government data and official surveys (BLS, Census, Pew Research, Gallup) → high credibility
- Original thought pieces with clear arguments → high for framing, moderate for claims
- Industry reports and trend analysis → moderate to high, depending on methodology
- Journalism and long-form reporting → moderate, check for primary sources
- Community and practitioner knowledge → moderate, valuable for ground truth
- Company websites and marketing → low credibility for claims, useful for feature comparison
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project is research and exploration, not implementation. Do not write product code, deploy anything, or modify systems outside `research/`.
- Do not fabricate sources or data. If information isn't findable, log it as a gap.
- Do not over-index on any single source. Triangulate.
- If a research question can't be answered with available tools and public sources, say so in `gaps.md` and flag it as needing primary research.

**Phase Pattern:** 8-12 phases (theoretical → evidence → landscape → practical → synthesis).

**Success Criteria:**
1. Every major claim has been tagged
2. The competitive landscape is mapped with enough detail to identify white space
3. All outputs have been audited for unsupported claims
4. The synthesis gives a clear picture of what to build first and why
5. Every factual claim traces to a processed source

---

### Competitive Analysis

**Finding Tags:**
- **CONFIRMED** — Multiple sources confirm this competitive claim or market position
- **DISPUTED** — Sources disagree or the claim doesn't hold up under scrutiny
- **UNVERIFIABLE** — Can't confirm with public sources; may require direct testing or insider knowledge
- **EMERGING** — New player, feature, or trend with limited data but worth tracking
- **GAP** — Market gap or unserved need identified through competitive analysis

**What to Analyze:**
- Market boundaries — what's in scope and what's adjacent?
- Player identification — who competes directly, indirectly, and who's adjacent?
- Feature and capability comparison — what does each player actually do vs. claim to do?
- Positioning and messaging — how does each player describe themselves and to whom?
- Pricing and business models — how do they make money, and what does it cost users?
- Technology and architecture — what's their technical approach? (when relevant)
- Traction and scale — user counts, revenue, funding, growth signals
- Strengths and weaknesses — what does each player do well and poorly?
- Trends — where is the market heading?
- White space — what's not being served?

**Source Credibility Hierarchy:**
- Product documentation, feature pages, and pricing pages → high for feature data, low for claims
- User reviews and community discussion (G2, Capterra, Reddit, HN) → high for implementation reality
- Industry analyst reports (Gartner, Forrester, CB Insights) → high for market structure
- SEC filings, investor decks, earnings calls → high for financials and strategy
- Crunchbase, PitchBook, LinkedIn → high for funding, team, and company data
- Company blogs and marketing → low credibility for claims, useful for positioning and messaging
- News coverage → moderate, check for primary source and recency
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project is research and analysis, not implementation. Do not write product code or modify systems outside `research/`.
- Do not fabricate competitive data. If a competitor's metrics aren't public, log it as unverifiable.
- Do not over-index on marketing claims. Verify features through documentation, reviews, or direct testing when possible.
- If competitive intelligence requires product access or insider knowledge, flag it in `gaps.md`.

**Phase Pattern:** 6-8 phases (market definition → competitors → features → positioning → pricing → trends → white space → synthesis).

**Success Criteria:**
1. Every identified competitor has been profiled with verified data
2. Feature comparison matrix covers all meaningful dimensions
3. Market gaps are specific enough to inform product decisions
4. All outputs have been audited for unsupported claims
5. The synthesis produces actionable positioning recommendations
6. Every factual claim traces to a processed source

---

### Company Research (For-Profit)

**Finding Tags:**
- **CONFIRMED** — Multiple independent sources confirm this claim or data point
- **DISPUTED** — Sources disagree or company claims don't match external evidence
- **UNVERIFIABLE** — Can't confirm with public sources; may require insider access or proprietary data
- **OUTDATED** — Information that was once accurate but may have changed (flag date)
- **GAP** — Important information that isn't publicly available

**What to Analyze:**
- Company identity — what do they do, for whom, and why does it matter?
- Leadership and governance — who runs the company, what's their track record?
- Products and services — what do they actually sell, and how good is it?
- Technology and IP — what's their technical approach and competitive moat?
- Financial health — revenue, margins, growth, funding, burn rate, path to profitability
- Market position — where do they sit in the competitive landscape?
- Customers and traction — who uses this, how many, and are they growing?
- Partnerships and ecosystem — who do they work with, and how dependent are they?
- Culture and talent — what's it like to work there, and can they recruit?
- Risks and challenges — what could go wrong, and what are they not addressing?

**Source Credibility Hierarchy:**
- SEC filings (10-K, 10-Q, S-1, proxy statements) → highest credibility for financials and risk factors
- Earnings call transcripts → high for strategy and forward-looking statements
- Patent filings and technical publications → high for technology and IP
- Industry analyst reports → high for market context and competitive positioning
- Crunchbase, PitchBook → high for funding history and investor data
- LinkedIn → high for team composition and hiring patterns
- User reviews (G2, Capterra, Trustpilot) → high for product quality reality
- Glassdoor, Blind → moderate for culture (skewed negative, but useful for patterns)
- Company website, blog, press releases → low credibility for claims, useful for positioning
- News coverage → moderate, check for primary source
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project is research, not investment advice. Findings are informational, not recommendations to buy, sell, or invest.
- Do not fabricate financial data. If metrics aren't public, log it as a gap.
- Do not access proprietary databases or paid services unless the user provides credentials.
- For private companies, financial data will be limited — focus on funding rounds, reported revenue, growth signals and flag gaps clearly.

**Phase Pattern:** 8-10 phases (overview → leadership → products/tech → financials → market position → customers → partnerships → culture → risks → synthesis).

**Success Criteria:**
1. Every major company claim has been verified against independent sources
2. Financial data is sourced from filings or credible estimates (not company marketing)
3. Competitive position is assessed relative to named competitors with evidence
4. Risks are specific and evidence-based, not generic
5. All outputs have been audited for unsupported claims
6. The synthesis produces a clear assessment of company health, trajectory, and risks
7. Every factual claim traces to a processed source

---

### Company Research (Non-Profit)

**Finding Tags:**
- **CONFIRMED** — Multiple independent sources confirm this claim or data point
- **DISPUTED** — Sources disagree or organizational claims don't match external evidence
- **UNVERIFIABLE** — Can't confirm with public sources; may require insider access or proprietary program data
- **OUTDATED** — Information that was once accurate but may have changed (flag date)
- **GAP** — Important information that isn't publicly available

**What to Analyze:**
- Mission and theory of change — what problem do they solve, and what's their approach?
- Leadership and governance — who runs the organization, what's the board composition?
- Programs and services — what do they actually do, and for whom?
- Impact measurement — how do they measure success, and is the evidence credible?
- Financial health — revenue sources, reserves, overhead ratio, sustainability
- Funding landscape — who funds them, how diversified, how dependent on any single source?
- Partnerships and ecosystem — who do they collaborate with, and how?
- Reputation and stakeholder perception — what do beneficiaries, donors, and peers think?
- Organizational capacity — staffing, infrastructure, ability to scale
- Risks and sustainability — what threatens the organization's ability to deliver?

**Source Credibility Hierarchy:**
- IRS Form 990 filings (via ProPublica Nonprofit Explorer, GuideStar/Candid) → highest credibility for financials
- Annual reports and audited financial statements → high credibility
- Charity evaluators (Charity Navigator, GuideStar/Candid, GiveWell, BBB Wise Giving) → high for ratings and analysis
- Academic evaluations and program impact studies → high for effectiveness evidence
- Government grant records (USASpending.gov, state databases) → high for public funding data
- Organization's own website, reports, publications → moderate for program descriptions, low for impact claims
- News coverage and investigative journalism → moderate to high, especially for controversies
- LinkedIn → useful for team composition and organizational scale
- Glassdoor/Indeed → moderate for organizational culture (small sample sizes)
- Beneficiary and community feedback → high for ground truth, but harder to access
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project is research, not a philanthropic recommendation. Findings are informational, not recommendations to fund or partner.
- Do not fabricate impact data. Non-profit impact measurement is notoriously difficult — be honest about what's measurable and what's claimed.
- Do not access proprietary databases unless the user provides credentials. 990 data is public and should be the financial foundation.
- Flag the difference between program spending claims and independently verified impact.

**Phase Pattern:** 8-10 phases (mission → leadership → programs → impact → financials (990) → funding → partnerships → capacity → risks → synthesis).

**Success Criteria:**
1. Financial analysis is grounded in 990 filings with at least 3 years of data when available
2. Impact claims are distinguished from measured outcomes — tag each clearly
3. Funding diversification and donor dependency are assessed with specific data
4. Organizational claims are verified against independent sources where possible
5. All outputs have been audited for unsupported claims
6. The synthesis produces a clear assessment of health, effectiveness, and sustainability
7. Every factual claim traces to a processed source

---

### Person Research

**Finding Tags:**
- **CONFIRMED** — Multiple independent sources confirm this claim or data point
- **DISPUTED** — Sources disagree or the person's claims don't match external evidence
- **UNVERIFIABLE** — Can't confirm with public sources; may require direct conversation or references
- **OUTDATED** — Information that was once accurate but may have changed (flag date)
- **SELF-REPORTED** — Claim originates from the person themselves with no independent verification
- **GAP** — Important information that isn't publicly available

**What to Analyze:**
- Identity and career arc — who are they, what's their professional trajectory, what are the major chapters of their career?
- Expertise and credibility — what evidence supports their claimed expertise? Published work, patents, speaking engagements, demonstrated outcomes, peer recognition.
- Track record — what have they built, led, or shipped? What were the outcomes? Distinguish between "was there when it happened" and "made it happen."
- Public positions and thought leadership — what have they said publicly? Talks, articles, interviews, social media. Are their positions consistent over time? Any controversial stances?
- Reputation and peer perception — what do people who've worked with them say? Awards, endorsements, references, but also criticism, disputes, or pattern of conflict.
- Network and affiliations — who do they associate with professionally? Board seats, advisory roles, investments, institutional affiliations. What does the network reveal about their position in their field?
- Financial and legal footprint — SEC filings if they're an officer/director, litigation, patents, corporate registrations, disclosed investments. Only what's in public record.
- Red flags and risk factors — gaps in timeline, inconsistencies between claimed and verifiable history, legal issues, patterns of short tenures, repeated conflicts, or claims that don't hold up.

**Source Credibility Hierarchy:**
- SEC filings, court records, patent filings, corporate registrations → highest credibility for verifiable facts
- Published work (books, peer-reviewed papers, named conference talks with recordings) → high for expertise validation
- Third-party profiles (Crunchbase, PitchBook, Bloomberg) → high for career data and funding involvement
- News coverage and investigative journalism → high for public record, moderate for characterization
- Interviews, podcasts, recorded talks by the person → high for stated positions (they said it publicly), low for factual claims (self-reported)
- LinkedIn profile → useful for career timeline structure, LOW credibility for claims about impact or role scope. Treat as self-reported unless independently verified.
- Personal website, blog, portfolio → useful for work samples and stated positions, low for factual claims about outcomes
- Twitter/X, public social media → useful for real-time positions and network signals, low for factual claims
- Glassdoor, Blind, anonymous reviews → moderate for pattern detection (multiple similar reports carry weight), low for individual claims
- Testimonials, endorsements, reference quotes on personal site → not independent evidence. Treat as marketing.
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project uses only publicly available information. Do not attempt to access private records, hack accounts, or social engineer information.
- Do not research personal life (family, health, relationships) unless the person has made it publicly relevant to their professional identity.
- Do not make character judgments. Report what the evidence shows and let the reader draw conclusions.
- Flag the difference between what the person claims and what can be independently verified. Self-reported accomplishments are data, not evidence.
- If the person has a thin public footprint, say so. Do not fill gaps with inference. A short report with clearly marked gaps is more valuable than a long report padded with speculation.
- This is research, not opposition research. The goal is an accurate picture, not a case for or against the person.

**Phase Pattern:** 6-10 phases, adapted by the plan generator based on the person's public profile depth and the reason for research. Typical structure:
- Phase 1: Career arc and identity (establish the timeline, roles, companies, transitions)
- Phase 2: Expertise validation (published work, patents, demonstrated outcomes, peer recognition)
- Phase 3: Track record deep dive (what did they actually do at each major role? outcomes vs. claims)
- Phase 4: Public positions and thought leadership (talks, writing, interviews, social media presence)
- Phase 5: Reputation and peer perception (what others say — awards, criticism, patterns)
- Phase 6: Network and affiliations (board seats, advisory roles, investors, institutional connections)
- Phase 7: Financial and legal footprint (only for individuals with public filings — SEC, litigation, patents)
- Phase 8: Red flags and risk assessment (inconsistencies, gaps, patterns that warrant attention)
- Phase 9: Synthesis — comprehensive profile, credibility assessment, key findings, open questions

For less public individuals, the plan generator should collapse phases where source material won't exist (e.g., skip the financial/legal phase for someone with no SEC filings) and deepen the phases where material is available.

**Success Criteria:**
1. Career timeline is verified against multiple sources — not just the person's own LinkedIn or bio
2. Every expertise claim is tagged: independently confirmed, self-reported only, or unverifiable
3. Track record distinguishes between "was present" and "was responsible" with evidence
4. Public positions are documented with direct quotes and sources, not paraphrased
5. Red flags are evidence-based and specific, not speculative
6. Gaps in the public record are explicitly identified — what couldn't be found and why it matters
7. All outputs have been audited for unsupported claims
8. The synthesis gives a clear, balanced picture that neither inflates nor deflates the person's profile
9. Every factual claim traces to a processed source

---

### Market/Industry Research

**Finding Tags:**
- **ESTABLISHED** — Well-documented trend or fact supported by multiple credible sources and data
- **EMERGING** — New trend or development with growing but limited evidence; direction is clear but magnitude is uncertain
- **DECLINING** — Trend, technology, or approach losing adoption or relevance, supported by data
- **CONTESTED** — Experts or data sources disagree on this point; present all sides
- **PROJECTED** — Forward-looking estimate or forecast; flag the source methodology and track record
- **GAP** — Important aspect of the landscape where reliable data doesn't exist or isn't publicly available

**What to Analyze:**
- Market definition and scope — what exactly are we talking about? Define boundaries clearly. What's in, what's adjacent, what's out.
- Current state and maturity — where is this market/technology on the maturity curve? Early adoption, growth, mainstream, saturation?
- Size and growth — market size estimates, growth rates, and the methodology behind them. Be skeptical of inflated projections.
- Adoption patterns — who's adopting, how fast, what's driving adoption? Segment by company size, industry, geography where data exists.
- Key players and ecosystem — not as competitors, but as participants. Who are the major vendors, platforms, standards bodies, open source projects, influencers? Map the ecosystem, not just the companies.
- Technology and capability landscape — what's the current state of the art? What works well? What's still immature? What are the technical constraints?
- Barriers and accelerators — what's slowing adoption? What's driving it? Regulatory, technical, cultural, economic factors.
- Segment and regional variations — does this look different for SMB vs. enterprise? US vs. Europe vs. Asia? Different industries?
- Emerging trends and inflection points — what's changing right now? What could shift the landscape in the next 1-3 years?
- Investment and funding patterns — where is money flowing? VC trends, M&A activity, enterprise spending patterns.
- Risks and uncertainties — what could derail the trend? Regulatory changes, technical failures, market corrections, competitive disruption.

**Source Credibility Hierarchy:**
- Government data and official statistics (BLS, Census, OECD, Eurostat) → highest credibility for macro data
- Peer-reviewed research and academic studies → high for methodology-backed findings
- Major analyst firms with disclosed methodology (Gartner, Forrester, IDC, McKinsey, Deloitte) → high for market sizing and trends, but scrutinize methodology and note if estimates vary across firms
- Industry associations and trade group reports → high for industry-specific data, moderate for advocacy-driven conclusions
- Survey data with disclosed methodology and sample size → moderate to high depending on rigor
- Earnings calls, SEC filings, investor presentations → high for individual company data, useful for trend signals
- Venture capital and funding databases (Crunchbase, PitchBook, CB Insights) → high for investment pattern data
- Technical documentation, benchmarks, published evaluations → high for capability assessment
- Developer surveys (Stack Overflow, JetBrains, etc.) → high for adoption signals within tech, limited outside tech
- News coverage and trade journalism → moderate, useful for recency but verify claims against primary sources
- Vendor-published reports and whitepapers → LOW credibility for market claims (marketing). Useful for product capability data and positioning.
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project is research and analysis, not strategy consulting. Present what the data shows; do not make business recommendations unless the synthesis phase specifically calls for implications.
- Do not fabricate market size estimates. If credible sources disagree, present the range with methodology notes. If no credible source exists, say so.
- Be explicit about the age of data. Market data older than 18 months may be significantly outdated in fast-moving sectors. Flag it.
- Distinguish between data (measured), estimates (modeled), and projections (forecasted). These are not the same thing.
- Vendor-funded research is not independent research. Note the funding source when citing analyst reports.
- Do not extrapolate trends linearly. "X grew 40% last year" does not mean it will grow 40% next year. Present what's known and flag the uncertainty.

**Phase Pattern:** 8-12 phases, adapted by the plan generator based on the topic scope and data availability. Typical structure:
- Phase 1: Market definition, scope, and boundaries (what exactly are we studying?)
- Phase 2: Current state and maturity assessment (where are we on the curve?)
- Phase 3: Market size, growth data, and adoption patterns (how big, how fast, who's adopting?)
- Phase 4: Key players and ecosystem mapping (who's involved and what roles do they play?)
- Phase 5: Technology and capability landscape (what works, what doesn't, what's coming?)
- Phase 6: Barriers and accelerators (what's helping and hurting adoption?)
- Phase 7: Segment and regional variations (does this look different for different audiences?)
- Phase 8: Investment and funding patterns (where's the money going?)
- Phase 9: Emerging trends and inflection points (what's changing right now?)
- Phase 10: Risks and uncertainties (what could shift the landscape?)
- Phase 11: Synthesis — landscape report, key findings, strategic implications, and open questions

For narrower topics, the plan generator should consolidate phases. For broader topics, it may split phases further (e.g., separate phases for different market segments).

**Success Criteria:**
1. Market boundaries are clearly defined — the reader knows exactly what's in scope and what's adjacent
2. Size and growth estimates include methodology source and confidence level; conflicting estimates are presented as ranges, not resolved to a single number
3. Adoption data distinguishes between data (measured), estimates (modeled), and projections (forecasted)
4. Key players are mapped by ecosystem role, not just listed — the reader understands the landscape structure
5. Barriers and accelerators are specific and evidence-based, not generic ("regulatory uncertainty" needs to name which regulations)
6. Data age is flagged — every statistic notes its source year
7. Vendor-funded research is identified as such
8. All outputs have been audited for unsupported claims
9. The synthesis provides a clear picture of the current state that someone could use to make informed decisions
10. Every factual claim traces to a processed source

---

### Presentation Research

**Finding Tags:**
- **STRONG EVIDENCE** — Claim is well-supported by multiple credible, current sources. Safe to lead with.
- **ANECDOTAL** — Supported by examples or stories but not systematic data. Useful for illustration, not as a foundation.
- **COUNTERPOINT** — Evidence or perspective that challenges or complicates one of your points. Must be acknowledged or addressed.
- **TIMELY** — Data or example from the last 12 months. High impact for audience credibility.
- **STALE** — Data older than 18 months in a fast-moving space. Still usable with date context, but vulnerable to "that's outdated" pushback.
- **GAP** — A point you want to make but can't adequately support with evidence yet.

**What to Research:**
- Your existing points and claims — what evidence supports each one? Which are strong, which are vulnerable?
- The audience — who are they, what do they already know, what do they care about, what will they push back on?
- The current landscape — what's happening right now in this topic space? What's the freshest data available?
- Counterpoints and objections — what would a smart skeptic say to each of your main points? What's the strongest argument against your thesis?
- Stories and examples — what concrete cases, companies, or people illustrate your points? Abstractions don't land on stage; specifics do.
- The through line — what single thread connects all your points into a narrative that builds toward a conclusion? This is the most important output.
- Narrative gaps — where does the story break? Where does one point not naturally lead to the next? These gaps need bridging evidence or restructuring.
- Quotable data — specific numbers, percentages, and comparisons that the audience will remember. "Companies that do X are 3x more likely to Y" is memorable. "Research suggests a positive correlation" is not.

**Source Credibility Hierarchy:**
- Peer-reviewed research and government data → highest credibility, strongest on stage
- Major analyst firms with named methodology (Gartner, McKinsey, Forrester) → high credibility, audiences recognize the names
- Named case studies with verifiable outcomes → high for illustration, moderate for generalization
- Recent survey data with disclosed sample size and methodology → high if current, drops fast with age
- Published interviews and talks by recognized experts → high for quotes and attributed positions
- News coverage from major outlets → moderate, useful for recency and narrative
- Industry blogs and thought leadership → moderate if the author has credibility, low otherwise
- Company press releases and marketing → LOW credibility on stage. Audiences are skeptical of vendor claims.
- Social media posts and threads → useful for zeitgeist and audience sentiment, not for factual claims
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This is research to support a presentation, not to write the presentation. The output is evidence, narrative structure, and talking points — not slides or scripts.
- Do not fabricate examples, statistics, or quotes. If you can't find evidence for a point, flag it as a GAP. Better to drop a point than to get caught with a bad stat on stage.
- Prioritize recency. A 2024 statistic is more valuable than a 2022 statistic in most presentation contexts. Flag data age explicitly.
- The through line matters more than completeness. A presentation with 5 well-supported points connected by a clear narrative beats 15 points with no thread.
- Counterpoints are not threats — they're opportunities. Addressing the strongest objection to your thesis makes you more credible, not less.
- Do not over-research. Presentation research should be focused and efficient. If a point requires more than 3-5 sources to validate, it's either well-established (and you have what you need) or too contested (and you need to reframe the point).

**Phase Pattern:** 5-8 phases, adapted by the plan generator based on how many claim clusters the user provides and the presentation context. Typical structure:
- Phase 1: Nugget inventory — catalog all existing points, claims, and ideas the user has. Identify which need evidence, which need sharpening, and which might not survive scrutiny.
- Phase 2: Audience and context research — who's in the room, what's the event, what's the format, what do they already know, what will they resist?
- Phase 3-5: Evidence gathering — one phase per major claim cluster. Validate each point, find supporting data, identify the strongest examples.
- Phase 6: Counterpoint and objection research — for each major claim, find the strongest argument against it. Research how others have addressed these objections.
- Phase 7: Through line discovery and narrative gap analysis — what connects everything? Where does the story break? What's the opening hook? What's the closing takeaway?
- Phase 8: Synthesis — presentation brief with narrative arc, evidence map, talking points per section, and recommended data points.

For shorter presentations or fewer claims, the plan generator should consolidate evidence phases. For keynotes or high-stakes talks, it may add phases for audience-specific framing or competitive positioning of the message.

**Synthesis Output Format:**

The synthesis for presentation research should produce a different format than other types:

1. **Presentation Brief** — One page: the through line, the audience, the core argument, and why it matters now.
2. **Narrative Arc** — The ordered sequence of points with transitions. How does point A lead to point B? What's the opening hook? What's the closing takeaway?
3. **Evidence Map** — For each point in the arc: the strongest supporting evidence (with source), the best example or story, the most likely objection and how to address it, and the most quotable data point.
4. **Talking Points** — Concise, speakable versions of each point. Not a script — the core of what to say in natural language.
5. **Kill List** — Points that didn't survive the research. What you came in wanting to say but can't adequately support. Better to know now than on stage.
6. **Open Questions** — Things worth mentioning but that need caveating, or areas where the data is contested.

**Success Criteria:**
1. Every major claim has been tagged with its evidence strength — the presenter knows which points are rock-solid and which are thin
2. Counterpoints have been identified for every major claim — no surprises from the audience
3. The through line is explicit and connects all points — not just a list of topics, but a narrative
4. Data is current — statistics note their source year and anything older than 18 months is flagged
5. Stories and examples are specific and verifiable — not hypothetical or generic
6. The kill list exists — points that can't be supported have been identified rather than quietly kept
7. All outputs have been audited for unsupported claims
8. The presentation brief could be handed to the presenter and they'd know exactly what they're arguing, why it matters, and what evidence backs each point
9. Every factual claim traces to a processed source

---

### Curriculum Research

**Finding Tags:**
- **CONFIRMED** — Subject matter claim verified by multiple credible sources. Safe to build curriculum around.
- **PRACTITIONER REALITY** — How practitioners actually do this work, which may differ from textbook descriptions. Critical for designing transfer activities and real-work scenarios.
- **COMMON MISCONCEPTION** — Something learners commonly believe that is incorrect or oversimplified. High-value for curriculum design — these become belief-challenging encounters in module design.
- **CONTESTED** — Experts or practitioners disagree on this point. Curriculum should acknowledge the debate rather than pick a side silently.
- **EMERGING** — New development, technique, or shift in the field with limited but growing evidence. Include with appropriate caveats.
- **OUTDATED** — Information or practice that was once standard but has been superseded. Valuable for curriculum design as a "what not to teach" marker.
- **GAP** — Important aspect of the domain where reliable information is thin or contradictory. Flag for the curriculum designer to address through expert consultation or primary research.

**What to Research:**
- Subject matter accuracy — are the core concepts, definitions, and frameworks current and correct? What does the authoritative literature say? Where do sources agree, and where do they diverge?
- Practitioner reality — what do people who do this work actually do day-to-day? How does real practice differ from textbook descriptions? What tools, workflows, and shortcuts do practitioners use? This is the foundation for transfer activities in the curriculum.
- Common misconceptions and failure patterns — what do beginners typically get wrong? What do even experienced practitioners misunderstand? Where do people plateau? These become the belief-challenging encounters and the basis for formative assessment design.
- Current state of the field — what's the accepted best practice right now? What recently changed? What's actively being debated? Curriculum that teaches yesterday's best practice has a short shelf life.
- What's changing — where is the field heading? What emerging practices, tools, or frameworks should learners be aware of even if they aren't yet standard? What's declining?
- Competing approaches — are there multiple schools of thought or methodologies? If so, which ones have the strongest evidence? Which are most widely adopted? The curriculum needs to take a position or explicitly present the landscape.
- What existing programs teach — what do other training programs, courses, or certifications cover on this topic? Where do they focus? What do they skip? This helps identify both table-stakes content and differentiation opportunities.
- Skill decomposition — what are the actual component skills a practitioner needs? Not topic areas, but specific things someone must be able to do. This directly feeds learning objective design.
- Prerequisite knowledge — what must a learner already know or be able to do before this curriculum makes sense? Where does the entry point sit?

**Source Credibility Hierarchy:**
- Peer-reviewed research in the domain → highest credibility for foundational claims
- Published practitioner case studies with verifiable outcomes → high for real-world practice
- Industry standards, professional body guidelines, certification frameworks → high for accepted practice
- Practitioner communities (forums, professional groups, conference talks with real examples) → high for ground truth on how work actually gets done
- Government data, labor statistics, occupational frameworks → high for workforce and industry context
- Subject matter expert interviews and published commentary → moderate to high depending on the expert's track record
- Textbooks and training materials from established programs → moderate for baseline content, but may lag current practice
- Blog posts, tutorials, and informal educational content → moderate if authored by credible practitioners, low otherwise
- Vendor training materials and product documentation → LOW for pedagogical claims, useful for tool-specific content
- AI-generated summaries without sources → not a source, do not use

**Boundaries:**
- This project is research to inform curriculum design, not curriculum design itself. The output is a subject matter foundation — verified facts, practitioner workflows, misconceptions, skill decompositions. Curriculum structure (outcomes, assessments, modules, sessions) happens in the curriculum builder, not here.
- Do not fabricate expertise. If the research reveals that the designer's understanding of the topic is incomplete or incorrect, that's a finding, not a problem.
- Do not conflate "widely taught" with "correct." Many training programs perpetuate outdated practices. The research should distinguish between what's commonly taught and what current evidence supports.
- Do not skip the practitioner reality phases. Textbook knowledge without practitioner grounding produces curriculum that sounds good in design but fails in the classroom.
- If a skill decomposition can't be verified through public sources, flag it as needing expert consultation. Don't guess at what practitioners actually do.

**Phase Pattern:** 6-10 phases, adapted by the plan generator based on the topic scope and how much the designer already knows. Typical structure:
- Phase 1: Domain landscape — what is this field? Boundaries, key concepts, major frameworks, current state. Establish the vocabulary and scope.
- Phase 2: Practitioner reality — how do people actually do this work? Daily workflows, tools, decision points, common challenges. Research from practitioner sources.
- Phase 3: Skill decomposition — what are the component skills? What must someone be able to do (not just know) to be competent? Map the skill structure.
- Phase 4: Common misconceptions and failure patterns — what do beginners get wrong? Where do people plateau? What beliefs need to be challenged?
- Phase 5: Current best practice — what's the accepted standard right now? Where does evidence support it? Where is it contested?
- Phase 6: Field trajectory — what's changing? Emerging practices, declining approaches, active debates.
- Phase 7: Competing approaches — multiple methodologies or schools of thought? Map them with evidence strength for each.
- Phase 8: Existing program landscape — what do other training programs cover? Where do they focus? What do they miss?
- Phase 9: Synthesis — subject matter foundation document with: verified core concepts, practitioner workflow map, skill decomposition, misconception inventory, field currency assessment, recommended curriculum scope, and open questions for the curriculum designer.

For topics where the designer has substantial existing knowledge, the plan generator should collapse early phases and deepen the misconception and practitioner reality phases. For entirely new domains, keep the full structure.

**Synthesis Output Format:**

The synthesis for curriculum research should produce outputs specifically shaped for curriculum builder intake:

1. **Subject Matter Foundation** — The verified core concepts, frameworks, and vocabulary. What's settled, what's debated, what's emerging. This is what the curriculum will teach.
2. **Practitioner Workflow Map** — How practitioners actually do this work. Named tasks, decision points, tools, common sequences. This directly feeds transfer context and real-work scenario design in the curriculum builder.
3. **Skill Decomposition** — The component skills at behavioral level ("can do X"). Organized by complexity and prerequisite relationships. This feeds learning objective design.
4. **Misconception Inventory** — What learners commonly believe that's wrong or oversimplified. Each entry: the misconception, why it persists, what the evidence actually shows, and how to surface it. This feeds belief-challenging encounter design in module structure.
5. **Field Currency Assessment** — What's current, what's changing, what's outdated. Shelf life estimate for key content areas. This helps the curriculum designer decide what to teach as established practice vs. what to flag as evolving.
6. **Curriculum Scope Recommendation** — Given everything found, what should and shouldn't be in the curriculum? What's table stakes? What's differentiation? What requires more contact hours than the program allows?
7. **Open Questions** — Things the research couldn't resolve that the curriculum designer needs to decide through expert judgment or direct experience.

**Success Criteria:**
1. Core subject matter claims are verified against multiple credible sources — not assumed from the designer's prior knowledge
2. Practitioner reality is documented from practitioner sources, not just textbooks — the curriculum designer knows how real work differs from theory
3. Skill decomposition uses behavioral language ("can do X") not topic labels ("understands X")
4. Common misconceptions are specific and evidence-based — not generic "beginners struggle with this"
5. Field currency is assessed — the designer knows which content has a short shelf life
6. Competing approaches are mapped with evidence strength, not just listed
7. All outputs have been audited for unsupported claims
8. The synthesis is structured for direct handoff to the curriculum builder's intake process
9. Every factual claim traces to a processed source
