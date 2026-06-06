# Just — task runner

[`just`](https://github.com/casey/just) is a command runner similar to
`make` but with cleaner syntax, no implicit dependencies, and a
single file. This dotfiles repo ships a starter `justfile` you can
copy to a project.

---

## Install (already done by the dotfiles setup)

```sh
# Linux (Arch):
sudo pacman -S just

# Linux (Fedora):
sudo dnf install just

# macOS:
brew install just

# Or via the in-container devcontainer feature (jungwinter)
```

---

## Use the template

```sh
# Copy the starter
cp ~/dotfiles/justfile ./justfile

# Edit it for your project:
#   - project_name, python_version, node_version
#   - add or remove recipes
#   - change default behavior
```

---

## Common recipes (built into the template)

| Recipe              | What it does                                   |
|---------------------|------------------------------------------------|
| `just`              | List all recipes (default)                     |
| `just bootstrap`    | Fresh dev env (install + pre-commit + trust)   |
| `just install`      | Install all deps (uv / bun / cargo / go)       |
| `just fmt`          | Format all code                                |
| `just lint`         | Lint all code                                  |
| `just typecheck`    | Type-check                                     |
| `just test`         | Run the test suite                             |
| `just test-cov`     | Run tests + coverage report                    |
| `just dev`          | Run the dev server                             |
| `just repl`         | Open a REPL                                    |
| `just commit msg`   | `git add -A && git commit -m msg`              |
| `just pr`           | Push + open PR with `gh`                       |
| `just clean`        | Remove build artifacts + caches                |
| `just update`       | Upgrade all deps                               |
| `just pre-commit`   | Run pre-commit on all files                    |
| `just docker-build` | Build the docker image                         |
| `just docker-run`   | Run the docker image                           |
| `just docker-shell` | Open a shell in the dev container              |

---

## Pattern recipes for projects

### Run a single test file
```just
test-file file:
    uv run pytest {{file}} -v
```
Usage: `just test-file tests/test_user.py`

### Database shell
```just
db:
    docker compose exec db psql -U app -d app
```

### Reset database
```just
db-reset:
    docker compose down -v
    docker compose up -d db
    just migrate
```

### Open the project in editor
```just
edit:
    $EDITOR .
```

### CI: full check (lint + typecheck + test)
```just
ci:
    just lint
    just typecheck
    just test
```

### Generate secrets for dev
```just
dev-secrets:
    @if [ ! -f .env ]; then cp .env.example .env && echo "Created .env from .env.example"; fi
    @echo "  Edit .env and add secrets manually"
```

---

## Recipe attributes (modifiers)

```just
# [private] — don't show in `just --list`
[private]
_internal:
    @echo "hidden"

# [doc("...")] — custom description
[doc("Build a release artifact")]
release:
    cargo build --release

# [confirm("...")] — prompt before running
[confirm("Are you sure you want to deploy?")]
deploy:
    rsync -avz ./dist/ deploy@server:/var/www/

# [group: '...'] — group recipes in --list
[group('docker')]
docker-build:
    docker build -t myapp .

# Multiple attributes
[doc("Run integration tests"), confirm("This will reset the DB")]
integ:
    just db-reset
    just test
```

---

## Variables and parameters

```just
# Setting variables
name := "myapp"
version := `git describe --tags --always`

# Parameters
greet person:
    @echo "Hello, {{person}}!"

# Default parameter values
deploy env="staging":
    @echo "Deploying to {{env}}..."

# Variadic
multi-say *args:
    @for arg in {{args}}; do echo "say: $arg"; done
```

---

## Just vs Make vs Task vs npm scripts

| Tool       | Strengths                                | Weaknesses                |
|------------|------------------------------------------|---------------------------|
| `just`     | Single file, modern syntax, no implicit  | Single platform (works on all 3 of ours) |
| `make`     | Ubiquitous, parallel jobs                | Implicit deps = magic, tab required |
| `go-task`  | YAML, cross-platform                     | YAML overhead              |
| `npm run`  | Already in JS projects                   | Node-only, weak DSL        |

We pick `just` because:
1. The DSL is clean and readable (`{{var}}` interpolation, params).
2. It works on Linux + macOS + WSL out of the box.
3. It's in package managers (no shell-script bootleg).
4. Cross-language (use the same justfile for Python + Node + Rust mixed).

---

## Aliases (in zsh)

```sh
alias j="just"
alias jl="just --list"
```

---

## Cheat sheet

```sh
just                       # show all recipes
just --evaluate            # show all variables
just <recipe>              # run a recipe
just <recipe> arg1 arg2    # with arguments
just --groups              # show recipes by group
just --fmt --check         # check justfile is formatted
just --fmt                 # auto-format the justfile
just --choose              # interactive picker
```
