require 'plugins.init' -- vim.pack.add + packadd

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.statusline'
require 'config.terminal'

require 'plugins.mini' -- mini.nvim modules
require 'plugins.ui' -- nvim-tree, gitsigns, fzf-lua
require 'plugins.builtin' -- Nvim 0.12 built-ins (undotree, ui2)
require 'plugins.treesitter'

require 'plugins.lsp'
require 'plugins.completion' -- blink.cmp
require 'plugins.format' -- conform.nvim
require 'plugins.lint' -- nvim-lint
