-- SQL no tiene LSP propio acá (sqlfluff no habla protocolo LSP).
-- Si más adelante quieres hover/goto real sobre tablas/columnas, evalúa
-- agregar "sqls" como server aparte.
--
-- Cambia el dialecto acá si usas otro motor (mysql, tsql, sqlite, snowflake, etc)
-- -> ver sqlfluff --dialect en su documentación para la lista completa.
local dialect_args = { '--dialect', 'postgres' }

return {
  server = nil,
  parsers = { 'sql' },
  formatters = { sql = { 'sqlfluff' } },
  linters = { sql = { 'sqlfluff' } },
  mason = { 'sqlfluff' },
  formatter_opts = {
    sqlfluff = { prepend_args = dialect_args },
  },
  linter_opts = {
    sqlfluff = { args = dialect_args },
  },
}
