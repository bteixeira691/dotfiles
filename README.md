# Dotfiles

Cross-platform dev environment for **Linux (Arch/Fedora/Debian)**, **macOS**, and **WSL2**.
Managed by [chezmoi](https://chezmoi.io) with [age](https://age-encryption.org) for secrets.

---

## Quickstart (new machine)

Three commands from a blank machine to a fully configured environment:

```bash
# 1. Clone the repo
git clone https://github.com/YOU/dotfiles.git ~/dotfiles

# 2. Run bootstrap — detects OS, installs packages + configs
bash ~/dotfiles/scripts/bootstrap.sh

# 3. Restart your shell
exec zsh
```

That's it. The bootstrap script handles everything:
- Detects your OS (Arch/Fedora/Debian/macOS/WSL/Windows)
- Installs **chezmoi** + **age** if missing
- Installs all 50+ CLI tools via the OS-specific package manager
- Runs `chezmoi apply` to symlink all configs (backs up existing files)
- Sets up zsh plugins, tmux plugin manager, git stubs
- Installs gas town (`gt`, `bd`, `bv`) via `go install`

**After bootstrap, open nvim once** to let LazyVim install plugins:
```bash
nvim
```

**Then set your git identity:**
```bash
nvim ~/.gitconfig.local      # add your name and email
nvim ~/.gitconfig.work        # work identity (if applicable)
nvim ~/.gitconfig.personal    # personal identity (if applicable)
```

---

## What's included

### Editor
- **Neovim** with **LazyVim** distribution, Tokyo Night theme
- **LSPs:** pyright, lua_ls, rust_analyzer, csharp_ls, sqls
- **Tools:** conform, nvim-lint, nvim-dap, neotest, gitsigns

### Shell (zsh)
- **zsh-vi-mode** with vim cursor shapes
- **Starship** prompt (Oh My Posh on Windows)
- **Atuin** for encrypted, searchable shell history (replaces Ctrl+R)
- **fzf-tab** for fzf-powered tab completion
- **direnv** for per-directory environments
- **fzf, zoxide, autosuggestions, syntax-highlighting**

### Terminal & multiplexer
- **Ghostty** with cross-platform keybinds and Tokyo Night palette
- **tmux** with `Ctrl-a` prefix, vim-style copy mode, tpm plugin manager

### Modern CLI tools (50+)
| Category | Tools |
|---|---|
| Core | fzf, ripgrep, fd, bat, eza, zoxide, btop, yazi |
| Git | lazygit, gitui, delta, git-absorb, gitleaks |
| Shell | starship, atuin, direnv, uv, mise |
| Languages | node, python, go, rust, dotnet, bun |
| Docker | lazydocker, dive, ctop, bandwhich |
| Extras | hyperfine, watchexec, mprocs, xh, miller, sd, trash-cli |

See [`packages/manifest.yaml`](packages/manifest.yaml) for the full list with OS-specific package names.

### AI agent & gas town
- **OpenCode** — daily-driver AI agent with 10 subagents and 10 skills
- **Gas town** — multi-agent orchestrator (`gt`, `bd`, `bv`)

---

## Daily workflow

```bash
# Edit a dotfile → chezmoi picks up the change
nvim ~/.zshrc
chezmoi diff           # see what would change
chezmoi re-add         # pull the change into the source repo
chezmoi git -- push    # commit + push

# Verify everything is set up correctly
~/dotfiles/scripts/verify.sh

# Add a new tool
# 1. Install it: add to packages/manifest.yaml + OS install script
# 2. Add config: dot_config/<toolname>/
# 3. Add alias:  dot_config/zsh/aliases.zsh
```

---

## Step-by-step guide (full detail)

### Prerequisites

Your machine needs **git** and **curl**. That's it — bootstrap installs everything else.

| OS | git comes with |
|---|---|
| Arch | `sudo pacman -S git curl` |
| Fedora | `sudo dnf install git curl` |
| Debian/Ubuntu | `sudo apt-get install git curl` |
| macOS | Xcode Command Line Tools (`xcode-select --install`) |
| WSL | `sudo apt-get install git curl` |
| Windows (native) | winget or Git for Windows |

### Bootstrap walkthrough

When you run `bootstrap.sh`, here's exactly what happens:

| Step | Action |
|---|---|
| 1 | Detects OS (arch/fedora/debian/macos/wsl/windows) |
| 2 | Installs **chezmoi** (if missing) |
| 3 | Installs **age** for encryption (if missing) |
| 4 | Installs all packages via OS-specific installer (pacman/dnf/apt/brew/winget) |
| 5 | Runs `go install` for gas town (`gt`, `bd`, `bv`) |
| 6 | Initializes chezmoi source (first time only) |
| 7 | Runs `chezmoi apply --force` — symlinks all dotfiles, backs up conflicts |
| 8 | Runs post-install: git stubs, tpm, zsh plugins, skills-lock hashes, scaffolders |

### After bootstrap

```bash
# 1. Let LazyVim install plugins (first nvim launch)
nvim

# 2. Edit git identity (these files are NOT in dotfiles — machine-specific)
nano ~/.gitconfig.local       # name + email
nano ~/.gitconfig.work        # work identity
nano ~/.gitconfig.personal    # personal identity

# 3. (Optional) Atuin cloud sync
atuin register -u <username> -e <email>
atuin sync

# 4. (Optional) Initialize gas town
gt town new

# 5. (Optional) Trust mise in projects
cd ~/work/myproject && mise trust && mise install
```

---

## Managing dotfiles (chezmoi workflow)

```bash
# See what's managed
chezmoi managed

# See pending changes
chezmoi diff

# Pull an edited file back into the source repo
chezmoi re-add ~/.zshrc

# Edit a managed file (opens in $EDITOR with chezmoi path)
chezmoi edit ~/.zshrc

# See the source path of a managed file
chezmoi source-path ~/.zshrc

# Commit and push
chezmoi git -- add -A
chezmoi git -- commit -m "update zsh config"
chezmoi git -- push
```

### Adding a new tool to the dotfiles

1. **Install the tool** — add it to `packages/manifest.yaml` and the relevant `install-*.sh` scripts
2. **Add config file** — create `dot_config/<toolname>/<config>` (chezmoi maps this to `~/.config/<toolname>/<config>`)
3. **Add shell integration** — add aliases to `dot_config/zsh/aliases.zsh`
4. **Run `chezmoi re-add`** to pull it into the source state
5. **Commit and push**

---

## Per-OS behavior

| Area | Linux | macOS | WSL | Windows native |
|---|---|---|---|---|
| Package manager | pacman/dnf/apt | Homebrew | apt | winget |
| Prompt | Starship | Starship | Starship | Oh My Posh |
| Fonts | JetBrains Mono Nerd | JetBrains Mono Nerd | JetBrains Mono Nerd | JetBrains Mono Nerd |
| Tmux clipboard | xclip | pbcopy | clip.exe | clip.exe |
| Ghostty | async-backend = epoll | macos-titlebar-style | async-backend | N/A |
| Terminal | Ghostty/Kitty | Ghostty/Kitty | Windows Terminal | Ghostty |
| Gas town | go install | go install | go install (in WSL) | Not supported |

---

## Structure

```
dotfiles/
├── README.md                       ← this file
├── .chezmoi/                       ← chezmoi config
├── dot_gitconfig.tmpl              ← ~/.gitconfig (template)
├── dot_zshenv                      ← ~/.zshenv
├── dot_tmux.conf                   ← ~/.tmux.conf
├── dot_config/                     ← ~/.config/ (chezmoi maps dot_ → .)
│   ├── nvim/                       ← LazyVim config
│   ├── zsh/                        ← 6 user config files (aliases, exports, etc.)
│   ├── ghostty/config
│   ├── starship.toml
│   ├── opencode/                   ← OpenCode AI agent config
│   └── ... (atuin, yazi, btop, lazygit, tmux, etc.)
├── packages/
│   ├── manifest.yaml               ← single tool manifest (all tools, per OS)
│   ├── arch.txt                    ← Arch package list (reference)
│   └── fedora.txt                  ← Fedora package list (reference)
├── Brewfile                        ← macOS packages
├── scripts/
│   ├── bootstrap.sh                ← main entry point (2-3 command setup)
│   ├── lib.sh                      ← shared functions (detect OS, install gas town, etc.)
│   ├── install-{arch,fedora,debian,mac}.sh   ← OS-specific installers
│   ├── install-windows.ps1         ← Windows (native) installer
│   └── post-install.sh             ← hooks after chezmoi apply
├── templates/                      ← copy-once project templates
├── docs/                           ← documentation
└── justfile                        ← task runner template
```

---

## Reference

### Zsh load order (matters!)

```dot_zshrc (zshrc):
1.  compinit                       (with daily cache)
2.  Source 5 user config files     (aliases, exports, vi-mode, tools, prompt)
3.  fzf-tab plugin                 (after compinit, before fzf keybindings)
4.  fzf-tab.zsh UI config
5.  fzf keybindings
6.  direnv hook
7.  zoxide init
8.  Atuin init                     (MUST be last — overrides Ctrl+R)
9.  Local overrides                (~/.zshrc.local if present)
```

### Gas town quick reference

```sh
gt status                          # dashboard
gt convoy create "Feature X" gt-abc gt-def
gt sling <bead-id> <rig>           # assign work to a polecat
gt prime                           # re-inject context after compaction
bd ready                           # unblocked work
bd create --title="..." --type=task --priority=2
bd sync                            # git sync at session end
```

See `docs/gas-town-integration.md` for the full picture.

### Secrets

Private files live in `private_*` and are encrypted with age:

```bash
chezmoi age encrypt --output ~/dotfiles/private_dot_secrets/foo.txt.age
```

The age key is stored at `~/.config/chezmoi/key.txt`. **Back this up.**
See `docs/SECRETS.md`.

### Validation

```bash
~/dotfiles/scripts/verify.sh       # checks all tools, files, and configs
```

---

## License

MIT.
