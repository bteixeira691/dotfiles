return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "csharpier",
        "netcoredbg",
        "emmet-language-server",
        -- roslyn-language-server is installed as a global dotnet tool and
        -- kept up to date from the Azure DevOps feed (daemon mode needs >= 5.12)
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Inlay hints are enabled per C# buffer in lua/config/autocmds.lua
      inlay_hints = { enabled = false },
      servers = {
        -- roslyn.nvim is the C# LSP; keep OmniSharp off
        omnisharp = { enabled = false },
        -- mason-lspconfig auto-enables every installed server; roslyn_ls would
        -- start a second, per-instance Roslyn next to the shared daemon.
        roslyn_ls = { enabled = false },
        csharp_ls = { enabled = false },

        cssls = {},
        html = {},
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        -- NOTE: `tsserver` no longer exists in nvim-lspconfig (renamed to
        -- `ts_ls`), so this block only produced an "invalid config" error on
        -- every TypeScript buffer. Enable `lazyvim.plugins.extras.lang.typescript`
        -- and configure `vtsls` if TS support is needed.
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
    },
  },
}
