return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- The current nvim-treesitter rewrite explicitly does not support
  -- lazy-loading. Keep it available at startup for native highlighting and
  -- parser installation.
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local treesitter = require("nvim-treesitter")
    local install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site")
    local languages = {
      "bash",
      "c",
      "cpp",
      "css",
      "dockerfile",
      "gdscript",
      "gdshader",
      "gitignore",
      "graphql",
      "haskell",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "prisma",
      "query",
      "rust",
      "svelte",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    }

    treesitter.setup({ install_dir = install_dir })
    if vim.fn.executable("tree-sitter") == 1 then
      treesitter.install(languages)
    end

    vim.treesitter.language.register("haskell", "lhaskell")

    local disabled_filetypes = {
      markdown = true,
      markdown_inline = true,
    }
    local group = vim.api.nvim_create_augroup("ConfigTreesitter", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        if disabled_filetypes[vim.bo[args.buf].filetype] then
          return
        end

        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
