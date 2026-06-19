return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local dap = require("dap")
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

      local adapter = {
        type = "executable",
        command = mason_path,
        args = { "--interpreter=vscode" },
      }

      dap.adapters.netcoredbg = adapter
      dap.adapters.coreclr = adapter
      dap.adapters["easy-dotnet"] = adapter

      dap.configurations.cs = dap.configurations.cs or {}
      table.insert(dap.configurations.cs, {
        type = "coreclr",
        name = "Launch",
        request = "launch",
        program = function()
          local cwd = vim.fn.getcwd()
          local fs_stat = vim.loop.fs_stat or vim.uv.fs_stat
          local dir = cwd
          while dir and dir ~= "/" do
            for _, entry in ipairs(vim.fn.readdir(dir) or {}) do
              local full = dir .. "/" .. entry
              local stat = fs_stat(full)
              if stat and stat.type == "file" and entry:match("%.csproj$") then
                local ok, lines = pcall(vim.fn.readfile, full)
                if ok and lines then
                  local name = entry:gsub("%.csproj$", "")
                  local tfm = "net10.0"
                  for _, line in ipairs(lines) do
                    local tf = line:match("<TargetFramework>(.-)</TargetFramework>")
                    if tf then tfm = tf; break end
                  end
                  return dir .. "/bin/Debug/" .. tfm .. "/" .. name .. ".dll"
                end
              end
            end
            dir = vim.fn.fnamemodify(dir, ":h")
          end
          return vim.fn.input("DLL path: ", cwd .. "/bin/Debug/net10.0/", "file")
        end,
      })

      local dapui = require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DapBreakpointSymbol",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
      })
      vim.fn.sign_define("DapStopped", {
        text = "→",
        texthl = "DapStoppedSymbol",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
      })
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = {
      controls = { enabled = false },
      expand_lines = true,
      floating = { border = "rounded" },
      render = {
        max_type_length = 60,
        max_value_lines = 200,
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.5 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 15,
          position = "bottom",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 50,
          position = "right",
        },
      },
    },
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      commented = false,
    },
  },
}
