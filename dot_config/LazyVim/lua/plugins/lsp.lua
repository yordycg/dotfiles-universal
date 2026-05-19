return {
  -- Mason: instala servidores LSP, linters y formatters automaticamente
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Python
        "pyright", -- LSP
        "ruff", -- linter + formatter
        "debugpy", -- debugger

        -- JS/TS
        "typescript-language-server",
        "eslint-lsp",
        "prettier",

        -- HTML / CSS
        "html-lsp",
        "css-lsp",
        "emmet-language-server",

        -- C#
        "omnisharp",

        -- C / C++
        "clangd",
        "clang-format",

        --General
        "lua-language-server",
        "stylua",
      },
    },
  },

  -- Config extra por servidor
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "standard",
                autoImportCompletions = true,
              },
            },
          },
        },
        ruff = {
          init_options = { settings = { lineLenght = 100 } },
        },
        omnisharp = {
          -- Para proyctos .NET
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
        },
        clangd = {
          -- Para C/C++: busca compile_commands.json
          cmd = { "clangd", "--background-index", "--clang-tidy" },
        },
        emmet_language_server = {
          -- Emmet en HTML, CSS, Django templates
          filetypes = { "html", "css", "htmldjango", "javascriptreact", "typescriptreact" },
        },
      },
    },
  },

  -- Formateo automatico al guardar
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        cs = { "csharpier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
}
