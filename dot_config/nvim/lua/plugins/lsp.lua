-- LSP customizations.
-- LazyVim's lsp.lua provides sane defaults; we add per-server settings.

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Servers to ensure are installed by Mason (in addition to LazyVim defaults)
      servers = {
        "pyright",
        "ruff",
        "ts_ls",
        "rust_analyzer",
        -- Pick ONE C# LSP (csharp_ls is in LazyVim's dotnet extra by default;
        -- uncomment omnisharp to swap):
        -- "omnisharp",
        "sqls",
        "jsonls",
        "yamlls",
        "html",
        "cssls",
      },
    },
  },

  -- Per-server settings (added to LazyVim's existing config, NOT re-setup)
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        ["lua_ls"] = function(_, opts)
          local cmp = require("cmp")
          local capabilities = cmp.default_capabilities()
          opts = vim.tbl_deep_extend("force", opts, {
            capabilities = capabilities,
            settings = {
              Lua = {
                completion = { callSnippet = "Replace" },
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
          require("lspconfig").lua_ls.setup(opts)
        end,

        ["pyright"] = function(_, opts)
          opts.before_init = function(_, config)
            config.settings.python = vim.tbl_deep_extend("force",
              config.settings.python or {},
              { analysis = { typeCheckingMode = "basic" } }
            )
          end
          require("lspconfig").pyright.setup(opts)
        end,

        ["rust_analyzer"] = function(_, opts)
          opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
            ["rust-analyzer"] = {
              checkOnSave = { command = "clippy" },
              cargo = { allFeatures = true },
              inlayHints = { enabled = true },
            },
          })
          require("lspconfig").rust_analyzer.setup(opts)
        end,

        ["sqls"] = function(_, opts)
          opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
            sqls = {
              connections = {},
            },
          })
          require("lspconfig").sqls.setup(opts)
        end,
      },
    },
  },
}
-- NOTE: nvim-cmp is fully handled by LazyVim's nvim-cmp extra. We don't
-- override it here; customize by editing LazyVim's nvim-cmp.lua spec.
