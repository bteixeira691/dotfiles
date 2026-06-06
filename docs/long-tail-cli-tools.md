# Long-tail CLI tools

A grab bag of single-purpose CLIs that make the daily workflow faster.
Each is small, focused, and replaces a clunky multi-step shell pipeline.

| Tool | Replaces | Why |
|------|----------|-----|
| `hyperfine` | ad-hoc `time` loops | Statistical benchmarking |
| `dive` | `docker history` + manual inspection | Layer-by-layer image analysis |
| `lazydocker` | `docker ps` + `docker logs` + ... | TUI for all docker ops |
| `ctop` | `docker stats` | Color-coded container metrics |
| `bandwhich` | `iftop` + `nethogs` | Per-process network usage |
| `gitui` | `lazygit` (alt) | TUI for git, written in Rust |
| `git-absorb` | `--fixup` + rebase dance | Auto-create fixup commits |
| `mprocs` | `docker compose up` + tmux | Multi-process TUI for dev |
| `pre-commit` | hand-written shell hooks | Git hooks framework |
| `watchexec` | `nodemon` + `entr` | Run command on file change |
| `trash` | `rm` (when not sure) | Move to trash, recoverable |
| `xh` | `curl` (human) / `http` (httpie) | httpie alternative, faster |
| `miller` | `awk` + `jq` for CSV | CSV/JSON/TSV processing |
| `sd` | `sed` (in scripts) | Simpler sed for find-replace |
| `gitleaks` | manual secret scanning | Pre-commit secret detection |
| `lazygit` | (already installed) | TUI for git |

---

## hyperfine — statistical benchmarks

```sh
hyperfine 'make'         # single command
hyperfine 'make' 'cmake --build .'   # compare two
hyperfine --warmup 3 'cmd1' 'cmd2'   # warmup runs
hyperfine 'sleep 1' --export-markdown bench.md
```

Common use:
```sh
# Compare two implementations
hyperfine 'uv run python slow.py' 'uv run python fast.py'
# Show: mean, stddev, outliers, comparison
```

## dive — analyze Docker image layers

```sh
dive myimage:tag              # interactive
dive myimage:tag --ci         # CI mode (exits non-zero on waste)
```

Shows: layer sizes, file diffs between layers, wasted space (duplicate
files across layers).

## lazydocker — TUI for docker

```sh
lzd         # alias
```

Keyboard:
- `q` quit
- `r` refresh
- `s` stop
- `L` view all logs
- `Space` to start/stop a service

## ctop — container metrics

```sh
ctop        # interactive
ctop -a      # show all containers
```

`top`-like view of container CPU/mem/net.

## bandwhich — per-process network

```sh
sudo bandwhich       # shows per-process bandwidth
```

Less noisy than `nethogs`. Color-coded by process.

## gitui — TUI for git

```sh
gitui       # or `gu` if you add the alias
```

Alternative to lazygit. Slightly different keybindings. Try both.

## git-absorb — auto-fixup commits

When you have a fix to a recent commit:

```sh
git add .               # stage your fix
git absorb              # auto-creates fixup! commits
git rebase -i --autosquash HEAD~N
```

Magic. Saves dozens of `git commit --fixup=<sha>` invocations.

## mprocs — run multiple dev processes

Create `.procs.yaml` in your project:
```yaml
procs:
  db:
    shell: "docker compose up db"
  api:
    shell: "uv run uvicorn main:app --reload --port 8000"
  worker:
    shell: "uv run python -m worker"
  web:
    shell: "cd frontend && bun run dev"
```

Then `mprocs` (or `mp`) opens a TUI with all 4 processes, switchable with
`Tab` or number keys. `Ctrl-r` to restart one, `Ctrl-x` to kill.

## pre-commit — git hooks framework

Install per-project:
```sh
uvx pre-commit init   # or just create .pre-commit-config.yaml
```

Example `~/.config/pre-commit/config.yaml` (global defaults) is shipped.

## watchexec — run command on file change

```sh
watchexec --exts py 'ruff check .'
watchexec -e ts,tsx 'bun run test'
watchexec -w src -r 'just dev'
```

Better than `nodemon`/`entr` because it has built-in debouncing and
glob support.

## trash — recoverable delete

```sh
trash myfile.txt       # moves to ~/.local/share/Trash
trash -l               # list trash
trash-empty            # empty trash
```

Set up an alias in your shell:
```sh
alias rm="trash"   # CAREFUL: this overrides rm
```

We don't override `rm` by default; use `rmt` alias instead.

## xh — http requests from CLI

httpie-compatible, faster (Rust):
```sh
xh https://api.example.com/users
xh post https://api.example.com/users name=alice email=alice@example.com
xh put https://api.example.com/users/1 name=bob
xh --json https://api.example.com/users/1
```

Better than `curl` for human-readable output. Alias: `http`.

## miller — CSV/JSON/TSV processing

```sh
# CSV → JSON
mlr --icsv --ojson cat data.csv

# Filter
mlr --icsv filter '$age > 30' data.csv

# Stats
mlr --icsv stats1 mean,sum,count -f age data.csv

# JSON → CSV
mlr --ijson --ocsv cat data.json
```

Like `awk` for structured data. Indispensable for ad-hoc data munging.

## sd — simpler find-and-replace

```sh
sd 'old' 'new' file.txt
sd 'foo.*' 'bar' file.txt
```

Replaces `sed -i 's/old/new/g'`. Better regex (uses Rust regex syntax).

## gitleaks — secret scanner

```sh
gitleaks detect --source .   # scan a directory
gitleaks protect --staged    # scan staged changes
```

Use as a pre-commit hook in `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

## lazygit — TUI for git (already in Phase 0)

```sh
lg     # alias
```

Quick reference:
- `c` commit
- `p` push
- `P` pull
- `b` branch menu
- `s` stash
- `Space` stage/unstage
- `/` start search
- `?` keybinding help

---

## Installing all of these (one-time)

Already in the dotfiles package lists. To install manually:

```sh
# Arch
sudo pacman -S hyperfine dive lazydocker ctop bandwhich gitui \
                git-absorb mprocs pre-commit watchexec trash-cli \
                xh miller sd gitleaks

# Fedora
sudo dnf install hyperfine dive lazydocker ctop bandwhich gitui \
                 git-absorb mprocs pre-commit watchexec trash-cli \
                 xh miller sd gitleaks

# macOS
brew install hyperfine dive lazydocker ctop bandwhich gitui \
             git-absorb mprocs pre-commit watchexec trash \
             xh miller sd gitleaks
```

---

## When NOT to install all of these

This is a lot of tools. If you're on a fresh machine, install in this
order, get used to each, then add the next:

1. **lazygit** (replace `git status` reflexively)
2. **pre-commit** (block bad commits)
3. **gitleaks** (in pre-commit)
4. **hyperfine** (when you actually need to benchmark)
5. **dive** (when you debug a slow docker build)
6. **lazydocker** (when you have 5+ containers)
7. **mprocs** (when you run multiple dev processes)
8. Everything else, as needed.

---

## Memory footprint

All of these together is ~150MB of disk and minimal RAM (they're
loaded on demand). Don't worry about it.
