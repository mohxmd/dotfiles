local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to install lazy.nvim:\n", "ErrorMsg" },
      { output, "WarningMsg" },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  change_detection = {
    notify = false,
  },
  pkg = {
    -- Exclude rockspecs so plugin metadata cannot trigger LuaRocks builds.
    sources = { "lazy", "packspec" },
  },
  rocks = {
    enabled = false,
    hererocks = false,
  },
})

require("config.theme").setup()
