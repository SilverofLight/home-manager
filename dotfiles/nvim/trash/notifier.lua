return {
  {
    "vigoux/notifier.nvim",
    config = function()
      require 'notifier'.setup {
        -- You configuration here
      }
    end
  },
  {
    "rcarriga/nvim-notify",
    config = function ()
      require("notify").setup({
        top_down = false
      })
    end
  }
}
