-- Debug keymaps (F-keys and <leader>d group)
-- Uses lazy.nvim's `keys` mechanism so it merges cleanly with dap-csharp.lua's config.
return {
  "mfussenegger/nvim-dap",
  keys = {
    { "<F5>",  function() require("dap").continue() end,        desc = "DAP: Continue" },
    { "<F6>",  function() require("dap").terminate() end,       desc = "DAP: Terminate" },
    { "<F9>",  function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
    { "<F10>", function() require("dap").step_over() end,       desc = "DAP: Step over" },
    { "<F11>", function() require("dap").step_into() end,       desc = "DAP: Step into" },
    { "<F12>", function() require("dap").step_out() end,        desc = "DAP: Step out" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
    { "<leader>dB", function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, desc = "DAP: Conditional breakpoint" },
    { "<leader>dr", function() require("dap").repl.open() end,  desc = "DAP: Open REPL" },
    { "<leader>dl", function() require("dap").run_last() end,   desc = "DAP: Run last" },
  },
}
