-- ************************************************************************************************
-- Language-pack loader
--
-- Lee cada archivo en lua/languages/*.lua (un lenguaje = un archivo = una fuente de verdad)
-- y expone helpers para que lsp/servers.lua, plugins/treesitter.lua, plugins/format.lua
-- y plugins/lint.lua se alimenten desde acá, en vez de tener listas duplicadas en cada uno.
--
-- Formato esperado de cada lua/languages/<lang>.lua:
-- return {
--   server     = "pyright"                              -- string simple, o:
--              | { name = "clangd", cmd = {...}, settings = {...}, filetypes = {...} },
--   parsers    = { "python" },                           -- nombres de parser treesitter
--   formatters = { python = { "ruff_format" } },          -- conform, keyed por FILETYPE
--   linters    = { python = { "ruff" } },                 -- nvim-lint, keyed por FILETYPE
--   mason      = { "pyright", "ruff" },                   -- binarios a auto-instalar
-- }
--
-- Para agregar un lenguaje: crear el archivo. Para quitarlo: borrarlo. Nada más se toca.
-- ************************************************************************************************

local M = {}

local function scan_languages()
  local specs = {}
  local dir = vim.fn.stdpath("config") .. "/lua/languages"

  if vim.fn.isdirectory(dir) == 0 then
    return specs
  end

  local files = vim.fn.globpath(dir, "*.lua", false, true)
  for _, file in ipairs(files) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    local ok, spec = pcall(dofile, file)
    if ok and type(spec) == "table" then
      specs[name] = spec
    else
      vim.notify("languages: fallo al cargar '" .. name .. "': " .. tostring(spec), vim.log.levels.WARN)
    end
  end

  return specs
end

M.specs = scan_languages()

-- Configura y habilita todos los LSP servers declarados por los lenguajes.
-- Devuelve la lista de nombres habilitados, por si se necesita loguear/depurar.
function M.setup_lsp()
  local enabled = {}

  for lang, spec in pairs(M.specs) do
    local server = spec.server
    if server ~= nil then
      if type(server) == "string" then
        table.insert(enabled, server)
      elseif type(server) == "table" and server.name then
        vim.lsp.config(server.name, {
          cmd = server.cmd,
          settings = server.settings,
          filetypes = server.filetypes,
        })
        table.insert(enabled, server.name)
      else
        vim.notify("languages: spec de servidor inválida en '" .. lang .. "'", vim.log.levels.WARN)
      end
    end
  end

  if #enabled > 0 then
    vim.lsp.enable(enabled)
  end

  return enabled
end

-- Lista plana de parsers de treesitter pedidos por todos los lenguajes
function M.parsers()
  local parsers = {}
  for _, spec in pairs(M.specs) do
    for _, p in ipairs(spec.parsers or {}) do
      table.insert(parsers, p)
    end
  end
  return parsers
end

-- Tabla filetype -> formatters, para conform.nvim
function M.formatters_by_ft()
  local out = {}
  for _, spec in pairs(M.specs) do
    for ft, fmts in pairs(spec.formatters or {}) do
      out[ft] = fmts
    end
  end
  return out
end

-- Tabla filetype -> linters, para nvim-lint
function M.linters_by_ft()
  local out = {}
  for _, spec in pairs(M.specs) do
    for ft, lnts in pairs(spec.linters or {}) do
      out[ft] = lnts
    end
  end
  return out
end

-- Opciones extra por herramienta de formatting (ej: dialecto de sqlfluff),
-- para conform.nvim -> formatters = { ... }
function M.formatter_opts()
  local out = {}
  for _, spec in pairs(M.specs) do
    for tool, opts in pairs(spec.formatter_opts or {}) do
      out[tool] = opts
    end
  end
  return out
end

-- Opciones extra por herramienta de linting (ej: dialecto de sqlfluff),
-- para nvim-lint -> linters[tool].args
function M.linter_opts()
  local out = {}
  for _, spec in pairs(M.specs) do
    for tool, opts in pairs(spec.linter_opts or {}) do
      out[tool] = opts
    end
  end
  return out
end

-- Unión de todos los binarios a auto-instalar vía mason (sin duplicados)
function M.mason_tools()
  local set = {}
  for _, spec in pairs(M.specs) do
    for _, tool in ipairs(spec.mason or {}) do
      set[tool] = true
    end
  end
  local out = {}
  for tool in pairs(set) do
    table.insert(out, tool)
  end
  return out
end

return M
