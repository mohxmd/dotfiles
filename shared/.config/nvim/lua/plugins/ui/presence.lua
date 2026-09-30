return {
  "andweeb/presence.nvim",
  -- presence.nvim uses Neovim's server socket as its peer identity. Do not
  -- load it in ordinary sessions where that socket does not exist.
  cond = vim.v.servername ~= nil and vim.v.servername ~= "",
  event = "VeryLazy",
  config = function()
    require("presence").setup({
      auto_update = true,
      neovim_image_text = "Neovim",
      main_image = "neovim",
      log_level = nil,
      debounce_timeout = 10,
      enable_line_number = false,
      blacklist = {},
      buttons = true,
      show_time = true,
    })
  end,
}
