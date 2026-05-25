return {
  {
    "glacambre/firenvim",
    -- Lazy load firenvim solo si NO estamos en el navegador
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      -- ============================================================
      -- Firenvim — Configuración por sitio
      -- ============================================================
      vim.g.firenvim_config = {
        globalSettings = {
          alt = "all",
        },
        localSettings = {
          -- Default: activar en todas las textareas con C-e
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never", -- <-- "never": solo activa con C-e (recomendado)
          },

          -- En GitHub activar automáticamente en textareas de PR/issues
          ["https?://github\\.com.*"] = {
            selector = "textarea.js-comment-field, textarea#pull_request_body",
            takeover = "always",
            priority = 1,
          },

          -- En sitios con editor propio, deshabilitar Firenvim
          ["https?://docs\\.google\\.com.*"] = {
            takeover = "never",
            priority = 9,
          },
          ["https?://notion\\.so.*"] = {
            takeover = "never",
            priority = 9,
          },
          ["https?://discord\\.com.*"] = {
            takeover = "never",
            priority = 9,
          },
        },
      }

      -- ============================================================
      -- Firenvim — Ajustes de UI cuando Neovim es lanzado por el browser
      -- ============================================================
      if vim.g.started_by_firenvim then
        -- Ajustes específicos para el frame del browser
        vim.opt.laststatus = 0 -- sin statusline
        vim.opt.ruler = false -- sin ruler
        vim.opt.showtabline = 0 -- sin tabline
        vim.opt.wrap = true -- wrap en textareas
        vim.opt.linebreak = true
        vim.opt.number = false -- sin números de línea (ocupa espacio)

        -- Fuente más pequeña para el frame (ajusta según tu preferencia)
        vim.opt.guifont = "Monospace:h12"
      end
    end,
  },
}
