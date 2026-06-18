local M = {}

function M.toggle_inlay_hints()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end

function M.format_toggle()
  require("lazyvim.util").format.toggle()
end

return M
