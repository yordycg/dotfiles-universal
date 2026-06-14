return {
  -- Glance: Vista "Peek" tipo VS Code para LSP
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    opts = {
      height = 20, -- Altura de la ventana flotante
      zindex = 45,
      detached = true,
      preview_win_opts = {
        cursorline = true,
        number = true,
        relativenumber = true,
      },
    },
    keys = {
      { "gD", "<CMD>Glance definitions<CR>", desc = "Peek Definition" },
      { "gR", "<CMD>Glance references<CR>", desc = "Peek References" },
      { "gY", "<CMD>Glance type_definitions<CR>", desc = "Peek Type Definition" },
      { "gM", "<CMD>Glance implementations<CR>", desc = "Peek Implementation" },
    },
  },

  -- Mason: instala servidores LSP, linters y formatters automaticamente
  {
    "mason-org/mason.nvim",
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
        fsautocomplete = {
          enabled = false,
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
