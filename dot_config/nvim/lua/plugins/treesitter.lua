-- Treesitter: parsers for syntax highlighting and code analysis
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- Auto-install disabled to avoid Schannel SSL errors in this environment.
      -- Run :TSInstall <lang> manually or parsers are installed via the build step.
      ensure_installed = {},
      auto_install = false,
      sync_install = false,
    },
    build = ":TSUpdate",
  },
}
