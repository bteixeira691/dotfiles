return {
  -- Herdr sidebar (one persistent nvim per Herdr tab), file picker and
  -- code annotations that get sent to the agent in the workspace.
  -- Herdr side: herdr plugin install ChmaraX/herdr-nvim
  -- Keys:      prefix+e (sidebar), prefix+o (pick file) in ~/.config/herdr/config.toml
  {
    "ChmaraX/herdr-nvim",
    -- config/lazy.lua defaults every plugin to lazy = true, so declare a trigger
    event = "VeryLazy",
    opts = {},
  },
}
