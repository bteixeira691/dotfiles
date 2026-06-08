-- nvim-rulebook: add inline comments to suppress diagnostics,
-- or look up rule documentation online
return {
  "chrisgrieser/nvim-rulebook",
  event = "VeryLazy",
  cmd = { "Rulebook" },
  keys = {
    { "<leader>di", "<cmd>Rulebook suppress<CR>", desc = "Suppress diagnostic inline" },
    { "<leader>dI", "<cmd>Rulebook lookup<CR>", desc = "Lookup diagnostic rule" },
  },
}
