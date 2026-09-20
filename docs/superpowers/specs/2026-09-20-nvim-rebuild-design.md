# Neovim config rebuild from LazyVim starter

**Date:** 2026-09-20
**Status:** Approved
**Owner:** bteixeira

## Problem

The current `~/.config/nvim` (chezmoi-managed, source in `~/Projects/dotfiles/dot_config/nvim`) is a heavily customized LazyVim config that has become cluttered and partially broken. The dotnet/DAP/neotest area in particular accumulated a lot of fix-churn (see dotfiles git log: `8951c32` back through `2a4ea94`). The user wants a clean rebuild from the official LazyVim starter, re-adding only what they actually use.

## Goals

- Replace `~/.config/nvim` with a fresh clone of `LazyVim/starter`.
- Keep the standard LazyVim directory structure so it can be diffed against upstream.
- Re-add only: full .NET workflow (roslyn LSP + easy-dotnet + netcoredbg DAP + csharpier + neotest), all 21 currently-enabled extras, copilot + copilot-chat, and a curated set of misc plugins.
- Old config remains recoverable via dotfiles git history (no data loss).

## Non-goals

- No custom theme work (stock LazyVim tokyonight default).
- No Avante (the old `lua/avante_templates.lua` is orphaned — zero references).
- No craftzdog theme helpers (`discipline`, `hsl`, `lsp` modules).
- No `nvim-highlight-colors`, no fzf-lua (using snacks picker).
- No `_G.dd` / `lua/util/debug.lua` helper (starter `init.lua` doesn't use it).

## Approach

**A — LazyVim starter + clean re-add** (chosen). Clone `LazyVim/starter` into `~/.config/nvim` (without `.git`; chezmoi is the source of truth), enable the extras, add the chosen plugins in per-concern files.

## Target layout

```
~/.config/nvim/
├── init.lua
├── lazy-lock.json
├── lazyvim.json
├── stylua.toml
└── lua/
    ├── config/
    │   ├── lazy.lua        # imports LazyVim + plugins, stock tokyonight theme
    │   ├── options.lua     # autoread, snacks picker
    │   ├── keymaps.lua     # .NET group, DAP F-keys, personal binds
    │   └── autocmds.lua    # C#/F# inlay hints, format-on-save
    └── plugins/
        ├── dotnet.lua      # roslyn + easy-dotnet + hopcsharp + dotnet keymaps
        ├── dap.lua         # dap-ui layout, virtual text, breakpoints panel
        ├── editor.lua      # at-file blink integration
        ├── misc.lua        # tmux, undo-glow, mini.bracketed, refactoring, git.nvim, close-buffers
        └── lsp.lua         # LSP server polish + omnisharp disabled
```

## Extras (lazyvim.json)

Keep all 21 current extras verbatim:

- `lazyvim.plugins.extras.ai.copilot`
- `lazyvim.plugins.extras.ai.copilot-chat`
- `lazyvim.plugins.extras.coding.blink`
- `lazyvim.plugins.extras.coding.mini-comment`
- `lazyvim.plugins.extras.coding.mini-snippets`
- `lazyvim.plugins.extras.coding.mini-surround`
- `lazyvim.plugins.extras.coding.yanky`
- `lazyvim.plugins.extras.editor.inc-rename`
- `lazyvim.plugins.extras.editor.illuminate`
- `lazyvim.plugins.extras.editor.aerial`
- `lazyvim.plugins.extras.dap.core`
- `lazyvim.plugins.extras.lang.dotnet`
- `lazyvim.plugins.extras.lang.docker`
- `lazyvim.plugins.extras.lang.json`
- `lazyvim.plugins.extras.lang.markdown`
- `lazyvim.plugins.extras.lang.sql`
- `lazyvim.plugins.extras.lsp.none-ls`
- `lazyvim.plugins.extras.test.core`
- `lazyvim.plugins.extras.ui.mini-animate`
- `lazyvim.plugins.extras.util.dot`
- `lazyvim.plugins.extras.util.mini-hipatterns`

## .NET workflow

The stock `lang.dotnet` extra already provides: csharpier/fantomas via conform, netcoredbg via mason, netcoredbg DAP adapter, neotest-vstest.

### C# LSP: roslyn.nvim, omnisharp disabled

- `roslyn.nvim` (`ft = { "cs", "csharp", "fsharp" }`, `broad_search = true`, `lock_target = false`) — matches current experience.
- Disable omnisharp in the `nvim-lspconfig` opts (`servers.omnisharp.enabled = false`).
- `hopcsharp.nvim` for quick actions.
- `roslyn-language-server` added to mason `ensure_installed`.

### easy-dotnet.nvim

- `lsp = { enabled = false }`, `auto_install_easy_dotnet_server = false`.
- Adds `~/.dotnet/tools` to PATH if present.
- netcoredbg auto-detection: mason bin → mason package → global `netcoredbg`.
- Debugger: `auto_register_dap = false`, `console = "integratedTerminal"`, value converters on.
- Managed terminals with tab mappings (`<Tab>`/`<S-Tab>`/`+`/`X`/`q`), auto-hide.
- `test_runner.neotest_integration = true`.

### Keymaps — `<leader>k` group

- `kb` build, `kc` clean, `kx` clean+build, `kr` run, `kw` watch
- `kt`/`ktt` run tests, `kdd` debug tests (`dap.continue({ new = true })`)
- `ka` add package, `kP` remove package, `ko` outdated, `ks` secrets
- `kv` `.NET` menu, `kT` toggle managed terminal
- `kD` EF DB update, `km` add migration (prompts name), `kM` list migrations

### DAP

- `lua/config/dap.lua`: netcoredbg adapter (coreclr alias + easy-dotnet server callback), "Launch app" config (build then dll picker). Uses `vim.loop.fs_stat or vim.uv.fs_stat`.
- dap-ui bottom layout (console/scopes/stacks/watches), expanded lines, rounded borders, controls disabled.
- `nvim-dap-virtual-text` enabled.
- Breakpoints panel custom module (`config/dap_breakpoints_panel.lua`), `<leader>dP`.
- F-keys: `<F5>` continue, `<F9>` toggle bp, `<F10>` step over, `<F11>` step into, `<F12>` step out.

### Formatting & autocmds

- csharpier via conform (already in extra); explicit csharpier plugin file not needed — verify and drop if redundant.
- Autocmds: C#/F# inlay hints on `LspAttach`; format-on-save for `*.cs`/`*.fs` on `BufWritePre`.

## Misc plugins (curated)

- `tmux.nvim` — seamless split/pane navigation.
- `undo-glow.nvim` — fade animation, yanked-text highlight.
- `mini.bracketed` — bracketed navigation.
- `refactoring.nvim` — visual `<leader>re` extract function, `<leader>rv` extract variable.
- `git.nvim` — `<leader>gb` blame, `<leader>go` browse.
- `close-buffers.nvim` — `<leader>th` close hidden, `<leader>tu` close nameless.
- `at-file.nvim` — blink integration (score_offset 100, ignores `.git`/`node_modules`/`bin`/`obj`).

## LSP polish (lsp.lua)

- tsserver inlay hints, `lua_ls` settings, `cssls`, `tailwindcss` (git root), `html`, `yamlls`.

## Options & keymaps

- `options.lua`: `vim.opt.autoread = true`, `vim.g.lazyvim_picker = "snacks"`.
- `keymaps.lua` personal binds: `x` → `"_x`, `+`/`-` increment/decrement, `<C-a>` select all, `<C-m>` jumplist forward, `H` highlight word under cursor, `<leader>bS` reload+save buffer.

## Verification checklist

1. `:checkhealth lazyvim` — no errors.
2. Open a `.cs` file in a real project → roslyn attaches, omnisharp absent (`:LspInfo`).
3. `:Dotnet build` succeeds; `<leader>kr` runs the app.
4. `<F5>` launches via netcoredbg; breakpoints hit; step keys work.
5. `<leader>t` shows dotnet tests (neotest-vstest); `<leader>ktt` runs them.
6. Copilot + Copilot Chat respond; blink completes; snacks picker opens.
7. tmux split navigation works inside tmux.

## Rollout

1. `mv ~/.config/nvim ~/.config/nvim.bak-<date>` (delete after verification).
2. Clone `LazyVim/starter` → `~/.config/nvim`, strip `.git`.
3. Write config files.
4. First `nvim` run installs plugins (`:Lazy install`).
5. Run verification checklist.
6. `chezmoi re-add ~/.config/nvim`, commit in `~/Projects/dotfiles` (`nvim: rebuild from LazyVim starter`).
7. Old config recoverable via dotfiles git history at all times.