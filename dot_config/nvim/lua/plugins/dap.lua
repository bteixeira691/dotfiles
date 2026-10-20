return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      -- Open the UI for every new session (easy-dotnet can start several).
      require("dap").listeners.after.event_initialized["dotnet_dapui"] = function()
        pcall(function()
          require("dapui").open({})
        end)
      end
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = function(_, opts)
      opts.controls = { enabled = false }
      opts.expand_lines = true
      opts.floating = { border = "rounded" }
      opts.render = { max_type_length = 80, max_value_lines = 200 }
      opts.layouts = {
        {
          position = "right",
          size = 45,
          elements = {
            { id = "scopes", size = 0.55 },
            { id = "watches", size = 0.25 },
          },
        },
        {
          position = "bottom",
          size = 12,
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
        },
      }
      -- easy-dotnet registers these widgets only when it is loaded (C# buffers).
      -- Referencing them from another language's session would error.
      if package.loaded["easy-dotnet"] then
        table.insert(opts.layouts[1].elements, 2, { id = "easy-dotnet_cpu", size = 0.1 })
        table.insert(opts.layouts[1].elements, 3, { id = "easy-dotnet_mem", size = 0.1 })
      end
      return opts
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      commented = false,
    },
  },
}
