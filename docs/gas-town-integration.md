# Gas Town integration

[Gas Town](https://github.com/gastownhall/gastown) is a multi-agent
orchestrator by Steve Yegge that lets you coordinate 20-30 AI agents
(Claude Code, OpenCode, Codex, Copilot) working on different tasks
with persistent work state.

This dotfiles repo provides the **host environment** for gas town — the
tools, configs, and skills the agents (Mayor, Polecats, Crew) use.

---

## What gas town provides

| Concept | What it is |
|---------|------------|
| **Mayor** | Singleton global AI coordinator (you talk to this) |
| **Town** | Your workspace directory, e.g. `~/gt/` |
| **Rig** | A project container (wraps a git repo) |
| **Crew** | Your persistent personal workspace inside a rig |
| **Polecat** | Worker agents — persistent identity, ephemeral sessions |
| **Deacon** | Background supervisor / watchdog |
| **Witness** | Per-rig polecat lifecycle manager |
| **Refinery** | Per-rig merge queue processor |
| **Hook** | Git worktree-based persistent storage |
| **Bead** (`bd`) | Git-backed issue tracker (work item) |
| **Convoy** (`gt convoy`) | A batched group of beads being worked on |
| **Molecule** | Multi-step recipe (DAG) of bead operations |

See `~/.local/share/gt/INSTALLING.md` (or
https://github.com/gastownhall/gastown/blob/main/docs/INSTALLING.md)
for the official install guide.

---

## What this dotfiles repo provides

The dotfiles ship:

1. **All gas town dependencies** in `Brewfile` / `packages/*.txt`:
   - `go` (gas town is Go)
   - `dolt` (Beeds' SQL backend — git for data)
   - `gastown` (the `gt` CLI itself, via brew)

2. **A pre-tuned OpenCode config** with:
   - `~/.config/opencode/AGENTS.md` (global system instructions)
   - `~/.config/opencode/agents/*.md` — 8 subagent role definitions
   - `~/.config/opencode/skills/*.md` — generic starter skills
   - `~/.config/opencode/skills-lock.json` — versioned skill lockfile
   - `~/.config/opencode/themes/tokyo-night.json`

3. **Skill/agent scaffolders** so you can create new ones in seconds:
   ```sh
   new-skill booking-domain      # creates ~/.agents/skills/booking-domain/SKILL.md
   new-agent backend-engineer    # creates ~/.opencode/agents/backend-engineer.md
   ```

4. **Zsh aliases** for fast gas town workflow:
   ```sh
   gt        # gas town CLI
   bd        # beads issue tracker
   bv        # beads graph triage (use --robot-* flags in scripts)
   gtr       # gt rig <name>         # create a new rig
   gtn       # gt nudge              # send a message to a polecat
   gts       # gt status             # dashboard
   ```

---

## Dotfiles ↔ Gas Town boundary

| Layer | Owned by |
|-------|----------|
| Shell, terminal, git, CLIs, nvim, opencode base config | **dotfiles** |
| Subagent role definitions (`.opencode/agents/`) | **dotfiles** (generic roles) — project overlays for project-specific roles |
| Skills (`.opencode/skills/`, `.agents/skills/`) | **dotfiles** (generic skills) + per-project skills in project repo |
| Beads DB (`.beads/`), rig state (`.gt/`) | **per-project** (committed to project repo) |
| `~/gt/` (town), hooks, worktrees | **gas town** |
| Mayor's context, Polecat sessions | **gas town runtime** |
| Persistent memory (your `brain/`) | **separate repo** (Obsidian vault) |

The dotfiles give you the platform. Gas town gives you the orchestration.
Your project repo gives you the per-project beads + skills.

---

## Recommended layout

```
~/gt/                           # gas town town directory
├── mayor/                      # Mayor agent context (singleton)
├── <project-a>/                # rig for project A
│   ├── .beads/                 # beads issue tracker (git-backed)
│   ├── .gt/                    # rig config
│   ├── crew/                   # your persistent workspace
│   ├── polecats/               # ephemeral workers (git worktrees)
│   └── hooks/                  # persistent state for polecats
└── <project-b>/                # rig for project B
    └── ...

~/dotfiles/                     # this repo
├── dot_config/opencode/        # OpenCode config (used by Mayor + polecats)
└── ...

~/brain/                        # Obsidian vault (persistent agent memory)
├── AGENTS.md
├── index.md
└── wiki/<project>/...
```

---

## Per-project OpenCode overlay

Gas town's polecats inherit your `~/.config/opencode/` config, but each
rig can override with a project-level `.opencode/` directory in the
project repo:

```
~/gt/myproject/
└── .opencode/
    ├── AGENTS.md               # project-specific instructions
    ├── agents/                 # project-specific subagents
    │   └── myproject-backend.md
    └── skills/                 # project-specific skills
        └── myproject-domain/
            └── SKILL.md
```

This is the **dotfiles skill** pattern: generic skills from dotfiles,
domain-specific skills from the project.

---

## Beads quick reference

```sh
# Issue CRUD
bd ready                           # unblocked, ready to work
bd list --status=open
bd show <id>
bd create --title="..." --type=task --priority=2
bd update <id> --status=in_progress
bd close <id>
bd dep add <a> <b>                 # a depends on b
bd sync                            # git sync

# Graph triage (NEVER run bare `bv` — it's interactive)
bv --robot-triage                  # ranked picks, blockers, health
bv --robot-next                    # single top pick + claim cmd
bv --robot-plan                    # parallel execution tracks
bv --robot-alerts                  # stale issues, cascades
bv --robot-insights                # full graph metrics
```

---

## Gas town quick reference

```sh
# Setup
gt install                         # one-time install of beads + dolt
gt town new                        # create a new town (~/gt by default)
gt rig new <name> <git-url>        # add a rig (project)

# Day-to-day
gt status                          # dashboard
gt convoy create "Feature X" gt-abc gt-def
gt convoy status hq-cv-abc
gt sling <bead> <rig>              # assign work to a rig's polecat
gt nudge <polecat> "msg"           # send a message to a polecat
gt prime                           # re-inject Mayor context after compaction
gt doctor                          # health check
gt --help                          # full help
```

---

## When to add a project-level skill

A skill belongs in the project (not dotfiles) if:
- It references project-specific code (`Features/AuthFeature/`, `MyDbContext`)
- It uses project-specific conventions (e.g. "all entities have `BusinessId`")
- It's tied to the project's domain (booking, billing, etc.)

A skill belongs in dotfiles if:
- It's a general pattern (e.g. "REST API error handling", "React form patterns")
- It's reusable across projects
- It teaches a language/library convention

The line is: **dotfiles = language/framework patterns, project = domain knowledge**.

---

## Skill scaffolder

Use `new-skill` to create a new skill in seconds:

```sh
new-skill my-skill-name
# Creates:
#   ~/.agents/skills/my-skill-name/SKILL.md
#   Updates ~/.config/opencode/skills-lock.json
```

Use `new-agent` to create a new subagent:

```sh
new-agent my-role
# Creates:
#   ~/.opencode/agents/my-role.md
```

Both templates match the format used by the gas town community and
Steve Yegge's `pbakaus/impeccable` etc.

---

## Common gotchas

- **Don't commit `~/gt/`** to your dotfiles — it's machine state, not config.
- **Beads DB is per-project** — `.beads/` lives in the project repo, not in dotfiles.
- **Mayor context is large** — `gt prime` re-injects it after compaction. Always run it on a new session.
- **Polecats are ephemeral** — their code lives in git hooks, not in your local clone.
- **The `gt` command conflicts with `git`'s `gt` shorthand** — if you have `git config --global alias.gt ...`, drop it.

---

## Resources

- Gas Town: https://github.com/gastownhall/gastown
- Beads: https://github.com/steveyegge/beads
- Steve Yegge's blog: https://steve-yegge.medium.com
- This dotfiles repo: `~/dotfiles/docs/gas-town-integration.md`
