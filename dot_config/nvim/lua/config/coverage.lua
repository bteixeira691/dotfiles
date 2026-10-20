-- Run a .NET test project with XPlat Code Coverage and summarize the result.

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "coverage" })
end

local function show_report(dir)
  local reports = vim.fs.find("coverage.cobertura.xml", { path = dir, type = "file", limit = 1 })
  if #reports == 0 then
    notify("No coverage.cobertura.xml produced in " .. dir, vim.log.levels.WARN)
    return
  end

  local xml = table.concat(vim.fn.readfile(reports[1]), "\n")
  local line_rate = tonumber(xml:match('line%-rate="([%d%.]+)"')) or 0
  local branch_rate = tonumber(xml:match('branch%-rate="([%d%.]+)"')) or 0

  local classes = {}
  for attrs in xml:gmatch("<class%s+([^>]*)>") do
    local filename = attrs:match('filename="([^"]+)"')
    local rate = tonumber(attrs:match('line%-rate="([%d%.]+)"'))
    if filename and rate then
      classes[#classes + 1] = { file = filename, rate = rate }
    end
  end
  table.sort(classes, function(a, b)
    return a.rate < b.rate
  end)

  local lines = {
    string.format("Lines:   %5.1f%%", line_rate * 100),
    string.format("Branches:%5.1f%%", branch_rate * 100),
    "",
    "Report: " .. reports[1],
    "",
    "Lowest coverage:",
  }
  for i = 1, math.min(#classes, 15) do
    lines[#lines + 1] = string.format("  %5.1f%%  %s", classes[i].rate * 100, classes[i].file)
  end
  if #classes == 0 then
    lines[#lines + 1] = "  (no per-file data)"
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "coverage"
  vim.bo[buf].modifiable = false

  local width = math.max(50, math.floor(vim.o.columns * 0.7))
  local height = math.min(math.max(10, #lines + 2), vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2)),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    style = "minimal",
    title = " Code coverage ",
    title_pos = "center",
  })
  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, desc = "Close coverage" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, desc = "Close coverage" })
end

---@param project string
function M.run_for(project)
  local outdir = vim.fs.joinpath(vim.fn.stdpath("state"), "coverage", os.date("%Y%m%d-%H%M%S"))
  vim.fn.mkdir(outdir, "p")
  local cmd = {
    "dotnet",
    "test",
    project,
    "--collect:XPlat Code Coverage",
    "--results-directory",
    outdir,
    "--logger",
    "console;verbosity=minimal",
  }
  notify("Running coverage: " .. vim.fs.basename(project))
  vim.system(cmd, { text = true, cwd = vim.fs.dirname(project) }, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      notify("Coverage run failed\n" .. (res.stderr or ""), vim.log.levels.ERROR)
      return
    end
    show_report(outdir)
  end))
end

function M.run()
  local dotnet = require("config.dotnet")
  dotnet.select_project({ tests = true, prompt = "Coverage: test project" }, function(project)
    if project then
      M.run_for(project)
    end
  end)
end

-- Exposed for tests / manual invocation with an existing report directory.
M.show_report = show_report

return M
