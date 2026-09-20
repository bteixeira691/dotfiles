# Neovim Config Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Replace the cluttered `~/.config/nvim` with a fresh LazyVim starter config that re-adds only the approved .NET workflow, extras, and misc plugins, then syncs it to the chezmoi dotfiles repo.

**Architecture:** Clone `LazyVim/starter` into `~/.config/nvim` (no local `.git`; chezmoi in `~/Projects/dotfiles` is the source of truth). Enable 21 LazyVim extras via `lazyvim.json`. Add custom plugins in per-concern files under `lua/plugins/`, custom adapters/autocmds/keymaps under `lua/config/`. Stock tokyonight theme (LazyVim default), snacks picker.

**Tech Stack:** Neovim >= 0.10, Lua 5.1 (LuaJIT), lazy.nvim, LazyVim v8 extras, chezmoi.

## Global Constraints

- Config lives at `~/.config/nvim`; chezmoi source at `~/Projects/dotfiles/dot_config/nvim`; commits happen only in the dotfiles repo (no git repo inside `~/.config/nvim`).
- Base = official `LazyVim/starter` (current `main`). No custom theme (stock tokyonight default).
- `lazyvim.json` extras list is EXACTLY these 21 strings:
  `lazyvim.plugins.extras.ai.copilot`, `lazyvim.plugins.extras.ai.copilot-chat`, `lazyvim.plugins.extras.coding.blink`, `lazyvim.plugins.extras.coding.mini-comment`, `lazyvim.plugins.extras.coding.mini-snippets`, `lazyvim.plugins.extras.coding.mini-surround`, `lazyvim.plugins.extras.coding.yanky`, `lazyvim.plugins.extras.editor.inc-rename`, `lazyvim.plugins.extras.editor.illuminate`, `lazyvim.plugins.extras.editor.aerial`, `lazyvim.plugins.extras.dap.core`, `lazyvim.plugins.extras.lang.dotnet`, `lazyvim.plugins.extras.lang.docker`, `lazyvim.plugins.extras.lang.json`, `lazyvim.plugins.extras.lang.markdown`, `lazyvim.plugins.extras.lang.sql`, `lazyvim.plugins.extras.lsp.none-ls`, `lazyvim.plugins.extras.test.core`, `lazyvim.plugins.extras.ui.mini-animate`, `lazyvim.plugins.extras.util.dot`, `lazyvim.plugins.extras.util.mini-hipatterns`
- C# LSP = roslyn.nvim; omnisharp must be DISABLED in nvim-lspconfig opts.
- .NET = easy-dotnet.nvim (lsp disabled, netcoredbg auto-detect, neotest integration), hopcsharp.nvim, netcoredbg DAP, dap-ui bottom layout, breakpoints panel, `<leader>k` keymap group, DAP F-keys.
- Misc plugins (EXACT set): `tmux.nvim`, `undo-glow.nvim`, `mini.bracketed`, `refactoring.nvim`, `git.nvim`, `close-buffers.nvim`, `at-file.nvim` (blink integration).
- DROPPED (do NOT add): avante templates, craftzdog modules, nvim-highlight-colors, fzf-lua, `_G.dd`/util/debug.lua, ProjektGunnar keymaps, custom treesitter/UI files, copilot.lua manual opts (extra provides defaults).
- `options.lua`: `vim.opt.autoread = true`, `vim.g.lazyvim_picker = "snacks"`.
- `lazy.lua`: starter content with `defaults.lazy = true`.
- Verify with headless nvim after every file-writing task (`nvim --headless "+Lazy! sync" +qa` and `nvim --headless "+qa"`), then a final interactive checklist.

## File Structure

