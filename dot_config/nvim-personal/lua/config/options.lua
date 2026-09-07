-- ************************************************************************************************
-- OPTIONS
-- ************************************************************************************************

require('koda').setup {
  theme = { dark = 'dark', light = 'light' },
  transparent = false,
}

vim.opt.termguicolors = true
-- Tema por defecto: Oxocarbon (alto contraste industrial/monocromático)
-- Alternativas disponibles: :colorscheme koda-high-contrast o :colorscheme koda-dark
vim.cmd.colorscheme 'oxocarbon'

vim.opt.number = true -- line number
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.cursorlineopt = 'both' -- highlight current line and its number
vim.opt.wrap = false -- do not wrap lines by default
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.opt.tabstop = 2 -- tabwidth
vim.opt.shiftwidth = 2 -- indent width
vim.opt.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- copy indent from current line

vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- case sensitive if uppercase in string
vim.opt.hlsearch = true -- highlight search matches
vim.opt.incsearch = true -- show matches as you type

-- Búsqueda nativa estilo y9san9: :grep con ripgrep directo a la quickfix
-- (soporta :Cfilter, ver plugins/builtin.lua). Formato vimgrep nativo.
vim.opt.grepprg = 'rg --vimgrep --no-messages --smart-case'
vim.opt.grepformat = '%f:%l:%c:%m'

vim.opt.signcolumn = 'yes' -- always show a sign column
vim.opt.colorcolumn = '100' -- show a column at 100 position chars
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.cmdheight = 1 -- single line command line
vim.opt.completeopt = 'menuone,noinsert,noselect' -- completion options
vim.opt.showmode = false -- do not show the mode, instead have it in statusline
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 0 -- popup menu transparency
vim.opt.winblend = 0 -- floating window transparency
vim.opt.conceallevel = 0 -- do not hide markup
vim.opt.concealcursor = '' -- do not hide cursorline in markup
vim.opt.lazyredraw = false -- disabled to prevent stutter/lag in modern Neovim UI loop
vim.opt.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = { eob = ' ' } -- hide "~" on empty lines

-- Persistencia de undo: sin directorio custom; Neovim 0.12 ya gestiona el
-- undodir por defecto en $XDG_STATE_HOME/nvim/undo (auto-creado).
vim.opt.backup = false -- do not create a backup file
vim.opt.writebackup = false -- do not write to a backup file
vim.opt.swapfile = false -- do not create a swapfile
vim.opt.undofile = true -- do create an undo file
vim.opt.updatetime = 300 -- faster completion
vim.opt.timeoutlen = 500 -- timeout duration
vim.opt.ttimeoutlen = 0 -- key code timeout
vim.opt.autoread = true -- auto-reload changes if outside of neovim
vim.opt.autowrite = false -- do not auto-save

vim.opt.selection = 'inclusive' -- include last char in selection
vim.opt.mouse = 'a' -- enable mouse support

-- Auto-recuperación de socket Wayland stale (común en herdr/tmux al reiniciar sesión gráfica)
if vim.env.WAYLAND_DISPLAY then
  local runtime_dir = vim.env.XDG_RUNTIME_DIR or ('/run/user/' .. vim.uv.getuid())
  local socket = runtime_dir .. '/' .. vim.env.WAYLAND_DISPLAY
  if vim.fn.getftype(socket) ~= 'socket' then
    local candidates = {}
    for _, path in ipairs(vim.fn.glob(runtime_dir .. '/wayland-[0-9]*', false, true)) do
      if vim.fn.getftype(path) == 'socket' then
        table.insert(candidates, path)
      end
    end
    if #candidates > 0 then
      table.sort(candidates)
      vim.env.WAYLAND_DISPLAY = vim.fn.fnamemodify(candidates[#candidates], ':t')
    end
  end
end
vim.opt.clipboard:append 'unnamedplus' -- use system clipboard
vim.opt.modifiable = true -- allow buffer modifications
vim.opt.iskeyword:append '-' -- include - in words
vim.opt.path:append '**' -- include subdirs in :find

vim.opt.guicursor =
  'n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'

-- Folding: requires treesitter available at runtime; safe fallback if not
vim.opt.foldmethod = 'expr' -- use expression for folding
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right
vim.opt.splitkeep = 'screen' -- keep screen text stable when splitting

vim.opt.inccommand = 'split' -- live preview of substitutions in real time
vim.opt.confirm = true -- confirm to save changes when closing unsaved buffers
vim.opt.jumpoptions = 'view' -- preserve window view when jumping with Ctrl-o/Ctrl-i
vim.opt.smoothscroll = true -- scroll wrapped lines smoothly

vim.opt.wildmenu = true -- tab completion
vim.opt.wildmode = 'longest:full,full' -- complete longest common match, full list, cycle with Tab
vim.opt.diffopt:append 'linematch:60' -- improve diff display
vim.opt.redrawtime = 10000 -- increase neovim redraw tolerance
vim.opt.maxmempattern = 20000 -- increase max memory

-- Neovide GUI Settings (Skia / Hardware rendering)
if vim.g.neovide then
  -- Tipografía: SF Mono ligaturizada con Skia sin hinting forzado y antialiasing puro
  vim.opt.guifont = 'Liga SFMono Nerd Font:h13:#h-none:#e-antialias'
  vim.g.neovide_pixel_geometry = 'RGBH'
  vim.g.neovide_text_gamma = 0.0
  vim.g.neovide_text_contrast = 0.5

  -- Padding perimetral equilibrado (espacioso pero aprovechando mejor la pantalla)
  vim.g.neovide_padding_top = 36
  vim.g.neovide_padding_left = 28
  vim.g.neovide_padding_right = 28
  vim.g.neovide_padding_bottom = 20

  -- Profundidad visual: Sombras y desenfoque GPU en ventanas flotantes (Telescope, LSP, popups)
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_floating_corner_radius = 8.0
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  -- Animaciones fluidas de cursor y desplazamiento
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_size = 0.5
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_scroll_animation_length = 0.2

  -- Zoom dinámico interactivo con teclado
  vim.g.neovide_scale_factor = 1.0
  local change_scale = function(delta)
    vim.g.neovide_scale_factor = math.max(0.5, math.min(2.0, (vim.g.neovide_scale_factor or 1.0) + delta))
  end
  vim.keymap.set({ 'n', 'v' }, '<C-=>', function()
    change_scale(0.05)
  end, { desc = 'Neovide Zoom In' })
  vim.keymap.set({ 'n', 'v' }, '<C-->', function()
    change_scale(-0.05)
  end, { desc = 'Neovide Zoom Out' })
  vim.keymap.set({ 'n', 'v' }, '<C-0>', function()
    vim.g.neovide_scale_factor = 1.0
  end, { desc = 'Neovide Reset Zoom' })
end

