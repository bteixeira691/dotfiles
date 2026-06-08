-- mason.nvim: non-LSP tools (formatters, linters, DAP adapters)
-- mason-lspconfig.nvim: LSP servers (C# is handled by roslyn.nvim via easy-dotnet)
return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "netcoredbg",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      -- LSP servers to auto-install.
      -- LazyVim extras (lang.docker, lang.json, lang.sql, lang.markdown, etc.)
      -- already populate this list automatically for their respective servers.
      -- Add extra servers here only if they are NOT covered by a LazyVim extra.
      ensure_installed = {
        "lua_ls",    -- Lua (neovim config)
        "jsonls",    -- JSON
      },
      -- Let LazyVim / nvim-lspconfig handle per-server setup.
      automatic_enable = true,
    },
  },
}
