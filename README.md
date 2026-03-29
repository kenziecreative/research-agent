# research-agent

Structured, AI-assisted research projects with state management, evidence standards, and integrity enforcement built in.

## Install

Clone or copy this project, then open a Claude Code session inside it. The `/research:*` commands are auto-discovered from `.claude/commands/research/`.

```bash
git clone https://github.com/kenziecreative/research-agent.git
cd research-agent
```

Then run `/research:init` to start a new research project.

## Update

```bash
cd research-agent
git pull
```

## What it does

`/research:init` asks three questions — research type, topic, and where to put the project — then scaffolds a complete research environment tailored to your topic. It launches an agent to do preliminary web research and generate a phase-by-phase research plan before writing anything, so the phases and questions are grounded, not generic.

**Supported research types:**

- **PRD Validation** — Pressure-test a Product Requirements Document against external evidence before engineering begins
- **Exploratory Thesis** — Build the evidence base for a thesis, concept, or vision
- **Competitive Analysis** — Map a competitive landscape, identify players, find white space
- **Company Research (For-Profit)** — Deep research on a specific company: financials, products, market position, risks
- **Company Research (Non-Profit)** — Mission, programs, impact, 990 financials, funding, governance
- **Person Research** — Career trajectory, expertise validation, public positions, reputation, red flags
- **Market/Industry Research** — Adoption patterns, key players, growth data, barriers, where things are heading
- **Presentation Research** — Build the evidence base and through line for a talk or presentation
- **Curriculum Research** — Research a subject domain to build a curriculum from scratch, producing a subject matter foundation for curriculum design

## Project structure

```
research-agent/
├── .claude/
│   ├── commands/research/       # Slash commands (auto-discovered as /research:*)
│   │   ├── init/SKILL.md        # Project scaffolder
│   │   ├── process-source/      # Process URL/file into structured note
│   │   ├── cross-ref/           # Find patterns across source notes
│   │   ├── check-gaps/          # Map coverage, identify holes
│   │   ├── audit-claims/        # Fact-check draft, promote to outputs
│   │   ├── summarize-section/   # Synthesize notes into draft section
│   │   ├── start-phase/         # Briefing for next phase (read-only)
│   │   ├── phase-insight/       # Current phase analysis (read-only)
│   │   └── progress/            # Project dashboard (read-only)
│   ├── agents/
│   │   └── research-integrity.md  # Post-write drift and integrity checker
│   ├── reference/               # Templates and standards (outside commands tree)
│   │   ├── templates/           # Type configs, empty-state files
│   │   │   ├── types/           # 9 research type templates
│   │   │   ├── source-standards.md
│   │   │   ├── cross-reference.md
│   │   │   ├── registry.md
│   │   │   └── canonical-figures.json
│   │   ├── writing-standards.md
│   │   └── tools-guide.md
│   ├── settings.json            # Hooks: output gates + state preservation
│   └── settings.local.json
└── README.md
```

## What gets created per project

Each project gets its own self-contained environment (no `.claude/` files written):

```
<project-root>/
├── CLAUDE.md                     # Project instructions, rules, and finding tags
├── research/
│   ├── research-plan.md          # Phase-by-phase research assignment (agent-generated)
│   ├── STATE.md                  # Persistent state — survives context clears
│   ├── sources/registry.md       # Index of all processed sources
│   ├── notes/                    # Structured note per source
│   ├── drafts/                   # Unaudited synthesis output
│   ├── outputs/                  # Audited, finalized sections
│   ├── audits/                   # Claim audit reports
│   ├── cross-reference.md        # Cross-source patterns
│   ├── gaps.md                   # Coverage tracker
│   └── reference/
│       ├── source-standards.md
│       ├── writing-standards.md
│       ├── tools-guide.md
│       └── canonical-figures.json  # Single source of truth for cross-phase numbers
└── source-material/              # Raw input documents
```

## How the workflow works

1. `/research:process-source <url-or-file>` — Fetch and structure a source into a research note
2. `/research:cross-ref` — Find patterns across all processed notes (mandatory every 5-8 sources)
3. `/research:check-gaps` — Map coverage against the research plan, identify holes (mandatory before each new phase)
4. `/research:summarize-section <phase>` — Synthesize notes into a draft (writes to `drafts/`, runs integrity check automatically)
5. `/research:audit-claims <filepath>` — Fact-check the draft against source notes; promotes to `outputs/` if it passes

**New navigation skills (read-only):**

6. `/research:start-phase` — Get a briefing before starting the next phase: questions, prior findings, context
7. `/research:phase-insight` — See which questions are well-covered vs. thin in the current phase
8. `/research:progress` — Project dashboard showing phase status, source counts, and next action

## Key integrity features

**`canonical-figures.json`** — Every number cited across phases is registered here. When a figure is carried forward, it must match the canonical value exactly. This prevents numbers from drifting as findings move from phase outputs into synthesis.

**`research-integrity` agent** — Runs automatically after every write. Catches fabricated data, range narrowing (source says "1-3x", output says "2-3x"), qualifier stripping, internal inconsistencies, and cross-phase drift.

**Hard gates (hooks)** — Nothing reaches `outputs/` without passing `/research:audit-claims`. These are enforced by hooks in `.claude/settings.json`, not just prose instructions.

**Project boundary rule** — All file writes stay inside the research project directory. The agent won't write to other projects or system paths even if asked.

## Requirements

- [Claude Code](https://claude.ai/code)
- Tavily MCP server (for web search and source extraction in research projects)
