-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here.

local map = vim.keymap.set
local opts = { noremap = true, silent = true, nowait = true }

-- --- Register-safe keybinds (don't pollute registers) ---
map("n", "x", '"_x')

-- Increment/decrement with + and -
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- Select all
map("n", "<C-a>", "gg<S-v>G")

-- Jumplist: C-m as C-i (more reachable than C-i which requires Tab on some keyboards)
map("n", "<C-m>", "<C-i>", opts)

-- --- Highlight word under cursor without moving ---
map("n", "H", function()
  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    vim.opt.hlsearch = true
    vim.api.nvim_exec2([[let @/ = expand('<cword>')]], {})
  end
end, { desc = "Highlight word" })

-- --- Dotnet (.NET) keymaps ---
map("n", "<leader>k", "<Nop>", { desc = "Dotnet" })
map("n", "<leader>kb", "<cmd>Dotnet build<CR>", { desc = "Build" })
map("n", "<leader>kc", "<cmd>Dotnet clean<CR>", { desc = "Clean" })
map("n", "<leader>kx", function()
  vim.cmd("Dotnet clean")
  vim.cmd("Dotnet build")
end, vim.tbl_extend("force", opts, { desc = "Clean+Build" }))
map("n", "<leader>kr", "<cmd>Dotnet run<CR>", { desc = "Run" })
map("n", "<leader>kw", "<cmd>Dotnet watch<CR>", { desc = "Watch" })
map("n", "<leader>kt", "<cmd>Dotnet test<CR>", { desc = "Run tests" })
map("n", "<leader>ktt", "<cmd>Dotnet test<CR>", { desc = "Run tests" })
map("n", "<leader>kdd", '<cmd>lua require("dap").continue({ new = true })<CR>', { desc = "Debug tests" })
map("n", "<leader>ka", "<cmd>Dotnet add package<CR>", { desc = "Add package" })
map("n", "<leader>kP", "<cmd>Dotnet remove package<CR>", { desc = "Remove package" })
map("n", "<leader>ko", "<cmd>Dotnet outdated<CR>", { desc = "Outdated" })
map("n", "<leader>ks", "<cmd>Dotnet secrets<CR>", { desc = "Secrets" })
map("n", "<leader>kv", "<cmd>Dotnet<CR>", { desc = "Dotnet menu" })
map("n", "<leader>kT", function()
  pcall(function()
    require("easy-dotnet.terminal").toggle()
  end)
end, { desc = "Toggle terminal" })
map("n", "<leader>kD", "<cmd>Dotnet ef database update<CR>", { desc = "EF DB update" })
map("n", "<leader>km", function()
  local name = vim.fn.input("Migration name: ")
  if name ~= "" then
    vim.cmd("Dotnet ef migrations add " .. vim.fn.fnameescape(name))
  end
end, vim.tbl_extend("force", opts, { desc = "Add migration" }))
map("n", "<leader>kM", "<cmd>Dotnet ef migrations list<CR>", { desc = "List migrations" })

-- --- Buffer keymaps (save/reload) ---
map("n", "<leader>bS", function()
  vim.cmd("checktime") -- reload file if changed on disk
  vim.cmd("update") -- save buffer
  vim.notify("Buffer reloaded & saved", vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "Reload & save" }))

-- --- Debug (DAP) keymaps ---
local function dap()
  local ok, m = pcall(require, "dap")
  return ok and m
end
map("n", "<F5>", function()
  local m = dap()
  if m then m.continue() end
end, { desc = "DAP Continue" })
map("n", "<F9>", function()
  local m = dap()
  if m then m.toggle_breakpoint() end
end, { desc = "DAP Toggle Breakpoint" })
map("n", "<F10>", function()
  local m = dap()
  if m then m.step_over() end
end, { desc = "DAP Step Over" })
map("n", "<F11>", function()
  local m = dap()
  if m then m.step_into() end
end, { desc = "DAP Step Into" })
map("n", "<F12>", function()
  local m = dap()
  if m then m.step_out() end
end, { desc = "DAP Step Out" })
map("n", "<leader>dP", function()
  require("config.dap_breakpoints_panel").toggle()
end, vim.tbl_extend("force", opts, { desc = "Breakpoints panel" }))

-- --- Refactor keymaps (visual mode) ---
map("v", "<leader>re", "<Esc><cmd>lua require('refactoring').refactor('Extract Function')<CR>",
  vim.tbl_extend("force", opts, { desc = "Extract function" }))
map("v", "<leader>rv", "<Esc><cmd>lua require('refactoring').refactor('Extract Variable')<CR>",
  vim.tbl_extend("force", opts, { desc = "Extract variable" }))