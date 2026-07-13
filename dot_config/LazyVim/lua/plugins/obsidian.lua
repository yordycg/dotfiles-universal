return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- Usa la última versión estable
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/workspace/assets/obsidian-notes", -- Tu ruta actual de notas sync
        },
      },

      -- Notas nuevas van por defecto a Zettelkasten
      notes_subdir = "000 Zettelkasten",
      new_notes_location = "notes_subdir",

      daily_notes = {
        folder = "Diario",
        date_format = "%Y-%m-%d",
      },

      templates = {
        folder = "600 Templates",
      },

      preferred_link_style = "wiki",

      -- Adjuntos/imágenes van a 400 Files (ruta relativa a la raíz del vault)
      attachments = {
        img_folder = "/400 Files",
      },

      ui = { enable = false }, -- se mantiene desactivado por render-markdown.nvim

      picker = {
        -- LazyVim reciente trae snacks.picker por defecto; si da problemas se puede cambiar a telescope.nvim o fzf-lua
        name = "snacks.picker",
      },

      completion = {
        min_chars = 2,
      },
    },
    keys = {
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "Nueva nota (Zettelkasten)" },
      { "<leader>ot", "<cmd>Obsidian template<cr>", desc = "Insertar plantilla" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Buscar texto en vault" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Ver backlinks" },
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Ir a nota (fuzzy)" },
      { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Nota diaria de hoy" },
      { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Nota diaria de ayer" },
      { "<leader>oc", "<cmd>Obsidian toc<cr>", desc = "Tabla de contenidos" },
      { "<leader>oT", "<cmd>Obsidian tags<cr>", desc = "Buscar por tag" },
      {
        "<leader>oN",
        function() require("util.obsidian-extras").new_note_in_folder() end,
        desc = "Nueva nota en carpeta específica",
      },
      {
        "<leader>om",
        function() require("util.obsidian-extras").move_note_to_folder() end,
        desc = "Mover nota a otra carpeta",
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
