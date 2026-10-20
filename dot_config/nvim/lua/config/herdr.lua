-- Herdr integration: pane navigation + one-tab-per-service runner.
-- Everything here is a no-op when Neovim is not running inside Herdr.

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "herdr" })
end

function M.enabled()
  return vim.env.HERDR_ENV == "1" and vim.env.HERDR_PANE_ID ~= nil
end

local function bin()
  if vim.env.HERDR_BIN_PATH and vim.env.HERDR_BIN_PATH ~= "" then
    return vim.env.HERDR_BIN_PATH
  end
  return "herdr"
end

local function workspace()
  return vim.env.HERDR_WORKSPACE_ID or "w0"
end

---Run a Herdr CLI command and decode its JSON result.
---@param args string[]
---@return table|nil result, string|nil err
local function json(args)
  local cmd = { bin() }
  vim.list_extend(cmd, args)
  local ok, res = pcall(vim.system, cmd, { text = true })
  if not ok then
    return nil, tostring(res)
  end
  local out = res:wait()
  if out.code ~= 0 then
    return nil, (out.stderr ~= "" and out.stderr) or ("herdr exited with " .. out.code)
  end
  -- Mutating commands (pane run, send-keys, ...) succeed with empty or
  -- non-JSON output; only commands like `tab create` return a result object.
  if out.stdout == nil or vim.trim(out.stdout) == "" then
    return {}
  end
  local decoded_ok, decoded = pcall(vim.json.decode, out.stdout)
  if not decoded_ok then
    return {}
  end
  return decoded.result or decoded
end

local function fire(args)
  local cmd = { bin() }
  vim.list_extend(cmd, args)
  pcall(vim.system, cmd, { detach = true })
end

-- ---------------------------------------------------------------- navigation

---Move inside Neovim; at a split edge hand the direction to Herdr.
---@param wincmd string
---@param direction "left"|"right"|"up"|"down"
function M.nav(wincmd, direction)
  local previous = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= previous then
    return
  end
  if not M.enabled() then
    return
  end
  -- Target the pane explicitly: --current resolves to the globally focused
  -- pane, which is not necessarily the one this Neovim instance lives in.
  fire({ "pane", "focus", "--direction", direction, "--pane", vim.env.HERDR_PANE_ID })
end

-- Herdr's shell-side navigation (bin/herdr-nvim-nav) reads this marker to
-- return focus to the Neovim pane that was used last in a workspace.
function M.update_marker()
  if not M.enabled() then
    return
  end
  local cache = vim.env.XDG_CACHE_HOME or vim.fs.joinpath(vim.env.HOME, ".cache")
  local dir = vim.fs.joinpath(cache, "herdr")
  vim.fn.mkdir(dir, "p")
  pcall(vim.fn.writefile, { vim.env.HERDR_PANE_ID }, vim.fs.joinpath(dir, "nvim-pane-" .. workspace()))
end

function M.setup()
  if not M.enabled() then
    return
  end
  M.update_marker()
  local group = vim.api.nvim_create_augroup("herdr_nav", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    group = group,
    callback = M.update_marker,
  })
end

-- ------------------------------------------------------------------ services

local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "herdr-services.json")
local state = { services = {} }
local state_loaded = false

local function load_state()
  if state_loaded then
    return
  end
  state_loaded = true
  local ok, lines = pcall(vim.fn.readfile, state_file)
  if not ok then
    return
  end
  local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if decoded_ok and type(decoded) == "table" and type(decoded.services) == "table" then
    state.services = decoded.services
  end
end

local function save_state()
  vim.fn.mkdir(vim.fs.dirname(state_file), "p")
  pcall(vim.fn.writefile, { vim.json.encode(state) }, state_file)
end

local function pane_alive(pane_id)
  if not pane_id then
    return false
  end
  return json({ "pane", "get", pane_id }) ~= nil
end

local function focus_tab(tab_id)
  if not tab_id then
    return
  end
  json({ "tab", "focus", tab_id })
end

