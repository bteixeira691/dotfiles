# Dev Containers — quick reference

A dev container is a Docker container with your project's full dev
environment. VS Code (or opencode) attaches to it via SSH-like protocol,
so you get a clean reproducible shell + editor experience per project.

This dotfiles repo ships templates you copy into a project to bootstrap
a devcontainer.

---

## When to use a devcontainer

- **Yes:** multi-language projects, complex build steps, cross-team
  onboarding (new devs run `code .` and get a working env in 2 min).
- **Yes:** when the project's deps conflict with your system (different
  Python version, pinned Node version, system libs).
- **No:** simple single-file scripts, quick throwaway experiments, or
  when the project already has a setup that works for you.

---

## Setup (one-time per project)

```sh
cd ~/work/myproject
mkdir -p .devcontainer

# Copy templates from this dotfiles repo
cp ~/dotfiles/templates/devcontainer.json.tmpl .devcontainer/devcontainer.json
cp ~/dotfiles/templates/Dockerfile.tmpl       .devcontainer/Dockerfile
cp ~/dotfiles/templates/post-create.sh.tmpl   .devcontainer/post-create.sh
chmod +x .devcontainer/post-create.sh

# Edit .devcontainer/devcontainer.json:
#   - name:        human-friendly name
#   - image:       the base image
#   - features:    the devcontainer features you need
#   - mounts:      bind-mounts from the host (ssh keys, gitconfig)
#   - forwardPorts: ports to expose to host

# Open in VS Code
code .
# (or with the CLI:)
devcontainer up --workspace-folder .
```

---

## Features used in the template

Features are composable install scripts. The template uses:

| Feature | Purpose |
|---------|---------|
| `devcontainers/features/common-utils` | zsh, common shell tools |
| `devcontainers/features/git` | git + diff-highlight |
| `ansible/devcontainer-features/uv` | uv (Python) |
| `jungwinter/features/mise` | mise + bun + just + direnv |

Browse all: https://containers.dev/features

---

## Host mount examples

```json
"mounts": [
    "source=${localEnv:HOME}/.ssh,target=/home/vscode/.ssh,type=bind,consistency=cached",
    "source=${localEnv:HOME}/.gitconfig.local,target=/home/vscode/.gitconfig.local,type=bind,consistency=cached,readonly",
    "source=${localEnv:HOME}/.config/gh,target=/home/vscode/.config/gh,type=bind,consistency=cached,readonly",
    "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached"
]
```

⚠️ **Read-only mounts for credentials** (`.gitconfig.local`, `~/.ssh`).
This is the right default for security.

---

## Dockerfile: when features aren't enough

Some projects need system packages not covered by features (e.g. a
specific Postgres version, a CUDA toolkit, ffmpeg, gtk for GUI apps).
Use the Dockerfile template to add them.

```sh
# In devcontainer.json, reference the Dockerfile:
"build": {
    "dockerfile": "Dockerfile"
}
```

---

## Post-create hook

The post-create.sh runs **once** when the container is built. Use it
to install deps and trust project configs.

Common recipes:
- `mise trust && mise install`
- `direnv allow`
- `uv sync` / `bun install` / `npm install`
- `dotnet tool restore`
- `pre-commit install`
- `git config --local core.hooksPath .githooks`

---

## Opencode integration

Opencode (and Claude Code, Aider) work inside dev containers by
attaching to a shell in the container:

```sh
# In the project root
code .    # opens VS Code
# Then in the terminal:
devcontainer exec --workspace-folder . bash
# Now run opencode/Claude in that shell.
```

Or in a single command:

```sh
devcontainer exec --workspace-folder . opencode
```

---

## Performance tips

- **Bind mount the source dir** with `consistency=cached` (default) — host
  writes show up faster in the container.
- **Use named volumes for caches** (`/home/vscode/.cache`, `node_modules`,
  `.venv`, `target` for Rust, etc.). Bind-mounting the source dir means
  the container's cache is wiped on every rebuild.
- **Multi-stage Dockerfile** if you need a heavy build step (e.g. Rust
  release build) — build in one stage, copy artifacts to a slimmer runtime.

---

## When NOT to use a devcontainer

- The project's setup is `git clone && make` and that works for you.
- You're doing throwaway experimentation.
- The project is tiny (one Python file, one Node script).
- You need GPU passthrough or other hardware access (config is annoying).

For these, just `cd` and use the local environment with direnv.
