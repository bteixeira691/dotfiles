return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "Issafalcon/neotest-dotnet",
      "Nsidorenco/neotest-vstest",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-dotnet")({
            discovery_root = "project",
          }),
          require("neotest-vstest"),
        },
      })
    end,
  },
}
