-- ************************************************************************************************
-- Blink.cmp (autocompletado)
-- ************************************************************************************************
require("blink.cmp").setup({
  keymap = {
    preset = "none",
    ["<C-Space>"] = { "show", "hide" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = { menu = { auto_show = true } },
  -- Expansión de snippets de los LSP (clangd, lua_ls, etc.) con el vim.snippet nativo
  -- (se eliminó LuaSnip; Tab/S-Tab ya están mapeados a snippet_forward/backward).
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
    active = function()
      return vim.snippet.active()
    end,
    jump = function(direction)
      vim.snippet.jump(direction)
    end,
  },
  sources = { default = { "lsp", "path", "buffer", "snippets" } },
  fuzzy = {
    implementation = "prefer_rust",
    prebuilt_binaries = { download = true },
  },
})
