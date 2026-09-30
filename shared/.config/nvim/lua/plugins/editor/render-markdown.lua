return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  cmd = { "RenderMarkdown" },
  keys = {
    { "<leader>om", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    file_types = { "markdown" },
    preset = "obsidian",
    render_modes = { "n", "c", "t" },
    restart_highlighter = false,
    anti_conceal = {
      enabled = false,
    },
  },
}
