return {
  -- Tema (tokyonight viene incluido en LazyVim)
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night", -- night | storm | moon | day
      transparent = false,
      terminal_colors = true,
    },
  },

  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

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
