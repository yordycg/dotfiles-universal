-- ************************************************************************************************
-- conform.nvim - Formatting on save (reemplaza efm-langserver)
--
-- formatters_by_ft ya NO se hardcodea acá por lenguaje. Cada lua/languages/<lang>.lua
-- declara sus propios formatters; este archivo solo mezcla eso con un puñado de
-- filetypes "misc" que no ameritan su propio archivo de lenguaje (json, html, etc).
-- ************************************************************************************************
local languages = require("config.languages")

require("conform").setup({
  formatters_by_ft = languages.formatters_by_ft(),

  format_on_save = function(bufnr)
    if vim.g.disable_autoformat then
      return
    end
    -- evita formatear buffers sin nombre o no modificables
    if not vim.bo[bufnr].modifiable then
      return
    end
    if vim.api.nvim_buf_get_name(bufnr) == "" then
      return
    end
    return { timeout_ms = 2000, lsp_fallback = true }
  end,

  -- Opciones extra por herramienta (ej: dialecto de sqlfluff), co-localizadas
  -- en el archivo del lenguaje que las declaró (ver lua/languages/sql.lua)
  formatters = languages.formatter_opts(),
})

-- Format manual bajo demanda
vim.keymap.set({ "n", "v" }, "<leader>mf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer/selection" })

-- Toggle format-on-save por si necesitas desactivarlo puntualmente
vim.g.disable_autoformat = false
vim.keymap.set("n", "<leader>tf", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  print("Autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
end, { desc = "Toggle autoformat on save" })
