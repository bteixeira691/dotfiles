-- Add virtual text support for nvim-dap (optional)
return {
  {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      pcall(function()
        require("nvim-dap-virtual-text").setup({
          enabled = true,
          commented = false,
        })
      end)
    end,
  },
}
