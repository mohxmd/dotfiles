return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {
    override_by_filename = {
      ["docker-compose.yml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["docker-compose.yaml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["docker-compose.server.yml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["docker-compose.server.yaml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["docker-compose.prod.yml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["docker-compose.prod.yaml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["docker-compose.dev.yml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["docker-compose.dev.yaml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["compose.yml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
      ["compose.yaml"] = {
        icon = "󰡨",
        color = "#458ee6",
        name = "Dockerfile",
      },
    },
  },
  config = function(_, opts)
    local devicons = require("nvim-web-devicons")
    devicons.setup(opts)

    local orig_get_icon = devicons.get_icon
    devicons.get_icon = function(name, ext, options)
      if name and (name:match("^docker%-compose%..*%.ya?ml$") or name:match("^compose%..*%.ya?ml$")) then
        return "󰡨", "DevIconDockerfile"
      end
      return orig_get_icon(name, ext, options)
    end
  end,
}
