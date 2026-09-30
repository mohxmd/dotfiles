local M = {}

local function executable(name)
  return vim.fn.executable(name) == 1
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ConfigIncludeFormatter", { clear = true })

  -- C/C++ include formatter
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = { "*.h", "*.hpp", "*.hh", "*.hxx", "*.c", "*.cc", "*.cpp", "*.cxx" },
    callback = function(args)
      require("config.tools.include_formatter").format(args.buf)
    end,
  })

  -- Typst auto-compile
  local typst_job = nil

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.typ",
    callback = function(args)
      if not executable("typst") then
        return
      end

      local file = vim.api.nvim_buf_get_name(args.buf)
      local pdf = file:gsub("%.typ$", ".pdf")

      if typst_job then
        vim.fn.jobstop(typst_job)
      end

      local job = vim.fn.jobstart({ "typst", "compile", file, pdf })
      typst_job = job > 0 and job or nil
    end,
  })

  -- :Skel command
  vim.api.nvim_create_user_command("Skel", function()
    require("config.tools.skeleton").insert()
  end, { desc = "Insert a project skeleton", force = true })

  -- :TypstPreview command
  vim.api.nvim_create_user_command("TypstPreview", function()
    if not executable("zathura") then
      vim.notify("TypstPreview requires zathura on PATH", vim.log.levels.WARN)
      return
    end

    local file = vim.fn.expand("%")
    if not file:match("%.typ$") then
      vim.notify("TypstPreview is available for Typst files", vim.log.levels.WARN)
      return
    end

    local pdf = file:gsub("%.typ$", ".pdf")
    vim.fn.jobstart({ "zathura", pdf })
  end, { desc = "Open the current Typst PDF", force = true })

  require("config.tools.cpp_extract").setup()
end

return M
