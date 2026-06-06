# act — run GitHub Actions locally

[`act`](https://github.com/nektos/act) runs your GitHub Actions
workflows in a local Docker container. Use it to test CI changes
without pushing to GitHub.

---

## Install (already done)

```sh
brew install act              # macOS
sudo pacman -S act            # Arch
sudo dnf install act          # Fedora
```

---

## Quick start

```sh
# Show what would run (dry-run)
act -l

# Run the default event (push)
act

# Run a specific job
act -j test

# Run a specific workflow file
act -W .github/workflows/ci.yml

# Run with a specific event
act pull_request
act workflow_dispatch -i

# Use a different .env file
act --env-file .env.act
```

---

## Default image

By default, `act` uses a giant image with all the tools GitHub runners
have. Override with a smaller image:

```sh
# .actrc  (in project root, or ~/.config/act/actrc)
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P ubuntu-22.04=catthehacker/ubuntu:act-22.04
-P ubuntu-24.04=catthehacker/ubuntu:act-24.04
```

The shipped config in `~/dotfiles/dot_config/act/actrc` does this by default.

---

## Secrets

act doesn't have access to your GitHub secrets. You have two options:

### Option 1: `.env` file
```sh
# .env.act  (gitignored)
GITHUB_TOKEN=ghp_xxx
DEPLOY_KEY=...
```

Then `act --secret-file .env.act` or set in `.actrc`:
```
--secret-file .env.act
```

### Option 2: `act --secret` (one-off)
```sh
act --secret GITHUB_TOKEN=ghp_xxx
```

### Option 3: Pull from GitHub (use with care)
`act` can read secrets from `gh` CLI if you have it authenticated.

---

## Common flags

| Flag | What it does |
|------|--------------|
| `-j <job>` | Run a specific job |
| `-W <file>` | Use a specific workflow file |
| `-l` | List workflows/jobs |
| `-n` | Dry run (don't execute) |
| `-v` | Verbose output |
| `--secret k=v` | Pass a secret |
| `--env k=v` | Pass an env var |
| `--container-architecture linux/amd64` | Override arch (e.g. for Apple Silicon) |
| `--bind` | Bind-mount the workspace into the runner |
| `--no-skip-checkout` | Don't skip the `actions/checkout` step |

---

## Common gotchas

### ARM64 (Apple Silicon) runners
GitHub's hosted runners are x86_64. On Apple Silicon, you may need:
```sh
act --container-architecture linux/amd64
```

### Service containers
```yaml
services:
  postgres:
    image: postgres:16
    env:
      POSTGRES_PASSWORD: test
```
act runs these as part of the job's network. Just works.

### Caching
`actions/cache@v4` works if the cache key matches GH. Otherwise, it
falls back to local cache files.

### `ubuntu-latest` on GitHub = 22.04
The `catthehacker/ubuntu:act-latest` image is 20.04. Use a specific
image in your `.actrc` to match GH's actual versions.

---

## Example .actrc for this dotfiles setup

The shipped config in `dot_config/act/actrc`:

```
-P ubuntu-latest=catthehacker/ubuntu:act-24.04
-P ubuntu-22.04=catthehacker/ubuntu:act-22.04
-P ubuntu-24.04=catthehacker/ubuntu:act-24.04
--container-architecture linux/amd64
--bind
--reuse
--no-skip-checkout
```

`--reuse` keeps the container around between runs (faster).
`--bind` makes changes to source files reflect in the runner.

---

## When to use act

- **Test a workflow change before pushing** — saves CI minutes.
- **Debug a flaky test** — easier to inspect in the local runner.
- **Develop the workflow itself** — act + watchexec is a tight loop.

## When NOT to use act

- The workflow depends on GitHub-only features (e.g. artifact uploads
  to GH Pages, deployment to GitHub environments).
- The matrix of OS versions matters (act only runs locally on your OS).
- The workflow uses self-hosted runners — they don't apply locally.

---

## Cheat sheet

```sh
act -l                                # list workflows
act -j test                           # run the `test` job
act push                              # run on push event
act pull_request                      # run on PR event
act workflow_dispatch                 # run on manual trigger
act --secret-file .env.act            # pass secrets
act --container-architecture linux/amd64   # for Apple Silicon
act --no-skip-checkout                # checkout your code
act --reuse                           # reuse container between runs
```
