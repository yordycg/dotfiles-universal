require 'plugins.init' -- vim.pack.add (ya carga los plugins)

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.statusline'
require 'config.terminal'

require 'plugins.mini' -- mini.nvim modules
require 'plugins.ui' -- oil, fzf-lua, gitsigns, theme-hub
require 'plugins.builtin' -- Nvim 0.12 built-ins (undotree, ui2)
require 'plugins.treesitter'

require 'plugins.lsp'
require 'plugins.completion' -- blink.cmp
require 'plugins.format' -- conform.nvim
require 'plugins.lint' -- nvim-lint

-- Resaltado 100% con Treesitter (lo arranca plugins/treesitter.lua por FileType).
-- Va al final del arranque para que ningún plugin vuelva a habilitar el
-- resaltado regex de Vim (evita doble parseo y discrepancias visuales).
vim.cmd 'syntax off'
