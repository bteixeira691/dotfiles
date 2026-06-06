-- nvim-dap: debugger with adapters for Python, Node, Rust, .NET

return {
  -- Adapter setup
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        config = function()
          require("dap-python").setup("python3")
          require("dap-python").test_runner = "pytest"
        end,
      },
      {
        "mfussenegger/nvim-dap-virtual-text",
        opts = {},
      },
    },
    keys = {
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "DAP: Toggle breakpoint",
      },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Condition: " }, function(input)
            require("dap").set_breakpoint(input)
          end)
        end,
        desc = "DAP: Conditional breakpoint",
      },
      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc = "DAP: Continue",
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc = "DAP: Step into",
      },
      {
        "<leader>do",
        function() require("dap").step_over() end,
        desc = "DAP: Step over",
      },
      {
        "<leader>dO",
        function() require("dap").step_out() end,
        desc = "DAP: Step out",
      },
      {
        "<leader>dr",
        function() require("dap").repl.toggle() end,
        desc = "DAP: REPL",
      },
      {
        "<leader>dl",
        function() require("dap").run_last() end,
        desc = "DAP: Run last",
      },
      {
        "<leader>dt",
        function() require("dap").terminate() end,
        desc = "DAP: Terminate",
      },
      {
        "<leader>du",
        function() require("dapui").toggle() end,
        desc = "DAP: UI toggle",
      },
    },
    config = function()
      local dap = require("dap")
      local mason_registry = require("mason-registry")
      local mason_bin = mason_registry.get_package("codelldb").get_install_path() .. "/extension/codelldb"
      local mason_bin_win = mason_registry.get_package("codelldb").get_install_path() .. "\\extension\\codelldb.exe"

      dap.adapters.codelldb = function(callback, conf)
        local cmd = vim.fn.executable(mason_bin) == 1 and mason_bin or mason_bin_win
        if vim.fn.executable(cmd) == 0 then
          vim.notify("codelldb adapter not found", vim.log.levels.ERROR)
          return
        end
        callback({
          type = "server",
          host = conf.host or "127.0.0.1",
          port = conf.port or "13000",
          executable = {
            command = cmd,
            args = { "--port", conf.port or "13000" },
          },
        })
      end

      dap.configurations.cs = {
        {
          type = "codelldb",
          name = "Launch .NET (current file)",
          request = "launch",
          program = function()
            local file = vim.fn.input("Path to .dll: ", "", "file")
            return file
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
        },
        {
          type = "codelldb",
          name = "Attach to .NET",
          request = "attach",
          pid = function()
            local handle = io.popen("pgrep -f 'dotnet' | head -1")
            local pid = handle:read("*a"):gsub("%s+", "")
            handle:close()
            return pid
          end,
        },
      }
    end,
  },
}
