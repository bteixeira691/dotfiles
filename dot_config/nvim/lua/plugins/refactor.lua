return {
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "lewis6991/async.nvim" },
    config = function()
      local ok, refactoring = pcall(require, "refactoring")
      if not ok then
        vim.schedule(function()
          vim.notify("refactoring.nvim: failed to load. Install dependencies and run :Lazy sync", vim.log.levels.WARN)
        end)
        return
      end
      pcall(function() refactoring.setup({}) end)
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("lspsaga").setup({
        code_action = { num_shortcut = true },
        lightbulb = { enable = false }, -- use nvim-lightbulb plugin
      })
    end,
  },
  {
    "kosayoda/nvim-lightbulb",
    event = "VeryLazy",
    config = function()
      require("nvim-lightbulb").setup({ autocmd = { enabled = true } })
    end,
  },
}
