local colorschemes = require("config.colorschemes")

local specs = {}

for _, item in ipairs(colorschemes.items) do
  if item.repo then
    local spec = {
      item.repo,
      lazy = true,
      priority = 1000,
    }

    if item.name then
      spec.name = item.name
    end

    table.insert(specs, spec)
  end
end

return specs
