-- ************************************************************************************************
-- Nvim 0.12 built-ins: undo tree + UI2 (no more "Press ENTER")
-- ************************************************************************************************

-- Undo tree interactivo incluido en el runtime de Nvim 0.12
vim.cmd 'packadd nvim.undotree'
vim.keymap.set('n', '<leader>uu', '<cmd>Undotree<cr>', { desc = 'Undotree' })

-- UI2: rediseño experimental del mensaje/commandline; elimina los "Press ENTER".
-- Se envuelve en pcall para que una API experimental no rompa el arranque.
pcall(function()
  require('vim._core.ui2').enable()
end)