# OpenCode + Gas Town deepening

This dotfiles setup ships a curated OpenCode config in
`~/.config/opencode/` and a starter set of skills + subagents. It's
designed to work with [gas town](https://github.com/gastownhall/gastown)
for multi-agent orchestration.

---

## What's installed

```
~/.config/opencode/
├── AGENTS.md                          # Global system-prompt instructions
├── config.json                        # OpenCode config (model, agents, MCP)
├── skills-lock.json                   # Versioned skill lockfile
├── agents/                            # 10 subagent role definitions
│   ├── build.md                       # Default active-coding agent
│   ├── plan.md                        # Read-only analysis agent
│   ├── backend-engineer.md            # API/business logic
│   ├── frontend-engineer.md           # React features (mid-level)
│   ├── frontend-senior.md             # Design systems, refactors
│   ├── qa-engineer.md                 # Tests, TDD
│   ├── devops-engineer.md             # Docker, CI/CD
│   ├── code-reviewer.md               # Read-only PR review
│   ├── product-manager.md             # Specs, user stories
│   └── marketing.md                   # Copy, growth, SEO
├── skills/                            # 5 generic starter skills
│   ├── rest-api-design.md
│   ├── database-patterns.md
│   ├── react-patterns.md
│   ├── i18n-patterns.md
│   └── multi-tenant-patterns.md
├── commands/                          # /slash commands
│   ├── plan.md
│   ├── build.md
│   ├── refactor.md
│   └── debug.md
└── themes/
    └── tokyo-night.json               # Custom theme overrides
```

---

## Subagents

Each subagent has a YAML frontmatter with:
- `description` — when to use it
- `mode: subagent` — for delegation
- `permission` block — what it can do

### Default agents

| Agent | Mode | Use for |
|-------|------|---------|
| `build` | active | actual coding |
| `plan` | read-only | design, refactor analysis |

### Domain agents (subagent pattern)

| Agent | Read | Edit | Write | Bash | Best for |
|-------|------|------|-------|------|----------|
| `backend-engineer` | ✓ | ✓ | ✓ | ✓ | API, data, business logic |
| `frontend-engineer` | ✓ | ✓ | ✓ | ✓ | React features |
| `frontend-senior` | ✓ | ✓ | ✓ | ✓ | Design systems, refactors |
| `qa-engineer` | ✓ | ✓ | ✓ | ✓ | Tests, TDD |
| `devops-engineer` | ✓ | ✓ | ✓ | ✓ | Docker, CI/CD, deploys |
| `code-reviewer` | ✓ | ✗ | ✗ | ✓ | PR review (read-only) |
| `product-manager` | ✓ | ✓ | ✓ | ✓ | Specs, user stories |
| `marketing` | ✓ | ✓ | ✓ | ✓ | Copy, growth, SEO |

Switch agents with `shift+tab` (in opencode TUI) or the `/plan` and
`/build` slash commands.

### Custom agents

Create a new agent:

```sh
new-agent my-role "Description of what it does"
# Default: full permissions
new-agent code-reviewer --read-only
# Read-only preset
new-agent data-engineer --no-write
# Can read+edit+bash, can't write
```

This creates `~/.config/opencode/agents/my-role.md` from the template.

---

## Skills

Skills are auto-loaded by keyword match. The shipped skills are:

| Skill | Loads on keywords like... |
|-------|---------------------------|
| `rest-api-design` | REST, API, endpoint, HTTP, status code, pagination |
| `database-patterns` | database, schema, migration, index, query, SQL |
| `react-patterns` | React, JSX, component, hook, state, props |
| `i18n-patterns` | i18n, locale, translation, ICU, intl |
| `multi-tenant-patterns` | tenant, multi-tenant, isolation, scoping |

Create a new skill:

```sh
new-skill my-pattern-name "Description"
# Creates:  ~/.agents/skills/my-pattern-name/SKILL.md
# Updates:  ~/.config/opencode/skills-lock.json
```

### skills-lock.json

Versioned lockfile that tracks:
- Each skill's source (local / github / community)
- SHA256 content hash (for tamper detection)
- Install timestamp
- License

```json
{
  "version": 1,
  "skills": {
    "my-skill": {
      "source": "local",
      "computedHash": "abc123...",
      "installedAt": "2026-06-05T...",
      "version": "0.1.0",
      "license": "MIT"
    }
  }
}
```

---

## Hierarchical skills

Skills can be nested (parent + children) for tool-specific sub-skills:

```
~/.agents/skills/
├── agent-browser/                    # parent (loaded first, hidden: true)
│   ├── SKILL.md                      #   discovery stub
│   ├── core/                         #   child: browser basics
│   ├── slack/                        #   child: Slack-specific
│   └── electron/                     #   child: Electron apps
└── rest-api-design/                  # leaf skill
    └── SKILL.md
```

Create with:

```sh
new-skill agent-browser/core
new-skill agent-browser/slack
```

The parent should be marked `hidden: true` in its frontmatter so the
agent only loads the relevant child.

---

## Slash commands

| Command   | What it does                          |
|-----------|---------------------------------------|
| `/commit` | Commit staged changes with AI message |
| `/explain`| Explain selected code                 |
| `/review` | Review the current diff               |
| `/test`   | Generate tests for selected code      |
| `/plan`   | Switch to plan agent                  |
| `/build`  | Switch to build agent                 |
| `/refactor` | Use the refactor skill               |
| `/debug`  | Use the debug skill                   |

Add a new command: drop a `.md` file in `~/.config/opencode/commands/`
with frontmatter:

```md
---
name: my-command
description: What it does
agent: plan    # optional: which agent to use
skill: refactor  # optional: which skill to use
---

# /my-command — short description

[template with {selection} or {file} placeholders]
```

---

## MCP servers

The config wires up three MCP servers:

| Server       | Purpose                              | Default  |
|--------------|--------------------------------------|----------|
| `filesystem` | Local file ops (fallback for tools)  | enabled  |
| `github`     | `gh` CLI as MCP (issues, PRs, repos) | enabled  |

To add more, edit `~/.config/opencode/config.json` → `mcp` section.

---

## Per-project overrides

For project-specific OpenCode config, add `AGENTS.md` to the project
root. OpenCode reads it in addition to the global one.

Example project `AGENTS.md`:
```md
# Project: my-api

## Stack
- Python 3.12, FastAPI, SQLModel, Postgres
- uv for deps
- pytest for tests

## Conventions
- We use `snake_case` for everything (no kebab-case file names)
- All API routes go in `app/routers/`
- All DB models go in `app/models/`

## Project skills
- This project uses: `app/.opencode/skills/my-domain/SKILL.md`
```

---

## Model selection

Default model: `anthropic/claude-sonnet-4.5` (good speed/quality balance).
`frontend-senior` uses `claude-opus-4.5` (higher quality, slower).

Override per-session with `opencode --model <model>` or in the
project's `AGENTS.md`.

---

## OpenCode vs Claude Code vs Aider

| Tool            | Strengths                                | Best for                        |
|-----------------|------------------------------------------|---------------------------------|
| **OpenCode**    | Open source, fast, agents, plan/build    | Daily driver, this setup        |
| **Claude Code** | Tight Claude integration, agentic        | Big refactors, doc work         |
| **Aider**       | Git-native, pair-programming feel        | Code generation, quick edits    |
| **Codex CLI**   | GPT-5, simple                            | Throwaway scripts               |
| **Continue**    | VS Code native                           | In-IDE completion               |

We use OpenCode as the daily driver. The dotfiles are model-agnostic —
swap in any model by editing `config.json`.

---

## Gas town integration

OpenCode is the **host** that gas-town polecats (worker agents) use.
See `~/dotfiles/docs/gas-town-integration.md` for the full picture.

Quick reference:

```sh
# Mayor (you, talking to the global coordinator)
gt prime                    # re-inject Mayor context

# Polecat (a worker, ephemeral session, persistent identity)
gt sling <bead-id> <rig>    # assign work to a polecat
gt nudge <polecat> "msg"    # send a message

# Beads (issue tracker)
bd ready                    # unblocked work
bd create --title="..."     # new bead
bd close <id>               # mark done
bv --robot-triage           # ranked picks (NEVER bare `bv`)

# Town
gt status                   # dashboard
gt doctor                   # health check
```

---

## Resources

- OpenCode docs: https://opencode.ai/docs
- AGENTS.md spec: https://opencode.ai/docs/agents
- Gas Town: https://github.com/gastownhall/gastown
- Beads: https://github.com/steveyegge/beads
- This dotfiles repo: `~/dotfiles/docs/opencode-guide.md`
- Gas town integration: `~/dotfiles/docs/gas-town-integration.md`
