# research-agent

A Claude Code command that scaffolds structured, AI-assisted research projects with state management, evidence standards, and integrity enforcement built in.

## Install

```bash
git clone https://github.com/kenziecreative/research-agent.git
ln -s "$(pwd)/research-agent/knz-research.md" ~/.claude/commands/knz-research.md
```

Then in any Claude Code session, run `/knz-research` to start a new research project.

## Update

```bash
cd /path/to/research-agent && git pull
```

Because the command is installed via symlink, the update is immediate — no re-linking needed.

## What it does

`/knz-research` asks three questions — research type, topic, and where to put the project — then scaffolds a complete research environment tailored to your topic. It launches an agent to do preliminary web research and generate a phase-by-phase research plan before writing anything, so the phases and questions are grounded, not generic.

**Supported research types:**

- **PRD Validation** — Pressure-test a Product Requirements Document against external evidence before engineering begins
- **Exploratory Thesis** — Build the evidence base for a thesis, concept, or vision
- **Competitive Analysis** — Map a competitive landscape, identify players, find white space
- **Company Research (For-Profit)** — Deep research on a specific company: financials, products, market position, risks
- **Company Research (Non-Profit)** — Mission, programs, impact, 990 financials, funding, governance
- **Person Research** — Career trajectory, expertise validation, public positions, reputation, red flags
- **Market/Industry Research** — Adoption patterns, key players, growth data, barriers, where things are heading
- **Presentation Research** — Build the evidence base and through line for a talk or presentation

## What gets created

Each project gets its own self-contained environment:

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
├── source-material/              # Raw input documents
└── .claude/
    ├── commands/                 # Project-level research commands
    │   ├── process-source.md
    │   ├── cross-ref.md
    │   ├── check-gaps.md
    │   ├── summarize-section.md
    │   └── audit-claims.md
    └── agents/
        └── research-integrity.md # Post-write drift and integrity checker
```

## How the workflow works

1. `/process-source <url-or-file>` — Fetch and structure a source into a research note
2. `/cross-ref` — Find patterns across all processed notes (mandatory every 5-8 sources)
3. `/check-gaps` — Map coverage against the research plan, identify holes (mandatory before each new phase)
4. `/summarize-section <phase>` — Synthesize notes into a draft (writes to `drafts/`, runs integrity check automatically)
5. `/audit-claims <filepath>` — Fact-check the draft against source notes; promotes to `outputs/` if it passes

## Key integrity features

**`canonical-figures.json`** — Every number cited across phases is registered here. When a figure is carried forward, it must match the canonical value exactly. This prevents numbers from drifting as findings move from phase outputs into synthesis.

**`research-integrity` agent** — Runs automatically after every write. Catches fabricated data, range narrowing (source says "1-3x", output says "2-3x"), qualifier stripping, internal inconsistencies, and cross-phase drift.

**Hard gates** — Nothing reaches `outputs/` without passing `/audit-claims`. No new phase starts without `/check-gaps` confirming the previous phase's coverage. No 6th source gets processed without running `/cross-ref` first.

**Project boundary rule** — All file writes stay inside the research project directory. The agent won't write to other projects or system paths even if asked.

## Requirements

- [Claude Code](https://claude.ai/code)
- Tavily MCP server (for web search and source extraction in research projects)
