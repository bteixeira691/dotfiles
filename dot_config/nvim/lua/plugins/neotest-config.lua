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
      local ok, neotest = pcall(require, "neotest")
      if not ok then return end

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
