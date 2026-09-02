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
  -- Expansión de snippets de los LSP (clangd, lua_ls, etc.) con el vim.snippet
  -- nativo. La activación/salto los gestiona blink.cmp internamente; aquí solo
  -- se declara `expand` (campos como active/jump ya no son válidos).
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  sources = { default = { "lsp", "path", "buffer", "snippets" } },
  fuzzy = {
    implementation = "prefer_rust",
    prebuilt_binaries = { download = true },
  },
})
