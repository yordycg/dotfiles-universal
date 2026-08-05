-- Native statusline. No plugin. Adapts to any colorscheme: the mode block colors
-- are derived from the theme's highlight groups on every ColorScheme, and the rest
-- uses existing groups (Diagnostic*, Added/Changed/Removed, Comment). Global.
--
-- Layout:
--   MODE  file.ts (typescript, +0~1-0)      lua_ls      8  3   Ln 12, Col 34
--   └mode └file    └(filetype, diff from vcsigns)  └lsp  └diagnostics  └position

local M = {}

-- Nerd Font glyph as a byte escape so it survives editing (\xNN, not a literal).
local LSP = '\xf3\xb0\x9a\xa9' -- U+F06A9

local diag = {
  { sev = vim.diagnostic.severity.ERROR, icon = '\xef\x81\x97', hl = 'DiagnosticError' }, --
  { sev = vim.diagnostic.severity.WARN, icon = '\xef\x81\xb1', hl = 'DiagnosticWarn' }, --
  { sev = vim.diagnostic.severity.INFO, icon = '\xef\x81\x9a', hl = 'DiagnosticInfo' }, --
  { sev = vim.diagnostic.severity.HINT, icon = '\xef\x83\xab', hl = 'DiagnosticHint' }, --
}

local mode_map = {
  n = 'NORMAL',
  no = 'O-PENDING',
  nov = 'O-PENDING',
  noV = 'O-PENDING',
  niI = 'NORMAL',
  niR = 'NORMAL',
  niV = 'NORMAL',
  v = 'VISUAL',
  V = 'V-LINE',
  ['\22'] = 'V-BLOCK', -- <C-v>
  s = 'SELECT',
  S = 'S-LINE',
  ['\19'] = 'S-BLOCK', -- <C-s>
  i = 'INSERT',
  ic = 'INSERT',
  ix = 'INSERT',
  R = 'REPLACE',
  Rv = 'V-REPLACE',
  c = 'COMMAND',
  cv = 'EX',
  r = 'PROMPT',
  rm = 'MORE',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  t = 'TERMINAL',
}

-- Which highlight group each mode uses for its colored block.
local mode_hl = {
  n = 'StlModeNormal',
  no = 'StlModeNormal',
  nov = 'StlModeNormal',
  noV = 'StlModeNormal',
  niI = 'StlModeNormal',
  niR = 'StlModeNormal',
  niV = 'StlModeNormal',
  v = 'StlModeVisual',
  V = 'StlModeVisual',
  ['\22'] = 'StlModeVisual',
  s = 'StlModeVisual',
  S = 'StlModeVisual',
  ['\19'] = 'StlModeVisual',
  i = 'StlModeInsert',
  ic = 'StlModeInsert',
  ix = 'StlModeInsert',
  R = 'StlModeReplace',
  Rv = 'StlModeReplace',
  c = 'StlModeCommand',
  cv = 'StlModeCommand',
  t = 'StlModeTerminal',
}

-- Borrow each mode color from an existing theme group so it tracks the colorscheme.
local mode_source = {
  StlModeNormal = 'Function',
  StlModeInsert = 'String',
  StlModeVisual = 'Keyword',
  StlModeReplace = 'DiagnosticError',
  StlModeCommand = 'Constant',
  StlModeTerminal = 'Type',
}

local function setup_hl()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local text = normal.bg or 0x1e1e2e -- dark text on the colored block
  for group, source in pairs(mode_source) do
    local src = vim.api.nvim_get_hl(0, { name = source, link = false })
    local color = src.fg or normal.fg or 0xcccccc
    vim.api.nvim_set_hl(0, group, { fg = text, bg = color, bold = true })
  end
  -- Subdued meta text: Comment's color, but never italic.
  local comment = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })
  vim.api.nvim_set_hl(0, 'StlMeta', { fg = comment.fg, italic = false })
  -- Filename block: a subtle background from the theme's CursorLine group.
  local cursorline = vim.api.nvim_get_hl(0, { name = 'CursorLine', link = false })
  local visual = vim.api.nvim_get_hl(0, { name = 'Visual', link = false })
  vim.api.nvim_set_hl(0, 'StlFile', { fg = normal.fg, bg = cursorline.bg or visual.bg })
  -- Unify the statusline background with the editor so the bar looks seamless;
  -- only the mode and filename blocks keep their own background.
  vim.api.nvim_set_hl(0, 'StatusLine', { fg = normal.fg, bg = normal.bg })
