-- DAP Breakpoints panel: bottom split with a logging REPL/terminal on the right
local M = {}
local api = vim.api
local items = {}
local bp_bufnr, repl_bufnr = nil, nil
local left_win, right_win = nil, nil
local buf_name = "DAP Breakpoints"
local panel_height = 12
local left_width = 70

local function create_bp_buf()
  if bp_bufnr and api.nvim_buf_is_valid(bp_bufnr) then return bp_bufnr end
  bp_bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_name(bp_bufnr, buf_name)
  api.nvim_buf_set_option(bp_bufnr, "buftype", "nofile")
  api.nvim_buf_set_option(bp_bufnr, "bufhidden", "hide")
  api.nvim_buf_set_option(bp_bufnr, "swapfile", false)
  api.nvim_buf_set_option(bp_bufnr, "buflisted", false)
  api.nvim_buf_set_option(bp_bufnr, "filetype", "dap-breakpoints")
  api.nvim_buf_set_option(bp_bufnr, "modifiable", false)
  api.nvim_buf_set_keymap(bp_bufnr, "n", "<CR>", "<cmd>lua require('config.dap_breakpoints_panel').jump_to()<CR>", { silent=true, noremap=true, nowait=true })
  api.nvim_buf_set_keymap(bp_bufnr, "n", "q", "<cmd>close<CR>", { silent=true, noremap=true, nowait=true })
  return bp_bufnr
end

local function open_repl_in_current_win()
  -- Create a terminal buffer directly in the current window.
  -- dap.repl.open() may open a floating window or split, which breaks the
  -- panel layout, so we avoid it and use a plain terminal instead.
  vim.cmd("terminal")
  repl_bufnr = api.nvim_get_current_buf()
  api.nvim_buf_set_name(repl_bufnr, "DAP Terminal")
  -- Hide line numbers and signcolumn in the terminal for a cleaner look
  pcall(api.nvim_set_option_value, "number", false, { win = api.nvim_get_current_win() })
  pcall(api.nvim_set_option_value, "relativenumber", false, { win = api.nvim_get_current_win() })
  pcall(api.nvim_set_option_value, "signcolumn", "no", { win = api.nvim_get_current_win() })
  if repl_bufnr and api.nvim_buf_is_valid(repl_bufnr) then
    pcall(api.nvim_buf_set_option, repl_bufnr, "filetype", "dap-repl")
  end
  return repl_bufnr
end

function M.refresh()
  local ok, bp_mod = pcall(require, "dap.breakpoints")
  if not ok then
    vim.notify("dap.breakpoints not available", vim.log.levels.WARN)
    return
  end
  local bps = bp_mod.get()
  local qf = bp_mod.to_qf_list(bps)
  items = qf
  local lines = {}
  for _, it in ipairs(qf) do
    local fname = api.nvim_buf_get_name(it.bufnr)
    local rel = fname ~= "" and vim.fn.fnamemodify(fname, ":~:.") or "[No name]"
    local text = it.text or ""
    table.insert(lines, string.format("%s:%d\t%s", rel, it.lnum, text))
  end
  if #lines == 0 then lines = {"No breakpoints set"} end
  local b = create_bp_buf()
  if not api.nvim_buf_is_valid(b) then return end
  api.nvim_buf_set_option(b, "modifiable", true)
  api.nvim_buf_set_lines(b, 0, -1, false, lines)
  api.nvim_buf_set_option(b, "modifiable", false)
end

function M.open()
  if left_win and api.nvim_win_is_valid(left_win) and right_win and api.nvim_win_is_valid(right_win) then
    api.nvim_set_current_win(left_win)
    return
  end
  -- create bottom split and put breakpoints on the left side of that strip
  vim.cmd("botright split")
  left_win = api.nvim_get_current_win()
  api.nvim_win_set_height(left_win, panel_height)
  local b = create_bp_buf()
  api.nvim_win_set_buf(left_win, b)
  -- create vertical split inside the bottom strip for the repl/terminal
  vim.cmd("vsplit")
  right_win = api.nvim_get_current_win()
  open_repl_in_current_win()
  pcall(api.nvim_win_set_width, left_win, left_width)
  M.refresh()
end

function M.close()
  if right_win and api.nvim_win_is_valid(right_win) then
    pcall(api.nvim_win_close, right_win, true)
    right_win = nil
  end
  if left_win and api.nvim_win_is_valid(left_win) then
    pcall(api.nvim_win_close, left_win, true)
    left_win = nil
  end
end

function M.toggle()
  if left_win and api.nvim_win_is_valid(left_win) then
    M.close()
  else
    M.open()
  end
end

function M.jump_to()
  local w = api.nvim_get_current_win()
  local pos = api.nvim_win_get_cursor(w)
  local row = pos[1]
  local it = items[row]
  if not it then
    vim.notify("No breakpoint on this line", vim.log.levels.INFO)
    return
  end
  local fname = api.nvim_buf_get_name(it.bufnr)
  M.close()
  if fname and fname ~= "" then
    vim.cmd("edit " .. vim.fn.fnameescape(fname))
    vim.cmd(tostring(it.lnum) .. "normal! zz")
  end
end

-- auto-refresh on DAP events
pcall(function()
  local ok, dap = pcall(require, "dap")
  if ok and dap.listeners and dap.listeners.after then
    dap.listeners.after.event_initialized["dap_breakpoints_panel"] = function() M.refresh() end
    dap.listeners.after.event_terminated["dap_breakpoints_panel"] = function() M.refresh() end
    dap.listeners.after.event_exited["dap_breakpoints_panel"] = function() M.refresh() end
    dap.listeners.after.event_stopped["dap_breakpoints_panel"] = function() M.refresh() end
    dap.listeners.after.event_continued["dap_breakpoints_panel"] = function() M.refresh() end
  end
end)

return M
