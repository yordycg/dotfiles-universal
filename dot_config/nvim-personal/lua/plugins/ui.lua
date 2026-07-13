-- ************************************************************************************************
-- UI: NvimTree, fzf-lua, gitsigns
-- ************************************************************************************************

-- NvimTree
require('nvim-tree').setup {
  view = {
    width = 35,
  },
  filters = {
    dotfiles = false,
  },
  renderer = {
    group_empty = true,
  },
  update_focused_file = {
    enable = true,
    update_root = true,
  },
}
vim.keymap.set('n', '<leader>e', function()
  require('nvim-tree.api').tree.toggle()
end, { desc = 'Toggle NvimTree' })

-- fzf-lua
require('fzf-lua').setup {}

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
