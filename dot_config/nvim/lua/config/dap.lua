local dap = require("dap")
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

local function find_netcoredbg()
  local candidates = {
    mason_bin .. "/netcoredbg",
    mason_bin .. "/../packages/netcoredbg/netcoredbg",
    vim.fn.exepath("netcoredbg"),
  }
  for _, p in ipairs(candidates) do
    if p and p ~= "" then
      local stat = vim.loop.fs_stat or vim.uv.fs_stat
      if stat(p) then return p end
    end
  end
  return nil
end

local cmd = find_netcoredbg()
if not cmd then
  vim.schedule(function()
    vim.notify("netcoredbg not found. Run :MasonInstall netcoredbg", vim.log.levels.WARN)
  end)
  return
end

local adapter = {
  type = "executable",
  command = cmd,
  args = { "--interpreter=vscode" },
  options = { detached = false },
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
    local dir = cwd
    local fs_stat = vim.loop.fs_stat or vim.uv.fs_stat
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
            local dll = dir .. "/bin/Debug/" .. tfm .. "/" .. name .. ".dll"
            if not fs_stat(dll) then
              vim.schedule(function()
                vim.notify("DLL not found. Build the project first.", vim.log.levels.WARN)
              end)
            end
            return dll
          end
        end
      end
      dir = vim.fn.fnamemodify(dir, ":h")
    end
    return vim.fn.input("DLL path: ", cwd .. "/bin/Debug/net10.0/", "file")
  end,
})
