local M = {}

local VAULT = vim.fn.expand("~/workspace/assets/obsidian-notes")

local FOLDERS = {
  "000 Zettelkasten",
  "100 Ing Informatica",
  "200 Snippets",
  "400 Files",
  "500 Excalidraw",
  "Inbox",
}

-- Crear una nota nueva eligiendo la carpeta destino con un picker
function M.new_note_in_folder()
  vim.ui.select(FOLDERS, { prompt = "¿En qué carpeta?" }, function(folder)
    if not folder then
      return
    end
    vim.ui.input({ prompt = "Título de la nota: " }, function(title)
      if not title or title == "" then
        return
      end
      local path = VAULT .. "/" .. folder .. "/" .. title .. ".md"
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end)
  end)
end

-- Mover la nota del buffer actual a otra carpeta, actualizando backlinks
function M.move_note_to_folder()
  local current_name = vim.fn.expand("%:t:r") -- nombre sin extensión
  vim.ui.select(FOLDERS, { prompt = "Mover nota a:" }, function(folder)
    if not folder then
      return
    end
    vim.cmd("wa")
    vim.cmd("Obsidian rename " .. vim.fn.fnameescape(folder .. "/" .. current_name))
    vim.defer_fn(function()
      vim.cmd("wa")
    end, 200)
  end)
end

return M
