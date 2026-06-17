---
name: dotfiles
description: Work on this dotfiles repo
keywords: [dotfiles, chezmoi, nvim, zsh, tmux, starship, ghostty, lazyvim]
---

# Dotfiles skill

This is the dotfiles repo. When working on it, follow these conventions.

## Layout

```
~/dotfiles/
├── README.md                          # step-by-step guide
├── .chezmoiroot
├── .chezmoiignore.tmpl
├── .chezmoi/chezmoi.toml.tmpl
├── Brewfile                           # macOS packages
├── packages/
│   ├── manifest.yaml                  # single source of truth for all tools
│   ├── arch.txt                       # Arch package list (reference)
│   └── fedora.txt                     # Fedora package list (reference)
├── justfile                           # local task runner
├── dot_zshrc / dot_zshenv             # ~ (chezmoi strips dot_ prefix)
├── dot_gitconfig.tmpl                 # git config (with includeIf)
├── dot_tmux.conf                      # tmux
├── dot_config/
│   ├── atuin/config.toml
│   ├── direnv/direnv.toml
│   ├── uv/uv.toml
│   ├── bunfig.toml
│   ├── act/actrc
│   ├── ghostty/config
│   ├── nvim/                          # LazyVim config
│   ├── starship.toml
│   ├── btop/btop.conf
│   ├── lazygit/config.yml
│   ├── delta/config.toml
│   ├── yazi/{yazi.toml,theme.toml}
│   ├── omp/omp.json
│   ├── opencode/                      # AI agent config
│   │   ├── AGENTS.md
│   │   ├── config.json
│   │   ├── agents/{build,plan,...}.md
│   │   └── skills/
│   └── zsh/{aliases,exports,vi-mode,tools,prompt,fzf-tab}.zsh
├── templates/
│   ├── devcontainer.json.tmpl
│   ├── Dockerfile.tmpl
│   └── post-create.sh.tmpl
├── scripts/
│   ├── bootstrap.sh                   # main entry point (2-3 command setup)
│   ├── lib.sh                         # shared functions (detect OS, install gastown, etc.)
│   ├── install-{arch,fedora,debian,mac}.sh   # OS-specific installers
│   ├── install-windows.ps1
│   └── post-install.sh                # hooks after chezmoi apply
└── docs/
    ├── SECRETS.md
    ├── gitconfig.local.example
    ├── python-uv-migration.md
    ├── direnv-usage.md
    ├── devcontainer-guide.md
    ├── justfile-recipes.md
    ├── when-to-use-bun.md
    └── act-usage.md
```

## Conventions

- **File naming:** `dot_X` becomes `~/.X` (chezmoi prefix).
- **Templating:** use `.tmpl` suffix for files with `{{ }}` template variables.
- **Comments:** minimal. Code is self-documenting.
- **Backups:** chezmoi backs up existing files to `~/.local/share/chezmoi/backups/`.
- **Validation:** every change must pass:
  - `bash -n` for shell scripts
  - `luac -p` for Lua files
  - JSON parser for .json
  - YAML parser for .yml
  - TOML parser for .toml

## When adding a new tool

1. **Add config** in `dot_config/<toolname>/`.
2. **Add zsh integration** in `dot_config/zsh/` (if shell-using).
3. **Update aliases** in `dot_config/zsh/aliases.zsh`.
4. **Update manifest:** add the tool to `packages/manifest.yaml` with OS-specific package names.
5. **Update install scripts** — add the package to the relevant `install-{arch,fedora,debian,mac}.sh` (or the PowerShell script for Windows). If the install step is common across platforms, add a function to `scripts/lib.sh` instead.
6. **Add post-install hook** in `scripts/post-install.sh` (e.g. plugin clone).
7. **Write a doc** in `docs/<tool>.md` if non-trivial.
8. **Update README** with the new tool in the feature list.

## When adding a shared install function

If a tool is installed the same way on all platforms (e.g. `go install`, `cargo install`, `curl ... | sh`), add it to `scripts/lib.sh` instead of repeating it in every `install-*.sh` script. This keeps the platform installers focused on package manager commands.

## nvim config specifics

- **Plugins:** use `lazy.nvim` + `LazyVim` (LazyVim is the base).
- **Extras:** enable in `lazyvim.json` only (don't add the plugin directly).
- **Custom plugins:** add to `lua/plugins/<name>.lua` as a `return { ... }` table.
- **Keymaps:** add to `lua/config/keymaps.lua` (or per-plugin).
- **Style:** 2 spaces, LF, LF only. Use stylua.toml.
- **Theme:** Tokyo Night (with Aether swap path in `lua/plugins/theme.lua`).

## Shell config specifics

- **Load order (in zshrc):**
  1. compinit
  2. Source 5 user config files
  3. fzf-tab plugin (before fzf keybindings)
  4. fzf keybindings
  5. direnv hook
  6. zoxide init
  7. atuin init (LAST)
- **Plugins sourced in tools.zsh** (last): zsh-syntax-highlighting must be last.

## Common gotchas

- **Ghostty** doesn't use terminfo — config palette in `dot_config/ghostty/config`.
- **Tmux** prefix is `Ctrl-a` (screen-like).
- **Git** per-machine overrides: edit `~/.gitconfig.local`, never the dotfiles.
- **Atuin** must load LAST in zsh to override Ctrl+R.
- **direnv** needs `direnv allow` in any project with `.envrc`.

## When the user says "this broke X"

1. `chezmoi diff` to see what changed.
2. `chezmoi apply --force` to re-apply.
3. `chezmoi managed` to see what's tracked.
4. Check `~/.local/share/chezmoi/backups/` for the previous version.
