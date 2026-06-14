local autocmd = vim.api.nvim_create_autocmd

-- Django templates: tratar como HTML + Jinja
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.html" },
  callback = function()
    if vim.fn.search("{%", "n") > 0 or vim.fn.search("{{", "n") > 0 then
      vim.bo.filetype = "htmldjango"
    end
  end,
})

-- Identacion 2 espacios en JS/TS/HTML/CSS/JSON/YAML
autocmd("FileType", {
  pattern = { "javascript", "typescript", "html", "css", "json", "yaml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Cerrar quickfix / help con 'q'
autocmd("FileType", {
  pattern = { "qf", "help", "man", "notify" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
  end,
})

autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Autocomando inteligente para auto-sync de notas en obsidian-notes (A + B)
local last_push_time = 0
local cooldown = 600 -- 10 minutos (600 segundos)

local function sync_notes(force)
  local current_time = os.time()
  if force or (current_time - last_push_time >= cooldown) then
    last_push_time = current_time
    local cmd = "git add -A && git diff-index --quiet HEAD || (git commit -m 'vault: auto-sync' && git push)"
    vim.fn.jobstart(cmd, {
      cwd = vim.fn.expand("~/workspace/assets/obsidian-notes"),
      detach = true,
    })
  end
end

local sync_group = vim.api.nvim_create_augroup("ObsidianAutoSync", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "FocusLost" }, {
  group = sync_group,
  pattern = "*/obsidian-notes/*.md",
  callback = function()
    sync_notes(false)
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = sync_group,
  pattern = "*/obsidian-notes/*.md",
  callback = function()
    sync_notes(true)
  end,
})
