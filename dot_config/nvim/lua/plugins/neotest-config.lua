-- neotest configuration with neotest-dotnet for C# tests + debug support
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "Issafalcon/neotest-dotnet",
        dependencies = { "mfussenegger/nvim-dap" },
        -- Fix: upstream returns {} instead of nil for empty spec lists,
        -- causing "attempt to index field 'context' (a nil value)"
        build = "sed -i 's/#specs < 0/#specs == 0/' lua/neotest-dotnet/utils/build-spec-utils.lua",
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
              adapter_name = "netcoredbg",
            },
            discovery_root = "solution",
          }),
        },
        -- LazyVim's neotest extra keymaps (set via which-key):
        -- <leader>tt = Run nearest test
        -- <leader>tT = Run file
        -- <leader>tl = Run last
        -- <leader>ts = Toggle summary
        -- <leader>to = Toggle output
      })
    end,
  },
}
