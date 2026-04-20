---
name: process-source
description: Process a URL, PDF, or document into a structured research note
argument-hint: "[url-or-file-path]"
---

# /research:process-source

Process a source into a structured research note.

## Input
The user will provide a URL, file path, or pasted content.

## Pre-check (mandatory)

1. **Read `research/STATE.md`** and check "Sources since last cross-reference."
2. **If the count is 5 or higher, stop.** Tell the user: "Cross-reference is overdue (N sources since last `/research:cross-ref`). Run `/research:cross-ref` before processing more sources." Do not proceed until cross-ref is run.
2a. **Verify `research/sources/registry.md` exists and is parseable.** If the file does not exist, create it with the empty header row before proceeding (first-source case — this is normal for a new project):

   ```markdown
   # Source Registry

   | # | Name | Type | Credibility | Date | Note file |
   |---|------|------|-------------|------|-----------|
   ```

   If the file exists but lacks a parseable markdown table (no header row, malformed separator, or structurally corrupted), stop and tell the user: "`research/sources/registry.md` exists but cannot be parsed as a markdown table. This is a registry corruption — restore from git or fix the file manually before processing more sources. Do not proceed." Do not silently recreate or repair a corrupted registry — the user needs to see it.
3. **Check for duplicate processing.** Before fetching the source, search `research/sources/registry.md` for the URL (or filename for local files). Also check `research/notes/` for a note file with a matching URL in its header.
   - If found in registry AND a complete note exists in `research/notes/`: warn the user and present two explicit options: "This source was already processed — see `research/notes/{file}`. Pick one: **(a) overwrite** — I'll re-fetch, regenerate the note from scratch, and update the existing registry row in place. STATE.md counters are NOT incremented because this is not a new source. **(b) skip** — leave the existing note as-is and move on." Wait for `a` or `b`. Do not accept an ambiguous response — re-ask if needed.
   - If found in registry BUT the note file is missing or truncated: warn the user: "This source appears partially processed (registered but note is missing or incomplete). I'll re-process it from scratch." This case is not a user choice — it's recovery from an interrupted prior run, and the fix is always re-process.
   - If not found anywhere: proceed normally.

   This prevents duplicate processing after context clears that interrupt mid-source, and avoids wasting extraction calls on sources already in the evidence base.

## Process

1. **Fetch the content.** For URLs, try each extraction tier in order on every source, every phase, every time:
   - **Tier 1:** `tvly extract "{url}" --format markdown` (via Bash)
   - **Tier 2:** `npx firecrawl-cli scrape "{url}" --format markdown --only-main-content` (via Bash)
   - **Tier 3:** `WebFetch` (built-in — always available, no CLI needed)
   - **Floor:** `npx playwright pdf "{url}" /tmp/extract-$(date +%s).pdf` then Read the PDF

   If a tier fails for a specific source, try the next tier for that source only. On the next source, start from Tier 1 again. Fallbacks are per-source, not per-session — a failure on one URL does not mean the tool is broken for all URLs.

   For local files: if the file is a PDF, try `pdftotext "{path}" /tmp/{basename}.txt` first (via Bash), then read the text file. If `pdftotext` is not installed (command not found), fall back to reading the PDF directly with the Read tool. For non-PDF files, read them directly. Do not work from search snippets.

   **If the source cannot be fetched** (domain blocks agents, paywall, 403, timeout, or any other access failure): do NOT silently skip the source or decide you have enough without it. Present the situation to the user and offer options:

   ```
   I can't access this source: {title / URL}
   Reason: {what happened — domain block, paywall, etc.}

   Options:
   1. You grab it — paste the FULL article body here (not just the abstract, lede, or a summary — the full body including any tables, captions, and pullquotes the note will need to cite). Alternatively, save the full text to source-material/ with a filename matching the original title or URL slug and I'll read it from there.
   2. Skip this source — I'll note it as inaccessible and move on
   3. Try an alternative URL — if you have a cached/archived version
   ```

   **Option 1 disambiguation:** if the user pastes content that looks like an abstract, an article preview, a list of bullet points from a marketing page, or anything notably shorter than a real article body, do not silently accept it. Ask: "That looks like a preview or abstract — is that the full article text, or is there more? If it's just the preview, I'll process it as an abstract-only source with reduced credibility weight and note the limitation in the source note. Tell me which one." Wait for the user to confirm before processing.

   Wait for the user to respond. Do not proceed until they choose. In a real research project, you wouldn't just ignore a source because it was hard to access.
