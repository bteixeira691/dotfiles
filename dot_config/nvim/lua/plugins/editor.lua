-- Editor tweaks + quality-of-life plugins on top of LazyVim.

return {
  -- Better comments
  {
    "numToStr/Comment.nvim",
    opts = {
      padding = true,
      sticky = true,
    },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts_balance = true,
        ts_config = {
          lua = { "string", "source" },
        },
      })
    end,
  },

  -- Better surround
  {
    "machakann/vim-surround",
    event = "VeryLazy",
  },

  -- Indent guides for code
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      indent = { char = "│" },
      use_treesitter = true,
      scope = { show_start = false, show_end = false, char = "│" },
    },
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings = {
        "<C-u>",
        "<C-d>",
        "<C-y>",
        "<C-e>",
        "<C-b>",
        "<C-f>",
      },
    },
  },

  -- Colorize hex colors in code
  {
    "folke/hex.nvim",
    config = function()
      require("hex").setup()
    end,
  },

  -- Which-key: visual keymap hints (LazyVim includes this)
  -- Just customize the appearance
  {
    "folke/which-key.nvim",
    opts = {
      icons = {
        mappings = vim.tbl_extend("force", {}, {
          Separator = "➜",
        }, require("lazyvim.plugins.ui.which-key").opts().icons.mappings or {}),
      },
    },
  },

  -- Gitsigns: git indicators in the sign column
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
        ignore_whitespace = false,
      },
    },
  },
}
