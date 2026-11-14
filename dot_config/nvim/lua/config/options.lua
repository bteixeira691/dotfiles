-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- .NET global tools: roslyn-language-server, dotnet-ef, dotnet-easydotnet.
-- Put them on PATH before any plugin (roslyn.nvim resolves the server from it).
local dotnet_tools = vim.fs.joinpath(vim.fn.expand("~"), ".dotnet", "tools")
-- Mason tools (csharpier, html-lsp for Razor, lua-language-server, ...)
local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
-- PATH is `;`-separated on Windows (`vim.fs.pathsep` does not exist there).
local pathsep = package.config:sub(1, 1) == "\\" and ";" or ":"
for _, dir in ipairs({ dotnet_tools, mason_bin }) do
  if vim.fn.isdirectory(dir) == 1 then
    local path = vim.env.PATH or ""
    if not path:find(dir, 1, true) then
      vim.env.PATH = dir .. pathsep .. path
    end
  end
end

-- Hot reload: auto-reload when the file changes on disk
vim.opt.autoread = true

-- Use snacks as the default picker
vim.g.lazyvim_picker = "snacks"
