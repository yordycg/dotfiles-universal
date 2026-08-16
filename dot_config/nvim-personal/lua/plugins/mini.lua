-- ************************************************************************************************
-- mini.nvim
-- ************************************************************************************************
require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({
  symbol = "▏",
  draw = {
    delay = 0,
    animation = require("mini.indentscope").gen_animation.none(),
  },
  options = {
    try_as_border = true,
  },
})

-- Tinte del scope de indentación: lo deriva del grupo Function del tema actual
-- para que se vea claro y siga a theme-hub al cambiar de colorscheme.
local indentscope_group = vim.api.nvim_create_augroup('MiniIndentscopeHighlight', { clear = true })
local function setup_indentscope_hl()
  local src = vim.api.nvim_get_hl(0, { name = 'Function', link = false })
  local fg = src.fg or vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).fg
  vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = fg })
end
setup_indentscope_hl()
vim.api.nvim_create_autocmd('ColorScheme', { group = indentscope_group, callback = setup_indentscope_hl })
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})
require("mini.icons").mock_nvim_web_devicons()

-- Resalta TODO/FIXME/HACK y colores hex (reemplaza todo-comments + colorizer)
require("mini.hipatterns").setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
  },
})

-- Popup de ayuda para leader-mappings (equivalente a which-key)
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = "n", keys = "<leader>" },
    { mode = "x", keys = "<leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
  },
  clues = {
    { mode = "n", keys = "<leader>b", desc = "+buffer" },
    { mode = "n", keys = "<leader>s", desc = "+split" },
    { mode = "n", keys = "<leader>f", desc = "+find" },
    { mode = "n", keys = "<leader>h", desc = "+git hunk" },
    { mode = "n", keys = "<leader>g", desc = "+goto/lsp" },
    { mode = "n", keys = "<leader>e", desc = "Toggle NvimTree" },
    { mode = "n", keys = "<leader>t", desc = "Floating Terminal" },
    { mode = "n", keys = "<leader>th", desc = "Theme Hub" },
    { mode = "n", keys = "<leader>u", desc = "+ui/toggle" },
    { mode = "n", keys = "<leader>m", desc = "+format/lint" },
    { mode = "n", keys = "<leader>c", desc = "+code" },
    { mode = "n", keys = "<leader>p", desc = "+paste/path" },
    { mode = "n", keys = "<leader>x", desc = "Delete without yank" },
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
  window = { config = { border = "rounded" } },
})
