local group = vim.api.nvim_create_augroup("ConfigCore", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 40 })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*",
  callback = function(args)
    local buffer = args.buf
    local filetype = vim.bo[buffer].filetype

    -- Markdown and text files may intentionally use trailing spaces for hard
    -- line breaks. Do not silently change those files on save.
    if not vim.bo[buffer].modifiable or vim.bo[buffer].readonly or vim.tbl_contains({
      "diff",
      "gitcommit",
      "mail",
      "markdown",
      "text",
    }, filetype) then
      return
    end

    local view = vim.fn.winsaveview()
    vim.cmd("silent keepjumps keeppatterns %s/\\s\\+$//e")
    vim.fn.winrestview(view)
  end,
})
