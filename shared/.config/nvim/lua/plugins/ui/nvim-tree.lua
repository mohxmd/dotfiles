return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local nvimtree = require("nvim-tree")

    nvimtree.setup({
      -- Neovim 0.12 removed the legacy FileExplorer autocmd event that
      -- older nvim-tree releases try to clear while hijacking netrw.
      -- Disable netrw directly and leave hijacking off to keep startup clean.
      disable_netrw = true,
      hijack_netrw = false,
      sync_root_with_cwd = true,
      respect_buf_cwd = false,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        side = "right",
        width = 35,
        preserve_window_proportions = true,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
        },
      },
      renderer = {
        highlight_opened_files = "all",
      },
      git = { enable = false },
      tab = {
        sync = {
          open = false,
          close = false,
          ignore = {},
        },
      },
    })

    local keymap = vim.keymap
    keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    keymap.set("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })
  end,
}
