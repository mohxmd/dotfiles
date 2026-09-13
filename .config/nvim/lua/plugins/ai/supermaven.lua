return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  cmd = {
    "SupermavenStart",
    "SupermavenStop",
    "SupermavenRestart",
    "SupermavenToggle",
    "SupermavenStatus",
    "SupermavenUseFree",
    "SupermavenUsePro",
    "SupermavenLogout",
    "SupermavenShowLog",
    "SupermavenClearLog",
  },
  config = function()
    local ok, err = pcall(function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { cpp = true, c = true, rust = true },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
      })
    end)

    if not ok then
      -- Supermaven downloads its optional agent on first use. Keep a
      -- missing network/authentication setup from breaking Neovim startup.
      vim.g.config_supermaven_setup_error = err
    end
  end,
}
