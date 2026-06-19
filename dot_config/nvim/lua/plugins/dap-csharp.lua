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
            { id = "scopes", size = 0.5 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 15,
          position = "bottom",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 50,
          position = "right",
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
