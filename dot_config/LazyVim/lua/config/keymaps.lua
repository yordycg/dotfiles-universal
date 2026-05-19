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

-- Diagnosticos -----------------------------------------------------
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble" })

-- Utilidades -----------------------------------------------------
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorador" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover linea abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover linea arriba" })
