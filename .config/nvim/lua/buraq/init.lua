local M = {}

local palette = require("buraq.palette")
local highlights = require("buraq.highlights")

M.colors = palette.colors

function M.setup(opts)
  if opts and opts.colors then
    M.colors = vim.tbl_deep_extend("force", M.colors, opts.colors)
  end
end

function M.load()
  if vim.g.colors_name then
    vim.cmd("highlight clear")
  end

  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "buraq"

  local groups = highlights.get(M.colors)
  for group, attrs in pairs(groups) do
    vim.api.nvim_set_hl(0, group, attrs)
  end
end

return M