| File | Responsibility |
|------|----------------|
| `~/.config/nvim/init.lua` | Bootstrap `config.lazy` (starter, unchanged) |
| `~/.config/nvim/lua/config/lazy.lua` | lazy.nvim setup, imports LazyVim + `plugins`, `lazy = true` |
| `~/.config/nvim/lazyvim.json` | 21 extras + version 8 |
| `~/.config/nvim/lua/config/options.lua` | autoread, snacks picker |
| `~/.config/nvim/lua/config/keymaps.lua` | `<leader>k` dotnet group, DAP F-keys, `<leader>dP`, personal binds, refactor binds |
| `~/.config/nvim/lua/config/autocmds.lua` | C#/F# inlay hints on LspAttach, format-on-save cs/fs |
| `~/.config/nvim/lua/config/dap.lua` | netcoredbg adapter (coreclr + easy-dotnet), "Launch app" config |
| `~/.config/nvim/lua/config/dap_breakpoints_panel.lua` | Custom breakpoints panel module (verbatim from old config) |
| `~/.config/nvim/lua/plugins/dotnet.lua` | roslyn.nvim, hopcsharp.nvim, easy-dotnet.nvim setup |
| `~/.config/nvim/lua/plugins/dap.lua` | nvim-dap-ui opts, dap-virtual-text, requires `config.dap` |
| `~/.config/nvim/lua/plugins/lsp.lua` | mason tools (roslyn-language-server/csharpier/netcoredbg), LSP server polish, omnisharp disabled |
| `~/.config/nvim/lua/plugins/misc.lua` | tmux, undo-glow, mini.bracketed, refactoring, git.nvim, close-buffers |
| `~/.config/nvim/lua/plugins/editor.lua` | at-file.nvim blink.cmp integration |

Kept verbatim from starter: `LICENSE`, `README.md`, `stylua.toml`, `.neoconf.json`, `.gitignore`. Deleted from starter: `lua/plugins/example.lua`.

---

### Task 0: Backup old config and clone the starter

**Files:**
- Move: `~/.config/nvim` -> `~/.config/nvim.bak-20260920`
- Create: fresh `~/.config/nvim` from `LazyVim/starter`

**Interfaces:**
- Consumes: nothing.
- Produces: `~/.config/nvim` with starter structure (no `.git`), old config preserved at `~/.config/nvim.bak-20260920` and in dotfiles git history.

- [x] **Step 1: Confirm no running nvim using the config**

Run: `pgrep -x nvim || echo "no nvim running"`
Expected: `no nvim running` (if nvim IS running, ask the user to close it first — moving the config under a live editor will break that session).

- [x] **Step 2: Move the current config aside**

```bash
mv ~/.config/nvim ~/.config/nvim.bak-20260920
```

- [x] **Step 3: Clone the LazyVim starter into place**

```bash
git clone --depth 1 https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
rm -f ~/.config/nvim/lua/plugins/example.lua
```

- [x] **Step 4: Verify the starter structure**

Run: `find ~/.config/nvim -type f | sort`
Expected: exactly `init.lua`, `lua/config/{autocmds,keymaps,lazy,options}.lua`, `LICENSE`, `README.md`, `stylua.toml`, `.neoconf.json`, `.gitignore` (no `lua/plugins/example.lua`, no `lazyvim.json`, no `.git`).

### Task 1: Bootstrap files — lazy.lua, lazyvim.json, options.lua

