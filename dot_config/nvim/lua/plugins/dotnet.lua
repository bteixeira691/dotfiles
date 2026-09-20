return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "csharp", "fsharp" },
    opts = {
      broad_search = true,
      lock_target = false,
    },
    config = function(_, opts)
      require("roslyn").setup(opts)
      -- mason's roslyn-language-server (5.11.0) has no --daemon-mode
      -- (added in 5.12.0-1.26453.19); drop it until the registry ships it.
      vim.lsp.config("roslyn", {
        cmd = {
          require("roslyn.utils").get_roslyn_lsp_path(),
          "--stdio",
          "--clientProcessId",
          tostring(vim.uv.os_getpid()),
        },
      })
    end,
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
      local uv = vim.uv or vim.loop
      local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
      if vim.fn.isdirectory(dotnet_tools) == 1 then
        vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
      end

      local data = vim.fn.stdpath("data")
      local debugger_bin = nil
      if uv.fs_stat(data .. "/mason/bin/netcoredbg") then
        debugger_bin = data .. "/mason/bin/netcoredbg"
      elseif uv.fs_stat(data .. "/mason/packages/netcoredbg/netcoredbg") then
        debugger_bin = data .. "/mason/packages/netcoredbg/netcoredbg"
      elseif vim.fn.executable("netcoredbg") == 1 then
        debugger_bin = "netcoredbg"
      end

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
    end,
  },
}