-- Options: personal tweaks on top of LazyVim defaults.
-- Don't override things LazyVim already sets well.

local opt = vim.opt

-- Editor feel
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.splitright = true
opt.splitbelow = true
opt.confirm = true
opt.termguicolors = true

-- Visual tweaks
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "" }
opt.foldlevel = 99
opt.foldenable = true
opt.list = true
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Search
opt.hlsearch = true
opt.incsearch = true

-- Indent guides + smart indent
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2

-- File handling
opt.swapfile = false
opt.backup = false
opt.autoread = true
opt.autowrite = true

-- Mouse: keep on for terminal users, off in TUI
if not vim.env.WAYLAND_DISPLAY and not vim.env.DISPLAY then
  opt.mouse = "a"
end

-- Clipboard: sync with system clipboard
opt.clipboard = "unnamedplus"

-- Persistent undo
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.fn.mkdir(vim.opt.undodir:get(), "p")
