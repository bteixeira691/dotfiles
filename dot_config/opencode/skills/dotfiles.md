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
├── README.md
├── .chezmoiroot
├── .chezmoiignore.tmpl
├── .chezmoi/chezmoi.toml.tmpl
├── Brewfile                          # macOS packages
├── packages/{arch,fedora}.txt        # Linux packages
├── justfile                          # local task runner
├── dot_zshrc / dot_zshenv            # ~ (chezmoi strips dot_ prefix)
├── dot_gitconfig.tmpl                # git config (with includeIf)
├── dot_tmux.conf                     # tmux
├── dot_config/
│   ├── atuin/config.toml             # Phase 1
│   ├── direnv/direnv.toml
│   ├── uv/uv.toml
│   ├── bunfig.toml
│   ├── act/actrc
│   ├── ghostty/config
│   ├── nvim/                          # LazyVim config
│   ├── starship.toml
│   ├── btop/btop.conf
│   ├── lazygit/config.yml
│   ├── delta/config.yml
│   ├── yazi/{yazi.toml,theme.toml}
│   ├── omp/omp.json
│   ├── opencode/                      # Phase 3
│   │   ├── AGENTS.md
│   │   ├── config.json
│   │   ├── agents/{build,plan}.md
│   │   └── skills/
│   └── zsh/{aliases,exports,vi-mode,tools,prompt,fzf-tab}.zsh
├── templates/                        # Phase 2
│   ├── devcontainer.json.tmpl
│   ├── Dockerfile.tmpl
│   └── post-create.sh.tmpl
├── scripts/
│   ├── bootstrap.sh                  # main entry
│   ├── install-{arch,fedora,debian,mac}.sh
│   ├── install-windows.ps1
│   └── post-install.sh
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
4. **Add to package lists:** `Brewfile`, `packages/arch.txt`, `packages/fedora.txt`.
5. **Update install scripts** if any special install steps needed.
6. **Add post-install hook** in `scripts/post-install.sh` (e.g. plugin clone).
7. **Write a doc** in `docs/<tool>.md` if non-trivial.
8. **Update README** with the new tool in the feature list.

## When adding a new install phase

- Don't break existing installers.
- Add a feature flag (env var) for opt-in.
- Update bootstrap.sh with a "phase X" log header.

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
