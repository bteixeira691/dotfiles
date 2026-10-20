# Neovim for C# microservices

LazyVim-based config tuned for a C#/.NET developer working on several
microservices at once, with one Neovim instance per repo and services running in
[Herdr](https://herdr.dev) tabs.

## Architecture

| Concern | Choice |
|---|---|
| C# LSP | `roslyn.nvim` + global `roslyn-language-server` in **daemon mode** (one shared server for all Neovim instances) |
| Build / run / debug / EF | `easy-dotnet.nvim` (LSP disabled; roslyn.nvim owns it) |
| Tests | `neotest` + `easy-dotnet.neotest` adapter (VSTest + Microsoft.Testing.Platform → xUnit v2/v3, NUnit) |
| Debugger | bundled `netcoredbg` via easy-dotnet-server, parallel sessions |
| Services | one Herdr tab per service, launched from the current repo |
| Formatting | `conform.nvim` + `csharpier` (single pass, LazyVim format-on-save) |

### Roslyn daemon mode

`roslyn.nvim` launches the server with `--daemon-mode`, which requires
`roslyn-language-server >= 5.12.0-1.26453.19`. The global tool is used; the older
Mason copy is disabled (`mason/packages/roslyn-language-server/roslyn-language-server.disabled`).

```bash
dotnet tool update -g roslyn-language-server --prerelease \
  --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json
```

`mason-lspconfig` auto-enables every installed server, so `roslyn_ls` is
explicitly disabled in `lua/plugins/lsp.lua`. Without that, every Neovim starts a
second, per-instance Roslyn server.

### Multiple solutions per repo

`roslyn.nvim` picks a target deterministically (solution named like the repo,
cwd or project dir). If a repo has several candidates, run `:Roslyn target`
once; the selection sticks via `vim.g.roslyn_nvim_selected_solution`.

`broad_search` is off: it can resolve project mode on the first FileType event
and solution mode on the next, which leaves two Roslyn clients attached to the
same buffer.

## Keymaps

Leader is `<space>`. LazyVim defaults still apply (`<leader>d*` debug,
`<leader>t*` neotest, `<leader>c*` code, ...).

### .NET (`<leader>k`)

| Key | Action |
|---|---|
| `kb` / `kB` | build project / solution |
| `kc` / `kx` | clean / clean+build |
| `kr` | run service in a new Herdr tab (project + launch profile) |
| `kR` | same, ask for a port (`--urls`) |
| `kw` | `dotnet watch` in a Herdr tab |
| `kl` | jump to a running service tab |
| `kp` | peek last lines of a service log |
| `kX` | Ctrl+C every service started from this Neovim |
| `kd` | debug project + profile (new session) |
| `kdd` | debug the persisted default project (new session) |
| `ka` | attach debugger to a process |
| `kt` / `ktt` | easy-dotnet test runner (browse the solution) |
| `kC` | run tests with XPlat code coverage + summary |
| `kA` / `kP` | add / remove NuGet package |
| `ko` | outdated packages (virtual text) |
| `ks` | user secrets |
| `kT` | easy-dotnet terminal |
| `kv` | `:Dotnet` command menu |
| `kD` / `km` / `kM` | EF: database update / add migration / list migrations |

### Debug sessions

| Key | Action |
|---|---|
| `<F5>` / `<F9>` | continue / toggle breakpoint |
| `<F10>` / `<F11>` / `<F12>` | step over / into / out |
| `<leader>dS` | switch between concurrent sessions |
| `<leader>dX` | terminate all sessions |
| `<leader>dx` | breakpoints panel |
| `<leader>du` | dap-ui (scopes, CPU/MEM, watches, REPL, console) |

Every `kd`/`kdd` starts an **additional** session (`dap.run(..., { new = true })`),
so several services can be debugged at once.

### Tests (LazyVim)

`<leader>tr` nearest, `<leader>tt` file, `<leader>tT` all, `<leader>td` debug
nearest, `<leader>ts` summary, `<leader>to` output, `<leader>tS` stop.

### Herdr

`<C-h/j/k/l>` moves Neovim splits and falls through to Herdr panes at an edge.
From a shell pane the same chords return to the last Neovim pane in the
workspace (`~/.local/bin/herdr-nvim-nav`, bound in `~/.config/herdr/config.toml`).
Sidebar panes (`nvim --remote-ui`) are ignored, so focus lands on the main editor.

Remove the `[[keys.command]]` blocks from `~/.config/herdr/config.toml` to go back
to prefix-only navigation.

#### herdr-nvim (sidebar, file picker, annotations)

[ChmaraX/herdr-nvim](https://github.com/ChmaraX/herdr-nvim) adds a persistent,
per-tab nvim sidebar plus code annotations that are sent to the agent in the
workspace.

```sh
herdr plugin install --yes ChmaraX/herdr-nvim
```

Herdr keys (already bound in `config.toml`):

| Key | Action |
|---|---|
| `prefix+e` | toggle the nvim sidebar for this tab |
| `prefix+o` | pick a file from the agent's recent output |

Neovim keys (annotations, `<leader>a` — LazyVim's AI group):

| Key | Action |
|---|---|
| `<leader>ac` | comment line / selection |
| `<leader>al` | list comments |
| `<leader>as` | paste comments into the agent input |
| `<leader>aS` | send comments (submits) |
| `<leader>ai` | insert `path:line` at the agent's cursor |

The sidebar is a headless nvim daemon per tab. `config/herdr.lua` ignores it for
navigation (`v:argv` contains `--headless`), so it never becomes the "main" nvim.

#### macOS note

The plugin stores its sockets in `$XDG_RUNTIME_DIR/herdr-nvim`. Linux uses
`/run/user/<uid>`; macOS has no writable `/run`, so `~/.zshenv` points
`XDG_RUNTIME_DIR` at `$TMPDIR/xdg-runtime-<uid>` (and `~/.config/zsh/.zshenv`
sources the canonical file because `ZDOTDIR` is set). A Herdr server started
before that fix keeps the old environment until restarted.

## Maintenance

```bash
dotnet tool update -g roslyn-language-server --prerelease \
  --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json
dotnet tool update -g EasyDotnet
```

```vim
:checkhealth roslyn
:checkhealth easy-dotnet
:Dotnet _server update
:Roslyn target
```

Config is chezmoi-managed: edit in the source (`chezmoi edit ~/.config/nvim/...`)
and run `chezmoi apply`.
