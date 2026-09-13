return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local qt_clangd_flag_pattern = "^Unknown argument:%s*['\"]?%-mno%-direct%-extern%-access['\"]?"
    local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]

    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, handler_config)
      local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
      if client and client.name == "clangd" and result and result.diagnostics then
        result = vim.deepcopy(result)
        result.diagnostics = vim.tbl_filter(function(diagnostic)
          return not (diagnostic.message or ""):match(qt_clangd_flag_pattern)
        end, result.diagnostics)
      end

      return default_publish_diagnostics(err, result, ctx, handler_config)
    end

    local function enable(server, opts)
      opts = opts or {}
      opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})
      vim.lsp.config(server, opts)
      vim.lsp.enable(server)
    end

    local function enable_if_executable(server, executable, opts)
      if vim.fn.executable(executable) == 1 then
        enable(server, opts)
      end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc, silent = true })
        end

        map("n", "gR", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
        map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
        map("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1 })
        end, "Go to previous diagnostic")
        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1 })
        end, "Go to next diagnostic")
        map("n", "K", vim.lsp.buf.hover, "Show documentation under cursor")
        map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")

        local filetype = vim.bo[event.buf].filetype
        local path = vim.api.nvim_buf_get_name(event.buf)
        local disable_inlay_hints = vim.tbl_contains({ "c", "cpp", "objc", "objcpp" }, filetype)
          or path:match("%.h$")
          or path:match("%.hh$")
          or path:match("%.hpp$")
          or path:match("%.hxx$")
          or path:match("%.inl$")

        if client and client.server_capabilities.inlayHintProvider and not disable_inlay_hints then
          vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        end
      end,
    })

    for severity, icon in pairs({ Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }) do
      local highlight = "DiagnosticSign" .. severity
      vim.fn.sign_define(highlight, { text = icon, texthl = highlight, numhl = "" })
    end

    vim.diagnostic.config({
      virtual_text = { prefix = "●", spacing = 2 },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    enable("ts_ls", {
      filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    })

    for _, server in ipairs({
      "html",
      "cssls",
      "svelte",
      "graphql",
      "emmet_ls",
      "pyright",
      "jdtls",
      "bashls",
    }) do
      enable(server)
    end

    enable("tailwindcss", {
      filetypes = {
        "html",
        "css",
        "scss",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "heex",
      },
    })

    enable("zls", {
      settings = {
        zls = {
          enable_inlay_hints = true,
          enable_snippets = true,
          warn_style = true,
        },
      },
    })

    -- Clangd discovers project-specific compiler settings from
    -- compile_commands.json or .clangd, keeping this config portable.
    enable("clangd", {
      cmd = { "clangd", "--background-index", "--clang-tidy" },
    })

    enable("lua_ls", {
      settings = {
        Lua = {
          completion = { callSnippet = "Replace" },
          workspace = { checkThirdParty = false },
        },
      },
    })

    enable("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          inlayHints = {
            typeHints = { enable = true },
            parameterHints = { enable = false },
            chainingHints = { enable = false },
            bindingModeHints = { enable = false },
            closureReturnTypeHints = { enable = "never" },
            lifetimeElisionHints = { enable = "never" },
            reborrowHints = { enable = false },
            closingBraceHints = { enable = false },
          },
        },
      },
    })

    enable("gdscript")
    enable_if_executable("gopls", "gopls")
    enable_if_executable("tinymist", "tinymist", {
      cmd = { "tinymist" },
      filetypes = { "typst" },
      root_markers = { ".git" },
    })
    enable_if_executable("hls", "haskell-language-server-wrapper", {
      cmd = { "haskell-language-server-wrapper", "--lsp" },
      filetypes = { "haskell", "lhaskell", "cabal" },
      root_markers = { "hie.yaml", "stack.yaml", "cabal.project", "package.yaml", "*.cabal", ".git" },
    })
    enable_if_executable("gdshader_lsp", "gdshader-lsp")
  end,
}
