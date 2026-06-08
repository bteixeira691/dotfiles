-- Override copilot.lua to load before avante.nvim
-- avante.nvim needs copilot during its config phase (on VeryLazy),
-- but copilot.lua is lazy-loaded with event = "BufReadPost" in the default
-- LazyVim extra. Loading it eagerly ensures avante can detect it.
return {
  {
    "zbirenbaum/copilot.lua",
    lazy = false,
    priority = 50,
  },
}
