-- ************************************************************************************************
-- PLUGINS (vim.pack nativo de Nvim 0.12)
--
-- vim.pack.add() ya ejecuta :packadd por cada plugin (los añade al runtimepath y
-- carga sus plugin/*.lua), así que NO hacen falta llamadas packadd adicionales.
-- Verificado empíricamente: comandos como :TmuxNavigatePrevious y :ThemeHub se
-- cargan al arrancar sin packadd manual.
-- herdr_nav.lua (dofile en config/keymaps.lua) es quien mapea <C-h/j/k/l> para la
-- navegación seamless; vim-tmux-navigator solo debe aportar los comandos
-- :TmuxNavigate* para el fallback fuera de herdr. Sin este flag sus nnoremap
-- <C-h/j/k/l> se aplican tras la config (vim.pack carga plugin/*.vim después del
-- init.lua) y pisan a herdr_nav, dejando sin cruce los bordes de split.
vim.g.tmux_navigator_no_mappings = 1

-- ************************************************************************************************
vim.pack.add {
  -- Colorscheme minimalista (estética Koda, ver config/options.lua)
  'https://github.com/oskarnurm/koda.nvim',
  'https://www.github.com/lewis6991/gitsigns.nvim',
  'https://www.github.com/echasnovski/mini.nvim',
  'https://www.github.com/ibhagwan/fzf-lua',
  -- Explorador de archivos tipo buffer (reemplaza nvim-tree, ver plugins/ui.lua)
  'https://github.com/stevearc/oil.nvim',
  -- Los parsers los instala plugins/treesitter.lua (API Lua del plugin);
  -- vim.pack no tiene paso de build, así que no se declara ninguno.
  'https://github.com/nvim-treesitter/nvim-treesitter',
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
  -- Snippets comunitarios (blink.cmp los carga solo si están en el runtimepath)
  'https://github.com/rafamadriz/friendly-snippets',
}
