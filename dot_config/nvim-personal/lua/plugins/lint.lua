-- ************************************************************************************************
-- nvim-lint
--
-- linters_by_ft ya NO se hardcodea acá por lenguaje. Cada lua/languages/<lang>.lua
-- declara sus propios linters; este archivo solo dispara el setup con eso.
-- ************************************************************************************************
local lint = require 'lint'
local languages = require 'config.languages'

lint.linters_by_ft = languages.linters_by_ft()

-- Opciones extra por herramienta (ej: dialecto de sqlfluff), co-localizadas
-- en el archivo del lenguaje que las declaró (ver lua/languages/sql.lua)
for tool, opts in pairs(languages.linter_opts()) do
  local linter = lint.linters[tool]
  if linter and opts.args then
    linter.args = vim.list_extend(vim.deepcopy(opts.args), linter.args or {})
  end
end

local augroup = vim.api.nvim_create_augroup('UserLint', { clear = true })

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'InsertLeave' }, {
  group = augroup,
  callback = function()
    -- evita lintear buffers sin nombre / no modificables (terminal, quickfix, etc)
    if vim.bo.buftype ~= '' or not vim.bo.modifiable then
      return
    end
    lint.try_lint()
  end,
})

local function trigger_lint()
  lint.try_lint()
end
vim.keymap.set('n', '<leader>cl', trigger_lint, { desc = 'Trigger linting for current file' })
vim.keymap.set('n', '<leader>ml', trigger_lint, { desc = 'Trigger linting for current file (alias)' })
