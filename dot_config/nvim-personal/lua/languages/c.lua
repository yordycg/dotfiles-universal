-- Nota: clangd necesita un compile_commands.json en la raíz del proyecto
-- (genéralo con `bear -- make` o `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1`)
-- para tener contexto real de includes/flags. Sin eso, el análisis es limitado.
--
-- clangd/clang-format/clang-tidy se instalan como paquetes de SISTEMA (pacman:
-- paquete `clang`), no via mason, porque se usan también desde la terminal
-- (clang-format, clang-tidy, bear). nvim los encuentra por PATH.
return {
  server = {
    name = "clangd",
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
    },
  },
  parsers = { "c", "cpp" },
  formatters = { c = { "clang_format" }, cpp = { "clang_format" } },
  linters = {},
}
