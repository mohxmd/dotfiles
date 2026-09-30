local M = {}

local uv = vim.uv or vim.loop

local function godot_root_for(path)
  local resolved = vim.fs.normalize(path)
  local match = vim.fs.find("project.godot", {
    path = resolved,
    upward = true,
    stop = uv.os_homedir(),
  })[1]

  if not match then
    return nil
  end

  return vim.fs.dirname(match)
end

local function ensure_godot_server(path)
  local root = godot_root_for(path)
  if not root then
    return
  end

  local address = vim.fs.joinpath(root, "godothost")
  if vim.tbl_contains(vim.fn.serverlist(), address) then
    return
  end

  pcall(vim.fn.serverstart, address)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("GodotHostServer", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      ensure_godot_server(vim.fn.getcwd())
    end,
  })

  vim.api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = function(event)
      ensure_godot_server(event.file or vim.fn.getcwd())
    end,
  })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    callback = function(event)
      local name = vim.api.nvim_buf_get_name(event.buf)
      if name ~= "" then
        ensure_godot_server(name)
      end
    end,
  })
end

return M
