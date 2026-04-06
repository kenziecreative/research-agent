# Research Agent

**A structured research system by [Kenzie Creative](https://www.kenzienotes.com).**

Research Agent turns Claude Code into a rigorous research partner. You pick a topic, it builds a phased research plan grounded in preliminary web research, and then you work through it together — collecting sources, finding patterns, identifying gaps, synthesizing findings, and fact-checking every claim before it reaches a final output. The system enforces the discipline that makes research trustworthy: every source is structured and registered, every number is tracked to its origin, every draft is audited against the evidence before it's promoted to a finished section.

The result isn't a summary of what an AI "knows" about your topic. It's a sourced, audited research output where every claim traces back to specific evidence, every figure is canonical across the entire project, and an integrity agent watches for fabrication, drift, and qualifier stripping on every write.

## What You Get

**A tailored research plan** generated from preliminary web research on your specific topic — not a generic template. The system researches before it plans, so the phases and questions reflect what actually matters for your subject.

**Type-aware source discovery** that knows where to look based on your research type. A company deep-dive searches SEC filings and financial databases. An exploratory thesis prioritizes academic papers. A non-profit investigation pulls 990 tax filings. The system routes to the right channels automatically — you review the candidates and decide what to process.

**Structured source processing** that turns URLs, PDFs, and documents into consistent research notes with credibility ratings, key findings tagged by type, and limitations called out — building a searchable evidence base as you go.

**Cross-referencing and gap analysis** that runs automatically as sources accumulate, surfacing patterns across your evidence and mapping exactly where coverage is strong and where holes remain. The system detects when multiple sources trace back to the same original claim — three blog posts citing the same study count as one data point, not three. Coverage is measured by independent sources that directly answer each question, not by volume.

**Audited outputs** where every draft section is fact-checked against your source notes before it can become a final deliverable. Claims that aren't supported get flagged. Numbers that drifted get caught. Qualifiers that got stripped get restored. Each section gets a confidence tier (High, Moderate, Low, Insufficient) based on source count, credibility, evidence directness, and staleness — so you know exactly how much weight to put on each part of the output. Nothing reaches the final output directory without passing audit.

**A canonical figures registry** that prevents the most common research failure mode: numbers changing as they travel from source to note to draft to synthesis. Every cross-phase figure is registered once and enforced everywhere.

## How It Works

Research Agent is built on [Claude Code](https://docs.anthropic.com/en/docs/claude-code). You answer four questions — research type, topic, where the project should live, and who the research is for — and the system scaffolds a complete research environment with a phased plan, state management, and all the protocols in place. The audience answer calibrates the evidence standard: investment due diligence requires every financial claim cross-referenced, while personal knowledge building optimizes for understanding over defensibility.

The process follows a strict cycle for each phase:

1. **Collect** — Start with `/research:discover` to find candidate sources across multiple channels, then process the best ones with `/research:process-source`
2. **Connect** — Cross-reference across all sources to find patterns
3. **Assess** — Check coverage gaps before moving on
4. **Synthesize** — Draft a section from the evidence
5. **Verify** — Audit the draft against source notes, promote to final output only if it passes

Phases are sequential. You finish one before starting the next. The system tracks your position in `STATE.md`, so you can stop and resume across sessions — it picks up exactly where you left off. Context clears between phases are encouraged; nothing lives in conversation history that isn't also written down.

## Research Types

| Type | What It Does |
|------|-------------|
| **PRD Validation** | Pressure-test a Product Requirements Document against external evidence. Tests assumptions, technical choices, timeline estimates, market claims. |
| **Exploratory Thesis** | Build the evidence base for a thesis, concept, or vision. Validate core claims, map the landscape, identify opportunities and risks. |
| **Competitive Analysis** | Map a competitive landscape for a product, market, or space. Identify players, compare features, find white space, assess positioning. |
| **Company Research (For-Profit)** | Deep research on a specific company. Financials, products, market position, leadership, technology, risks. |
| **Company Research (Non-Profit)** | Deep research on a non-profit. Mission, programs, impact, 990 financials, funding, governance, effectiveness. |
| **Person Research** | Deep research on an individual. Career trajectory, expertise validation, published work, public positions, reputation, red flags. |
| **Market/Industry Research** | Map the current state of a market, technology, or trend. Adoption patterns, key players, growth data, barriers, and where things are heading. |
| **Presentation Research** | Build the evidence base and narrative thread for a presentation. Validate claims, find supporting data, identify counterpoints, discover the through line. |
| **Curriculum Research** | Research a subject domain to build a curriculum from scratch. Verify accuracy, map practitioner reality, identify misconceptions, assess field currency. |
| **Opportunity Discovery** | Discover product opportunities for a specific audience or niche. Map where they gather, what they complain about, what they pay for, and where existing solutions fall short. |
| **Customer Safari** | Build strategic intelligence about a target audience by observing their natural online behavior. Map communities, categorize observations (Pains, Delights, Recommendations, Questions, Jargon), score trends, and produce prioritized market intelligence. |

Each type has its own phase structure, finding tags, source credibility hierarchy, and validation standards. The research plan adapts to the type — a company deep-dive produces different phases than a thesis validation.

## This Is Not a Summarizer

Research Agent doesn't ask Claude what it "knows" and hand you a summary. It sends Claude to find sources, process them into structured evidence, cross-reference across them, identify what's missing, and then synthesize from that evidence base — with every claim auditable back to a specific source.

If a draft says a market is growing at 15% CAGR, that number exists in a source note, with a credibility rating, from a specific document. If the number drifted from 12-18% in the source to "approximately 15%" in the draft, the integrity agent catches it. If a qualifier got dropped — "in North America" became just "globally" — the audit flags it.

The system is designed to produce research you can trust because you can trace it, not because an AI said it confidently.

## Getting Started

You'll need [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and the [Tavily MCP server](https://docs.tavily.com/) configured for web search and source extraction.

```bash
git clone https://github.com/kenziecreative/research-agent.git your-project-name
cd your-project-name
```

Replace `your-project-name` with a name for your research project (e.g., `competitor-analysis`, `market-sizing`, `ceo-background-check`).

**Important:** Don't name the clone `research`. The system creates a `research/` directory inside the project for your research files. Cloning into a directory also called `research` produces a `research/research/` nesting that confuses path resolution across sessions.

Then open Claude Code in the project directory and run:

```
/research:init
```

That walks you through setup — research type, topic, and project location. From there, the system guides you through each phase.

## External APIs Used by Discovery

The `/research:discover` command calls several free, public APIs to find sources across different channels. **No API keys or accounts are required** — these are all open-access. The system degrades gracefully if any are unavailable; it skips the channel and reports what happened.

| API | What It Does | Who Should Know |
|-----|-------------|----------------|
| **[OpenAlex](https://openalex.org/)** | Searches academic papers by topic. Returns titles, authors, citation counts, DOIs, and open-access links. | Sends HTTP requests to `api.openalex.org` with a `mailto` parameter for polite pool access. No auth required. Free and open. |
| **[SEC EDGAR EFTS](https://efts.sec.gov/LATEST/search-index?q=)** | Searches SEC filings (10-K, 10-Q, 8-K, DEF 14A, S-1) by company name or CIK. | Sends HTTP requests to `efts.sec.gov` with a `User-Agent` header identifying the tool, per SEC's [fair access policy](https://www.sec.gov/os/accessing-edgar-data). Rate-limited to 5 req/s. Free, public data. |
| **[ProPublica Nonprofit Explorer](https://projects.propublica.org/nonprofits/api)** | Looks up nonprofit organizations by name or EIN. Returns 990 filing data, revenue, and links to full PDF filings. | Sends HTTP requests to `projects.propublica.org`. No auth required. Free and open. |
| **[Google Patents](https://patents.google.com/)** | Constructs search URLs for patent discovery by assignee or inventor. | Builds a URL that gets extracted via Tavily — no direct API call to Google. |
| **[Tavily](https://tavily.com/)** | Web search, news, financial sources, and social signals. The primary discovery engine. | Requires the Tavily MCP server to be configured (you set this up during install). Used for web-search, financial, social-signals, and domain-specific channels. |

All HTTP API calls are made via `curl` in the terminal. You can see exactly what's being requested. Nothing is sent to these services other than search queries derived from your research topic.

## Commands

| Command | What It Does |
|---------|-------------|
| `/research:init` | Start a new research project |
| `/research:discover` | Find candidate sources across multiple channels based on research type |
| `/research:process-source` | Process a URL or file into a structured research note |
| `/research:cross-ref` | Find patterns across all processed source notes |
| `/research:check-gaps` | Map coverage against the research plan, identify holes |
| `/research:summarize-section` | Synthesize notes into a draft section |
| `/research:audit-claims` | Fact-check a draft against source notes; promote to output if it passes |
| `/research:start-phase` | Get a briefing before starting the next phase |
| `/research:phase-insight` | See which questions are well-covered vs. thin in the current phase |
| `/research:progress` | Project dashboard — phase status, source counts, next action |

## Integrity Features

**Canonical figures registry** — Every number cited across phases is registered in a single source of truth. When a figure is carried forward, it must match the canonical value exactly. Numbers don't drift.

**Research integrity agent** — Runs automatically after every write. Catches fabricated data, range narrowing (source says "1-3x", output says "2-3x"), qualifier stripping, internal inconsistencies, and cross-phase drift.

**Contradiction detection** — When credible sources genuinely conflict, the system flags the contradiction with both sides cited and a suggested resolution. Synthesis is blocked until you make a resolution decision — contradictions don't get silently averaged away.

**Source staleness warnings** — Each research type has its own staleness threshold (1 year for competitive analysis, up to 5 for curriculum research). When a source exceeds the threshold, you see a warning during synthesis with the source name, data year, and how far over the threshold it is.

**Counter-evidence requirement** — For PRD Validation and Exploratory Thesis research types, the system blocks synthesis until at least one credible source challenges the central claim. If nobody disagrees with your thesis, that's a finding worth noting — but you have to look first.

**Hard gates** — Nothing reaches the final output directory without passing `/research:audit-claims`. This is enforced by hooks, not just instructions. The system will block a write to `outputs/` if no audit report exists.

## Picking Up Where You Left Off

Research projects run across multiple sessions. The system is designed for that.

Every phase completion, source processed, decision made, and gap identified is tracked in `STATE.md`. When you come back — whether it's the next day or next week — the system reads your state and picks up exactly where you left off. You don't need to re-explain anything.

Context clears between phases are encouraged, not just tolerated. Each phase gets a fresh context window for sharper analysis, and `STATE.md` carries everything forward. A `PreCompact` hook warns you if state hasn't been saved before context compresses, so nothing gets lost.

## License

MIT
