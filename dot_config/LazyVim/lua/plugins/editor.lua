return {
  -- LazyGit integrado
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Explorador
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitgnored = false,
        },
        follow_current_file = { enabled = true },
      },
    },
  },

  -- Harpoon 2: navegacion rapida entre archivos clave del proyecto
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon: agregar",
      },
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toogle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon: menu",
      },
      {
        "<leader>1",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "Harpoon: archivo 1",
      },
      {
        "<leader>2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Harpoon: archivo 2",
      },
      {
        "<leader>3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Harpoon: archivo 3",
      },
      {
        "<leader>4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Harpoon: archivo 4",
      },
    },
  },

  -- Busqueda en proyecto (ripgrep)
  -- En repos grandes fzf-lua es mucho mas rapido que telescope
  {
    "ibhagwan/fzf-lua",
    opts = {
      files = { cmd = "fd --type f --hidden --follow --exclude .git" },
    },
  },

  -- Comentarios
  {
    "numToStr/Comment.nvim",
    event = "BufReadPre",
    config = true,
  },

  -- Saltar a cualquier parte de la pantalla
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
    },
  },

  -- Mostrar identacion
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = { scope = { enabled = true } },
  },

  -- Mostrar colores hex en CSS/HTML
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "html", "javascript", "typescript", "htmldjango" },
    opts = { user_defalt_options = { tailwind = true } },
  },
}
