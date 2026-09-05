-- ************************************************************************************************
-- FLOATING TERMINAL
-- ************************************************************************************************
local augroup = vim.api.nvim_create_augroup("UserTerminal", { clear = true })

vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

local terminal_state = { buf = nil, win = nil, is_open = false }

local function FloatingTerminal()
  if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
    return
  end

  if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
    terminal_state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[terminal_state.buf].bufhidden = "hide"
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.wo[terminal_state.win].winblend = 0
  vim.wo[terminal_state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
  vim.api.nvim_set_hl(0, "FloatingTermNormal", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "FloatingTermBorder", { link = "FloatBorder" })

  local has_terminal = false
  local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
  for _, line in ipairs(lines) do
    if line ~= "" then
      has_terminal = true
      break
    end
  end
  if not has_terminal then
    vim.fn.termopen(os.getenv("SHELL"))
  end

  terminal_state.is_open = true
  vim.cmd("startinsert")

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = terminal_state.buf,
    callback = function()
      -- fix: termianl_state -> terminal_state
      if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
        vim.api.nvim_win_close(terminal_state.win, false)
        terminal_state.is_open = false
      end
    end,
    once = true,
  })
end

vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc>", function()
  if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
  end
end, { noremap = true, silent = true, desc = "Close floating terminal" })

-- ************************************************************************************************
-- LAZYGIT FLOATING WINDOW
-- ************************************************************************************************
local function open_lazygit()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit no se encuentra instalado o en el PATH", vim.log.levels.WARN, { title = "LazyGit" })
    return
  end

  local git_root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local width = math.floor(vim.o.columns * 0.92)
  local height = math.floor(vim.o.lines * 0.90)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " LazyGit ",
    title_pos = "center",
  })

  vim.wo[win].winblend = 0
  vim.wo[win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"

  -- Dejar que <Esc> pase de forma transparente a lazygit dentro de su buffer
  vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = buf, nowait = true })

  vim.fn.termopen("lazygit", {
    cwd = git_root,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      vim.cmd("checktime")
      pcall(function()
        if package.loaded["gitsigns"] then
          require("gitsigns").refresh()
        end
      end)
    end,
  })

  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("LazyGit", open_lazygit, { desc = "Open LazyGit in floating window" })
vim.keymap.set("n", "<leader>gg", open_lazygit, { noremap = true, silent = true, desc = "LazyGit" })

