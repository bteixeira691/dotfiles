-- tmux.nvim: seamless navigation between nvim splits and tmux panes
return {
  "aserowy/tmux.nvim",
  config = function()
    require("tmux").setup()
  end,
}
