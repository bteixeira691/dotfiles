return {
  -- Razor syntax highlighting. roslyn.nvim already provides Razor/CSHTML
  -- language-server support (co-hosting); this only adds the parser.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "razor" } },
  },

  -- Close/rename HTML-style tags in Razor markup.
  {
    "windwp/nvim-ts-autotag",
    opts = {
      aliases = {
        razor = "html",
      },
    },
  },

  -- Emmet abbreviations in Blazor markup (`div.card` -> <div class="card">).
  -- Mason installs the server; it only completes, so it won't add diagnostics.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        emmet_language_server = {
          filetypes = { "html", "css", "scss", "razor" },
        },
      },
    },
  },
}
