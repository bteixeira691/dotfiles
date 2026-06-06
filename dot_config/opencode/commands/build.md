---
name: build
description: Switch to build mode (active coding)
agent: build
---

# /build — switch to build agent

Switch the conversation to the `build` agent. Use this when you're
ready to actually make code changes.

## Behavior

When the user invokes `/build`:
1. Switch to the `build` agent.
2. The build agent has full read/write/execute permissions.
3. Stay in build mode until the user explicitly switches (e.g. `/plan`).

## Permissions (in build mode)

- ✅ Edit any file in the project
- ✅ Run linters, formatters, tests
- ✅ Run `git` read + write (local)
- ✅ Install project-local deps
- ⚠️  Ask before: pushing, deleting files, migrations
- ❌ Never: force-push, commit secrets, modify dotfiles
