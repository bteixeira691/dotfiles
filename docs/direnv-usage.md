# direnv usage

[direnv](https://direnv.net) loads/unloads environment variables
based on the current directory. It reads `.envrc` files and exports
variables only inside that directory.

---

## Quick start

```sh
cd ~/work/myproject
# Edit .envrc (see examples below)
da         # alias for `direnv allow`
cd ../..
cd ~/work/myproject   # direnv re-activates on entry
```

On every `cd` into the directory, the env is loaded (if `.envrc` is
allowed). On `cd` out, it's unloaded.

---

## Common `.envrc` patterns

### 1. Auto-activate a uv venv (Python project)

```sh
# .envrc
use uv
```

This:
- Detects `.python-version` (or `pyproject.toml` `requires-python`)
- Creates `.venv` if missing
- Exports `VIRTUAL_ENV`, prepends `.venv/bin` to `PATH`
- Exports `UV_PROJECT_ENVIRONMENT`

### 2. Manual uv venv

```sh
# .envrc
export VIRTUAL_ENV="$PWD/.venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
export UV_PROJECT_ENVIRONMENT="$VIRTUAL_ENV"
```

### 3. Load a `.env` file

```sh
# .envrc
dotenv .env
```

Or for a `.env` that may not exist:

```sh
# .envrc
dotenv_if_exists .env
```

### 4. Node project (auto-detect from package.json engines)

```sh
# .envrc
use node
```

### 5. Mise project (multi-tool: py + node + go)

```sh
# .envrc
use mise
# (reads .mise.toml in the project)
```

### 6. Add project bin to PATH

```sh
# .envrc
PATH_add bin
PATH_add node_modules/.bin
```

### 7. Set per-project API keys (encrypted)

```sh
# .envrc
export DATABASE_URL="postgresql://localhost/dev"
export OPENAI_API_KEY="$(gopass show work/openai)"
```

For secrets, use gopass or 1Password CLI, not committed `.envrc`.

### 8. Require a tool to be installed

```sh
# .envrc
env_vars_required AWS_PROFILE
```

### 9. Reload .envrc after editing

```sh
dr         # alias for `direnv reload`
# or
direnv reload
```

### 10. Allow, deny, status

```sh
da                # allow this .envrc (must run after each edit)
da .              # same, in current dir
da !              # allow and don't ask again
dr                # reload
dst               # show what's loaded
```

---

## Security

direnv executes `.envrc` as a shell script. To prevent untrusted code:

1. **Always review `.envrc` before `direnv allow`.**
2. **Use the whitelist** of `use_*` and `dotenv` stdlib helpers (already
   configured in `~/.config/direnv/direnv.toml`).
3. **Don't store secrets in `.envrc`** — use `gopass`, `1Password CLI`,
   or `chezmoi age` encryption.

---

## Common gotchas

- **Sub-shells don't inherit direnv state.** If you `bash` inside a
  direnv-loaded dir, the new shell re-loads. This is by design.
- **Tmux panes / splits** can be tricky — if the parent shell already
  loaded env, the pane inherits. If you start a fresh tmux session
  inside the dir, it loads fresh.
- **`direnv deny`** removes the allow for the current dir.
- **Edit `.envrc` → `dr` to reload** (don't `da` again unless it timed out).
- **NFS / slow filesystems** can make `cd` slow if `.envrc` is large.
  Use `dotenv_if_exists` or short `use_*` calls only.

---

## Stack integration

- **zsh**: `eval "$(direnv hook zsh)"` (already in `dot_zshrc`)
- **bash**: `eval "$(direnv hook bash)"` (Windows WSL: same)
- **tmux**: just works (each new pane re-evaluates the dir's `.envrc`)
- **VSCode**: works if shell integration is enabled
- **Neovim**: works with `:terminal`

---

## Cheat sheet

| Alias | Command | Purpose |
|-------|---------|---------|
| `da`  | `direnv allow` | Approve the current `.envrc` |
| `dr`  | `direnv reload` | Re-evaluate without re-allowing |
| `dst` | `direnv status` | Show what's currently loaded |
|       | `direnv edit` | Open `.envrc` in `$EDITOR` |
|       | `direnv prune` | Forget all .envrc state in parent dirs |
|       | `direnv deny` | Disable for this dir |
