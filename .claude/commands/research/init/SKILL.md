---
name: init
description: Scaffold a structured research project with state management, evidence standards, and agent-driven workflows
disable-model-invocation: true
---

# /research:init — Initialize a Structured Research Project

You are scaffolding a new research project. This skill creates the research infrastructure: directory structure, CLAUDE.md, STATE.md, reference protocols, source registry, gap tracker, cross-reference file, and a research plan tailored to the project's topic and type.

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

**Question 4 — Audience & Evidence Standard:**

Ask: "Who is this research for, and how will they use it? This helps calibrate how rigorous the evidence standards need to be."

Provide examples:
- Internal decision-making (exec team evaluating a strategy)
- External publication (academic paper, journalism, public report)
- Investment / due diligence (evaluating a company or market for investment)
- Pitch deck / fundraising support (building evidence for a pitch)
- Curriculum design (building a knowledge base to teach from)
- Personal knowledge building (satisfying your own curiosity on a topic)

Accept free-form answers. The user may describe an audience not on this list. The purpose is to understand the stakes and the standard, not to force a category.

Wait for all four answers before proceeding.

## Step 2: Create Directory Structure

Create the following directories at the target path:

```
<project-root>/
├── research/
│   ├── sources/
│   ├── notes/
│   ├── drafts/
│   ├── outputs/
│   ├── audits/
│   ├── reference/
│   └── discovery/               # Discovery strategy and candidate sources
└── source-material/
```

Note: No `.claude/commands/`, `.claude/agents/`, or `.claude/settings.json` — these live in the research-agent project, not in the scaffolded research project.

## Step 3: Generate the Research Plan

Read the matching type template from `.claude/reference/templates/types/` to get the type-specific finding tags, validation standards, phase structure patterns, and credibility hierarchy.

Read the type-channel map from `.claude/reference/discovery/type-channel-maps/{research-type}.md`. You will pass this content to the plan-generator subagent so it can produce the discovery strategy alongside the research plan.

Launch an agent (use `subagent_type: "general-purpose"`, model: `sonnet`) to generate the research plan. Provide the agent with:
- The research type
- The topic description / source material the user provided
- The type-specific template content so the agent knows the finding tags, validation standards, and phase structure patterns
- The audience and evidence standard answer, so the agent can calibrate phase depth and source requirements
- The type-channel map content from `.claude/reference/discovery/type-channel-maps/{research-type}.md`

Give the agent these instructions:

---

### Plan Generator Instructions

You generate research plans for structured AI-assisted research projects. Your output is the content for a `research-plan.md` file that defines the entire research arc for a project.

**Audience calibration:** The evidence standard for this project is set by the audience. Use the audience context to:
- Adjust the number of sources expected per phase (higher for external publication or investment due diligence, lower for personal knowledge building)
- Calibrate the level of triangulation required before a finding is treated as confirmed
- Set the tone of the success criteria (defensibility for investment research, accuracy for curriculum, understanding for personal research)
Do not override the evidence standard set by the audience. A personal knowledge project should not require academic-grade triangulation. An investment due diligence project should not accept single-source financial claims.

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

**Phase cycle:** Complete all steps before proceeding to Phase 2: Collect sources → /research:cross-ref → /research:check-gaps → /research:summarize-section → /research:audit-claims. Do not start Phase 2 until this phase's audit passes.

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

**Common Failure Modes — Plan Generation:**

| Failure Mode | Prevention |
|---|---|
| Misidentifying the research subject — generating a plan for a similarly-named but wrong entity | State the exact research subject at the top of the plan. If the topic is ambiguous, stop and ask. Do not resolve ambiguity by picking the most likely match. |
| Generic phases — questions that could apply to any company/topic rather than this specific one | Every question should reference something specific about the subject. "What is the market size?" is generic. "Does the claimed $4.7B TAM hold up against independent estimates?" is specific. |
| Over-scoping — generating 12 phases when the topic warrants 6 | Match phase count to available evidence. A person with minimal public footprint needs fewer phases than a Fortune 500 company. Collapse phases where sources will not exist. |
| Under-specifying source priority — vague "be skeptical of marketing" without naming specific source types | Name the specific source types that mislead for this topic. For a startup: press coverage that parrots founder claims. For a non-profit: self-reported impact metrics. |

