---
name: gastown-workflow
description: Gas Town multi-agent orchestration workflow — beads lifecycle, convoy management, polecat coordination, rig setup, and mayor operations
license: MIT
---

# Gas Town Workflow

Patterns for orchestrating multi-agent workflows with Gas Town (`gt`)
and Beads (`bd`).

## Beads lifecycle

```sh
# 1. Create a bead for each unit of work
bd create --title="Add auth middleware" --type=task --priority=1
bd create --title="Fix login timeout" --type=bug --priority=0
bd create --title="Write deploy docs" --type=task --priority=2

# 2. Link dependencies
bd dep add bead-b bead-a      # b depends on a

# 3. Triage (robot mode)
bv --robot-triage             # ranked picks + blockers
bv --robot-next               # single top pick + claim

# 4. Work through them
bd update bead-a --status=in_progress
bd close bead-a               # done

# 5. Sync
bd sync
```

## Convoy orchestration

```sh
# Batch related beads into a convoy
gt convoy create "Phase 2: Payments" payment-schema payment-api payment-ui

# Check status
gt convoy status hq-cv-xxx

# Sling to a rig's polecat
gt sling payment-schema myproject --polecat=backend
gt sling payment-api myproject --polecat=backend
gt sling payment-ui myproject --polecat=frontend
```

## Polecat workflow

```sh
# At session start
gt prime                          # inject full context
bd sync                           # pull latest bead state
bd ready                           # what's ready to work?

# During work
bd start <bead-id>                # claim and start
bd update <bead-id> --status=in_progress

# At session end
bd close <bead-id>                # mark complete
bd sync                           # push changes
```

## Rig setup

```sh
# Create a new rig for a project
gt rig new myproject https://github.com/org/myproject.git

# Verify
gt status
```

## Mayor operations

- `gt status` — full dashboard (rigs, beads, convoys, polecats)
- `gt prime` — re-inject context after compaction
- `gt nudge <polecat> "message"` — instruct a worker
- `gt doctor` — health check
- `bd sync` — always sync before/after sessions

## Anti-patterns

- ❌ Running `bv` without `--robot-*` flag (interactive mode breaks automation)
- ❌ Skipping `gt prime` at session start
- ❌ Skipping `bd sync` at session end
- ❌ Ad-hoc slinging without a convoy for related work
- ❌ Ignoring blocker chains — resolve deps before slinging
- ❌ Assigning beads without clear acceptance criteria

## See also

- [addyosmani/agent-skills: planning-and-task-breakdown](../.agents/skills/planning-and-task-breakdown/SKILL.md)
- [addyosmani/agent-skills: git-workflow-and-versioning](../.agents/skills/git-workflow-and-versioning/SKILL.md)