---@param project string
---@param profile { name: string|nil, port: integer|nil, url: string|nil }
---@param opts { watch?: boolean, port?: integer }
local function start_service(project, profile, opts)
  load_state()
  local key = table.concat({ workspace(), project, profile.name or "-", tostring(opts.port or 0) }, "|")

  local existing = state.services[key]
  if existing and pane_alive(existing.pane) then
    focus_tab(existing.tab)
    notify("Reusing running service: " .. existing.label)
    return
  end

  local dir = vim.fs.dirname(project)
  local name = vim.fs.basename(project):gsub("%.csproj$", "")
  local label = name
  if opts.port then
    label = string.format("%s :%d", name, opts.port)
  end
  if opts.watch then
    label = label .. " (watch)"
  end

  local created, err = json({ "tab", "create", "--label", label, "--cwd", dir, "--no-focus" })
  if not created or not created.root_pane or not created.tab then
    notify("Could not create Herdr tab: " .. (err or "unexpected response"), vim.log.levels.ERROR)
    return
  end

  local pane_id = created.root_pane.pane_id
  local tab_id = created.tab.tab_id
  json({ "pane", "rename", pane_id, label })

  local argv = { "dotnet", opts.watch and "watch" or "run", "--project", project }
  if profile.name then
    vim.list_extend(argv, { "--launch-profile", profile.name })
  end
  -- launchSettings wins over the environment, so pass --urls to the app itself.
  if opts.port and not opts.watch then
    vim.list_extend(argv, { "--", "--urls", string.format("http://localhost:%d", opts.port) })
  end

  local command = table.concat(vim.tbl_map(vim.fn.shellescape, argv), " ")
  local ran, run_err = json({ "pane", "run", pane_id, command })
  if not ran then
    notify("Could not start service: " .. (run_err or "unknown error"), vim.log.levels.ERROR)
    return
  end

  state.services[key] = {
    pane = pane_id,
    tab = tab_id,
    label = label,
    project = project,
    profile = profile.name,
    port = opts.port,
    watch = opts.watch or false,
    started = os.time(),
  }
  save_state()
  notify(string.format("Started %s in Herdr tab %s", label, tab_id))
end

---Start a service in its own Herdr tab, using its launchSettings profile.
---@param opts? { watch?: boolean, ask_port?: boolean }
function M.run_service(opts)
  opts = opts or {}
  if not M.enabled() then
    notify("Not running inside Herdr", vim.log.levels.WARN)
    return
  end
  local dotnet = require("config.dotnet")
  dotnet.select_project({ tests = false, prompt = opts.watch and "Watch service" or "Run service" }, function(project)
    if not project then
      return
    end
    local profiles = dotnet.read_profiles(project)
    dotnet.select_profile(profiles, function(profile)
      if not profile then
        return
      end
      if not opts.ask_port then
        return start_service(project, profile, { watch = opts.watch, port = profile.port })
      end
      local default = profile.port and tostring(profile.port) or ""
      vim.ui.input({ prompt = string.format("Port for %s [%s]: ", vim.fs.basename(project), default) }, function(input)
        if input == nil then
          return
        end
        local port = tonumber(vim.trim(input)) or profile.port
        start_service(project, profile, { watch = opts.watch, port = port })
      end)
    end)
  end)
end

---@return table[]
local function live_services()
  load_state()
  local list = {}
  local stale = false
  for key, service in pairs(state.services) do
    if pane_alive(service.pane) then
      service.key = key
      list[#list + 1] = service
    else
      state.services[key] = nil
      stale = true
    end
  end
  if stale then
    save_state()
  end
  table.sort(list, function(a, b)
    return a.label < b.label
  end)
  return list
end

---Pick a running service and jump to its Herdr tab.
function M.services_menu()
  local list = live_services()
  if #list == 0 then
    notify("No running services", vim.log.levels.WARN)
    return
  end
  if #list == 1 then
    return focus_tab(list[1].tab)
  end
  vim.ui.select(list, {
    prompt = "Herdr services",
    format_item = function(service)
      return service.label
    end,
  }, function(choice)
    if choice then
      focus_tab(choice.tab)
    end
  end)
end

local function show_logs(service)
  local cmd = { bin(), "pane", "read", service.pane, "--source", "recent-unwrapped", "--lines", "400" }
  local ok, res = pcall(vim.system, cmd, { text = true })
  local text
  if ok then
    local out = res:wait()
    text = out.code == 0 and out.stdout or ("could not read pane: " .. out.stderr)
  else
    text = "could not read pane: " .. tostring(res)
  end

  local lines = vim.split(text, "\n", { plain = true })
  while #lines > 1 and vim.trim(lines[#lines]) == "" do
    table.remove(lines)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "log"
  vim.bo[buf].modifiable = false

  local width = math.max(40, math.floor(vim.o.columns * 0.85))
  local height = math.max(10, math.floor(vim.o.lines * 0.8))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    style = "minimal",
    title = " " .. service.label .. " ",
    title_pos = "center",
  })
  vim.wo[win].wrap = false
  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, desc = "Close logs" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, desc = "Close logs" })
end

---Show the last lines of a running service without leaving Neovim.
function M.peek_logs()
  local list = live_services()
  if #list == 0 then
    notify("No running services", vim.log.levels.WARN)
    return
  end
  if #list == 1 then
    return show_logs(list[1])
  end
  vim.ui.select(list, {
    prompt = "Show logs for",
    format_item = function(service)
      return service.label
    end,
  }, function(choice)
    if choice then
      show_logs(choice)
    end
  end)
end

---Send Ctrl+C to every service started by this Neovim instance.
function M.stop_all()
  local list = live_services()
  if #list == 0 then
    notify("No running services", vim.log.levels.WARN)
    return
  end
  for _, service in ipairs(list) do
    fire({ "pane", "send-keys", service.pane, "ctrl+c" })
    state.services[service.key] = nil
  end
  save_state()
  notify(string.format("Stopped %d service(s)", #list))
end

return M
