### La arquitectura "un archivo por lenguaje"

Cada `lua/languages/<lang>.lua` declara TODO sobre ese lenguaje en un solo lugar:

```lua
-- lua/languages/python.lua
return {
  server     = "pyright",                      -- string simple, o tabla { name, cmd, settings }
  parsers    = { "python" },                   -- parsers de treesitter
  formatters = { python = { "ruff_format" } }, -- conform, keyed por FILETYPE
  linters    = { python = { "ruff" } },        -- nvim-lint, keyed por FILETYPE
  mason      = { "pyright", "ruff" },          -- binarios a auto-instalar
}
```

`lua/config/languages.lua` escanea esa carpeta y expone helpers (`parsers()`,
`formatters_by_ft()`, `linters_by_ft()`, `mason_tools()`, `setup_lsp()`) que
`treesitter.lua`, `format.lua`, `lint.lua` y `lsp/servers.lua` consumen.

**Agregar un lenguaje = crear un archivo. Quitarlo = borrarlo.** No hay que
tocar tablas en 4 archivos distintos.

Casos especiales:

- **Sin LSP propio** (ej. SQL, donde sqlfluff no habla protocolo LSP): `server = nil`.
- **Opciones extra por herramienta** (ej. dialecto de sqlfluff): campos opcionales
  `formatter_opts` / `linter_opts` en el mismo archivo del lenguaje — ver `sql.lua`.
- **Server con cmd/settings custom** (ej. clangd con flags, lua_ls con globals):
  `server = { name = "clangd", cmd = {...}, settings = {...} }`.

1. **clangd + C/C++**: para que el LSP tenga contexto real de tus proyectos, genera
   `compile_commands.json` en la raíz de cada proyecto:
   ```bash
   bear -- make        # o
   cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=1
   ```

## Cómo agregar un lenguaje nuevo

1. Crea `lua/languages/<lang>.lua` con el formato de arriba (mira `python.lua` o `go.lua` como plantilla).
2. Nada más. Al reabrir Neovim, el loader lo recoge automáticamente:
   mason instala sus binarios, treesitter instala su parser, conform y
   nvim-lint quedan wireados, y el LSP se habilita.

Ejemplo agregando Rust:

```lua
-- lua/languages/rust.lua
return {
  server = { name = "rust_analyzer", settings = { ["rust-analyzer"] = { check = { command = "clippy" } } } },
  parsers = { "rust" },
  formatters = { rust = { "rustfmt" } },
  linters = {}, -- rust_analyzer ya cubre esto vía LSP diagnostics
  mason = { "rust-analyzer" },
}
```
