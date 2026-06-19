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
dap.adapters["easy-dotnet"] = function(callback, config)
  if config and config.port then
    callback({ type = "server", host = config.host or "127.0.0.1", port = config.port })
  else
    callback(adapter)
  end
end

dap.configurations.cs = dap.configurations.cs or {}
table.insert(dap.configurations.cs, {
  type = "coreclr",
  name = "Launch app",
  request = "launch",
  console = "internalConsole",
  program = function()
    vim.cmd("Dotnet build")
    return vim.fn.input("App DLL: ", vim.fn.getcwd() .. "/bin/Debug/net10.0/", "file")
  end,
})
table.insert(dap.configurations.cs, {
  type = "coreclr",
  name = "Debug tests",
  request = "launch",
  console = "internalConsole",
  program = function()
    vim.cmd("Dotnet build")
    return vim.fn.input("Test DLL: ", vim.fn.getcwd() .. "/bin/Debug/net10.0/", "file")
  end,
})
