return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- Usa la última versión estable
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp", -- Para autocompletar enlaces y tags
    },
    keys = {
      { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Insertar Plantilla" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Nueva Nota" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Buscar Notas (Grep)" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks de la nota" },
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/workspace/assets/obsidian-notes", -- Tu ruta actual de notas sync
        },
      },
      
      -- 1. Configuraciones del Vault
      notes_subdir = "Inbox", -- Subcarpeta opcional para notas nuevas rápidas
      daily_notes = {
        folder = "Diario",
        date_format = "%Y-%m-%d",
      },
      
      -- 2. Formato de enlaces
      preferred_link_style = "wiki", -- Usa [[WikiLinks]] por defecto
      
      -- 3. Desactivar UI incorporada para evitar conflictos con render-markdown
      ui = {
        enable = false,
      },

      -- 4. Plantillas (Templates)
      templates = {
        folder = "600 Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { 
      "nvim-treesitter/nvim-treesitter", 
      "nvim-mini/mini.icons" -- O nvim-web-devicons si lo prefieres
    },
    ft = { "markdown" },
    opts = {
      heading = {
        sign = true,
        position = "overlay",
      },
      checkbox = {
        enabled = true,
      },
    },
  }
}
