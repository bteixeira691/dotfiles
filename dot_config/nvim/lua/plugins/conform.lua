-- Conform.nvim: auto-format on save with per-filetype formatters.
-- LazyVim already configures conform via extras; this adds fine-tuning.

return {
  {
    "stevearc/conform.nvim",
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable format-on-save for specific filetypes
        local ignore = { "sql", "markdown" }
        return not vim.tbl_contains(ignore, vim.bo[bufnr].filetype)
      end,
      formatters_by_ft = {
        -- Override LazyVim defaults with our preferred toolchain
        python          = { "ruff_fix", "ruff_format" },
        javascript      = { "prettierd", "prettier", stop_after_first = true },
        typescript      = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json            = { "prettierd", "prettier", stop_after_first = true },
        yaml            = { "prettierd", "prettier", stop_after_first = true },
        html            = { "prettierd", "prettier", stop_after_first = true },
        css             = { "prettierd", "prettier", stop_after_first = true },
        scss            = { "prettierd", "prettier", stop_after_first = true },
        rust            = { "rustfmt", "rustic_format" },
        go              = { "goimports", "gofmt" },
        lua             = { "stylua" },
        csharp          = { "csharpier", "dotnet_format" },
        cs              = { "csharpier", "dotnet_format" },
        sql             = { "sqlfluff" },
        markdown        = { "prettierd", "prettier", "markdownlint_fix", stop_after_first = true },
        sh              = { "shfmt" },
        bash            = { "shfmt" },
      },
    },
  },
}
