return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "csharp", "fsharp" },
    opts = {
      broad_search = true,
      lock_target = false,
    },
  },
  {
    "leblocks/hopcsharp.nvim",
    ft = { "cs", "csharp" },
    config = function()
      pcall(require, "hopcsharp")
    end,
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp" },
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    cmd = { "Dotnet" },
    config = function()
      local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
      if vim.fn.isdirectory(dotnet_tools) == 1 then
        vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
      end

      local mason_data = vim.fn.stdpath("data")
      local mason_bin = mason_data .. "/mason/bin/netcoredbg"
      local mason_pkg = mason_data .. "/mason/packages/netcoredbg/netcoredbg"
      local debugger_bin = nil
      if vim.loop.fs_stat(mason_bin) then
        debugger_bin = mason_bin
      elseif vim.loop.fs_stat(mason_pkg) then
        debugger_bin = mason_pkg
      elseif vim.fn.executable("netcoredbg") == 1 then
        debugger_bin = "netcoredbg"
      end

      local ok, err = pcall(function()
        require("easy-dotnet").setup({
          lsp = { enabled = false },
          auto_install_easy_dotnet_server = false,
          debugger = {
            auto_register_dap = false,
            bin_path = debugger_bin,
            console = "integratedTerminal",
            apply_value_converters = true,
            mappings = { open_variable_viewer = { lhs = "T", desc = "open variable viewer" } },
          },
          managed_terminal = {
            auto_hide = true,
            auto_hide_delay = 15000,
            mappings = {
              next_tab = { lhs = "<Tab>", desc = "Next terminal tab" },
              prev_tab = { lhs = "<S-Tab>", desc = "Previous terminal tab" },
              new_terminal = { lhs = "+", desc = "New user terminal" },
              close_terminal = { lhs = "X", desc = "Close current terminal tab" },
              hide_panel = { lhs = "q", desc = "Hide terminal panel" },
            },
          },
          test_runner = { neotest_integration = true },
        })
      end)
      if not ok then
        vim.schedule(function()
          vim.notify("easy-dotnet: " .. tostring(err), vim.log.levels.WARN)
        end)
      end
    end,
  },
}
