return {
  -- =========================================================================
  -- Colección de Colores y Temas (Instalación)
  -- =========================================================================

  -- 1. Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte | frappe | macchiato | mocha
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = { enabled = true },
        treesitter = true,
        mason = true,
        mini = { enabled = true },
        which_key = true,
        indent_blankline = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
      },
    },
  },

  -- 2. Kanagawa
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      theme = "dragon", -- wave | dragon | lotus
      background = { dark = "dragon", light = "lotus" },
    },
  },

  -- 3. One Dark
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = {
      style = "darker", -- dark, darker, cool, deep, warm, warmer, light
      code_style = {
        comments = "none",
      },
    },
  },

  -- 4. Nord
  {
    "shaunsingh/nord.nvim",
    priority = 1000,
  },

  -- 5. y9nika (Tema personalizado solicitado)
  {
    "y9san9/y9nika.nvim",
    priority = 1000,
  },

  -- =========================================================================
  -- Configuración de LazyVim (Tema Activo)
  -- =========================================================================

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark", -- <- Puedes cambiar este valor manualmente por el tema que desees
    },
  },

  -- =========================================================================
  -- Plugins de Interfaz de Usuario (UI)
  -- =========================================================================

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = { theme = "doom" },
  },

  -- Notificaciones flotantes
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },
}
