---
name: plan
description: Switch to plan mode (read-only analysis)
agent: plan
---

# /plan — switch to plan agent

Switch the conversation to the read-only `plan` agent. Use this when
you want analysis and proposals without code changes.

## Behavior

When the user invokes `/plan`:
1. Switch to the `plan` agent.
2. Continue the conversation in that mode.
3. Stay in plan mode until the user explicitly switches (e.g. `/build`
   or pressing `shift+tab` to exit plan mode).

## When to suggest /plan

Suggest `/plan` when the user is:
- Asking "how should I..."
- Asking "what's the best way to..."
- Stuck on a design decision
- Wanting to understand a problem before changing code
- Reviewing an approach for a non-trivial change