end

-- Clients that use LSP as transport but are not language servers.
local lsp_ignore = { copilot = true }

local function lsp()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if not lsp_ignore[c.name] then
      names[#names + 1] = c.name
    end
  end
  if #names == 0 then
    return ''
  end
  return '%#StlMeta#' .. LSP .. ' ' .. table.concat(names, ', ') .. '%*'
end

-- VCS cluster: git diff counts, computed from the extmarks gitsigns places in
-- the 'gitsigns_signs_' namespace (gitsigns removed its stats API). No dependency
-- on plugin internals beyond that stable namespace name.
local VCS_SIGN_NS = 'gitsigns_signs_'

local function git_signs_stats(bufnr)
  -- create_namespace reutiliza el id existente si gitsigns ya creó el namespace
  -- (los namespaces se indexan por nombre), así que es seguro llamarlo siempre.
  local ns = vim.api.nvim_create_namespace(VCS_SIGN_NS)
  local stats = { added = 0, modified = 0, removed = 0 }
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
  for _, mark in ipairs(marks) do
    local details = mark[4] or {}
    local hl = details.sign_hl_group or ''
    if hl:find('^GitSignsAdd') or hl:find('^GitSignsUntracked') then
      stats.added = stats.added + 1
    elseif hl:find('^GitSignsChange') then
      stats.modified = stats.modified + 1
    elseif hl:find('^GitSignsDelete') then
      stats.removed = stats.removed + 1
    end
  end
  return stats
end

local vcs_stats = {}

local function update_vcs_stats()
  vcs_stats = git_signs_stats(0) or {}
  vim.cmd('redrawstatus')
end

local vcs_augroup = vim.api.nvim_create_augroup('UserStatusVCS', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  group = vcs_augroup,
  callback = update_vcs_stats,
})
vim.api.nvim_create_autocmd('User', {
  group = vcs_augroup,
  pattern = 'GitSignsUpdate',
  callback = update_vcs_stats,
})

local function vcs()
  local s = vcs_stats
  if not s or (s.added + s.modified + s.removed) == 0 then
    return ''
  end
  return '%#StlMeta# '
    .. '%#Added#+' .. s.added
    .. '%#Changed#~' .. s.modified
    .. '%#Removed#-' .. s.removed
    .. '%*'
end

local function diagnostics()
  local c = vim.diagnostic.count(0)
  local out = {}
  for _, d in ipairs(diag) do
    local n = c[d.sev] or 0
    if n > 0 then
      out[#out + 1] = '%#' .. d.hl .. '# ' .. d.icon .. ' ' .. n .. '%*'
    end
  end
  return #out > 0 and (table.concat(out) .. ' ') or ''
end

function M.render()
  local m = vim.api.nvim_get_mode().mode
  local label = mode_map[m] or 'UNKNOWN'
  local hl = mode_hl[m] or 'StlModeNormal'
  return table.concat {
    '%#' .. hl .. '# ' .. label .. ' %*', -- colored mode block
    '%#StlFile# %<%t%m%r %*', -- filename block (with background)
    vcs(), -- #bookmark +added~changed-removed
    '%=', -- ---- center ----
    lsp(), -- attached LSP server(s)
    '%=', -- ---- right ----
    diagnostics(),
    '%#StlMeta# %{&filetype} %*', -- filetype, right side
    ' Ln %l, Col %c ', -- position, VSCode-style
  }
end

setup_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_hl })

vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

return M
