return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      fuzzy = { implementation = "lua" }, -- fall back to Lua implementation to avoid Schannel curl errors
    },
  },
}
