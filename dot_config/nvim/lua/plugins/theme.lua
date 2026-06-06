-- Theme: Tokyo Night
-- (LazyVim includes tokyonight as a default; this picks it explicitly)

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",  -- night | storm | day | moon
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        functions = {},
        variables = {},
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}

-- To switch back to Aether (your Omarchy default), replace this file with:
-- return {
--   { "bjarneo/aether.nvim", branch = "v3", name = "aether", priority = 1000, opts = {} },
--   { "LazyVim/LazyVim", opts = { colorscheme = "aether" } },
-- }
