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