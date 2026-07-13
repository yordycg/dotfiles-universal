return {
  server = {
    name = "pyright",
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
        },
      },
    },
  },
  parsers = { "python" },
  -- ruff hace format + organize imports, no dupliques con black/isort
  formatters = { python = { "ruff_organize_imports", "ruff_format" } },
  linters = { python = { "ruff" } },
  mason = { "pyright", "ruff" },
}
