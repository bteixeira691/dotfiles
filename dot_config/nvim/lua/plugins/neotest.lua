-- Neotest: integrated test runner

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-pytest",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-rust",
      "nvim-neotest/neotest-dotnet",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-pytest")({
            dap = { justMyCode = false },
          }),
          require("neotest-jest")({
            jestCommand = "npx jest --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
          require("neotest-go")({
            experimental = true,
            args = {},
          }),
          require("neotest-rust")({
            args = { "--no-fail-fast" },
            runner = "neotest",
          }),
          require("neotest-dotnet")({
            dotnetcmd = "dotnet test",
          }),
        },
        status = { virtual_text = true, signs = true },
        output = { open_on_run = true },
        quickfix = { enabled = false, open = false },
        icons = {
          running_animated = { Text = "🟡" },
          passed = { Text = "✅" },
          running = { Text = "🔵" },
          failed = { Text = "❌" },
          skipped = { Text = "➖" },
          unknown = { Text = "🟦" },
        },
      })
    end,
    keys = {
      {
        "<leader>tt",
        function() require("neotest").run.run() end,
        desc = "Neotest: Run nearest",
      },
      {
        "<leader>tT",
        function() require("neotest").run.run(vim.fn.expand("%")) end,
        desc = "Neotest: Run file",
      },
      {
        "<leader>tr",
        function() require("neotest").run.run(vim.fn.getcwd()) end,
        desc = "Neotest: Run project",
      },
      {
        "<leader>td",
        function() require("neotest").run.run({ suite = false }) end,
        desc = "Neotest: Debug nearest",
      },
      {
        "<leader>ts",
        function() require("neotest").summary.toggle() end,
        desc = "Neotest: Summary",
      },
      {
        "<leader>to",
        function() require("neotest").output.open({ enter = true, auto_close = true }) end,
        desc = "Neotest: Output",
      },
      {
        "<leader>tO",
        function() require("neotest").output_panel.toggle() end,
        desc = "Neotest: Output panel",
      },
      {
        "<leader>tx",
        function()
          require("neotest").run.stop()
        end,
        desc = "Neotest: Stop",
      },
    },
  },
}
