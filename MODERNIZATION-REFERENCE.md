# Claude Code Plugin Modernization Reference

**Source project:** KNZ Curriculum Builder (`knz-builder-src`)
**Date completed:** 2026-03-28
**Purpose:** Reference for bringing all Kelsey Ruger projects to current Claude Code best practices. Apply this to any project using plugins, skills, agents, or hooks.

---

## What Changed and Why

Claude Code merged `commands/` into `skills/` as the recommended pattern. Skills support features commands don't: supporting files in a directory, invocation control, subagent execution via `context: fork`, dynamic context injection, and the Agent Skills open standard. Commands still work but are legacy — new features ship for skills only.

---

## 1. Commands → Skills Migration

### The change

Every `commands/foo.md` becomes `skills/foo/SKILL.md`.

**Before:**
```
.claude/
  commands/
    intake.md
    validate.md
```

**After:**
```
.claude/
  skills/
    intake/
      SKILL.md
    validate/
      SKILL.md
```

### Frontmatter update

Commands only had `description`. Skills add `name` and `disable-model-invocation`:

**Before (command):**
```yaml
---
description: Run validation on a curriculum package
---
```

**After (skill):**
```yaml
---
name: validate
description: Run validation on a curriculum package
disable-model-invocation: true
---
```

- `name` — lowercase, hyphens allowed, max 64 chars. Defaults to directory name if omitted, but explicit is better.
- `disable-model-invocation: true` — Prevents Claude from auto-invoking. Use this for pipeline commands the user invokes explicitly. Omit it for reference skills Claude should load automatically when relevant.

### Path references

After moving files, grep the entire plugin for any hardcoded `commands/` paths and update them to `skills/*/SKILL.md`. In our case there was one: `approve` referenced `commands/verify.md` → updated to `skills/verify/SKILL.md`.

### Supporting files

Skills live in directories, so they can have supporting files alongside SKILL.md. We moved project scaffold templates into `skills/init/project-scaffold/` and referenced them via `${CLAUDE_SKILL_DIR}/project-scaffold/` in the skill content. Available substitutions:

- `${CLAUDE_SKILL_DIR}` — absolute path to the skill's directory
- `$ARGUMENTS` / `$0`, `$1`, `$2` — arguments passed to the skill
- `${CLAUDE_SESSION_ID}` — current session ID

### Delete commands/ directory

After migration, delete the `commands/` directory entirely. No backward compatibility shim needed.

---

## 2. Plugin.json Enrichment

### Minimal (what we had)
```json
{
  "name": "curriculum",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "Kelsey Ruger" }
}
```

### Recommended (current schema)
```json
{
  "name": "curriculum",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "Kelsey Ruger", "email": "kelsey@kenziecreative.com" },
  "homepage": "https://...",
  "repository": "https://...",
  "license": "MIT",
  "keywords": ["curriculum", "pedagogy"],
  "skills": "./skills/",
  "agents": "./agents/",
  "hooks": "./hooks.json"
}
```

Explicit path declarations (`"skills": "./skills/"`) make the plugin more robust than relying on convention. Add them.

---

## 3. Skill Frontmatter — Full Field Reference

| Field | Type | Purpose |
|-------|------|---------|
| `name` | string | Display name (lowercase, hyphens, max 64 chars) |
| `description` | string | Tells Claude when to auto-invoke; shows in `/` menu |
| `argument-hint` | string | Hint for autocomplete, e.g. `[project-name]` |
| `disable-model-invocation` | boolean | `true` = user-only; prevents auto-invocation |
| `user-invocable` | boolean | `false` = hidden from `/` menu; Claude-only |
| `allowed-tools` | string | Comma-separated: `Read, Grep, Bash(npm *)` |
| `model` | string | Override session model for this skill |
| `effort` | string | `low`, `medium`, `high`, `max` |
| `context` | string | `fork` to run in isolated subagent |
| `agent` | string | Subagent type when `context: fork` (`Explore`, `Plan`, `general-purpose`) |
| `paths` | string/array | Glob patterns limiting when skill activates |
| `hooks` | object | Hooks scoped to skill lifecycle |

---

## 4. Modernization Opportunities (What We Scoped for v5.0)

These are improvements identified but not yet implemented. Apply the same audit to any project.

### 4a. `allowed-tools` on read-only skills

Skills that only read state (dashboards, status checks, verification) should restrict tools to prevent accidental writes:

