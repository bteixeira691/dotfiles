require("config.dap")

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
  },

  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = {
      controls = { enabled = false },
      expand_lines = true,
      floating = { border = "rounded" },
      render = {
        max_type_length = 60,
        max_value_lines = 200,
      },
      layouts = {
        {
          elements = {
            { id = "console", size = 0.25 },
            { id = "scopes", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 20,
          position = "bottom",
        },
      },
    },
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      commented = false,
    },
  },
}
