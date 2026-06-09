-- fff.nvim: fast fuzzy file finder (replaces Snacks picker for file/grep)
-- Config adapted from: https://github.com/Sin-cy/dotfiles
--
-- First run: install the fff binary with:
--   :Lazy build fff.nvim
-- This downloads a prebuilt binary or compiles from source (requires Rust + C compiler).

return {
  "dmtrKovalenko/fff.nvim",
  enabled = true,
  build = function()
    local ok, err = pcall(require("fff.download").download_or_build_binary)
    if not ok then
      vim.notify(
        "fff.nvim build failed: " .. tostring(err)
          .. ". Run :Lazy build fff.nvim to retry, or install the binary manually.",
        vim.log.levels.WARN
      )
    end
  end,
  lazy = false,
  config = function()
    require("fff").setup({
      install = {
        timeout = 1200, -- 20 minutes
      },
      title = "Find Files",
      max_results = 100,
      max_threads = 4,
      lazy_sync = true,
      prompt = "🛸 ",
      layout = {
        width = 0.75,
        height = 0.85,
        prompt_position = "bottom",
        preview_position = "right",
        preview_size = 0.5,
        flex = false,
      },
      preview = {
        enabled = true,
        max_lines = 100,
        max_size = 10 * 1024 * 1024, -- 10MB
        chunk_size = 8192,
        binary_file_threshold = 1024,
        line_numbers = false,
        wrap_lines = false,
        show_file_info = true,
      },
      keymaps = {
        close = { "<C-c>", "<Esc>" },
        select = "<CR>",
        select_split = "<C-s>",
        select_vsplit = "<C-v>",
        select_tab = "<C-t>",
        move_up = { "<Up>", "<C-p>", "<C-k>" },
        move_down = { "<Down>", "<C-n>", "<C-j>" },
        preview_scroll_up = "<C-u>",
        preview_scroll_down = "<C-d>",
      },
      git = {
        status_text_color = true,
      },
      hl = {
        border = "FloatBorder",
        normal = "Normal",
        cursor = "CursorLine",
        matched = "IncSearch",
        title = "Title",
        prompt = "Question",
        active_file = "Visual",
        frecency = "Number",
        debug = "Comment",
        git_staged = "FFFGitStaged",
        git_modified = "FFFGitModified",
        git_deleted = "FFFGitDeleted",
        git_renamed = "FFFGitRenamed",
        git_untracked = "FFFGitUntracked",
        git_ignored = "FFFGitIgnored",
      },
      frecency = {
        enabled = true,
        db_path = vim.fn.stdpath("cache") .. "/fff_nvim",
      },
      debug = {
        show_scores = false,
      },
    })
  end,
  keys = {
    {
      "<leader>ff",
      function()
        require("fff").find_files()
      end,
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>fF",
      function()
        require("fff").find_in_git_root()
      end,
      desc = "Find Files in Git Root",
    },
    {
      "<leader>sg",
      function()
        require("fff").live_grep({
          grep = { modes = { "fuzzy", "plain" } },
        })
      end,
      desc = "Grep (Root Dir)",
    },
    {
      "<leader>sG",
      function()
        require("fff").live_grep({
          grep = { modes = { "fuzzy", "plain" } },
        })
      end,
      desc = "Grep (cwd)",
    },
  },
}
