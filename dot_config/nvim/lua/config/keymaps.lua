-- Custom keymaps on top of LazyVim's defaults.
-- LazyVim already binds the common LSP/file/buffer keys; only add what's missing.

local map = LazyVim.safe_keymap_set

-- Better window navigation: Alt + hjkl
map("n", "<A-h>", "<C-w>h", { desc = "Window left" })
map("n", "<A-j>", "<C-w>j", { desc = "Window down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window up" })
map("n", "<A-l>", "<C-w>l", { desc = "Window right" })

-- Move text up/down (visual)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })

-- Clear search highlight with <Esc>
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic (line)" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

-- Quick file save
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>w<cr>a", { desc = "Save file" })

-- Yank to system clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

-- Toggle line wrapping
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })

-- Close all but current
map("n", "<leader>qa", "<cmd>%bd|e#|bd#<cr>", { desc = "Close all but current" })

-- Quick terminal
map({ "n", "t" }, "<C-\\>", "<cmd>close<cr>", { desc = "Close terminal" })
