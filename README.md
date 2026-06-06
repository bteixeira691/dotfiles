# Dotfiles

Cross-platform dev environment for **Linux (Omarchy / Fedora)**, **macOS**, and **WSL2**.
Managed by [chezmoi](https://chezmoi.io) with [age](https://age-encryption.org) for secrets.
Designed to host [gas town](https://github.com/gastownhall/gastown) for multi-agent orchestration.

---

## What's included

### Editor
- **Neovim** with **LazyVim** distribution
- **Theme:** Tokyo Night (one-file swap path back to Aether)
- **LSPs:** pyright, lua_ls, rust_analyzer, csharp_ls, sqls (and per-project extras)
- **Tools:** conform, nvim-lint, nvim-dap, neotest, autopairs, surround, gitsigns, neoscroll

### Shell (zsh)
- **zsh-vi-mode** with vim cursor shapes
- **Starship** prompt (Oh My Posh for Windows)
- **Atuin** for encrypted, searchable shell history (replaces Ctrl+R)
- **fzf-tab** for fzf-powered tab completion
- **direnv** for per-directory environments
- **fzf, zoxide, autosuggestions, syntax-highlighting**

### Terminal
- **Ghostty** with cross-platform keybinds and Tokyo Night palette

### Multiplexer
- **tmux** with `Ctrl-a` prefix, vim-style copy mode, tpm plugin manager

### Modern CLI tools
- **Core:** fzf, ripgrep, fd, bat, eza, zoxide, btop, lazygit, delta, yazi
- **Extended:** hyperfine, dive, lazydocker, ctop, bandwhich, gitui, git-absorb, mprocs, pre-commit, watchexec, trash, xh, miller, sd, gitleaks

### Dev workflow
- **uv** — Python (replaces pip / poetry / pyenv)
- **bun** + Node — for new projects
- **just** — task runner
- **act** — local GitHub Actions testing
- **devcontainer** — templates for `.devcontainer/devcontainer.json`, `Dockerfile`, `post-create.sh`
- **pre-commit** — global config + per-project hooks

### AI agent & gas town
- **OpenCode** — daily-driver AI agent
  - 10 subagents (build, plan, backend, frontend×2, qa, devops, code-reviewer, pm, marketing)
  - 5 generic skills (rest-api, db, react, i18n, multi-tenant) + 5 dev skills (code-review, refactor, write-test, debug, dotfiles)
  - 8 slash commands
  - MCP servers (filesystem, github)
  - Tokyo Night theme
- **Gas town** — multi-agent orchestrator (Mayor, Polecats, Crew, Beads, Rigs)
  - `gt`, `bd`, `bv` CLIs installed via `go install`
  - Zsh aliases for all gas town subcommands
  - `~/.config/opencode/AGENTS.md` includes gas-town etiquette (polecat behavior, `gt prime`, `bd sync`)
- **Scaffolders:** `new-skill <name>` and `new-agent <name>` to create new skills/agents from templates
- **skills-lock.json** — versioned lockfile tracking skill content hashes

### Git
- Per-machine overrides via `~/.gitconfig.local` (NOT in dotfiles)
- `includeIf` for `~/work/*` → work identity, `~/personal/*` → personal identity
- 200+ aliases, delta pager, signed commits, autosquash, rerere

### Secrets
- Encrypted with `age` (SSH keys, API tokens)
- Stored in `private_*` paths
- Key backup instructions in `docs/SECRETS.md`

---

## Quickstart (new machine)

The bootstrap script (`scripts/bootstrap.sh`) automates everything — OS detection, package install with `go install` for gas town, chezmoi init + apply, and post-install hooks (ssh key stub, tmux tpm, fzf-tab, zsh plugins, skills-lock.json recompute, scaffolder install).

```bash
# 1. Clone the repo
git clone https://github.com/<you>/dotfiles.git ~/dotfiles

# 2. Run bootstrap (detects OS, installs all packages + chezmoi + configs)
#    This does: OS detect → install prereqs (chezmoi, age, git) →
#               install packages via OS-specific script → chezmoi apply →
#               post-install hooks (scaffolders, tpm, fzf-tab, zsh plugins,
#               skills-lock hashes, gitconfig stubs, gas town via go install)
bash ~/dotfiles/scripts/bootstrap.sh

# 3. Reload your shell (zsh plugins + aliases need a fresh session)
exec zsh

# 4. Edit ~/.gitconfig.local with your real name and email
nvim ~/.gitconfig.local

# 5. Open nvim — LazyVim auto-installs plugins on first start
nvim

# 6. (Optional) trust mise configs in your projects
cd ~/work/myproject && mise trust && mise install

# 7. (Optional) register for Atuin cloud sync
atuin register -u <username> -e <email>
atuin sync

# 8. (Optional) initialize gas town
gt town new

# 9. (Optional) create a custom skill or subagent
new-skill my-pattern "description"
new-agent my-role "description" --read-only
```

### What bootstrap.sh does, step by step

| Step | What happens |
|------|-------------|
| 1 | Detects OS (arch/fedora/debian/macos/wsl/windows) |
| 2 | Installs **chezmoi** (if missing) |
| 3 | Installs **age** (encryption, if missing) |
| 4 | Installs all packages via `install-{os}.sh` (tools, languages, fonts) |
| 5 | Runs **`go install`** for gas town (`gt`, `bd`, `bv`) if `go` is present |
| 6 | Runs **`chezmoi init --source ~/dotfiles`** (first time only) |
| 7 | Runs **`chezmoi apply --force`** — creates all symlinks, backs up old configs |
| 8 | Post-install: stubs `.gitconfig.local`, clones tpm + zsh plugins, computes skills-lock hashes, installs scaffolders to `~/.local/bin/` |

After bootstrap, you have a fully configured shell. **Step 3-9 are just for extras.**

---

## Daily workflow

```bash
# Edit a tracked dotfile → chezmoi picks up the change
nvim ~/.zshrc
chezmoi diff        # see what would change
chezmoi re-add      # pull the change into the source repo
chezmoi git -- push # commit + push

# Copy a template to a new project
cp ~/dotfiles/templates/devcontainer.json.tmpl ~/work/myproj/.devcontainer/devcontainer.json
cp ~/dotfiles/templates/SKILL.md.tmpl ~/.agents/skills/my-pattern/SKILL.md
cp ~/dotfiles/justfile ~/work/myproj/justfile

# Add a new skill (creates file + updates skills-lock.json)
new-skill my-pattern-name "Description here"
new-skill agent-browser/slack "Slack automation"

# Add a new subagent
new-agent my-role "Description"               # full permissions
new-agent code-reviewer --read-only           # read-only preset
new-agent data-engineer --no-write            # can edit, can't write
```

---

## Per-OS behavior

chezmoi templates render differently per OS:
- `dot_config/starship.toml` linked on Linux/macOS
- `dot_config/omp/omp.json` (oh-my-posh) linked on Windows
- Tmux, ghostty, nvim configs are 100% portable
- `scripts/install-{arch,fedora,debian,mac}.sh` and `install-windows.ps1` are OS-detected

---

## Structure

```
dotfiles/
├── README.md
├── .chezmoiroot
├── .chezmoiignore.tmpl
├── .chezmoi/chezmoi.toml.tmpl
├── .gitignore
├── Brewfile                              # macOS packages
├── packages/{arch,fedora}.txt            # Linux package lists
├── justfile                              # project-local task runner template
├── templates/                            # copy-once project templates
│   ├── devcontainer.json.tmpl
│   ├── Dockerfile.tmpl
│   ├── post-create.sh.tmpl
│   ├── SKILL.md.tmpl                     # new-skill source
│   └── AGENT.md.tmpl                     # new-agent source
├── scripts/                              # bootstrap + installers + scaffolders
│   ├── bootstrap.sh                      # main entry: OS detect, install, link
│   ├── install-{arch,fedora,debian,mac}.sh
│   ├── install-windows.ps1
│   ├── post-install.sh                   # hooks after chezmoi apply
│   ├── new-skill.sh                      # scaffold a new skill
│   └── new-agent.sh                      # scaffold a new subagent
├── dot_config/                           # → ~/.config/
│   ├── nvim/                             # LazyVim (init.lua, lazyvim.json, lua/)
│   ├── zsh/                              # 5 user config files + fzf-tab.zsh
│   ├── ghostty/config
│   ├── atuin/config.toml                 # shell history
│   ├── direnv/direnv.toml                # per-project env
│   ├── uv/uv.toml                        # Python
│   ├── bunfig.toml                       # Bun
│   ├── act/actrc                         # local GitHub Actions
│   ├── opencode/                         # AI agent config
│   │   ├── AGENTS.md                     # global system instructions
│   │   ├── config.json                   # model, agents, MCP
│   │   ├── skills-lock.json              # versioned skill lockfile
│   │   ├── agents/                       # 10 subagent definitions
│   │   │   ├── build.md                  #   default active-coding
│   │   │   ├── plan.md                   #   read-only analysis
│   │   │   ├── backend-engineer.md
│   │   │   ├── frontend-engineer.md
│   │   │   ├── frontend-senior.md
│   │   │   ├── qa-engineer.md
│   │   │   ├── devops-engineer.md
│   │   │   ├── code-reviewer.md
│   │   │   ├── product-manager.md
│   │   │   └── marketing.md
│   │   ├── skills/                       # 10 skills (5 generic + 5 dev)
│   │   │   ├── rest-api-design.md
│   │   │   ├── database-patterns.md
│   │   │   ├── react-patterns.md
│   │   │   ├── i18n-patterns.md
│   │   │   ├── multi-tenant-patterns.md
│   │   │   ├── code-review.md
│   │   │   ├── refactor.md
│   │   │   ├── write-test.md
│   │   │   ├── debug.md
│   │   │   └── dotfiles.md
│   │   ├── commands/                     # 4 /slash commands
│   │   │   ├── plan.md
│   │   │   ├── build.md
│   │   │   ├── refactor.md
│   │   │   └── debug.md
│   │   └── themes/tokyo-night.json
│   ├── lazydocker/config.yml
│   ├── gitui/config.toml
│   ├── mprocs/config.yaml
│   ├── pre-commit/config.yaml
│   ├── starship.toml
│   ├── btop/btop.conf
│   ├── lazygit/config.yml
│   ├── delta/config.toml                 # git pager (lenient TOML)
│   ├── yazi/{yazi.toml,theme.toml}
│   └── omp/omp.json                      # Windows prompt
├── dot_zshrc                             # → ~/.zshrc
├── dot_zshenv                            # → ~/.zshenv
├── dot_tmux.conf                         # → ~/.tmux.conf
├── dot_gitconfig.tmpl                    # → ~/.gitconfig
└── docs/                                 # documentation
    ├── SECRETS.md                        # age encryption guide
    ├── gitconfig.local.example
    ├── python-uv-migration.md            # Python → uv
    ├── direnv-usage.md
    ├── devcontainer-guide.md
    ├── justfile-recipes.md
    ├── when-to-use-bun.md
    ├── act-usage.md
    ├── opencode-guide.md                 # OpenCode config + skills/agents
    ├── gas-town-integration.md           # gas town workflow
    └── long-tail-cli-tools.md            # hyperfine, dive, lazydocker, etc.
```

---

## Load order in zsh (matters!)

```dot_zshrc (zshrc):
1.  compinit                       (with daily cache)
2.  Source 5 user config files     (aliases, exports, vi-mode, tools, prompt)
3.  fzf-tab plugin                 (after compinit, before fzf keybindings)
4.  fzf-tab.zsh UI config          (6th file, sourced after plugin)
5.  fzf keybindings                (after fzf-tab)
6.  direnv hook                    (after compinit)
7.  zoxide init
8.  Atuin init                     (MUST be last — overrides Ctrl+R)
9.  Local overrides                (~/.zshrc.local if present)

dot_config/zsh/tools.zsh (sourced at step 2):
-  tmux auto-attach
-  mise activate
-  fzf-git
-  zsh-autosuggestions
-  zsh-syntax-highlighting         (must be last in tools.zsh)
```

---

## Gas town quick reference

```sh
# Setup (one-time)
gt town new                        # create ~/gt/
gt rig new <name> <git-url>        # add a project (rig)

# Day-to-day
gt status                          # dashboard
gt convoy create "Feature X" gt-abc gt-def
gt sling <bead-id> <rig>           # assign work to a polecat
gt nudge <polecat> "msg"           # send a message
gt prime                           # re-inject Mayor context after compaction
gt doctor                          # health check

# Beads (issue tracker)
bd ready                           # unblocked work
bd create --title="..." --type=task --priority=2
bd update <id> --status=in_progress
bd close <id>
bd sync                            # git sync at session end

# Beads graph triage (NEVER bare `bv` — it's interactive)
bv --robot-triage                  # ranked picks, blockers
bv --robot-next                    # top pick + claim cmd
bv --robot-plan                    # parallel execution tracks
```

See `docs/gas-town-integration.md` for the full picture.

---

## Secrets

Private files live in `private_*` and are encrypted with age. To add a secret:

```bash
chezmoi age encrypt --output ~/dotfiles/private_dot_secrets/foo.txt.age
# then add `private_dot_secrets/foo.txt.age` to the repo
```

The age key is stored locally at `~/.config/chezmoi/key.txt`. **Back this up.**

See `docs/SECRETS.md` for the full workflow.

---

## Validation

Run from repo root to validate all config files:

```bash
python3 -c "
import os, json, subprocess, tomllib, yaml, toml
ok = fail = 0
for root, _, files in os.walk('.'):
    for f in files:
        path = os.path.join(root, f)
        try:
            if f.endswith('.toml'):
                with open(path, 'rb') as fh: tomllib.load(fh)
            elif f.endswith('.json'): json.load(open(path))
            elif f.endswith(('.yml','.yaml')): yaml.safe_load(open(path))
            elif f.endswith('.lua'):
                subprocess.run(['luac','-p',path], check=True, capture_output=True)
            elif f.endswith('.sh'):
                subprocess.run(['bash','-n',path], check=True, capture_output=True)
            else: continue
            ok += 1
        except Exception as e:
            fail += 1; print(f'FAIL {path}: {e}')
print(f'{ok} passed, {fail} failed')
"
```

Requirements: `python3 -m pip install pyyaml toml` (if pyyaml/toml not already installed).
Note: TOML files use strict `tomllib` (Python 3.11+). Files with non-strict syntax are skipped.
Delta (`dot_config/delta/config.toml`) is valid TOML but uses non-standard keys; it's parsed as git-config format if strict parse fails (see validation script in CI).

---

## License

MIT. Copy, modify, redistribute — your call.
