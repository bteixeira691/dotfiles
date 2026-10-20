-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ---------------------------------------------------------------- editor QoL

-- Register-safe delete
map("n", "x", '"_x')

-- Increment/decrement with + and -
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- Select all
map("n", "<C-a>", "gg<S-v>G")

-- Jumplist: C-m as C-i (more reachable than Tab-based C-i)
map("n", "<C-m>", "<C-i>", { desc = "Jump forward" })

-- Highlight word under cursor without moving
map("n", "H", function()
  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    vim.opt.hlsearch = true
    vim.api.nvim_exec2([[let @/ = expand('<cword>')]], {})
  end
end, { desc = "Highlight word" })

-- Reload & save (useful after branch switches / dotnet run touching files)
map("n", "<leader>bS", function()
  vim.cmd("checktime")
  vim.cmd("update")
  vim.notify("Buffer reloaded & saved", vim.log.levels.INFO)
end, { desc = "Reload & save" })

-- ------------------------------------------------- Herdr pane <-> window nav

local herdr = require("config.herdr")
herdr.setup()

map("n", "<C-h>", function()
  herdr.nav("h", "left")
end, { desc = "Go to left window/pane" })
map("n", "<C-j>", function()
  herdr.nav("j", "down")
end, { desc = "Go to lower window/pane" })
map("n", "<C-k>", function()
  herdr.nav("k", "up")
end, { desc = "Go to upper window/pane" })
map("n", "<C-l>", function()
  herdr.nav("l", "right")
end, { desc = "Go to right window/pane" })

-- ------------------------------------------------------------ Debug (nvim-dap)

local function dap(fn)
  return function()
    local ok, mod = pcall(require, "dap")
    if ok then
      mod[fn]()
    end
  end
end

map("n", "<F5>", dap("continue"), { desc = "Debug: continue / start" })
map("n", "<F9>", dap("toggle_breakpoint"), { desc = "Debug: toggle breakpoint" })
map("n", "<F10>", dap("step_over"), { desc = "Debug: step over" })
map("n", "<F11>", dap("step_into"), { desc = "Debug: step into" })
map("n", "<F12>", dap("step_out"), { desc = "Debug: step out" })

-- Multiple sessions: easy-dotnet starts each debug run with new = true
map("n", "<leader>dS", function()
  require("config.dap_sessions").pick()
end, { desc = "Switch debug session" })
map("n", "<leader>dX", function()
  require("config.dap_sessions").terminate_all()
end, { desc = "Terminate all debug sessions" })
map("n", "<leader>dx", function()
  require("config.dap_breakpoints_panel").toggle()
end, { desc = "Debug breakpoints panel" })

-- ------------------------------------------------------------------- .NET

map("n", "<leader>k", "<Nop>", { desc = "Dotnet" })

-- Build
map("n", "<leader>kb", "<cmd>Dotnet build<CR>", { desc = "Build project" })
map("n", "<leader>kB", "<cmd>Dotnet build solution<CR>", { desc = "Build solution" })
map("n", "<leader>kc", "<cmd>Dotnet clean<CR>", { desc = "Clean" })
map("n", "<leader>kx", function()
  vim.cmd("Dotnet clean")
  vim.cmd("Dotnet build")
end, { desc = "Clean + build" })

-- Run / watch in Herdr (one tab per service)
map("n", "<leader>kr", function()
  require("config.herdr").run_service()
end, { desc = "Run service in Herdr" })
map("n", "<leader>kR", function()
  require("config.herdr").run_service({ ask_port = true })
end, { desc = "Run service on a custom port" })
map("n", "<leader>kw", function()
  require("config.herdr").run_service({ watch = true })
end, { desc = "Watch service in Herdr" })
map("n", "<leader>kl", function()
  require("config.herdr").services_menu()
end, { desc = "Focus running service" })
map("n", "<leader>kp", function()
  require("config.herdr").peek_logs()
end, { desc = "Peek service logs" })
map("n", "<leader>kX", function()
  require("config.herdr").stop_all()
end, { desc = "Stop all services" })

-- Debug (every invocation starts an additional session)
map("n", "<leader>kd", "<cmd>Dotnet debug profile<CR>", { desc = "Debug project + profile" })
map("n", "<leader>kdd", "<cmd>Dotnet debug default<CR>", { desc = "Debug default project" })
map("n", "<leader>ka", "<cmd>Dotnet debug attach<CR>", { desc = "Attach debugger" })

-- Tests
map("n", "<leader>kt", "<cmd>Dotnet testrunner<CR>", { desc = "Test runner" })
map("n", "<leader>ktt", "<cmd>Dotnet testrunner<CR>", { desc = "Test runner" })
map("n", "<leader>kC", function()
  require("config.coverage").run()
end, { desc = "Test coverage" })

-- Packages / project
map("n", "<leader>kA", "<cmd>Dotnet add package<CR>", { desc = "Add package" })
map("n", "<leader>kP", "<cmd>Dotnet remove package<CR>", { desc = "Remove package" })
map("n", "<leader>ko", "<cmd>Dotnet outdated<CR>", { desc = "Outdated packages" })
map("n", "<leader>ks", "<cmd>Dotnet secrets<CR>", { desc = "User secrets" })
map("n", "<leader>kv", "<cmd>Dotnet<CR>", { desc = "Dotnet menu" })
map("n", "<leader>kT", function()
  pcall(function()
    require("easy-dotnet.terminal").toggle()
  end)
end, { desc = "Dotnet terminal" })

-- EF Core
map("n", "<leader>kD", "<cmd>Dotnet ef database update<CR>", { desc = "EF: database update" })
map("n", "<leader>km", function()
  local name = vim.fn.input("Migration name: ")
  if name ~= "" then
    vim.cmd("Dotnet ef migrations add " .. vim.fn.fnameescape(name))
  end
end, { desc = "EF: add migration" })
map("n", "<leader>kM", "<cmd>Dotnet ef migrations list<CR>", { desc = "EF: list migrations" })

-- Refactor (visual mode)
map("v", "<leader>re", "<Esc><cmd>lua require('refactoring').refactor('Extract Function')<CR>", { desc = "Extract function" })
map("v", "<leader>rv", "<Esc><cmd>lua require('refactoring').refactor('Extract Variable')<CR>", { desc = "Extract variable" })
