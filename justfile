# Justfile — task runner (https://github.com/casey/just)
# Project-local. Copy to ~/work/<project>/justfile and adapt.
#
# Usage:
#   just            # list available recipes (default)
#   just <recipe>   # run a recipe
#   just --evaluate # show all variables
#   just --list     # formatted list with descriptions

# --- Project settings -------------------------------------------------------
project_name   := "myproject"
python_version := "3.12"
node_version   := "22"
go_version     := "1.23"
app_port       := "8000"

# --- OS detection (for cross-platform recipes) ------------------------------
os := if os() == "macos" { "darwin" } else { "linux" }

# --- Default recipe: show available recipes ---------------------------------
default:
    @just --list --unsorted

# --- Environment setup ------------------------------------------------------
[doc("Bootstrap a fresh dev environment")]
bootstrap:
    @echo "==> Bootstrapping {{project_name}}"
    @echo "  - detecting env manager..."
    @command -v mise >/dev/null && echo "  - using mise" || echo "  - mise not found"
    @command -v uv >/dev/null && echo "  - using uv" || echo "  - uv not found"
    @command -v direnv >/dev/null && echo "  - direnv: run 'direnv allow' after first cd" || true
    @just install
    @just pre-commit-install
    @echo "✓ Bootstrap complete"

[doc("Install all project dependencies")]
install:
    @if [ -f pyproject.toml ]; then uv sync; fi
    @if [ -f package.json ]; then bun install || npm install; fi
    @if [ -f Cargo.toml ]; then cargo fetch; fi
    @if [ -f go.mod ]; then go mod download; fi
    @if [ -f .dotnet/project.assets.json ] || [ -f *.sln ]; then dotnet restore; fi
    @echo "✓ Dependencies installed"

# --- Code quality -----------------------------------------------------------
[doc("Format all code")]
fmt:
    @if [ -f pyproject.toml ]; then uv run ruff format .; fi
    @if [ -f package.json ]; then bun run format 2>/dev/null || npm run format 2>/dev/null || true; fi
    @if [ -d .dotnet ] || [ -f *.sln ]; then dotnet format; fi

[doc("Lint all code")]
lint:
    @if [ -f pyproject.toml ]; then uv run ruff check .; fi
    @if [ -f package.json ]; then bun run lint 2>/dev/null || npm run lint 2>/dev/null || true; fi
    @if [ -d .dotnet ] || [ -f *.sln ]; then dotnet format --verify-no-changes; fi

[doc("Type-check")]
typecheck:
    @if [ -f pyproject.toml ]; then uv run mypy . 2>/dev/null || true; fi
    @if [ -f package.json ]; then bun run typecheck 2>/dev/null || npm run typecheck 2>/dev/null || true; fi

# --- Tests ------------------------------------------------------------------
[doc("Run the test suite")]
test:
    @if [ -f pyproject.toml ]; then uv run pytest -v; fi
    @if [ -f package.json ]; then bun run test 2>/dev/null || npm test 2>/dev/null || true; fi
    @if [ -d .dotnet ] || [ -f *.sln ]; then dotnet test; fi

[doc("Run tests with coverage")]
test-cov:
    @if [ -f pyproject.toml ]; then uv run pytest --cov --cov-report=html --cov-report=term; fi

# --- Run ---------------------------------------------------------------------
[doc("Run the dev server")]
dev:
    @if [ -f pyproject.toml ]; then uv run python -m {{project_name}} || uv run uvicorn main:app --reload --port {{app_port}}; fi
    @if [ -f package.json ]; then bun run dev 2>/dev/null || npm run dev 2>/dev/null || true; fi

[doc("Open a REPL")]
repl:
    @if [ -f pyproject.toml ]; then uv run ipython; fi
    @if [ -f package.json ]; then bun run repl 2>/dev/null || true; fi

# --- Git --------------------------------------------------------------------
[doc("Quick commit: add + commit with conventional message")]
commit msg:
    git add -A
    git commit -m "{{msg}}"

[doc("Push and open PR")]
pr:
    git push -u origin HEAD
    gh pr create --fill

# --- Housekeeping -----------------------------------------------------------
[doc("Clean build artifacts and caches")]
clean:
    rm -rf .venv node_modules dist build target __pycache__ .pytest_cache .ruff_cache .mypy_cache
    find . -name "*.pyc" -delete
    find . -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true

[doc("Update all dependencies to latest")]
update:
    @if [ -f pyproject.toml ]; then uv lock --upgrade && uv sync; fi
    @if [ -f package.json ]; then bun update 2>/dev/null || npm update 2>/dev/null || true; fi
    @if [ -d .dotnet ] || [ -f *.sln ]; then dotnet outdated; fi

[doc("Install pre-commit hooks")]
pre-commit-install:
    @command -v pre-commit >/dev/null && pre-commit install || echo "pre-commit not installed; skipping"

[doc("Run pre-commit on all files")]
pre-commit:
    @command -v pre-commit >/dev/null && pre-commit run --all-files || echo "pre-commit not installed"

# --- Docker -----------------------------------------------------------------
[doc("Build the docker image")]
docker-build:
    docker build -t {{project_name}}:dev -f .devcontainer/Dockerfile .

[doc("Run the docker image")]
docker-run:
    docker run --rm -it -p {{app_port}}:{{app_port}} {{project_name}}:dev

[doc("Open a shell in the dev container")]
docker-shell:
    docker run --rm -it -v "$PWD:/workspace" {{project_name}}:dev bash
