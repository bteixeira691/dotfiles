-- undo-glow.nvim: animated visual feedback for undo, redo, yank, paste, search
return {
  "y3owk1n/undo-glow.nvim",
  version = "*",
  event = "VeryLazy",
  opts = {
    animation = {
      enabled = true,
      duration = 300,
      animation_type = "fade",
    },
    highlights = {
      undo = { hl_color = { bg = "#693232" } },
      redo = { hl_color = { bg = "#2F4640" } },
      yank = { hl_color = { bg = "#7A683A" } },
      paste = { hl_color = { bg = "#325B5B" } },
      search = { hl_color = { bg = "#5C475C" } },
    },
  },
  init = function()
    -- Highlight yanked text
    vim.api.nvim_create_autocmd("TextYankPost", {
      desc = "Highlight yanked text",
      callback = function()
        require("undo-glow").yank()
      end,
    })
  end,
}
