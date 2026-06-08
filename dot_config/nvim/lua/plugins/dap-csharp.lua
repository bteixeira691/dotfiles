-- nvim-dap C# debugging with nvim-dap-ui
-- The dotnet LazyVim extra (lazyvim.plugins.extras.lang.dotnet) registers a
-- basic netcoredbg adapter + "Launch file" prompt. easy-dotnet.nvim (dotnet.lua)
-- registers its own "easy-dotnet" adapter with auto-attach.
-- This file adds the DAP UI (windows, listeners) and a smarter launch config
-- that defaults to the executable project (not the class library).
return {
  {
    "mfussenegger/nvim-dap",
    -- nvim-dap-virtual-text is handled by its own plugin spec (dap-virtual-text.lua)
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        -- nvim-dap-ui requires nvim-nio at require() time
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
          { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "x" } },
        },
        config = function()
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup({
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.33 },
                  { id = "stacks", size = 0.33 },
                  { id = "breakpoints", size = 0.34 },
                },
                size = 50,
                position = "left",
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                size = 15,
                position = "bottom",
              },
            },
            floating = {
              max_height = 0.5,
              max_width = 0.5,
              mappings = { close = { "q", "<Esc>" } },
            },
            controls = {
              enabled = false,
            },
            mappings = {
              expand = { "<CR>", "<2-LeftMouse>" },
              open = "o",
              remove = "d",
              edit = "e",
              repl = "r",
              toggle = "t",
              watch = "w",
            },
          })
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end

          -- Ensure netcoredbg is registered as an adapter with a valid command.
          -- The LazyVim dotnet extra registers it via vim.fn.exepath("netcoredbg")
          -- but Mason installs netcoredbg to a non-standard path and exepath may
          -- not find it until the shell rc is sourced. Search Mason first.
          local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
          local netcoredbg_cmd = vim.loop.fs_stat(mason_bin) and mason_bin or "netcoredbg"
          if not dap.adapters["netcoredbg"] then
            dap.adapters["netcoredbg"] = {
              type = "executable",
              command = netcoredbg_cmd,
              args = { "--interpreter=vscode" },
              options = { detached = false },
            }
          elseif dap.adapters["netcoredbg"].command == "" then
            dap.adapters["netcoredbg"].command = netcoredbg_cmd
          end

          -- Extract TFM from csproj lines and return the expected DLL path.
          local function build_dll_path(entry, lines, project_dir)
            local name = entry:gsub("%.csproj$", "")
            local tfm = "net10.0"
            for _, line in ipairs(lines) do
              local tf = line:match("<TargetFramework>(.-)</TargetFramework>")
              if tf then tfm = tf; break end
            end
            local dll = project_dir .. "/bin/Debug/" .. tfm .. "/" .. name .. ".dll"
            if vim.loop.fs_stat(dll) then
              return dll
            else
              vim.schedule(function()
                vim.notify(
                  "DLL not found at " .. dll .. ". Run 'dotnet build' first.",
                  vim.log.levels.WARN
                )
              end)
              return dll
            end
          end

          -- Walk up from cwd to find the executable project (.csproj using
          -- Microsoft.NET.Sdk.Web).  This avoids launching class-library DLLs
          -- (Application, Domain, Infrastructure) which throw
          -- MissingMethodException / "entry point not found".
          -- Scans one level deep into subdirectories (the csproj is often in
          -- a subfolder like ShiftScheduler.API/ relative to the solution root).
          local function find_executable_dll()
            local cwd = vim.fn.getcwd()
            -- Walk up from cwd, scanning each directory for a .csproj that
            -- uses Microsoft.NET.Sdk.Web.  Scans one level deep into
            -- subdirectories (the csproj is often in a subfolder like
            -- ShiftScheduler.API/ShiftScheduler.API.csproj relative to the
            -- solution root).
            local dir = cwd
            while dir and dir ~= "/" do
              for _, entry in ipairs(vim.fn.readdir(dir) or {}) do
                local full_path = dir .. "/" .. entry
                local stat = vim.loop.fs_stat(full_path)
                -- readdir may return entries that disappeared between calls;
                -- skip them silently.
                if not stat then
                  -- cannot stat, skip this entry
                elseif stat.type == "file" and entry:match("%.csproj$") then
                  local ok, lines = pcall(vim.fn.readfile, full_path)
                  if ok and lines then
                    local content = table.concat(lines, " ")
                    if content:find('Sdk="Microsoft%.NET%.Sdk%.Web"') then
                      return build_dll_path(entry, lines, dir)
                    end
                  end
                elseif stat.type == "directory" then
                  -- Peek inside subdirectory for a csproj
                  for _, sub in ipairs(vim.fn.readdir(full_path) or {}) do
                    if sub:match("%.csproj$") then
                      local sub_path = full_path .. "/" .. sub
                      local ok2, lines2 = pcall(vim.fn.readfile, sub_path)
                      if ok2 and lines2 then
                        local content2 = table.concat(lines2, " ")
                        if content2:find('Sdk="Microsoft%.NET%.Sdk%.Web"') then
                          return build_dll_path(sub, lines2, full_path)
                        end
                      end
                    end
                  end
                end
              end
              -- Move up one directory
              dir = vim.fn.fnamemodify(dir, ":h")
            end
            -- Nothing found — prompt the user
            return vim.fn.input(
              "Path to executable DLL: ",
              cwd .. "/bin/Debug/net10.0/",
              "file"
            )
          end

          -- Add config if not already present
          dap.configurations.cs = dap.configurations.cs or {}
          local has_config = false
          for _, cfg in ipairs(dap.configurations.cs) do
            if cfg.name and cfg.name:find("Launch") and cfg.type == "netcoredbg" then
              has_config = true
              break
            end
          end
          if not has_config then
            table.insert(dap.configurations.cs, 1, {
              type = "netcoredbg",
              name = "Launch (netcoredbg)",
              request = "launch",
              program = find_executable_dll,
              cwd = "${workspaceFolder}",
              stopAtEntry = false,
              justMyCode = false,
              console = "integratedTerminal",
            })
          end
        end,
      },
    },
  },
}
