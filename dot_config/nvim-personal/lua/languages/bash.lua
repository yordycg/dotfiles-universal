return {
  server = "bashls",
  parsers = { "bash" },
  formatters = { sh = { "shfmt" }, bash = { "shfmt" }, zsh = { "shfmt" } },
  linters = { sh = { "shellcheck" }, bash = { "shellcheck" }, zsh = { "shellcheck" } },
  mason = { "bash-language-server", "shfmt", "shellcheck" },
}
