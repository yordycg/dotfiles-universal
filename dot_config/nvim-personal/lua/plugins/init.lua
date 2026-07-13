-- ************************************************************************************************
-- PLUGINS (vim.pack)
-- ************************************************************************************************
vim.pack.add {
  -- Colorscheme / Theme
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
}

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
