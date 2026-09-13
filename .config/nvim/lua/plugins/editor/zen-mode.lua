return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    {
      "<leader>zz",
      function()
        require("zen-mode").toggle()
        vim.wo.wrap = false
        vim.wo.number = true
        vim.wo.relativenumber = true
      end,
      desc = "Toggle Zen mode",
    },
  },
}
