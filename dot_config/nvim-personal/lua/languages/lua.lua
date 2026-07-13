return {
  server = {
    name = "lua_ls",
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        telemetry = { enable = false },
      },
    },
  },
  parsers = { "lua" },
  formatters = { lua = { "stylua" } },
  linters = { lua = { "luacheck" } },
  mason = { "lua-language-server", "stylua", "luacheck" },
}
