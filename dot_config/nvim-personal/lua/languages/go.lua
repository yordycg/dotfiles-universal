-- Go. Server: gopls. Formatter: goimports (formats + manages imports).
return {
  server = {
    name = 'gopls',
    settings = {
      gopls = {
        gofumpt = true,
        staticcheck = true,
        analyses = {
          unusedparams = true,
        },
      },
    },
  },
  parsers = { 'go', 'gomod', 'gowork', 'gosum' },
  formatters = { go = { 'goimports', 'gofumpt' } },
  linters = { go = { 'staticcheck' } },
  mason = { 'gopls', 'goimports', 'gofumpt', 'staticcheck' },
}
