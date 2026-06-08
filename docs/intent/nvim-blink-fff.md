# Intent: nvim blink.cmp + fff.nvim

## Confirmed — 2026-06-08

- **Outcome:** Apply Sin-cy's full blink.cmp opts (luasnip + friendly-snippets, ghost_text, auto_brackets, cmdline, source providers) to the existing LazyVim config. Add fff.nvim for file finding and live grep, replacing the default Snacks picker for those specific actions.
- **User:** .NET developer. LazyVim-based config.
- **Why now:** Reference config has a blink.cmp with a complete snippet pipeline and a fast file finder to adopt.
- **Success:** Snippet expansion works via blink.cmp. These keymaps use fff:

  | Keymap | Action |
  |--------|--------|
  | `<leader>ff` | fff find_files |
  | `<leader>fF` | fff find_in_git_root |
  | `<leader>sg` | fff live_grep (root dir) |
  | `<leader>sG` | fff live_grep (cwd) |

  Everything else (buffers, diagnostics, symbols, git, etc.) stays on LazyVim's default Snacks picker.
- **Constraint:** LazyVim framework stays. .NET/DAP/test/refactoring tooling untouched. No keymap rebinding beyond swapping the 4 handlers.
- **Out of scope:** No config rewrite. No theme/UI/color changes. No removing existing plugins or LazyVim extras. fff does nothing for buffers.

## Files changed

| File | Change |
|------|--------|
| `lua/plugins/blink-fix.lua` | Replaced with luasnip + friendly-snippets + full blink.cmp opts |
| `lua/plugins/fff.lua` | New — fff.nvim plugin spec with keymap overrides |
| `lua/plugins/at-file.lua` | Fixed — removed broken `opts`/`config`, registered as blink.cmp source provider in blink-fix.lua |
