return {
  -- undo-glow.nvim: animated visual feedback for undo, redo, yank, paste, search
  {
    "y3owk1n/undo-glow.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      animation = {
        enabled = true,
        -- 300ms per undo/yank/paste made fast editing feel laggy. 120ms is
        -- still visible but no longer delays the next keystroke.
        duration = 120,
        animation_type = "fade",
      },
      highlights = {
        undo = { hl_color = { bg = "#693232" } },
        redo = { hl_color = { bg = "#2F4640" } },
        yank = { hl_color = { bg = "#7A683A" } },
        paste = { hl_color = { bg = "#325B5B" } },
        search = { hl_color = { bg = "#5C475C" } },
      },
    },
    init = function()
      -- Highlight yanked text
      vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight yanked text",
        callback = function()
          require("undo-glow").yank()
        end,
      })
    end,
  },

  -- mini.bracketed: bracket navigation
  {
    "nvim-mini/mini.bracketed",
    event = "BufReadPost",
    config = function()
      local bracketed = require("mini.bracketed")
      bracketed.setup({
        file = { suffix = "" },
        window = { suffix = "" },
        quickfix = { suffix = "" },
        yank = { suffix = "" },
        treesitter = { suffix = "n" },
      })
    end,
  },

  -- refactoring.nvim: extract function/variable (visual mode)
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "lewis6991/async.nvim" },
    config = function()
      require("refactoring").setup({})
    end,
  },

  -- Scrolling animation is the one that feels like input lag on long files.
  -- Cursor/resize animations stay on.
  {
    "nvim-mini/mini.animate",
    opts = function(_, opts)
      opts.scroll = opts.scroll or {}
      opts.scroll.enable = false
      return opts
    end,
  },
}
