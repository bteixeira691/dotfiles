# AGENTS.md — OpenCode global instructions
# This file is read by OpenCode on every invocation (system-level).
# Project-level instructions can extend or override in AGENTS.md at project root.
# Compatible with: OpenCode, Claude Code, gas-town polecats, OpenAI Codex CLI.

## Coding principles

1. **Read before writing.** Always read the file you're about to edit
   (and surrounding context) before suggesting changes. Use file
   search tools liberally.

2. **Prefer the project's existing patterns.** Match the surrounding
   code style, naming, and library choices. If a project uses Tab for
   indentation, use Tab. If it uses spaces, use spaces. Don't introduce
   a new style.

3. **Don't add comments unless asked.** Self-documenting code is the
   goal. If a comment is necessary, explain *why* not *what*.

4. **Test what you change.** If a project has tests, run them after
   non-trivial changes. If there are no tests, suggest a basic test
   for new behavior.

5. **Security first.** Never log or commit secrets. Never disable
   security checks without flagging it. Use least-privilege defaults.

6. **Bias toward minimal diffs.** Smallest change that solves the
   problem. Don't refactor adjacent code unless asked.

7. **Cite file:line.** When referencing code, use `path/to/file.ext:line`
   format so the user can navigate.

## Project conventions

- **Python:** Use `uv` for envs, `ruff` for format/lint, `pytest` for tests.
- **TypeScript:** Prefer Bun for new projects, npm for existing.
  Use `prettier` + `eslint`.
- **Rust:** `cargo fmt` + `cargo clippy` + `cargo test`.
- **Dotfiles:** This repo itself — use `chezmoi` and follow existing
  patterns.
- **Zsh:** Tools in `dot_config/zsh/*.zsh`, loaded in zshrc in correct order.
- **Gas town (gastownhall):** Polecats inherit this AGENTS.md. Mayor
  is the global coordinator. See `~/dotfiles/docs/gas-town-integration.md`.

## Tool usage

- **Search:** `rg` (ripgrep) with `.gitignore` respect.
- **Edit:** Use `Edit` tool with the exact `oldString` from a prior read.
- **Bash:** Explain non-trivial commands in 5-10 words.
- **Files:** Prefer `Read` over `cat`. Prefer `Glob` over `find`.
- **LSP:** Rely on LSP for symbols, references, definitions.
- **Beads (`bd`):** Use for issue tracking in gas-town projects.

## Subagents (when to use)

- **`build`** (default for actual work) — make code changes
- **`plan`** (read-only) — design, refactor strategy, debugging analysis
- **`backend-engineer`** — API/business logic/data modeling
- **`frontend-engineer`** — React features, pages, components (mid-level)
- **`frontend-senior`** — design systems, large refactors, accessibility, perf
- **`qa-engineer`** — tests, test strategy, flaky test debugging
- **`devops-engineer`** — Docker, CI/CD, deployment, monitoring
- **`code-reviewer`** — read-only PR/branch review
- **`product-manager`** — specs, user stories, edge cases, PR descriptions
- **`marketing`** — landing page copy, email campaigns, SEO, growth

## Skills (auto-loaded by keyword match)

Generic skills in `~/.config/opencode/skills/`:
- `rest-api-design` — endpoint shape, status codes, errors, pagination
- `database-patterns` — schema, migrations, indexes, queries, transactions
- `react-patterns` — composition, state, forms, performance, a11y
- `i18n-patterns` — strings, ICU, locale, formatting, RTL
- `multi-tenant-patterns` — tenant scoping, query filters, JWT, isolation

Project-level skills in `<project>/.opencode/skills/` override these
for project-specific knowledge.

## Forbidden actions

- ❌ Don't `rm -rf` outside the project root.
- ❌ Don't `sudo` without explicit user approval.
- ❌ Don't `git push --force` to main/master.
- ❌ Don't commit secrets, `.env`, or credential files.
- ❌ Don't install global packages without asking.
- ❌ Don't add `console.log` / `print()` debug statements.
- ❌ Don't change git config globally.

## Confirmation policy

Ask before:
- Running commands that modify state outside the project (`pip install`, `brew install`).
- Creating or deleting files outside the project.
- Sending network requests beyond read-only APIs.
- Running tests that take >30s (offer to background it).
- Any `gt sling` or `bd` operation that affects gas-town state.

## Gas town etiquette (when running as a polecat)

- **You're a polecat.** Your work persists via git hooks, not your local clone.
- **Always `gt prime` at session start** to inject full context.
- **Use `bd` for issues, not TODOs.** Update status: `in_progress` → `closed`.
- **Run `bd sync` at session end.**
- **Don't touch other polecats' hooks.** Each hook is one polecat's worktree.
- **Use the rig's `.opencode/AGENTS.md`** for project-specific instructions.