```yaml
---
name: resume
description: Show pipeline status
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(cat *)
---
```

**Audit question:** Does this skill need to write files? If no, add `allowed-tools`.

### 4b. `context: fork` for agent isolation

Skills that dispatch worker agents via prose instructions ("spawn a Task with the content of...") should use structural isolation instead:

```yaml
---
name: validate
description: Run three-tier validation
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Write
---
```

This replaces prose-based agent dispatch with Claude Code's native isolation. The skill runs in a subagent with its own context — no risk of the orchestrator's context interfering.

**Audit question:** Does this skill tell Claude to "spawn a Task" or "dispatch an agent" in its body text? If yes, consider `context: fork`.

### 4c. Plugin-scoped hooks

Create `hooks/hooks.json` at the plugin root for guardrails currently enforced only by prose:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "prompt",
          "prompt": "Check if this write targets a stage directory whose prerequisite stage is incomplete. If so, block it."
        }]
      }
    ]
  }
}
```

Hook types available: `command` (shell), `http` (POST), `prompt` (LLM evaluation), `agent` (agentic verification).

Hook events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PermissionRequest`, `Notification`, `SubagentStart`, `SubagentStop`, `Stop`, `PreCompact`, `SessionEnd`.

**Audit question:** Are there rules in skill body text that say "never do X" or "always check Y before Z"? Those are candidates for hooks.

### 4d. `argument-hint` for parameterized skills

```yaml
---
name: init
description: Initialize a new project workspace
argument-hint: "[project-name]"
disable-model-invocation: true
---
```

**Audit question:** Does the skill accept user input as an argument (not via interactive prompting)? Add `argument-hint`.

### 4e. Dynamic context injection

Skills that instruct Claude to read a file can inject it at parse time instead:

```markdown
## Current State
!`cat workspace/*/STATE.md 2>/dev/null || echo "No active project"`
```

The `` !`command` `` syntax runs at skill parse time. Output replaces the placeholder before Claude sees the skill content. This is faster and more reliable than prose instructions to "read the file."

**Audit question:** Does the skill say "read [file] first" or "load [file] before proceeding"? Consider `` !`command` `` injection.

---

## 5. Dead Code Cleanup Checklist

When modernizing a project, also check for:

- [ ] `scripts/install.sh` or `scripts/dev-reload.sh` — old plugin installation patterns. Plugins are now installed via `claude plugin install` or settings.json entries.
- [ ] `scripts/release.sh` — superseded by GSD milestone tagging or git tags.
- [ ] `VERSION` file — if only used by deleted release scripts.
- [ ] Any `commands/` directory — should be migrated to `skills/`.
- [ ] Hardcoded paths to `commands/*.md` in any file across the project.
- [ ] `templates/` directories whose contents belong inside a skill directory as supporting files.

---

## 6. Migration Procedure (Step by Step)

For any project that needs this migration:

1. **Inventory commands:** `ls .claude/commands/` or `.claude/plugins/*/commands/`
2. **Create skill directories:** `mkdir -p skills/{name}` for each command
3. **Copy with frontmatter update:** For each command, copy to `skills/{name}/SKILL.md`, adding `name` and `disable-model-invocation: true` to frontmatter
4. **Move supporting files:** If any command references external templates or data files, move them into the skill directory and update references to use `${CLAUDE_SKILL_DIR}/`
5. **Update internal path references:** Grep entire plugin for `commands/` and update to `skills/*/SKILL.md`
6. **Update plugin.json:** Add explicit `"skills": "./skills/"` path
7. **Delete commands/ directory**
8. **Sanity check:** Verify all skills appear in Claude Code's `/` menu, test key workflows

---

## 7. Verification Checklist

After migration, confirm:

- [ ] `commands/` directory does not exist
- [ ] Every skill directory has a `SKILL.md`
- [ ] Every migrated skill has `name`, `description`, `disable-model-invocation: true` in frontmatter
- [ ] Zero references to `commands/` path anywhere in the project
- [ ] All internal cross-references updated (skill A referencing skill B uses new path)
- [ ] Supporting files moved into skill directories with `${CLAUDE_SKILL_DIR}` references
- [ ] `plugin.json` has explicit path declarations
- [ ] Skills appear in `/` autocomplete menu
- [ ] Key workflows still function (test 2-3 representative skills end to end)