**Quality Standards:**
- Every question must be specific enough that a researcher knows what to search for
- Questions must be answerable with publicly available sources (flag any that require internal access)
- Phase names must be descriptive and scannable
- Output filenames follow the pattern: `##-slug.md`
- Synthesis phase always produces at minimum an executive summary and a full report
- Be specific in "be skeptical of" — name source types that tend to mislead for this topic

You have access to WebSearch and WebFetch — use them to understand the topic before generating the plan. Do preliminary research so the phases and questions are grounded, not generic. **Preliminary research is for context only — it does not change the subject you were given.**

Write the final research plan to `<project-root>/research/research-plan.md`.

**Discovery Strategy Generation:**

After generating the research plan, also produce `research/discovery/strategy.md`. Use the type-channel map content provided to you.

For each phase in the research plan you just generated:
- Find the matching Discovery Group in the type-channel map by keyword-matching the phase name to Discovery Group names (e.g., a phase named "Financial Analysis" matches a "Financial" or "Financials" Discovery Group)
- If a match is found: record the phase name, its primary channels, and its secondary channels from the type-channel map
- If no match is found: record the phase as "no discovery — uses existing sources"

Write `<project-root>/research/discovery/strategy.md` with this format:

```markdown
# Discovery Strategy: [Research Type]

This file maps each research phase to its highest-value discovery channels.
Generated by /research:init — read automatically by /research:discover.

---

## Phase 1: [Phase Name]
**Primary channels:** [channel1], [channel2]
**Secondary channels:** [channel3], [channel4]

## Phase 2: [Phase Name]
**Primary channels:** [channel1]
**Secondary channels:** [channel2], [channel3]

[...repeat for each phase with a Discovery Group match...]

## Phase N: [Phase Name]
no discovery — uses existing sources

[...etc for phases without a matching Discovery Group...]
```

---

Wait for the agent to complete before proceeding.

## Step 4: Assemble and Write Files

### CLAUDE.md

Assemble a slim CLAUDE.md by combining:

0. **Research Type Field** — A single line at the very top of the file: `research-type: {type}` where `{type}` is the kebab-case research type value from the user's Question 1 answer (e.g., `company-for-profit`, `market-industry`, `company-non-profit`, `prd-validation`, `competitive-analysis`, `person-research`, `exploratory-thesis`, `curriculum-research`, `presentation-research`). This field is machine-readable — the discover skill's pre-check reads it to select the correct type-channel map.

1. **Project Purpose** — Generated from the research type and topic. One paragraph describing what this research project does and why.

2. **Audience & Evidence Standard:**

