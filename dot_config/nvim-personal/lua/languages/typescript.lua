return {
  server = "ts_ls",
  parsers = { "javascript", "typescript" },
  formatters = {
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
  },
  linters = {
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
  },
  mason = { "typescript-language-server", "prettierd", "eslint_d" },
}
