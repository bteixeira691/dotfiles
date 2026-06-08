-- Minimal Lua fallback for avante_templates when Rust binary is missing
local M = {}
local cache_dir, project_dir = nil, nil
local function try_read(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end
function M.initialize(cdir, pdir)
  cache_dir = cdir
  project_dir = pdir
end
local function find_template(name)
  local paths = {}
  if cache_dir and cache_dir ~= "" then table.insert(paths, cache_dir .. "/" .. name) end
  if project_dir and project_dir ~= "" then table.insert(paths, project_dir .. "/" .. name) end
  table.insert(paths, name)
  for _, p in ipairs(paths) do
    local s = try_read(p)
    if s then return s end
  end
  return nil
end
function M.render(template, context)
  local content = find_template(template)
  if not content then return "" end
  if type(context) == "table" then
    for k, v in pairs(context) do
      local val = v
      if type(v) ~= "string" then val = vim.inspect(v) end
      content = content:gsub("{{%s*" .. k .. "%s*}}", val)
    end
  end
  return content
end
return M
