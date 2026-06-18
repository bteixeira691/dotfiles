return {
  {
    "saghen/blink.cmp",
    dependencies = { "benborla/at-file.nvim" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      table.insert(opts.sources.default, "at_file")
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.at_file = {
        name = "AtFile",
        module = "at-file",
        score_offset = 100,
        opts = {
          integration = "blink",
          ignores = { ".git", "node_modules", "bin", "obj" },
        },
      }
    end,
  },
}
