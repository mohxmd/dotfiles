local colorschemes = require("config.colorschemes")

return vim.tbl_map(function(item)
  local spec = {
    item.repo,
    -- The configured default theme is applied during startup, so it must
    -- be available before the theme state loader runs. Other themes stay
    -- lazy and are loaded automatically when selected.
    lazy = item.repo ~= "oskarnurm/koda.nvim",
    priority = 1000,
  }

  if item.name then
    spec.name = item.name
  end

  return spec
end, colorschemes.items)
