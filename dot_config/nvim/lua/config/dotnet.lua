-- Shared helpers for .NET projects, launch profiles and test projects.
-- Used by the Herdr service runner and the coverage command.

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "dotnet" })
end

-- Repository root: prefer the git root so a monorepo lists every service.
function M.root()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = (buf ~= "" and vim.fs.dirname(buf)) or vim.uv.cwd()
  local git = vim.fs.root(start, { ".git" })
  if git then
    return git
  end
  return vim.fs.root(start, { "*.sln", "*.slnx", "*.csproj" }) or vim.uv.cwd()
end

local function fd()
  if vim.fn.executable("fd") == 1 then
    return "fd"
  end
  if vim.fn.executable("fdfind") == 1 then
    return "fdfind"
  end
end

local function is_test_project(path)
  local name = vim.fs.basename(path):gsub("%.csproj$", "")
  return name:match("[Tt]ests?$") ~= nil
    or name:match("%.Tests?$") ~= nil
    or name:match("Specs?$") ~= nil
    or name:match("[Ii]ntegration") ~= nil
end

---List .csproj files below `root`.
---@param opts? { root?: string, tests?: boolean|nil } tests=true -> only test projects, false -> exclude them, nil -> all
---@return string[]
function M.list_projects(opts)
  opts = opts or {}
  local root = opts.root or M.root()
  local found = {}

  local bin = fd()
  if bin then
    local cmd = {
      bin,
      "--color",
      "never",
      "--exclude",
      "bin",
      "--exclude",
      "obj",
      "--exclude",
      "node_modules",
      "--exclude",
      ".git",
      "-e",
      "csproj",
      ".",
      root,
    }
    local res = vim.system(cmd, { text = true }):wait()
    if res.code == 0 then
      for line in res.stdout:gmatch("[^\r\n]+") do
        if not vim.startswith(line, "/") then
          line = vim.fs.joinpath(root, line)
        end
        found[#found + 1] = vim.fs.normalize(line)
      end
    end
  else
    local matches = vim.fs.find(function(name)
      return name:match("%.csproj$") ~= nil
    end, { path = root, type = "file", limit = 2000 })
    for _, path in ipairs(matches) do
      found[#found + 1] = vim.fs.normalize(path)
    end
  end

  local seen, projects = {}, {}
  for _, path in ipairs(found) do
    if not seen[path] then
      seen[path] = true
      local test = is_test_project(path)
      if opts.tests == nil or test == opts.tests then
        projects[#projects + 1] = path
      end
    end
  end
  table.sort(projects)
  return projects
end

---@param path string
---@return string
function M.display_path(path)
  return vim.fn.fnamemodify(path, ":~:.")
end

---Select a project asynchronously. `cb(nil)` when cancelled.
---@param opts { tests?: boolean|nil, prompt?: string, root?: string }
---@param cb fun(project: string|nil)
function M.select_project(opts, cb)
  local projects = M.list_projects(opts)
  if #projects == 0 then
    notify("No .csproj found" .. (opts.tests == true and " (test projects)" or ""), vim.log.levels.WARN)
    return cb(nil)
  end
  if #projects == 1 then
    return cb(projects[1])
  end
  vim.ui.select(projects, {
    prompt = opts.prompt or "Select project",
    format_item = M.display_path,
  }, function(choice)
    cb(choice)
  end)
end

-- Remove // and /* */ comments plus trailing commas from a JSON5-ish file
-- (launchSettings.json is JSONC in practice). String contents are preserved.
local function strip_json5(text)
  local out = {}
  local i, n = 1, #text
  local in_string, escaped = false, false

  while i <= n do
    local c = text:sub(i, i)
    if in_string then
      out[#out + 1] = c
      if escaped then
        escaped = false
      elseif c == "\\" then
        escaped = true
      elseif c == '"' then
        in_string = false
      end
      i = i + 1
    elseif c == '"' then
      in_string = true
      out[#out + 1] = c
      i = i + 1
    elseif c == "/" and text:sub(i + 1, i + 1) == "/" then
      while i <= n and text:sub(i, i) ~= "\n" do
        i = i + 1
      end
    elseif c == "/" and text:sub(i + 1, i + 1) == "*" then
      i = i + 2
      while i <= n and not (text:sub(i, i) == "*" and text:sub(i + 1, i + 1) == "/") do
        i = i + 1
      end
      i = i + 2
    else
      out[#out + 1] = c
      i = i + 1
    end
  end

  return (table.concat(out):gsub(",%s*([}%]])", "%1"))
end

---Read launchSettings.json profiles for a project.
---@param project string
---@return { name: string|nil, url: string|nil, port: integer|nil, env: table<string,string>|nil }[]
function M.read_profiles(project)
  local dir = vim.fs.dirname(project)
  local path = vim.fs.joinpath(dir, "Properties", "launchSettings.json")
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return { { name = nil } }
  end

  local decoded_ok, data = pcall(vim.json.decode, strip_json5(table.concat(lines, "\n")))
  if not decoded_ok or type(data) ~= "table" then
    notify("Could not parse " .. path, vim.log.levels.WARN)
    return { { name = nil } }
  end

  local profiles = {}
  for name, profile in pairs(data.profiles or {}) do
    if type(profile) == "table" and profile.commandName == "Project" then
      local url = profile.applicationUrl
      profiles[#profiles + 1] = {
        name = name,
        url = url,
        port = url and tonumber(url:match(":(%d+)")) or nil,
        env = profile.environmentVariables,
      }
    end
  end
  table.sort(profiles, function(a, b)
    return a.name < b.name
  end)

  if #profiles == 0 then
    return { { name = nil } }
  end
  return profiles
end

---Select a launch profile asynchronously.
---@param profiles { name: string|nil, url: string|nil, port: integer|nil }[]
---@param cb fun(profile: { name: string|nil, url: string|nil, port: integer|nil }|nil)
function M.select_profile(profiles, cb)
  if #profiles == 1 then
    return cb(profiles[1])
  end
  vim.ui.select(profiles, {
    prompt = "Launch profile",
    format_item = function(profile)
      if profile.port then
        return string.format("%s  (%s)", profile.name, profile.url or profile.port)
      end
      return profile.name
    end,
  }, function(choice)
    cb(choice)
  end)
end

---Nearest solution file (used for solution-wide operations).
---@param root? string
---@return string|nil
function M.solution(root)
  local matches = vim.fs.find(function(name)
    return name:match("%.slnx?$") ~= nil
  end, { path = root or M.root(), upward = true, type = "file", limit = 1 })
  return matches[1]
end

return M
