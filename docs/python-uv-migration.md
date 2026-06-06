# Python Migration: pyenv + venv + pip → uv

This dotfiles setup ships with [`uv`](https://docs.astral.sh/uv) as the
**only** Python tool. No pyenv, no virtualenv, no pip-tools, no poetry.
This document covers the one-time migration from the old toolchain.

---

## Why uv?

| Tool replaced | Replaced by `uv` command |
|---------------|--------------------------|
| pyenv         | `uv python install` / `uv python list` |
| virtualenv    | `uv venv` (auto-created per project) |
| pip           | `uv pip` |
| pip-tools     | `uv lock` + `uv sync` |
| poetry        | `uv project` (in `pyproject.toml`) |
| pipx          | `uv tool install` |
| conda (mamba) | `uv` + system Python or `micromamba` |

Single Rust binary, 10-100× faster, drop-in compatible with all
existing `requirements.txt` / `pyproject.toml` files.

---

## 1. Install uv (already done by post-install)

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh   # Linux/macOS
# or
brew install uv                                   # macOS (alternative)
```

After install, `uv` lives at `~/.local/bin/uv`.

---

## 2. Pick the global Python version (optional)

If you want a system-wide default Python:

```sh
# Add to ~/.config/uv/uv.toml  (already configured)
# python = "3.12"

# Or install manually:
uv python install 3.12
```

---

## 3. Migrate existing projects

### Project with `requirements.txt` (old workflow)

Before:
```sh
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

After:
```sh
# uv auto-creates a venv in the project on first run
uv sync                          # or: uv pip install -r requirements.txt
uv run python main.py
```

### Project with `pyproject.toml` (Poetry)

```sh
# Convert once:
uvx --from poetry poetry export -f requirements.txt > requirements.txt
uv pip install -r requirements.txt

# Or: edit pyproject.toml to remove [tool.poetry], add [project]
#     and use [tool.uv] for sources.
```

### Project with `Pipfile` (Pipenv)

```sh
# Convert:
pipenv requirements > requirements.txt
uv pip install -r requirements.txt
```

---

## 4. Pin a Python version per project

Create `.python-version` in the project root:

```sh
uv python pin 3.12
```

This is auto-detected by uv and direnv (see below).

---

## 5. Per-project env with direnv

Create `.envrc` in the project root:

```sh
# .envrc
use uv                       # auto-activates .venv and matches python version
# or:
export VIRTUAL_ENV="$(uv venv --quiet && pwd)/.venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
export UV_PROJECT_ENVIRONMENT="$(uv venv --quiet && pwd)/.venv"
```

First time: `da` (alias for `direnv allow`).

---

## 6. Globally installed CLI tools (was pipx)

Old:
```sh
pipx install black
```

New:
```sh
uv tool install black
# or
uvx black                     # one-shot (no install)
```

Tools installed this way are isolated but on PATH (e.g. `~/.local/bin/black`).

---

## 7. Virtual environment management

| Action | Old | New |
|--------|-----|-----|
| Create venv | `python -m venv .venv` | `uv venv` |
| Activate | `source .venv/bin/activate` | (just use `uv run`) |
| Deactivate | `deactivate` | (use `uv run` to scope) |
| Remove | `rm -rf .venv` | `rm -rf .venv` (same) |
| Run script | `python script.py` | `uv run script.py` |
| Install pkg | `pip install x` | `uv add x` (in pyproject) or `uv pip install x` |
| List pkgs | `pip list` | `uv pip list` |
| Replicate | `pip freeze > req.txt` | `uv lock` + `uv sync` |

**Key insight:** With `uv run`, you almost never need to activate the
venv manually. The venv is auto-created if missing.

---

## 8. Lockfile workflow (for reproducible installs)

In a project with `pyproject.toml`:

```sh
uv add requests                 # adds to deps, updates lock
uv sync                         # installs from lock
```

This creates `uv.lock` (TOML). Commit it. CI installs with `uv sync --frozen`.

---

## 9. Common gotchas

- **`pyenv` shims** still in `$PATH` will mask `uv run`. Either uninstall
  pyenv or `pyenv shell system` in the project.
- **`PYTHONDONTWRITEBYTECODE=1`** is set globally in `dot_zshenv` — no `.pyc` files.
- **`python` and `pip` are not aliased globally** by default; use `py` and `pip` aliases (which call `uv`).
  If you want bare `python` to be `uv run python`, add to `~/.zshrc.local`:
  ```sh
  alias python="uv run python"
  alias pip="uv pip"
  ```
- **Wheel build dependencies** (e.g. for `psycopg2`) — uv installs them automatically
  if your toolchain (`gcc`, `make`, `pkgconf`, `openssl-devel`) is present.

---

## 10. Removing the old toolchain

```sh
# Linux (Arch):
sudo pacman -Rns python-pyenv pipenv poetry

# Linux (Fedora):
sudo dnf remove python-pip pipenv poetry

# macOS:
brew uninstall pyenv pipenv poetry

# Then remove any stale venvs and lockfiles:
find ~ -name "Pipfile.lock" -delete
find ~ -name "poetry.lock" -not -path "*/node_modules/*" -delete
```

You do NOT need to keep pip — `uv pip` is a drop-in replacement that
doesn't need pip itself.

---

## Cheat sheet

```sh
uv python install 3.12         # install a Python version
uv python list                 # list available
uv python list --only-installed # show installed
uv python find 3.12            # path to a specific python
uv venv                        # create .venv in current dir
uv init                        # create a new project (pyproject.toml)
uv add requests                # add dep to project
uv remove requests             # remove dep
uv sync                        # install all deps from lock
uv lock                        # regenerate lock
uv run python main.py          # run with project env
uv run pytest                  # run any command in project env
uvx ruff                       # run a tool without installing
uv tool install ruff           # install a tool globally
uv pip list                    # list installed packages
uv pip install -r req.txt      # install from requirements
uv pip freeze > req.txt        # export deps
```
