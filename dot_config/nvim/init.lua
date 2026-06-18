-- bootstrap lazy.nvim, LazyVim and your plugins
_G.dd = function(...)
  require("util.debug").dump(...)
end
vim.print = _G.dd

require("config.lazy")