This research is for: [user's answer from Question 4]

Evidence calibration — include the appropriate guidance based on the audience type:
- **Internal decision-making:** Focus on directional accuracy and actionable findings. Single-source findings are acceptable when flagged. Speed matters — do not over-triangulate when the decision timeline is tight.
- **External publication:** Every claim must be fully sourced and triangulated. No single-source findings presented as established. All contradictions must be presented. Qualifiers are mandatory. This is the highest evidence bar.
- **Investment / due diligence:** Emphasis on verifiable numbers, risk identification, and red flags. Single-source financial claims are unacceptable. Cross-reference all quantitative claims. Skepticism toward self-reported metrics.
- **Pitch deck / fundraising support:** Evidence must be defensible under skeptical questioning. Focus on claims that will be challenged by investors. Flag any finding that relies on the company's own reporting.
- **Curriculum design:** Prioritize accuracy of mental models over precision of specific numbers. Focus on practitioner reality over theory. Flag areas where the field is actively debating — the curriculum must not present contested claims as settled.
- **Personal knowledge building:** Balanced depth — thorough but not exhaustive. Flag uncertainty but do not over-hedge. Optimize for understanding, not defensibility.

When the audience is not one of the above, calibrate based on: Who will read this? What decisions will they make from it? What happens if a claim turns out to be wrong?

3. **Directory Structure:**

```
research/
├── research-plan.md          # Master research prompt (the assignment)
├── STATE.md                  # Persistent research state
├── sources/
│   └── registry.md           # Index of all processed sources
├── notes/                    # Structured notes per source
├── drafts/                   # Unaudited synthesis (written by /research:summarize-section)
├── outputs/                  # Audited, final sections (promoted by /research:audit-claims only)
├── audits/                   # Claim audit reports
├── reference/                # Protocol and standards reference files
│   └── canonical-figures.json # Single source of truth for cross-phase numbers
├── discovery/               # Discovery strategy and candidate sources
├── cross-reference.md        # Cross-source patterns
└── gaps.md                   # Coverage tracker
```

Do not create files outside this structure for research artifacts. Working files go in `research/`. Synthesized sections go to `research/drafts/` first. Only `/research:audit-claims` promotes a draft to `research/outputs/`. Nothing in `outputs/` should exist without a corresponding audit report in `audits/`.

**Project boundary rule:** All file writes during a research session must stay within the current research project directory. Do not write to other projects, system directories, or external paths — even when responding to a user request that could be handled by a skill designed for a different context (e.g., a note-capture skill pointed at another project). If the user wants to capture a note or action item, write it to `research/notes-to-self.md` within this project. Never invoke a skill that writes outside the current project directory.

4. **Skills:**

| Skill | Trigger | Job |
|-------|---------|-----|
| Process Source | `/research:process-source <url-or-file>` | Processes raw source into structured note |
| Cross-Reference | `/research:cross-ref` | Finds patterns across all processed notes |
| Gap Tracker | `/research:check-gaps` | Maps research coverage, identifies holes |
| Claim Auditor | `/research:audit-claims <filepath>` | Fact-checks a draft against source notes |
| Summarize Section | `/research:summarize-section <name>` | Synthesizes notes into polished draft sections |
| Start Phase | `/research:start-phase` | Shows what's needed to begin the next phase |
| Phase Insight | `/research:phase-insight` | Analyzes current phase progress and thin areas |
| Progress | `/research:progress` | Shows project dashboard with phase status |
| Discover Sources | `/research:discover` | Finds candidate sources for the current phase using type-aware multi-channel discovery |

**Integrity agent:** `research-integrity` — runs automatically after writing any source note, draft, or synthesis. Watches for fabricated data, range narrowing, qualifier stripping, cross-phase drift, unsourced claims.

5. **Workflow:**

**Research is phase-sequential.** You work one phase at a time, in order. Each phase completes its full cycle before the next phase begins. Do not collect sources for Phase 3 while working on Phase 1. Do not batch source collection across multiple phases. Do not invent phase groupings or reorder phases.

The cycle for each phase:

1. **Collect** — Start by running `/research:discover` to find candidate sources for the current phase, then use `/research:process-source` for each URL, PDF, or document relevant to the *current phase only*.
2. **Connect** — Run `/research:cross-ref` after every 5-8 new sources to find patterns. This is mandatory, not optional.
3. **Assess** — Run `/research:check-gaps` to confirm coverage for this phase. Fill gaps with more sources if needed.
4. **Synthesize** — Use `/research:summarize-section` to produce a draft in `research/drafts/`. This is NOT a final output.
5. **Verify** — Run `/research:audit-claims` on the draft. This is what promotes it from `drafts/` to `outputs/`. No exceptions.
6. **Transition** — Update STATE.md, mark the phase complete, recommend context clear, and only then begin the next phase.

`research/discovery/strategy.md` maps each phase to its highest-value discovery channels. The discover skill reads this file automatically.

Read the research plan in `research/research-plan.md` before starting. It defines the phases and their order.

**Enforcement rules — these are structural, not guidelines:**

- **Phases are sequential.** Complete Phase N's full cycle (collect → connect → assess → synthesize → verify) before starting Phase N+1. Do not collect sources for future phases. Do not batch work across phases. Do not group or reorder phases. The research plan defines the order — follow it.
- **Nothing reaches `research/outputs/` without passing `/research:audit-claims`.** `/research:summarize-section` writes to `research/drafts/`. `/research:audit-claims` checks the draft against source notes and, if it passes, moves it to `research/outputs/`. If it fails, the draft stays in `drafts/` with an audit report listing what needs fixing.
- **`/research:cross-ref` is mandatory after every 5-8 new sources.** Before processing a 9th source without a cross-reference, stop and run `/research:cross-ref` first. `research/cross-reference.md` must reflect current patterns at all times.
- **`/research:check-gaps` is mandatory before starting a new phase.** Do not begin Phase N+1 until `/research:check-gaps` has confirmed coverage status for Phase N. If gaps remain, fill them or document them explicitly in `research/gaps.md` with a reason they're acceptable.
- **Phase completion requires all five steps.** A phase is not complete until: sources collected for this phase, cross-reference is current, gaps are assessed, draft is written, and audit has passed. STATE.md should not mark a phase complete until all five are done.
- **Canonical figures registry is the source of truth for cross-phase numbers.** When citing a number from a previous phase, check `research/reference/canonical-figures.json` first. If registered, use the canonical value. If not registered and this is a cross-phase citation, register it before using it. Never copy numbers from STATE.md summaries or conversation memory.
- **Never skip, fold, reorder, or merge phases without explicit user approval.** If `/research:check-gaps` reveals a phase has insufficient source coverage, tell the user and present options: (1) collect more sources to fill the gaps, (2) skip the phase with the user's explicit approval, or (3) fold the phase's questions into another phase with the user's explicit approval. Do not make this decision yourself. Do not record a phase-skip in STATE.md without the user confirming it on screen first.
- **Running `/research:discover` at the start of each phase is recommended but not mandatory.** It surfaces the highest-value sources for the current phase's questions via multi-channel discovery. Sources can still be found manually and processed with `/research:process-source`.

**Clear context between phases.** Each phase should start with a fresh context window. STATE.md and your research files carry everything forward — nothing critical lives in conversation history. A fresh context for each phase produces sharper analysis than a saturated one. Before clearing, ensure STATE.md is fully up to date with current position, completed work, and next action. After clearing, read STATE.md first before resuming work.

**At the end of every phase, remind the user:** "Phase [N] is complete and STATE.md is updated. I'd recommend clearing context before starting Phase [N+1] — you'll get sharper results with a fresh window, and nothing is lost because STATE.md has everything."

6. **[Type] Standards** — Include from the matching type template:
   - The "What to Validate/Explore/Analyze" section
   - The "Finding Tags" section

7. **State Management:**

Research state lives in `research/STATE.md`. It is the source of truth for project position — not memory, not conversation history, not file timestamps.

On every new session or after context clear: Read `research/STATE.md` first. Don't start working until you know where you are. The "Current Phase Cycle" section tells you exactly which step you're on — pick up there. **If STATE.md records any skipped, folded, or deferred phases, report this to the user before resuming work.** The user may not have been present when that decision was made — surface it explicitly so they can confirm or reverse it.

During work: Update state at every transition — phase start/end, meaningful task completion, user decisions. Check off cycle steps as they complete. Write state BEFORE doing anything expensive in case of compaction. A PreCompact hook will warn you if STATE.md is stale, but don't rely on it — update proactively.

The "Active phase" field in STATE.md tells you which phase to work on. Do not work on any other phase. When the current phase's cycle checklist is fully checked, mark it complete, generate the next phase's cycle checklist, and update "Active phase."

8. **Context Management:**

This is a long-running project. Clear context between research phases — each phase gets a fresh window for sharper analysis. STATE.md is the source of truth that carries everything forward. Before clearing context, always update STATE.md with current position, completed work, key decisions, and next action. After clearing or starting a new session: read `research/STATE.md` first. If unsure what's been done, run `/research:check-gaps` before starting new work.

9. **Boundaries** — From the type-specific template.

10. **Reference Protocols:**

Detailed protocols are in `research/reference/`. Read the relevant file when you need the full protocol:

| Protocol | File | Read When |
|----------|------|-----------|
| Source & Evidence Standards | `research/reference/source-standards.md` | Processing sources, citing evidence, assessing credibility |
| Writing & File Standards | `research/reference/writing-standards.md` | Writing output sections, naming files |
| Tools Guide (Tavily) | `research/reference/tools-guide.md` | Using Tavily search, extract, map, or crawl |

Write the assembled CLAUDE.md to `<project-root>/CLAUDE.md`.

### Reference Files

Copy the following files to the project:

1. Copy `.claude/reference/writing-standards.md` to `<project-root>/research/reference/writing-standards.md`
2. Copy `.claude/reference/tools-guide.md` to `<project-root>/research/reference/tools-guide.md`

### source-standards.md

Read `.claude/reference/templates/source-standards.md` as a template. Replace the `[INSERT THE SOURCE CREDIBILITY HIERARCHY FROM THE MATCHING TYPE TEMPLATE]` placeholder with the Source Credibility Hierarchy from the matching type template. Write the result to `<project-root>/research/reference/source-standards.md`.

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
- [ ] **Collect** — Sources gathered for this phase's questions (start with /research:discover)
- [ ] **Connect** — `/research:cross-ref` run, cross-reference.md current
- [ ] **Assess** — `/research:check-gaps` run, coverage confirmed for this phase
- [ ] **Synthesize** — `/research:summarize-section` run, draft in `drafts/`, integrity checked
- [ ] **Verify** — `/research:audit-claims` passed, output promoted to `outputs/`

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

**Cross-ref is due when "Sources since last cross-reference" reaches 5.** Do not process a 6th source without running `/research:cross-ref` first. `/research:cross-ref` resets this counter to 0.

## Next Action
Begin Phase 1: Collect sources relevant to Phase 1 questions only.
```

Write to `<project-root>/research/STATE.md`.

### Other Files

- Copy `.claude/reference/templates/registry.md` to `<project-root>/research/sources/registry.md`

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

- Copy `.claude/reference/templates/cross-reference.md` to `<project-root>/research/cross-reference.md`

- Copy `.claude/reference/templates/canonical-figures.json` to `<project-root>/research/reference/canonical-figures.json`

### Source Material

If the user provided a document path, URL, or pasted content as part of the topic description, save it to `source-material/` with an appropriate filename.

## Step 5: Verify

Before reporting to the user, verify the scaffolding is complete:

1. **Run `ls <project-root>/research/`** — confirm all expected files and directories exist:
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
   - `discovery/strategy.md`
2. **Confirm NO `.claude/commands/`, `.claude/agents/`, or `.claude/settings.json` were created** — these live in the research-agent project, not in the scaffolded research project.
3. **Read `<project-root>/CLAUDE.md`** — confirm it references the nine skills with `/research:*` qualified names and the correct finding tags for the selected research type.
4. **Read `<project-root>/research/STATE.md`** — confirm the phase checklist matches the research plan and the Phase 1 cycle checklist is present with all five steps unchecked.

If anything is missing, create it before proceeding. If the CLAUDE.md references incorrect skill names or has mismatched finding tags, fix it.

## Step 6: Report

Tell the user what was created. Include:
- The full directory path
- The research type selected
- The number of phases in the research plan
- The finding tags for this project type
- The nine research skills available: `/research:process-source`, `/research:cross-ref`, `/research:check-gaps`, `/research:audit-claims`, `/research:summarize-section`, `/research:start-phase`, `/research:phase-insight`, `/research:progress`, `/research:discover`
- Next steps: open a session in the project directory, read STATE.md, and start with Phase 1
- Reminder to review the research plan in `research/research-plan.md` before starting work
- Reminder to clear context between phases for sharper analysis

Do NOT initialize a git repo — the user will handle version control separately.
