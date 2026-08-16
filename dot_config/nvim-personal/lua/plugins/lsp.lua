-- La instalación completa de herramientas la garantiza el script de aprovisionamiento
-- .chezmoiscripts/run_once_after_27-setup-nvim-tools.sh.tmpl (espera a terminar y no
-- depende de dejar nvim abierto). Durante ese run se desactiva este loop para no
-- lanzar instalaciones duplicadas.
local languages = require("config.languages")
require("mason").setup({})

if not vim.g.nvim_mason_provision then
  local registry = require("mason-registry")
  for _, name in ipairs(languages.mason_tools()) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end
end

-- El log LSP crece sin límite (el stderr de clangd se captura como ERROR).
-- Se trunca al arrancar si supera ~10 MB.
local lsp_log = vim.fn.stdpath("state") .. "/lsp.log"
if vim.fn.getfsize(lsp_log) > 10 * 1024 * 1024 then
  vim.fn.writefile({}, lsp_log)
end

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    focusable = false,
    style = "minimal",
  },
})

do
  local orig = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig(contents, syntax, opts, ...)
  end
end

local function lsp_on_attach(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then
    return
  end

  local bufnr = ev.buf
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Inlay hints (tipos inline) cuando el server los soporta (go, rust, ts, etc.)
  if client.supports_method("textDocument/inlayHint", bufnr) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  vim.keymap.set("n", "<leader>gd", function()
    require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
  end, opts)

  vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

  vim.keymap.set("n", "<leader>gS", function()
    vim.cmd("vsplit")
    vim.lsp.buf.definition()
  end, opts)

  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

  vim.keymap.set("n", "<leader>D", function()
    vim.diagnostic.open_float({ scope = "line" })
  end, opts)
  vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.open_float({ scope = "cursor" })
  end, opts)
  vim.keymap.set("n", "<leader>nd", function()
    vim.diagnostic.jump({ count = 1 })
  end, opts)
  vim.keymap.set("n", "<leader>pd", function()
    vim.diagnostic.jump({ count = -1 })
  end, opts)

  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  vim.keymap.set("n", "<leader>fr", function()
    require("fzf-lua").lsp_references()
  end, opts)
  vim.keymap.set("n", "<leader>ft", function()
    require("fzf-lua").lsp_typedefs()
  end, opts)
  vim.keymap.set("n", "<leader>fw", function()
    require("fzf-lua").lsp_workspace_symbols()
  end, opts)
  vim.keymap.set("n", "<leader>fi", function()
    require("fzf-lua").lsp_implementations()
  end, opts)

  if client:supports_method("textDocument/codeAction", bufnr) then
    vim.keymap.set("n", "<leader>or", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
        bufnr = bufnr,
      })
      vim.defer_fn(function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, 50)
    end, opts)
  end
end

local augroup = vim.api.nvim_create_augroup("UserLsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
  vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })

-- Navegación por brackets entre diagnósticos (complementa <leader>nd/pd). Global,
-- funciona también con los de nvim-lint. ]e/[e saltan solo a errores.
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })
vim.keymap.set("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })

vim.lsp.config["*"] = {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
}

languages.setup_lsp()
