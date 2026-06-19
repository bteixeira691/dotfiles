-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here.

-- LazyVim already defines <leader>b (buffer), <leader>d (debug), <leader>r (refactor) groups.
-- which-key auto-discovers keymaps from `vim.keymap.set` with `desc`, so we don't need
-- the deprecated which_key.register() calls.

local map = vim.keymap.set
local opts = { noremap = true, silent = true, nowait = true }

-- --- Discipline: cowboy mode (warns on excessive h/j/k/l/+/-) ---
local discipline = require("craftzdog.discipline")
discipline.cowboy()

-- --- Register-safe keybinds (don't pollute registers) ---
-- Only add ones that don't conflict with LazyVim groups.
-- LazyVim uses <leader>p (yank history), <leader>c (code), <leader>d (debug), <leader>r (refactor).
map("n", "x", '"_x')

-- Increment/decrement with + and -
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- Select all
map("n", "<C-a>", "gg<S-v>G")

-- Disable continuations (o/O inserts blank line above/below)
map("n", "<Leader>o", "o<Esc>^Da", opts)
map("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist: C-m as C-i (more reachable than C-i which requires Tab on some keyboards)
map("n", "<C-m>", "<C-i>", opts)

-- --- LSP helpers (craftzdog) ---
map("n", "<leader>i", function()
  require("craftzdog.lsp").toggle_inlay_hints()
end, { desc = "Toggle inlay hints" })

map("n", "<leader>h", function()
  require("craftzdog.hsl").replace_hex_with_hsl()
end, { desc = "Replace hex with HSL" })

vim.api.nvim_create_user_command("ToggleAutoformat", function()
  require("craftzdog.lsp").format_toggle()
end, {})

-- --- Highlight word under cursor without moving ---
map("n", "H", function()
  local word = vim.fn.expand("<cword>")
  if word ~= "" then
    vim.opt.hlsearch = true
    vim.api.nvim_exec2([[let @/ = expand('<cword>')]], {})
  end
end, { desc = "Highlight word" })

-- --- Dotnet (.NET) keymaps ---
map("n", "<leader>k",  "<Nop>", { desc = "Dotnet" })
map("n", "<leader>kb", "<cmd>Dotnet build<CR>",        { desc = "Build" })
map("n", "<leader>kc", "<cmd>Dotnet clean<CR>",        { desc = "Clean" })
map("n", "<leader>kx", function()
  vim.cmd("Dotnet clean")
  vim.cmd("Dotnet build")
end, vim.tbl_extend("force", opts, { desc = "Clean+Build" }))
map("n", "<leader>kr", "<cmd>Dotnet run<CR>",          { desc = "Run" })
map("n", "<leader>kw", "<cmd>Dotnet watch<CR>",        { desc = "Watch" })
map("n", "<leader>kt", "<cmd>Dotnet test<CR>",  { desc = "Run tests" })
map("n", "<leader>ktt", "<cmd>Dotnet test<CR>", { desc = "Run tests" })
map("n", "<leader>kdt", function()
  require("dap").continue({ new = true })
end, { desc = "Debug test" })
map("n", "<leader>ka", "<cmd>Dotnet add package<CR>",  { desc = "Add package" })
map("n", "<leader>kP", "<cmd>Dotnet remove package<CR>", { desc = "Remove package" })
map("n", "<leader>ko", "<cmd>Dotnet outdated<CR>",     { desc = "Outdated" })
map("n", "<leader>ks", "<cmd>Dotnet secrets<CR>",      { desc = "Secrets" })
map("n", "<leader>kv", "<cmd>Dotnet<CR>",              { desc = "Dotnet menu" })
map("n", "<leader>kT", function()
  pcall(function() require("easy-dotnet.terminal").toggle() end)
end, { desc = "Toggle terminal" })
map("n", "<leader>kD", "<cmd>Dotnet ef database update<CR>", { desc = "EF DB update" })
map("n", "<leader>km", function()
  local name = vim.fn.input("Migration name: ")
  if name ~= "" then
    vim.cmd("Dotnet ef migrations add " .. vim.fn.fnameescape(name))
  end
end, vim.tbl_extend("force", opts, { desc = "Add migration" }))
map("n", "<leader>kM", "<cmd>Dotnet ef migrations list<CR>", { desc = "List migrations" })

-- --- ProjektGunnar (NuGet helpers) ---
map("n", "<leader>kp", "<Nop>", { desc = "ProjektGunnar" })
map("n", "<leader>kpa", "<cmd>ProjektGunnar AddNugetToProject<CR>", { desc = "Add NuGet" })
map("n", "<leader>kpr", "<cmd>ProjektGunnar RemoveNugetFromProject<CR>", { desc = "Remove NuGet" })
map("n", "<leader>kpu", "<cmd>ProjektGunnar UpdateNugetsInProject<CR>", { desc = "Update NuGets" })
map("n", "<leader>kpU", "<cmd>ProjektGunnar UpdateNugetsInSolution<CR>", { desc = "Update all NuGets" })
map("n", "<leader>kpA", "<cmd>ProjektGunnar AddProjectToProject<CR>", { desc = "Add project ref" })
map("n", "<leader>kpR", "<cmd>ProjektGunnar RemoveProjectFromProject<CR>", { desc = "Remove project ref" })
map("n", "<leader>kpS", "<cmd>ProjektGunnar AddProjectToSolution<CR>", { desc = "Add to solution" })
map("n", "<leader>kpf", "<cmd>ProjektGunnar ForgetCachedSolutionFile<CR>", { desc = "Forget cache" })

-- --- Buffer keymaps (save/reload) ---
-- LazyVim already registers <leader>b group; just add overrides
map("n", "<leader>bS", function()
  vim.cmd("checktime")  -- reload file if changed on disk
  vim.cmd("update")     -- save buffer
  vim.notify("Buffer reloaded & saved", vim.log.levels.INFO)
end, vim.tbl_extend("force", opts, { desc = "Reload & save" }))

-- --- Debug (DAP) keymaps ---
-- LazyVim defines <leader>d group: <leader>db = toggle breakpoint, <leader>dc = continue, etc.
-- Add IDE-style F-key shortcuts
local function dap()
  local ok, m = pcall(require, "dap")
  return ok and m
end
map("n", "<F5>", function() local m = dap(); if m then m.continue() end end, { desc = "DAP Continue" })
map("n", "<F9>", function() local m = dap(); if m then m.toggle_breakpoint() end end, { desc = "DAP Toggle Breakpoint" })
map("n", "<F10>", function() local m = dap(); if m then m.step_over() end end, { desc = "DAP Step Over" })
map("n", "<F11>", function() local m = dap(); if m then m.step_into() end end, { desc = "DAP Step Into" })
map("n", "<F12>", function() local m = dap(); if m then m.step_out() end end, { desc = "DAP Step Out" })
map("n", "<leader>dP", function()
  require("config.dap_breakpoints_panel").toggle()
end, vim.tbl_extend("force", opts, { desc = "Breakpoints panel" }))

-- --- Refactor keymaps ---
-- LazyVim already defines <leader>r group and code-action/rename.
-- Only add extract refactors (visual mode).
map("v", "<leader>re", "<Esc><cmd>lua require('refactoring').refactor('Extract Function')<CR>",
  vim.tbl_extend("force", opts, { desc = "Extract function" }))
map("v", "<leader>rv", "<Esc><cmd>lua require('refactoring').refactor('Extract Variable')<CR>",
  vim.tbl_extend("force", opts, { desc = "Extract variable" }))
