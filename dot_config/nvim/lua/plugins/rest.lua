-- rest.nvim: run HTTP requests from Neovim (test APIs without leaving the editor)
return {
  "rest-nvim/rest.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    result_split_in_new_tab = true,
    skip_ssl_verification = false,
    encode_url = true,
    highlight = { enabled = true, timeout = 150 },
  },
  keys = {
    { "<leader>rr", "<cmd>Rest run<CR>", desc = "Run REST request" },
    { "<leader>rl", "<cmd>Rest last<CR>", desc = "Rerun last REST request" },
  },
}
