-- blink.cmp: completion with full opts from Sin-cy's dotfiles
-- Uses blink.cmp's built-in default snippet engine with friendly-snippets.
-- https://github.com/Sin-cy/dotfiles/tree/main/nvim/.config/nvim
return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      fuzzy = { implementation = "lua" }, -- fall back to Lua to avoid Schannel curl errors
      keymap = { preset = "default" },
      completion = {
        menu = { auto_show = true },
        documentation = { auto_show = true },
        ghost_text = { enabled = false, show_with_menu = false },
        accept = { auto_brackets = { enabled = true } },
      },
      cmdline = {
        enabled = true,
        keymap = { preset = "cmdline" },
        completion = { menu = { auto_show = true } },
      },
      sources = {
        default = { "lsp", "path", "buffer", "snippets" },
        providers = {
          lsp = {
            opts = { tailwind_color_icon = "󱓻" },
          },
          at_file = {
            name = "AtFile",
            module = "at-file",
            opts = {
              root = "auto",
              max_entries = 10000,
            },
          },
        },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },
      snippets = { preset = "default" },
    },
  },
}
