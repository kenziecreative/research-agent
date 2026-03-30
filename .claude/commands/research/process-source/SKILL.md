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

## Process

1. **Fetch the content.** For URLs, use Tavily extract (preferred) or WebFetch to get the full content. For files, read them directly. Do not work from search snippets.
2. **Read `research/reference/source-standards.md`** for credibility assessment criteria and `.claude/reference/source-assessment-guide.md` for deeper assessment methods (methodology quality, conflict of interest, sample size, replication status).
3. **Verify this source is about the research subject.** Before writing anything, confirm the fetched content is actually about the subject defined in `research/research-plan.md` (the "Research Subject" line at the top). If the content is about a similarly-named but different thing (different company, product, plugin, person, etc.), stop and tell the user: "This source appears to be about [what you found], not [the research subject]. Please confirm whether this is the correct source before I process it." Do not process a mismatched source.
4. **Determine the author.** Only use an author name that appears explicitly as a byline in the extracted content. Do not infer an author name from the site name, domain, URL slug, or any other source. If no byline is present in the extracted text, record the author as "Unknown — no byline in extracted content." A human would either already know whose site it is or look for an about page — never treat the site name as the author name.
5. **Create a structured note** at `research/notes/<slugified-source-title>.md` with:
   - Source title, URL/path, date accessed, source type
   - Author (verified byline only — see step 4)
   - Credibility assessment based on the project's source credibility hierarchy
   - Key findings — the important claims, data points, and arguments from this source
   - Relevance — which research plan phases this source informs
   - Finding tags applied to key claims (use the project's tag set from CLAUDE.md)
   - Direct quotes for important claims (with context)
   - Contradictions or tensions with previously processed sources (if any)
6. **Add the source to `research/sources/registry.md`** — new row with source number, name, type, credibility rating, date, and note filename.
7. **Update `research/STATE.md`** — increment both "Total count" and "Sources since last cross-reference."

## Guardrails

1. Process sources only for the current phase. If a source contains information relevant to a future phase, note the relevance but do not extract findings for that phase.
2. Never infer an author from the domain name, URL structure, or site branding. If no byline appears in the extracted text, the author is "Unknown."
3. Assess credibility against the project's specific credibility hierarchy, not a generic one. Read `research/reference/source-standards.md` every time.
4. Preserve the source's own qualifiers, ranges, and uncertainty language in the structured note. Do not clean up hedging.
5. If the source contradicts previously processed sources, flag the contradiction explicitly in the note — do not leave it for cross-ref to discover.

## Common Failure Modes

| Failure Mode | Prevention |
|---|---|
| Misattributing the author — using site name or domain as author name | Only record an author name that appears as a byline in the extracted content. "Unknown" is correct when no byline exists. |
| Accepting source claims at face value without credibility assessment | Every note must include a credibility assessment. A company's blog post about its own product is low-credibility for performance claims regardless of how detailed it is. |
| Processing sources for future phases instead of the current one | Check STATE.md for the active phase. Extract findings relevant to the current phase only. Note future-phase relevance in the Relevance field but do not tag those findings. |
| Working from search snippets instead of full content | Always extract or read the full source content. Search snippets are for discovery, not for note-taking. Partial content leads to missing context and qualifier stripping. |
| Silently resolving contradictions within a source | When a source contains contradictory figures for the same metric, flag both values. Do not pick the one that fits the narrative. |

## Output
Summarize the key findings for the user. Note which research phases this source is relevant to and any contradictions with existing sources. If "Sources since last cross-reference" is now 4 or 5, remind the user: "Cross-reference is due soon (N/5 sources). Run `/research:cross-ref` after the next source or two."
