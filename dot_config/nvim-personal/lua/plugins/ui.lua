-- ************************************************************************************************
-- UI: Oil (explorador de archivos), fzf-lua, gitsigns, theme-hub
-- ************************************************************************************************

-- Oil: editar el filesystem como un buffer (filosofía y9san9). Sustituye a
-- nvim-tree; para navegar árboles se usa fzf-lua (<leader>ff) y `:grep`.
require('oil').setup {
  columns = { 'icon', 'size', 'mtime' },
  view_options = { show_hidden = false },
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  lsp_file_methods = { enabled = true },
}
-- Toggle en ventana flotante (paridad UX con el nvim-tree); para tomar el
-- buffer entero usa `:Oil` (navegación estilo vim-vinegar, `-` sube un nivel).
vim.keymap.set('n', '<leader>e', function()
  require('oil').toggle_float()
end, { desc = 'Toggle file explorer (Oil)' })

-- fzf-lua
require('fzf-lua').setup {}
require('fzf-lua').register_ui_select()

vim.keymap.set('n', '<leader>ff', function()
  require('fzf-lua').files()
end, { desc = 'FZF Files' })
vim.keymap.set('n', '<leader>fg', function()
  require('fzf-lua').live_grep()
end, { desc = 'FZF Live Grep' })
vim.keymap.set('n', '<leader>fb', function()
  require('fzf-lua').buffers()
end, { desc = 'FZF Buffers' })
vim.keymap.set('n', '<leader>fh', function()
  require('fzf-lua').help_tags()
end, { desc = 'FZF Help Tags' })
vim.keymap.set('n', '<leader>fx', function()
  require('fzf-lua').diagnostics_document()
end, { desc = 'FZF Diagnostics Document' })
vim.keymap.set('n', '<leader>fX', function()
  require('fzf-lua').diagnostics_workspace()
end, { desc = 'FZF Diagnostics Workspace' })

-- gitsigns.nvim
require('gitsigns').setup {
  signs = {
    add = { text = '\u{2590}' },
    change = { text = '\u{2590}' },
    delete = { text = '\u{2590}' },
    topdelete = { text = '\u{25e6}' },
    changedelete = { text = '\u{25cf}' },
    untracked = { text = '\u{25cb}' },
  },
  signcolumn = true,
  current_line_blame = false,
}

vim.keymap.set('n', ']h', function()
  require('gitsigns').next_hunk()
end, { desc = 'Next git hunk' })
vim.keymap.set('n', '[h', function()
  require('gitsigns').prev_hunk()
end, { desc = 'Previous git hunk' })
vim.keymap.set('n', '<leader>hs', function()
  require('gitsigns').stage_hunk()
end, { desc = 'Stage hunk' })
vim.keymap.set('n', '<leader>hr', function()
  require('gitsigns').reset_hunk()
end, { desc = 'Reset hunk' })
vim.keymap.set('n', '<leader>hp', function()
  require('gitsigns').preview_hunk()
end, { desc = 'Preview hunk' })
vim.keymap.set('n', '<leader>hb', function()
  require('gitsigns').blame_line { full = true }
end, { desc = 'Blame line' })
vim.keymap.set('n', '<leader>hB', function()
  require('gitsigns').toggle_current_line_blame()
end, { desc = 'Toggle inline blame' })
vim.keymap.set('n', '<leader>hd', function()
  require('gitsigns').diffthis()
end, { desc = 'Diff this' })

-- theme-hub.nvim
require('theme-hub').setup {
  install_dir = vim.fn.stdpath 'data' .. '/theme-hub',
  auto_install_on_select = true,
  apply_after_install = true,
  -- No persistir: el default determinístico es koda-dark (config/options.lua).
  -- Si se persistiera, theme-hub re-aplicaría un tema viejo al arrancar y
  -- pisaría el colorscheme de la config.
  persistent = false,
}

-- En <leader>uc (grupo "ui"): si quedara en <leader>th, <leader>t (terminal) sería
-- prefijo suyo y mini.clue esperaría a desambiguar en vez de abrir la terminal al toque.
vim.keymap.set('n', '<leader>uc', '<cmd>ThemeHub<cr>', { desc = 'Select theme (Theme Hub)' })
