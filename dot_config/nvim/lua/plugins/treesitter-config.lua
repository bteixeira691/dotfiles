return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {}, -- disable auto-install (fails due to Schannel SSL issue)
      auto_install = false, -- don't try to auto-install missing parsers
      sync_install = false,
    },
  },
}
