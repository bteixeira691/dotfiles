-- C# debugging: netcoredbg adapter + smart launch config
-- The DAP Core extra (lazyvim.plugins.extras.dap.core) handles the base
-- nvim-dap/nvim-dap-ui setup, keymaps, and auto-open/close.
return {
  -- Add C# adapter and smart auto-discovery launch config
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      -- Locate netcoredbg from Mason first (not always in PATH at plugin load time)
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
      local fs_stat = vim.loop.fs_stat or vim.uv.fs_stat
      local netcoredbg_cmd = fs_stat(mason_bin) and mason_bin or "netcoredbg"

      -- Fix LazyVim dotnet extra's netcoredbg adapter if exepath returned ""
      if dap.adapters["netcoredbg"] and dap.adapters["netcoredbg"].command == "" then
        dap.adapters["netcoredbg"].command = netcoredbg_cmd
      end

      -- Smart auto-discovery: walk up from cwd to find the executable .csproj
      -- (Microsoft.NET.Sdk.Web), parse <TargetFramework>, build DLL path.
      local function find_executable_dll()
        local cwd = vim.fn.getcwd()
        local dir = cwd
        while dir and dir ~= "/" do
          for _, entry in ipairs(vim.fn.readdir(dir) or {}) do
            local full_path = dir .. "/" .. entry
            local stat = fs_stat(full_path)
            if stat and stat.type == "file" and entry:match("%.csproj$") then
              local ok, lines = pcall(vim.fn.readfile, full_path)
              if ok and lines then
                local content = table.concat(lines, " ")
                if content:find('Sdk="Microsoft%.NET%.Sdk%.Web"') then
                  local name = entry:gsub("%.csproj$", "")
                  local tfm = "net10.0"
                  for _, line in ipairs(lines) do
                    local tf = line:match("<TargetFramework>(.-)</TargetFramework>")
                    if tf then tfm = tf; break end
                  end
                  local dll = dir .. "/bin/Debug/" .. tfm .. "/" .. name .. ".dll"
                  if not fs_stat(dll) then
                    vim.schedule(function()
                      vim.notify("DLL not found at " .. dll .. ". Run 'dotnet build' first.", vim.log.levels.WARN)
                    end)
                  end
                  return dll
                end
              end
            elseif stat and stat.type == "directory" then
              for _, sub in ipairs(vim.fn.readdir(full_path) or {}) do
                if sub:match("%.csproj$") then
                  local sub_path = full_path .. "/" .. sub
                  local ok2, lines2 = pcall(vim.fn.readfile, sub_path)
                  if ok2 and lines2 then
                    local content2 = table.concat(lines2, " ")
                    if content2:find('Sdk="Microsoft%.NET%.Sdk%.Web"') then
                      local name = sub:gsub("%.csproj$", "")
                      local tfm = "net10.0"
                      for _, line in ipairs(lines2) do
                        local tf = line:match("<TargetFramework>(.-)</TargetFramework>")
                        if tf then tfm = tf; break end
                      end
                      local dll = full_path .. "/bin/Debug/" .. tfm .. "/" .. name .. ".dll"
                      if not fs_stat(dll) then
                        vim.schedule(function()
                          vim.notify("DLL not found at " .. dll .. ". Run 'dotnet build' first.", vim.log.levels.WARN)
                        end)
                      end
                      return dll
                    end
                  end
                end
              end
            end
          end
          dir = vim.fn.fnamemodify(dir, ":h")
        end
        return vim.fn.input("Path to executable DLL: ", cwd .. "/bin/Debug/net10.0/", "file")
      end

      -- Register the smart launch config if not already present
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
          name = "Launch (auto-detect)",
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

  -- Disable nvim-dap-ui winbar controls to avoid the nil element crash
  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = {
      controls = { enabled = false },
    },
  },
}
