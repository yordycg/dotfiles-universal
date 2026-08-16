-- ************************************************************************************************
-- PLUGINS (vim.pack)
-- ************************************************************************************************
vim.pack.add {
  {
    src = 'https://github.com/catppuccin/nvim',
    name = 'catppuccin',
  },
  'https://www.github.com/lewis6991/gitsigns.nvim',
  'https://www.github.com/echasnovski/mini.nvim',
  'https://www.github.com/ibhagwan/fzf-lua',
  'https://www.github.com/nvim-tree/nvim-tree.lua',
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    -- need tree-sitter-cli installed
  },
  -- Language Server Protocols / LSP
  'https://www.github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  {
    src = 'https://github.com/saghen/blink.cmp',
    version = vim.version.range '1.*',
  },
  -- Formatting & Linting (reemplaza efm-langserver)
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  -- Navegación seamless entre ventanas nvim y panes tmux
  -- (fallback homelab; en herdr lo gestiona vim-herdr-navigation)
  'https://github.com/christoomey/vim-tmux-navigator',
  -- Gestor interactivo de temas y dependencia
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/Erl-koenig/theme-hub.nvim',
  -- Dependencia de theme-hub para que los temas con lush se rendericen bien
  'https://github.com/rktjmp/lush.nvim',
}

-- LuaSnip quedó como resto en el lockfile pero ya no se usa (blink.cmp usa vim.snippet).
-- Se marca como eliminado (acepta lista) para que se borre del lock y del disco.
pcall(vim.pack.del, { 'LuaSnip' })

local function packadd(name)
  vim.cmd('packadd ' .. name)
end

packadd 'catppuccin'
packadd 'nvim-treesitter'
packadd 'gitsigns.nvim'
packadd 'mini.nvim'
packadd 'fzf-lua'
packadd 'nvim-tree.lua'
-- LSP
packadd 'nvim-lspconfig'
packadd 'mason.nvim'
packadd 'blink.cmp'
-- Format & Lint
packadd 'conform.nvim'
packadd 'nvim-lint'
packadd 'vim-tmux-navigator'
packadd 'plenary.nvim'
packadd 'theme-hub.nvim'
packadd 'lush.nvim'
