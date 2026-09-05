-- ************************************************************************************************
-- AUTOCMDS
-- ************************************************************************************************
local augroup = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

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

-- C/C++: indent de 4 espacios para alinear con learning-c/.clang-format
-- (IndentWidth: 4). El resto de lenguajes conserva los 2 globales.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- Heurística pasiva de indentación para archivos existentes (cero plugins)
-- Respeta si un archivo ajeno usa tabuladores o 4 espacios sin alterar la config global de 2.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Detect file indentation heuristic",
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" or vim.bo[ev.buf].filetype == "" then
      return
    end
    if vim.bo[ev.buf].filetype == "c" or vim.bo[ev.buf].filetype == "cpp" then
      return
    end

    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, 50, false)
    local space_indent_counts = { [2] = 0, [4] = 0 }
    local has_tabs = false

    for _, line in ipairs(lines) do
      if line:match("^\t") then
        has_tabs = true
        break
      end
      local spaces = line:match("^( +)%S")
      if spaces then
        local len = #spaces
        if len == 4 or len == 8 then
          space_indent_counts[4] = space_indent_counts[4] + 1
        elseif len == 2 or len == 6 then
          space_indent_counts[2] = space_indent_counts[2] + 1
        end
      end
    end

    if has_tabs then
      vim.opt_local.expandtab = false
    elseif space_indent_counts[4] > space_indent_counts[2] and space_indent_counts[4] >= 2 then
      vim.opt_local.tabstop = 4
      vim.opt_local.shiftwidth = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.expandtab = true
    end
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
  pattern = { "help", "fzf", "lspinfo", "mason" },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})
