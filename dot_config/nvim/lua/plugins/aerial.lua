-- aerial.nvim: code outline sidebar for navigating classes, methods, properties
return {
  "stevearc/aerial.nvim",
  event = "VeryLazy",
  opts = {
    close_on_select = true,
    show_linum = false,
    layout = {
      min_width = 28,
      default_direction = "right",
    },
  },
  keys = {
    { "<leader>cs", "<cmd>AerialToggle<CR>", desc = "Aerial (code outline)" },
  },
}
