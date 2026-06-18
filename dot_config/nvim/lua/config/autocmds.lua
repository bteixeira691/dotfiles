-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

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
