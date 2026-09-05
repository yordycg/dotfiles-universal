-- ************************************************************************************************
-- KEYMAPS (generales, no-LSP)
-- ************************************************************************************************
vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

-- Better movement in wrapped text
vim.keymap.set("n", "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set({ "n", "i" }, "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlights" })

-- Salir de un comentario sin el líder: Enter + borra lo insertado conservando la
-- indentación (i_CTRL-U). Enter normal sigue continuando el comentario (multi-línea).
vim.keymap.set("i", "<C-CR>", "<CR><C-u>", { desc = "Break comment (no leader)" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- Navegación entre panes: la gestiona vim-herdr-navigation (fuera de herdr cae
-- a tmux vía vim-tmux-navigator). Cargado al final para ganar sobre sus maps.
if vim.fn.filereadable(vim.fn.expand("~/.config/herdr/editor/herdr_nav.lua")) == 1 then
  dofile(vim.fn.expand("~/.config/herdr/editor/herdr_nav.lua"))
end

vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", { desc = "Move to previous window/pane" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Mover líneas/selectiones lo cubre mini.move (<M-h/j/k/l> en n y v); los
-- <A-j/k> de abajo lo duplicaban (Alt == Meta) y quedaban sobrescritos.
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

local function copy_file_path()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("file: " .. path)
end
vim.keymap.set("n", "<leader>cp", copy_file_path, { desc = "Copy full file path" })
vim.keymap.set("n", "<leader>pa", copy_file_path, { desc = "Copy full file path (alias)" })

vim.keymap.set("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

vim.keymap.set("n", "<leader>bd", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Delete buffer keeping layout" })
