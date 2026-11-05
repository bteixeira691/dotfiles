-- Cache compiled Lua modules on disk. Startup is already fast, but this also
-- helps runtime imports (LSP handlers, pickers, DAP) after the first load.
if vim.loader then
  vim.loader.enable()
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
