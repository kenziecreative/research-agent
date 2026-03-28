---
name: process-source
description: Process a URL, PDF, or document into a structured research note
argument-hint: "[url-or-file-path]"
disable-model-invocation: true
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
2. **Read `research/reference/source-standards.md`** for credibility assessment criteria.
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

## Output
Summarize the key findings for the user. Note which research phases this source is relevant to and any contradictions with existing sources. If "Sources since last cross-reference" is now 4 or 5, remind the user: "Cross-reference is due soon (N/5 sources). Run `/research:cross-ref` after the next source or two."
