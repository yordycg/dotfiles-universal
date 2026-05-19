local map = vim.keymap.set

-- Navegacion ventanas ------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })

-- Buffers ----------------------------------------------------------
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer anterior" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Buffer siguiente" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Cerrar buffer" })

-- LSP -------------------------------------------------------------
map("n", "gd", vim.lsp.buf.definition, { desc = "Ir a definicion" })
map("n", "gr", vim.lsp.buf.references, { desc = "Referencias" })
map("n", "K", vim.lsp.buf.hover, { desc = "Documentacion" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Renombrar simbolo" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Diagnosticos -----------------------------------------------------
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Error anterior" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Error siguiente" })
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble" })

-- Utilidades -----------------------------------------------------
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorador" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover linea abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover linea arriba" })