2. **Read `research/reference/source-standards.md`** for credibility assessment criteria and `.claude/reference/source-assessment-guide.md` for deeper assessment methods (methodology quality, conflict of interest, sample size, replication status).
3. **Verify this source is about the research subject.** Before writing anything, confirm the fetched content is actually about the subject defined in `research/research-plan.md` (the "Research Subject" line at the top). If the content is about a similarly-named but different thing (different company, product, plugin, person, etc.), stop and tell the user: "This source appears to be about [what you found], not [the research subject]. Please confirm whether this is the correct source before I process it." Do not process a mismatched source.
4. **Determine the author.** Only use an author name that appears explicitly as a byline in the extracted content. Do not infer an author name from the site name, domain, URL slug, or any other source. If no byline is present in the extracted text, record the author as "Unknown — no byline in extracted content." A human would either already know whose site it is or look for an about page — never treat the site name as the author name.
5. **Create a structured note** at `research/notes/<slugified-source-title>.md` with:
   - Source title, URL/path, date accessed, source type
   - Author (verified byline only — see step 4)
   - Credibility assessment based on the project's source credibility hierarchy
   - Origin chain — whether this source is primary (original data/research) or secondary (reporting on someone else's findings). If secondary, record the original source it cites (name, author, date if available). If the source cites multiple original sources for different claims, record the origin for each major claim separately.
   - Key findings — the important claims, data points, and arguments from this source
   - Relevance — which research plan phases this source informs
   - Finding tags applied to key claims. Tag set fallback chain: **(1)** read `CLAUDE.md` and use the Finding Tags section; **(2)** if that section is missing (init drifted or project predates the convention), fall back to the type template at `.claude/reference/templates/types/{research-type}.md` where `{research-type}` comes from CLAUDE.md's `research-type` field; **(3)** if neither source yields a tag set, do not invent tags — record "Tag set unavailable — CLAUDE.md and type template both missing the Finding Tags section. Tags not applied to this note." in the note's Finding Tags field and continue. Never fabricate tags.
   - Direct quotes for important claims (with context)
   - Contradictions or tensions with previously processed sources (if any)
6. **Add the source to `research/sources/registry.md`** — new row with source number, name, type, credibility rating, date, and note filename.
7. **Update `research/STATE.md`** — increment both "Total count" and "Sources since last cross-reference." **After the edit, re-read STATE.md and confirm both counters reflect the new value (old value + 1).** If the re-read shows either counter unchanged, do not report the source as processed — surface the write failure with the expected vs. actual values, and stop before moving on to the next step. The cross-ref checkpoint depends on this counter being correct; silent drift here produces a silently-overdue cross-reference.
8. **Update the source material digest (if applicable).** If the source being processed is a file located in `source-material/`, check whether it is listed in `research/source-material-digest.md`. If the digest exists and the file is not listed, add it to the "Files Read" table with read status "full" and append any new named entities, dates, credentials, stated facts, or assumptions to the corresponding digest sections. If the digest does not exist but `source-material/` contains multiple files, note to the user that the digest is missing and suggest running `/research:start-phase` (which will prompt for retroactive digest generation). If the source is a URL or a file outside `source-material/`, skip this step.

## Guardrails

1. Process sources only for the current phase. If a source contains information relevant to a future phase, note the relevance but do not extract findings for that phase.
2. Never infer an author from the domain name, URL structure, or site branding. If no byline appears in the extracted text, the author is "Unknown."
3. Assess credibility against the project's specific credibility hierarchy, not a generic one. Read `research/reference/source-standards.md` every time.
4. Preserve the source's own qualifiers, ranges, and uncertainty language in the structured note. Do not clean up hedging.
5. If the source contradicts previously processed sources, flag the contradiction explicitly in the note — do not leave it for cross-ref to discover.
6. Record the origin chain for every source. If a source presents its own original research, record it as primary. If it reports on others' findings, record each cited original with enough detail (title, author, date) for cross-ref to match origins across sources.
7. **Run in the main conversation, not in a spawned subagent.** `/research:process-source` is meant to execute in the main agent's context — the one the user is talking to — not as a task delegated to the Agent tool. This is non-negotiable and applies equally to single-source invocations and to batch processing after `/research:discover`. The reasoning: each call reads STATE.md, updates STATE.md's "Sources since last cross-reference" counter, writes to `research/sources/registry.md`, consults the commonplace book and prior source notes for contradiction detection, and may surface an access failure or contradiction the user needs to react to in real time. A subagent running this in a cold context races with the main agent over STATE.md, can't see contradictions the main agent already surfaced earlier in the session, can't be interrupted by the user mid-source, and turns the mandatory cross-reference checkpoint into a silent threshold that gets walked past. If you are tempted to spawn a subagent to "process the remaining N sources in parallel" or "work through the queue while I do something else," stop — that is the failure mode, not the solution. Process one source, print the status, process the next.
8. **Do not wrap batch processing in a TodoWrite/TaskCreate task list.** The candidates file at `research/discovery/{phase}-candidates.md` is the work queue. `research/STATE.md`'s counter is the checkpoint trigger. `research/sources/registry.md` is the completion ledger. A parallel todo list ("Process Source 39", "Process Source 40", "Run cross-ref", "Process Source 42"…) duplicates state into a place that disappears on `/clear`, drifts from the authoritative files, and — most importantly — reframes the cross-ref checkpoint as just another checkbox in a list. The checkpoint is a hard interrupt on the batch, not a queue item. Read the candidates file in order, process each source inline, print one status line per completion, stop when STATE.md shows the counter has hit the threshold.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Misattributing the author — using site name or domain as author name | Only record an author name that appears as a byline in the extracted content. "Unknown" is correct when no byline exists. |
| Accepting source claims at face value without credibility assessment | Every note must include a credibility assessment. A company's blog post about its own product is low-credibility for performance claims regardless of how detailed it is. |
| Processing sources for future phases instead of the current one | Check STATE.md for the active phase. Extract findings relevant to the current phase only. Note future-phase relevance in the Relevance field but do not tag those findings. |
| Working from search snippets instead of full content | Always extract or read the full source content. Search snippets are for discovery, not for note-taking. Partial content leads to missing context and qualifier stripping. |
| Processing a file from source-material/ without updating the digest | When the source path begins with `source-material/`, after writing the note, update `research/source-material-digest.md` with the file's contents (add to Files Read table, append new entities/dates/credentials/facts/assumptions). The digest is the reconciliation anchor for `/research:start-phase` — drift produces false blockers or misses real drops. |
| Silently skipping blocked or paywalled sources | Never decide on your own to skip a source you can't access. Present the access failure to the user with options: they provide the content, explicitly skip it, or offer an alternative URL. The user decides, not the agent. |
| Sticky fallback — using a lower tier for all sources after one failure | Fallbacks are per-source, not per-session. Always start from Tier 1 (`tvly extract`) on every source. A failure on one URL does not mean that tier won't work on the next. Reset to Tier 1 on every new source. |
| Silently resolving contradictions within a source | When a source contains contradictory figures for the same metric, flag both values. Do not pick the one that fits the narrative. |
| Missing origin chain — not recording whether a source is primary or secondary | Every source note must include an origin chain field. If the source's originality status is unclear from the content, record "Origin unclear — could not determine from extracted content" rather than omitting the field. |
| Delegating source processing to a spawned subagent (Agent tool) — individual or batch | `/research:process-source` runs in the main conversation, not a subagent. A spawned subagent has a cold context (no commonplace book, no prior source notes in memory, no in-session contradictions), races with the main agent over STATE.md and registry.md, can't be interrupted by the user mid-source, and — in batch mode — silently walks past the cross-reference checkpoint because the main agent isn't watching the counter. Process each source inline. If the candidate list is long and you are tempted to "parallelize" by spawning subagents, resist: the bottleneck isn't agent throughput, it's the cross-ref cadence and user visibility. |
| Wrapping batch processing in a TodoWrite/TaskCreate task list | The candidates file is the queue, STATE.md is the counter, registry.md is the ledger. A parallel todo list ("Process Source 39", "Run cross-ref at 5-source threshold", "Process Source 42"…) duplicates state into a place `/clear` destroys, drifts from the authoritative files, and — the real bug — converts the cross-reference checkpoint from a hard interrupt into a queue item a task-list-driven loop will simply tick past. Read the candidates file top-to-bottom and process sources inline. One status line per source is the correct cadence; a progress bar is not. |

## Output
Summarize the key findings for the user. Note which research phases this source is relevant to and any contradictions with existing sources. If "Sources since last cross-reference" is now 4 or 5, remind the user: "Cross-reference is due soon (N/5 sources). Run `/research:cross-ref` after the next source or two."
