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

-- Animaciones suaves (scroll, resize, open/close). El cursor se deja nativo
-- para no pelear con el movimiento del cursor de blink.cmp.
-- El scroll con la rueda del ratón se salta la animación vía predicate para
-- evitar tirones, bloqueos o desplazamiento corto en ráfaga.
local mouse_scrolled = false
for _, scroll in ipairs({ "Up", "Down" }) do
  local key = "<ScrollWheel" .. scroll .. ">"
  vim.keymap.set({ "", "i" }, key, function()
    mouse_scrolled = true
    return key
  end, { expr = true })
end

local animate = require("mini.animate")
animate.setup({
  scroll = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
    subscroll = animate.gen_subscroll.equal({
      predicate = function(total_scroll)
        if mouse_scrolled then
          mouse_scrolled = false
          return false
        end
        return total_scroll > 1
      end,
    }),
  },
  resize = { enable = true },
  open = { enable = true },
  close = { enable = true },
  cursor = { enable = false },
})

-- Alinear asignaciones/argumentos: ga inicia, gA alinea sobre el espacio
require("mini.align").setup({})

-- Sesiones de nvim persistentes (complementa :restart de Nvim 0.12)
require("mini.sessions").setup({
  directory = vim.fn.stdpath("state") .. "/sessions",
})

vim.keymap.set("n", "<leader>ss", function()
  require("mini.sessions").write(nil, { force = true })
end, { desc = "Save session" })
vim.keymap.set("n", "<leader>sl", function()
  require("mini.sessions").read(nil, { force = true })
end, { desc = "Load session" })
vim.keymap.set("n", "<leader>sd", function()
  require("mini.sessions").delete(nil, { force = true })
end, { desc = "Delete session" })

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
    -- Grupos principales de nivel 1 (+submenús)
    { mode = "n", keys = "<leader>b", desc = "+buffer" },
    { mode = "n", keys = "<leader>c", desc = "+code" },
    { mode = "n", keys = "<leader>f", desc = "+find / fzf" },
    { mode = "n", keys = "<leader>g", desc = "+git / goto" },
    { mode = "n", keys = "<leader>h", desc = "+hunk (git)" },
    { mode = "n", keys = "<leader>s", desc = "+session / split" },
    { mode = "n", keys = "<leader>u", desc = "+ui / toggle" },

    -- Atajos directos de nivel 1
    { mode = "n", keys = "<leader>e", desc = "Oil (file explorer)" },
    { mode = "n", keys = "<leader>t", desc = "Floating Terminal" },
    { mode = "n", keys = "<leader>x", desc = "Delete without yank" },
    { mode = "x", keys = "<leader>p", desc = "Paste without yank" },
    { mode = "n", keys = "<leader>d", desc = "Diagnostic float (cursor)" },
    { mode = "n", keys = "<leader>D", desc = "Diagnostic float (line)" },
    { mode = "n", keys = "<leader>q", desc = "Diagnostic list (loclist)" },

    -- +buffer (<leader>b)
    { mode = "n", keys = "<leader>bn", desc = "Next buffer" },
    { mode = "n", keys = "<leader>bp", desc = "Previous buffer" },
    { mode = "n", keys = "<leader>bd", desc = "Delete buffer" },

    -- +code (<leader>c)
    { mode = "n", keys = "<leader>ca", desc = "Code action" },
    { mode = "n", keys = "<leader>cf", desc = "Format buffer/selection" },
    { mode = "x", keys = "<leader>cf", desc = "Format selection" },
    { mode = "n", keys = "<leader>cl", desc = "Trigger linting" },
    { mode = "n", keys = "<leader>co", desc = "Organize imports" },
    { mode = "n", keys = "<leader>cp", desc = "Copy file path" },
    { mode = "n", keys = "<leader>rn", desc = "Rename symbol" },

    -- +find (<leader>f)
    { mode = "n", keys = "<leader>ff", desc = "Find files" },
    { mode = "n", keys = "<leader>fg", desc = "Live grep" },
    { mode = "n", keys = "<leader>fb", desc = "Buffers" },
    { mode = "n", keys = "<leader>fh", desc = "Help tags" },
    { mode = "n", keys = "<leader>fx", desc = "Diagnostics (document)" },
    { mode = "n", keys = "<leader>fX", desc = "Diagnostics (workspace)" },
    { mode = "n", keys = "<leader>fr", desc = "LSP references" },
    { mode = "n", keys = "<leader>ft", desc = "LSP type definitions" },
    { mode = "n", keys = "<leader>fw", desc = "LSP workspace symbols" },
    { mode = "n", keys = "<leader>fi", desc = "LSP implementations" },

    -- +git / goto (<leader>g)
    { mode = "n", keys = "<leader>gg", desc = "LazyGit" },
    { mode = "n", keys = "<leader>gd", desc = "Definitions (fzf)" },
    { mode = "n", keys = "<leader>gD", desc = "Definition (jump)" },
    { mode = "n", keys = "<leader>gS", desc = "Definition (split)" },

    -- +hunk (<leader>h)
    { mode = "n", keys = "<leader>hs", desc = "Stage hunk" },
    { mode = "n", keys = "<leader>hr", desc = "Reset hunk" },
    { mode = "n", keys = "<leader>hp", desc = "Preview hunk" },
    { mode = "n", keys = "<leader>hb", desc = "Blame line" },
    { mode = "n", keys = "<leader>hB", desc = "Toggle inline blame" },
    { mode = "n", keys = "<leader>hd", desc = "Diff this" },

    -- +session / split (<leader>s)
    { mode = "n", keys = "<leader>ss", desc = "Save session" },
    { mode = "n", keys = "<leader>sl", desc = "Load session" },
    { mode = "n", keys = "<leader>sd", desc = "Delete session" },
    { mode = "n", keys = "<leader>sv", desc = "Split vertical" },
    { mode = "n", keys = "<leader>sh", desc = "Split horizontal" },

    -- +ui (<leader>u)
    { mode = "n", keys = "<leader>uu", desc = "Undotree" },
    { mode = "n", keys = "<leader>ud", desc = "Toggle diagnostics" },
    { mode = "n", keys = "<leader>uf", desc = "Toggle autoformat" },

    -- mini.align (aparecen al pulsar el prefijo g)
    { mode = "n", keys = "ga", desc = "Align (MiniAlign)" },
    { mode = "n", keys = "gA", desc = "Align with preview (MiniAlign)" },
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
  window = {
    delay = 350,
    config = { border = "rounded" },
  },
})
