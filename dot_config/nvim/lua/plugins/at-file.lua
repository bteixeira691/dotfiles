-- at-file.nvim: @-based file path completion for blink.cmp
return {
  "benborla/at-file.nvim",
  event = "VeryLazy",
  opts = {
    ---@type "blink" | "nvim-cmp"
    integration = "blink",
    ignores = {
      ".git",
      "node_modules",
      "bin",
      "obj",
    },
  },
  dependencies = {
    "saghen/blink.cmp",
  },
}
