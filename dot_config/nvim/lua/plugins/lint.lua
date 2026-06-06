-- nvim-lint: in-editor linting with per-filetype linters.

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- LazyVim's linters_by_ft gets merged with this
      linters_by_ft = {
        python = { "ruff" },
        ["python.*"] = { "ruff" },
        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
        rust = { "clippy" },
        go = { "golangci_lint" },
        csharp = { "csharp_ls" },
        cs = { "csharp_ls" },
        sql = { "sqlfluff" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        yaml = { "yamllint" },
        dockerfile = { "hadolint" },
        terraform = { "tflint" },
        markdown = { "markdownlint" },
      },
    },
  },
}
