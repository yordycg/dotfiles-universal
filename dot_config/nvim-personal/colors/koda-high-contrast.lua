-- Koda High Contrast Colorscheme for Neovim
-- Variante de alto contraste basada en la arquitectura y tokens de Koda (Oskar Nurm)

local palette = {
  bg         = "#080808",
  fg         = "#e0e0e0",
  dim        = "#555555",
  line       = "#202020",
  keyword    = "#9e9e9e",
  type       = "#9e9e9e",
  operator   = "#9e9e9e",
  comment    = "#687076",
  border     = "#ffffff",
  emphasis   = "#ffffff",
  func       = "#ffffff",
  string     = "#ffffff",
  char       = "#ffffff",
  special    = "#ffffff",
  const      = "#e5c07b",
  highlight  = "#458ee6",
  info       = "#8ebeec",
  success    = "#86cd82",
  warning    = "#e5c07b",
  danger     = "#ff7676",
  green      = "#14ba19",
  orange     = "#ff5733",
  red        = "#ff5555",
  pink       = "#f2a4db",
  cyan       = "#5abfb5",
}

local ok, config = pcall(require, "koda.config")
if not ok then
  vim.notify("koda.nvim is required for koda-high-contrast", vim.log.levels.ERROR)
  return
end

local groups = require("koda.groups")

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "koda-high-contrast"

local hl_groups = groups.setup(palette, config.options, "dark")
for group, hl in pairs(hl_groups) do
  vim.api.nvim_set_hl(0, group, hl)
end
