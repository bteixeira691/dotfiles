-- Switching between concurrent nvim-dap sessions.
-- easy-dotnet starts every debug session with dap.run(..., { new = true }),
-- so a microservice stack can be debugged in parallel.

local M = {}

local function dap()
  return require("dap")
end

---@return { id: any, name: string, state: string, session: any }[]
function M.list()
  local ok, sessions = pcall(function()
    return dap().sessions()
  end)
  if not ok then
    return {}
  end
  local out = {}
  for id, session in pairs(sessions) do
    local name = (session.config and session.config.name) or "session"
    out[#out + 1] = {
      id = id,
      name = name,
      state = session.stopped_thread_id and "stopped" or "running",
      session = session,
    }
  end
  table.sort(out, function(a, b)
    return tostring(a.id) < tostring(b.id)
  end)
  return out
end

---Pick one of the active sessions and make it the focused one.
function M.pick()
  local sessions = M.list()
  if #sessions == 0 then
    vim.notify("No active debug sessions", vim.log.levels.INFO, { title = "dap" })
    return
  end

  local current = dap().session()
  vim.ui.select(sessions, {
    prompt = "Debug sessions",
    format_item = function(session)
      local marker = current and current.id == session.id and "● " or "  "
      local name = session.name or "session"
      if session.session.config and session.session.config.project then
        name = session.session.config.project
      end
      return string.format("%s%s  [%s] %s", marker, name, tostring(session.id), session.state)
    end,
  }, function(choice)
    if not choice then
      return
    end
    dap().set_session(choice.session)
    pcall(function()
      require("dapui").open()
    end)
    vim.notify("Switched to debug session " .. tostring(choice.id), vim.log.levels.INFO, { title = "dap" })
  end)
end

---Terminate every top-level session at once.
function M.terminate_all()
  local ok, sessions = pcall(function()
    return dap().sessions()
  end)
  if not ok or next(sessions) == nil then
    vim.notify("No active debug sessions", vim.log.levels.INFO, { title = "dap" })
    return
  end
  dap().terminate({ all = true })
end

---Short status string, e.g. for a statusline.
function M.status()
  local sessions = M.list()
  if #sessions == 0 then
    return ""
  end
  local current = dap().session()
  local state = current and current.stopped_thread_id and "stopped" or "running"
  return string.format("DAP %d (%s)", #sessions, state)
end

return M
