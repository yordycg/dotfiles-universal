local opt = vim.opt

-- Basicos
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cursorline = true

-- Identacion
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Busqueda
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Scroll
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Persistencia
opt.undofile = true
opt.swapfile = false

-- Rendiemiento
opt.updatetime = 200
opt.timeoutlen = 300
opt.lazyredraw = false -- no usar con noice.nvim

-- Python: apuntar al venv si existe
vim.g.python3_host_prog = vim.fn.exepath("python3")
