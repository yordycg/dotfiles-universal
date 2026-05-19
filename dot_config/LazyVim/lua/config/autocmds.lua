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