**Files:**
- Modify: `~/.config/nvim/lua/config/lazy.lua`
- Create: `~/.config/nvim/lazyvim.json`
- Modify: `~/.config/nvim/lua/config/options.lua`
- Keep: `~/.config/nvim/init.lua` (starter's 2-line version — unchanged)

**Interfaces:**
- Consumes: starter clone from Task 0.
- Produces: the bootstrap that imports the 21 extras; later tasks only add plugin specs under `lua/plugins/` (auto-imported by `{ import = "plugins" }`).

- [x] **Step 1: Write `lua/config/lazy.lua`**

Replace the starter's `lua/config/lazy.lua` with exactly:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- custom plugins lazy-load by default; each spec declares its own triggers
    lazy = true,
    version = false, -- always use the latest git commit
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

- [x] **Step 2: Write `lazyvim.json`**

Create `~/.config/nvim/lazyvim.json`:

```json
{
  "extras": [
    "lazyvim.plugins.extras.ai.copilot",
    "lazyvim.plugins.extras.ai.copilot-chat",
    "lazyvim.plugins.extras.coding.blink",
    "lazyvim.plugins.extras.coding.mini-comment",
    "lazyvim.plugins.extras.coding.mini-snippets",
    "lazyvim.plugins.extras.coding.mini-surround",
    "lazyvim.plugins.extras.coding.yanky",
    "lazyvim.plugins.extras.editor.inc-rename",
    "lazyvim.plugins.extras.editor.illuminate",
    "lazyvim.plugins.extras.editor.aerial",
    "lazyvim.plugins.extras.dap.core",
    "lazyvim.plugins.extras.lang.dotnet",
    "lazyvim.plugins.extras.lang.docker",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.markdown",
    "lazyvim.plugins.extras.lang.sql",
    "lazyvim.plugins.extras.lsp.none-ls",
    "lazyvim.plugins.extras.test.core",
    "lazyvim.plugins.extras.ui.mini-animate",
    "lazyvim.plugins.extras.util.dot",
    "lazyvim.plugins.extras.util.mini-hipatterns"
  ],
  "version": 8
}
```

- [x] **Step 3: Write `lua/config/options.lua`**

Replace the starter's `lua/config/options.lua` with exactly:

```lua
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Hot reload: auto-reload when file changes on disk
vim.opt.autoread = true

-- Use snacks as the default picker (disable fzf)
vim.g.lazyvim_picker = "snacks"
```

- [x] **Step 4: Syntax-check the two Lua files**

Run (bare nvim, no config boot):
```bash
nvim --headless -u NONE "+luafile ~/.config/nvim/lua/config/lazy.lua" +qa
nvim --headless -u NONE "+luafile ~/.config/nvim/lua/config/options.lua" +qa
```
Expected: both exit 0 with no error output.

- [x] **Step 5: Validate `lazyvim.json`**

Run: `python3 -m json.tool ~/.config/nvim/lazyvim.json > /dev/null && echo "valid json"`
Expected: `valid json`

---

### Task 2: First install — LazyVim + all 21 extras

**Files:**
- Creates: `~/.config/nvim/lazy-lock.json` (generated by lazy.nvim)
- Creates: `~/.local/share/nvim/lazy/` (plugin installs; outside config)

**Interfaces:**
- Consumes: bootstrap from Task 1.
- Produces: a working stock LazyVim + extras installation; base for all later tasks.

- [x] **Step 1: Run the install (non-interactive)**

Run:
```bash
nvim --headless "+Lazy! sync" +qa
echo "exit=$?"
```
Expected: `exit=0`. First run downloads LazyVim + all extra plugins (can take several minutes).

- [x] **Step 2: Smoke-test plugin load**

Run:
```bash
nvim --headless "+lua local s = require('lazy').stats(); print('loaded=' .. s.loaded .. ' count=' .. s.count)" +qa
```
Expected: `loaded=` number greater than 0 and `count=` equal to number of LazyVim plugins (both positive).

- [x] **Step 3: Verify clean boot**

Run: `nvim --headless "+qa" 2>&1; echo "exit=$?"`
Expected: `exit=0` with no Lua errors on stderr.

---

### Task 3: .NET workflow — plugins/dotnet.lua, config/dap.lua, plugins/dap.lua, breakpoints panel

**Files:**
- Create: `~/.config/nvim/lua/plugins/dotnet.lua`
- Create: `~/.config/nvim/lua/config/dap.lua`
- Create: `~/.config/nvim/lua/plugins/dap.lua`
- Create: `~/.config/nvim/lua/config/dap_breakpoints_panel.lua`

**Interfaces:**
- Consumes: LazyVim `lang.dotnet` + `dap.core` extras from Task 2 (conform csharpier, mason netcoredbg/csharpier, netcoredbg DAP adapter, neotest-vstest).
- Produces: `easy-dotnet.nvim` `Dotnet` command + managed terminals, roslyn LSP, netcoredbg DAP adapters/configs (`dap.adapters.netcoredbg|coreclr|easy-dotnet`, `dap.configurations.cs` with "Launch app"), dap-ui layout, breakpoints panel module `config.dap_breakpoints_panel` (functions `toggle/refresh/jump_to`), `<leader>k`/F-key keymaps (wired in Task 6).

- [x] **Step 1: Write `lua/plugins/dotnet.lua`**

```lua
return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "csharp", "fsharp" },
    opts = {
      broad_search = true,
      lock_target = false,
    },
  },
  {
    "leblocks/hopcsharp.nvim",
    ft = { "cs", "csharp" },
    config = function()
      pcall(require, "hopcsharp")
    end,
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp" },
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    cmd = { "Dotnet" },
    config = function()
      local uv = vim.uv or vim.loop
      local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
      if vim.fn.isdirectory(dotnet_tools) == 1 then
        vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
      end

      local data = vim.fn.stdpath("data")
      local debugger_bin = nil
      if uv.fs_stat(data .. "/mason/bin/netcoredbg") then
        debugger_bin = data .. "/mason/bin/netcoredbg"
      elseif uv.fs_stat(data .. "/mason/packages/netcoredbg/netcoredbg") then
        debugger_bin = data .. "/mason/packages/netcoredbg/netcoredbg"
      elseif vim.fn.executable("netcoredbg") == 1 then
        debugger_bin = "netcoredbg"
      end

      require("easy-dotnet").setup({
        lsp = { enabled = false },
        auto_install_easy_dotnet_server = false,
        debugger = {
          auto_register_dap = false,
          bin_path = debugger_bin,
          console = "integratedTerminal",
          apply_value_converters = true,
          mappings = { open_variable_viewer = { lhs = "T", desc = "open variable viewer" } },
        },
        managed_terminal = {
          auto_hide = true,
          auto_hide_delay = 15000,
          mappings = {
            next_tab = { lhs = "<Tab>", desc = "Next terminal tab" },
            prev_tab = { lhs = "<S-Tab>", desc = "Previous terminal tab" },
            new_terminal = { lhs = "+", desc = "New user terminal" },
            close_terminal = { lhs = "X", desc = "Close current terminal tab" },
            hide_panel = { lhs = "q", desc = "Hide terminal panel" },
          },
        },
        test_runner = { neotest_integration = true },
      })
    end,
  },
}
```

- [x] **Step 2: Write `lua/config/dap.lua`**

```lua
local dap = require("dap")
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

local function find_netcoredbg()
  local candidates = {
    mason_bin .. "/netcoredbg",
    mason_bin .. "/../packages/netcoredbg/netcoredbg",
    vim.fn.exepath("netcoredbg"),
  }
  for _, p in ipairs(candidates) do
    if p and p ~= "" then
      local stat = vim.loop.fs_stat or vim.uv.fs_stat
      if stat(p) then return p end
    end
  end
  return nil
end

local cmd = find_netcoredbg()
if not cmd then return end

local adapter = {
  type = "executable",
  command = cmd,
  args = { "--interpreter=vscode" },
  options = { detached = false },
}

dap.adapters.netcoredbg = adapter
dap.adapters.coreclr = adapter
dap.adapters["easy-dotnet"] = function(callback, config)
  if config and config.port then
    callback({ type = "server", host = config.host or "127.0.0.1", port = config.port })
  else
    callback(adapter)
  end
end

dap.configurations.cs = dap.configurations.cs or {}
table.insert(dap.configurations.cs, {
  type = "coreclr",
  name = "Launch app",
  request = "launch",
  console = "internalConsole",
  program = function()
    vim.fn.system("dotnet build -c Debug 2>&1")
    local dll = vim.fn.input("DLL path: ", vim.fn.getcwd() .. "/bin/Debug/net10.0/", "file")
    if dll == "" then return nil end
    return dll
  end,
})
```

- [x] **Step 3: Write `lua/plugins/dap.lua`**

```lua
require("config.dap")

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
  },

  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = {
      controls = { enabled = false },
      expand_lines = true,
      floating = { border = "rounded" },
      render = {
        max_type_length = 60,
        max_value_lines = 200,
      },
      layouts = {
        {
          elements = {
            { id = "console", size = 0.25 },
            { id = "scopes", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 20,
          position = "bottom",
        },
      },
    },
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      commented = false,
    },
  },
}
```

- [x] **Step 4: Write `lua/config/dap_breakpoints_panel.lua`**

Copy the file verbatim from the old config at `~/.config/nvim.bak-20260920/lua/config/dap_breakpoints_panel.lua` (134 lines). Verify after copy with `wc -l` (must be 134).

```bash
cp ~/.config/nvim.bak-20260920/lua/config/dap_breakpoints_panel.lua ~/.config/nvim/lua/config/dap_breakpoints_panel.lua
wc -l ~/.config/nvim/lua/config/dap_breakpoints_panel.lua
```

- [x] **Step 5: Install new plugins + clean boot**

```bash
nvim --headless "+Lazy! sync" +qa
echo "exit=$?"
```
Expected: `exit=0` (downloads roslyn.nvim, hopcsharp.nvim, easy-dotnet.nvim, nvim-dap-ui, nvim-dap-virtual-text).

Then: `nvim --headless "+qa" 2>&1; echo "exit=$?"` — expected `exit=0`, no Lua errors.

---

### Task 4: LSP polish — plugins/lsp.lua (omnisharp disabled)

**Files:**
- Create: `~/.config/nvim/lua/plugins/lsp.lua`

**Interfaces:**
- Consumes: LazyVim extras (mason, nvim-lspconfig, conform) from Task 2.
- Produces: `roslyn-language-server`/`csharpier`/`netcoredbg` in mason `ensure_installed`; LSP server opts for `cssls`, `tailwindcss`, `tsserver`, `html`, `yamlls`, `lua_ls`; `omnisharp` server disabled (so roslyn.nvim from Task 3 is the only C# server).

- [x] **Step 1: Write `lua/plugins/lsp.lua`**

```lua
return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "csharpier",
        "netcoredbg",
        "roslyn-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        -- roslyn.nvim is the C# LSP; keep omnisharp off
        omnisharp = { enabled = false },
        cssls = {},
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        tsserver = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        html = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        lua_ls = {
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      setup = {},
    },
  },
}
```

- [x] **Step 2: Install + clean boot**

```bash
nvim --headless "+Lazy! sync" +qa
echo "exit=$?"
```
Expected: `exit=0` (no new plugin downloads for this task; specs merged).

Then: `nvim --headless "+qa" 2>&1; echo "exit=$?"` — expected `exit=0`.

---

### Task 5: Misc plugins — misc.lua, editor.lua

**Files:**
- Create: `~/.config/nvim/lua/plugins/misc.lua`
- Create: `~/.config/nvim/lua/plugins/editor.lua`

**Interfaces:**
- Consumes: blink.cmp extra from Task 2 (for at-file integration).
- Produces: plugin specs for `tmux.nvim`, `undo-glow.nvim`, `mini.bracketed`, `refactoring.nvim`, `git.nvim`, `close-buffers.nvim`; blink `at_file` source provider (name `at_file`, module `at-file`).

- [x] **Step 1: Write `lua/plugins/misc.lua`**

```lua
return {
  -- tmux.nvim: seamless navigation between nvim splits and tmux panes
  {
    "aserowy/tmux.nvim",
    config = function()
      require("tmux").setup()
    end,
  },

  -- undo-glow.nvim: animated visual feedback for undo, redo, yank, paste, search
  {
    "y3owk1n/undo-glow.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      animation = {
        enabled = true,
        duration = 300,
        animation_type = "fade",
      },
      highlights = {
        undo = { hl_color = { bg = "#693232" } },
        redo = { hl_color = { bg = "#2F4640" } },
        yank = { hl_color = { bg = "#7A683A" } },
        paste = { hl_color = { bg = "#325B5B" } },
        search = { hl_color = { bg = "#5C475C" } },
      },
    },
    init = function()
      -- Highlight yanked text
      vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight yanked text",
        callback = function()
          require("undo-glow").yank()
        end,
      })
    end,
  },

  -- mini.bracketed: bracket navigation
  {
    "nvim-mini/mini.bracketed",
    event = "BufReadPost",
    config = function()
      local bracketed = require("mini.bracketed")
      bracketed.setup({
        file = { suffix = "" },
        window = { suffix = "" },
        quickfix = { suffix = "" },
        yank = { suffix = "" },
        treesitter = { suffix = "n" },
      })
    end,
  },

  -- refactoring.nvim: extract function/variable (visual mode)
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "lewis6991/async.nvim" },
    config = function()
      require("refactoring").setup({})
    end,
  },

  -- git.nvim: blame + browse
  {
    "dinhhuy258/git.nvim",
    event = "BufReadPre",
    opts = {
      keymaps = {
        blame = "<Leader>gb",
        browse = "<Leader>go",
      },
    },
  },

  -- close-buffers.nvim: close hidden/nameless buffers
  {
    "kazhala/close-buffers.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>th",
        function()
          require("close_buffers").delete({ type = "hidden" })
        end,
        desc = "Close Hidden Buffers",
      },
      {
        "<leader>tu",
        function()
          require("close_buffers").delete({ type = "nameless" })
        end,
        desc = "Close Nameless Buffers",
      },
    },
  },
}
```

- [x] **Step 2: Write `lua/plugins/editor.lua`**

```lua
return {
  -- at-file.nvim: @path completion in blink.cmp
  {
    "saghen/blink.cmp",
    dependencies = { "benborla/at-file.nvim" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      table.insert(opts.sources.default, "at_file")
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.at_file = {
        name = "AtFile",
        module = "at-file",
        score_offset = 100,
        opts = {
          integration = "blink",
          ignores = { ".git", "node_modules", "bin", "obj" },
        },
      }
    end,
  },
}
```

- [x] **Step 3: Install new plugins + clean boot**

```bash
nvim --headless "+Lazy! sync" +qa
echo "exit=$?"
```
Expected: `exit=0` (downloads tmux.nvim, undo-glow.nvim, mini.bracketed, refactoring.nvim, git.nvim, close-buffers.nvim, at-file.nvim).

Then: `nvim --headless "+qa" 2>&1; echo "exit=$?"` — expected `exit=0`, no Lua errors.

---

### Task 6: Keymaps + autocmds

**Files:**
- Create: `~/.config/nvim/lua/config/keymaps.lua`
- Create: `~/.config/nvim/lua/config/autocmds.lua`

**Interfaces:**
- Consumes: easy-dotnet `Dotnet` command + `config.dap_breakpoints_panel` from Task 3, `refactoring` from Task 5.
- Produces: `<leader>k` group, DAP F-keys, `<leader>dP`, personal binds, refactor visual binds; C#/F# inlay-hint + format-on-save autocmds.

- [x] **Step 1: Write `lua/config/keymaps.lua`**

```lua
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here.

local map = vim.keymap.set
local opts = { noremap = true, silent = true, nowait = true }

-- --- Register-safe keybinds (don't pollute registers) ---
map("n", "x", '"_x')

-- Increment/decrement with + and -
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- Select all
map("n", "<C-a>", "gg<S-v>G")

-- Jumplist: C-m as C-i (more reachable than C-i which requires Tab on some keyboards)
map("n", "<C-m>", "<C-i>", opts)

-- --- Highlight word under cursor without moving ---
map("n", "H", function()
  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    vim.opt.hlsearch = true
    vim.api.nvim_exec2([[let @/ = expand('<cword>')]], {})
  end
end, { desc = "Highlight word" })

-- --- Dotnet (.NET) keymaps ---
map("n", "<leader>k", "<Nop>", { desc = "Dotnet" })
map("n", "<leader>kb", "<cmd>Dotnet build<CR>", { desc = "Build" })
map("n", "<leader>kc", "<cmd>Dotnet clean<CR>", { desc = "Clean" })
map("n", "<leader>kx", function()
  vim.cmd("Dotnet clean")
  vim.cmd("Dotnet build")
end, vim.tbl_extend("force", opts, { desc = "Clean+Build" }))
map("n", "<leader>kr", "<cmd>Dotnet run<CR>", { desc = "Run" })
map("n", "<leader>kw", "<cmd>Dotnet watch<CR>", { desc = "Watch" })
map("n", "<leader>kt", "<cmd>Dotnet test<CR>", { desc = "Run tests" })
map("n", "<leader>ktt", "<cmd>Dotnet test<CR>", { desc = "Run tests" })
map("n", "<leader>kdd", '<cmd>lua require("dap").continue({ new = true })<CR>', { desc = "Debug tests" })
map("n", "<leader>ka", "<cmd>Dotnet add package<CR>", { desc = "Add package" })
map("n", "<leader>kP", "<cmd>Dotnet remove package<CR>", { desc = "Remove package" })
map("n", "<leader>ko", "<cmd>Dotnet outdated<CR>", { desc = "Outdated" })
map("n", "<leader>ks", "<cmd>Dotnet secrets<CR>", { desc = "Secrets" })
map("n", "<leader>kv", "<cmd>Dotnet<CR>", { desc = "Dotnet menu" })
map("n", "<leader>kT", function()
  pcall(function()
    require("easy-dotnet.terminal").toggle()
  end)
end, { desc = "Toggle terminal" })
map("n", "<leader>kD", "<cmd>Dotnet ef database update<CR>", { desc = "EF DB update" })
map("n", "<leader>km", function()
  local name = vim.fn.input("Migration name: ")
  if name ~= "" then
    vim.cmd("Dotnet ef migrations add " .. vim.fn.fnameescape(name))
  end
end, vim.tbl_extend("force", opts, { desc = "Add migration" }))
map("n", "<leader>kM", "<cmd>Dotnet ef migrations list<CR>", { desc = "List migrations" })

-- --- Buffer keymaps (save/reload) ---
map("n", "<leader>bS", function()
  vim.cmd("checktime") -- reload file if changed on disk
  vim.cmd("update") -- save buffer
  vim.notify("Buffer reloaded & saved", vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "Reload & save" }))

-- --- Debug (DAP) keymaps ---
local function dap()
  local ok, m = pcall(require, "dap")
  return ok and m
end
map("n", "<F5>", function()
  local m = dap()
  if m then m.continue() end
end, { desc = "DAP Continue" })
map("n", "<F9>", function()
  local m = dap()
  if m then m.toggle_breakpoint() end
end, { desc = "DAP Toggle Breakpoint" })
map("n", "<F10>", function()
  local m = dap()
  if m then m.step_over() end
end, { desc = "DAP Step Over" })
map("n", "<F11>", function()
  local m = dap()
  if m then m.step_into() end
end, { desc = "DAP Step Into" })
map("n", "<F12>", function()
  local m = dap()
  if m then m.step_out() end
end, { desc = "DAP Step Out" })
map("n", "<leader>dP", function()
  require("config.dap_breakpoints_panel").toggle()
end, vim.tbl_extend("force", opts, { desc = "Breakpoints panel" }))

-- --- Refactor keymaps (visual mode) ---
map("v", "<leader>re", "<Esc><cmd>lua require('refactoring').refactor('Extract Function')<CR>",
  vim.tbl_extend("force", opts, { desc = "Extract function" }))
map("v", "<leader>rv", "<Esc><cmd>lua require('refactoring').refactor('Extract Variable')<CR>",
  vim.tbl_extend("force", opts, { desc = "Extract variable" }))
```

- [x] **Step 2: Write `lua/config/autocmds.lua`**

```lua
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Enable LSP inlay hints for C# (type annotations inline, like Rider)
vim.api.nvim_create_augroup("lsp_inlay_hints", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = "lsp_inlay_hints",
  pattern = { "*.cs", "*.fs" },
  callback = function(args)
    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
  end,
})

-- Format on save for C# and F# via conform (csharpier) when available
vim.api.nvim_create_augroup("dotnet_format", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = "dotnet_format",
  pattern = { "*.cs", "*.fs" },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local conform = pcall(require, "conform")
    if conform then
      require("conform").format({ bufnr = bufnr })
    else
      pcall(function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end)
    end
  end,
})
```

- [x] **Step 3: Clean boot**

Run: `nvim --headless "+qa" 2>&1; echo "exit=$?"`
Expected: `exit=0`, no Lua errors (no new plugins in this task; specs only).

---

### Task 7: Full verification

**Files:**
- None (read-only checks). Fix any config files that produce errors.

**Interfaces:**
- Consumes: the complete config from Tasks 0-6.
- Produces: confidence the new config works; possibly small fixes.

- [x] **Step 1: Headless boot + Lazy stats**

```bash
nvim --headless "+qa" 2>&1; echo "exit=$?"
nvim --headless "+lua local s = require('lazy').stats(); print('loaded=' .. s.loaded .. ' count=' .. s.count)" +qa
```
Expected: `exit=0`, no Lua errors; `loaded` and `count` both positive.

- [x] **Step 2: `:checkhealth lazyvim`**

Run inside nvim: `:checkhealth lazyvim`
Expected: no ERROR rows. WARN about missing optional tools (e.g. `fzf`, `rg` dependencies) is acceptable.

- [x] **Step 3: Interactive .NET LSP check**

Open a `.cs` file in a real project (e.g. `nvim ~/Projects/Kalen/backend/ZivqonScheduler.Api/Program.cs`). Then:
- `:LspInfo` — roslyn must be the active client for the buffer; **omnisharp must NOT appear**.
- Inlay hints appear for C# code (autocmds from Task 6).

- [x] **Step 4: Interactive easy-dotnet check**

In the same `.cs` buffer:
- `:Dotnet build` — succeeds.
- `<leader>kr` — app runs.
- `<leader>kv` — `.NET` menu opens.
- `<leader>kT` — managed terminal toggles.

- [x] **Step 5: Interactive DAP check**

- Set a breakpoint (`<F9>`), then `<F5>` — netcoredbg launches (picks dll; if auto-path wrong, type the dll path).
- `<F10>`/`<F11>`/`<F12>` step; `<leader>dP` opens the breakpoints panel; dap-ui bottom layout renders.

- [x] **Step 6: Interactive neotest check**

- `<leader>t` (or `<leader>tt`) — dotnet tests appear via neotest-vstest.
- `<leader>ktt` runs tests via `Dotnet test`.

- [x] **Step 7: Interactive AI / completion / picker check**

- Copilot suggestions appear in a `.cs` file; `:CopilotChat` opens.
- blink.cmp completes; `@` triggers at-file provider in a Lua/Markdown buffer.
- `<leader><space>` (or `<leader>sf`) opens the snacks picker.

- [x] **Step 8: tmux check**

Inside a tmux session with nvim open: Ctrl+h/j/k/l moves across nvim splits and tmux panes.

- [x] **Step 9: Fix issues and re-verify**

If any check failed, fix the relevant file, re-run `nvim --headless "+Lazy! sync" +qa`, and re-run the failed check. Iterate until all pass.

---

### Task 8: Rollout — sync to chezmoi and commit dotfiles

**Files:**
- Modify: `~/Projects/dotfiles/dot_config/nvim/*` (chezmoi source)
- Modify: `~/Projects/dotfiles/docs/superpowers/plans/2026-09-20-nvim-rebuild.md` (this plan, checkboxes ticked)

**Interfaces:**
- Consumes: verified `~/.config/nvim` from Task 7.
- Produces: dotfiles repo commit with the new config; old config remains in dotfiles git history and at `~/.config/nvim.bak-20260920`.

- [x] **Step 1: Sync the new config into chezmoi**

```bash
rm -rf ~/Projects/dotfiles/dot_config/nvim
chezmoi add ~/.config/nvim
chezmoi managed | grep nvim | head -30
```
Expected: `chezmoi managed` lists the new nvim files (including `lazy-lock.json`, `lazyvim.json`).

- [x] **Step 2: Apply-check (no unexpected diffs)**

Run: `chezmoi diff`
Expected: no diff output (target matches source).

- [x] **Step 3: Commit the plan + config in the dotfiles repo**

```bash
cd ~/Projects/dotfiles
git add docs/superpowers/plans/2026-09-20-nvim-rebuild.md dot_config/nvim
git commit -m "nvim: rebuild from LazyVim starter"
```

- [x] **Step 4: Final sanity boot**

Run: `nvim --headless "+qa" 2>&1; echo "exit=$?"`
Expected: `exit=0`.

- [x] **Step 5: Offer cleanup**

Tell the user the old config is at `~/.config/nvim.bak-20260920` and ask if they want it deleted (it is also preserved in dotfiles git history). Do not delete without confirmation.

---