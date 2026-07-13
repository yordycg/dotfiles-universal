-- ************************************************************************************************
-- AUTOCMDS
-- ************************************************************************************************
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position",
  callback = function()
    if vim.o.diff then -- except in diff mode
      return
    end

    local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
    local last_line = vim.api.nvim_buf_line_count(0)

    local row = last_pos[1]
    if row < 1 or row > last_line then
      return
    end

    pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
  end,
})

-- Wrap, linebreak and spellcheck on markdown and text files
-- (fix: "makdown" -> "markdown")
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Cerrar buffers "utilitarios" con q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth", "notify" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

-- Revisar cambios externos al recuperar foco (complementa autoread)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = augroup,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Crear directorios padres automáticamente al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function(ev)
    if ev.match:match("^%w+://") then -- skip remote/scp/fugitive buffers
      return
    end
    local dir = vim.fn.fnamemodify(ev.file, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Quitar trailing whitespace al guardar (usa mini.trailspace)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    if vim.bo.filetype ~= "markdown" then
      pcall(function()
        require("mini.trailspace").trim()
      end)
    end
  end,
})

-- Igualar splits al redimensionar la ventana
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "help", "fzf", "NvimTree", "lspinfo", "mason" },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})
