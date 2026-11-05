-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local group = vim.api.nvim_create_augroup("dotnet", { clear = true })

-- Inlay hints for C#/F#. The hint categories themselves are configured in
-- lua/plugins/dotnet.lua via the Roslyn `csharp|inlay_hints` settings.
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  pattern = { "*.cs", "*.fs", "*.razor" },
  callback = function(args)
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = args.buf })
  end,
})

-- Pick up changes made outside Neovim (branch switch, dotnet CLI, git pull).
-- Throttled: `checktime` stats every loaded buffer, and tmux/herdr focus
-- changes can fire it several times per second on large repos.
local last_checktime = 0
vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  callback = function()
    local now = vim.uv.now()
    if now - last_checktime < 1000 then
      return
    end
    last_checktime = now
    if vim.fn.getcmdwintype() == "" then
      pcall(vim.cmd, "checktime")
    end
  end,
})

-- Formatting on save is handled by LazyVim (conform + csharpier).
-- Do not add a second BufWritePre hook here.
