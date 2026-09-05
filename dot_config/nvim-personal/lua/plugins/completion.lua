-- ************************************************************************************************
-- Blink.cmp (autocompletado)
-- ************************************************************************************************
require("blink.cmp").setup({
  keymap = {
    preset = "none",
    ["<C-Space>"] = { "show", "hide" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-y>"] = { "select_and_accept", "fallback" },
    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = { menu = { auto_show = true } },
  -- Asistencia automática de firmas/parámetros al escribir funciones
  signature = {
    enabled = true,
    window = { border = "rounded" },
  },
  -- Expansión de snippets de los LSP (clangd, lua_ls, etc.) con el vim.snippet
  -- nativo. preset='default' delega en vim.snippet.expand(snippet) pasando el string correcto.
  snippets = {
    preset = "default",
  },
  sources = { default = { "lsp", "path", "buffer", "snippets" } },
  fuzzy = {
    implementation = "prefer_rust",
    prebuilt_binaries = { download = true },
  },
})
