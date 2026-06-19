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
            { id = "scopes", size = 0.33 },
            { id = "stacks", size = 0.33 },
            { id = "watches", size = 0.34 },
          },
          size = 15,
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
