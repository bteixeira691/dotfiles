return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      {
        "Issafalcon/neotest-dotnet",
        dependencies = { "mfussenegger/nvim-dap" },
      },
    },
    config = function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then return end

      neotest.setup({
        adapters = {
          require("neotest-dotnet")({
            dap = {
              args = { justMyCode = false },
              adapter_name = "coreclr",
            },
            discovery_root = "solution",
          }),
        },
      })
    end,
  },
}
