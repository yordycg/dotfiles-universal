# ⌨️ Tridactyl Cheatsheet (Firefox Vim)

Guía rápida de comandos y atajos configurados en `~/.config/tridactyl/tridactylrc`.

## 🚀 Navegación de Pestañas
| Tecla | Acción |
|-------|--------|
| `J`   | Siguiente pestaña |
| `K`   | Pestaña anterior |
| `g0`  | Primera pestaña |
| `g$`  | Última pestaña |
| `x`   | Cerrar pestaña actual |
| `X`   | Restaurar pestaña cerrada (Undo) |
| `t`   | Nueva pestaña (enfoque barra URL) |
| `T`   | Duplicar URL actual en nueva pestaña |

## 📄 Navegación de Página
| Tecla | Acción |
|-------|--------|
| `d`   | Scroll media página ABAJO |
| `u`   | Scroll media página ARRIBA |
| `f`   | Abrir enlace (Hints) |
| `F`   | Abrir enlace en pestaña nueva |

## 🔍 Búsqueda (Prefijos en `:open` o `:tabopen`)
| Prefijo | Motor de Búsqueda |
|---------|-------------------|
| `g`     | Google |
| `ddg`   | DuckDuckGo (Defecto) |
| `gh`    | GitHub |
| `yt`    | YouTube |
| `mdn`   | Mozilla Developer Network |
| `w`     | Wikipedia |

*Ejemplo:* `:tabopen yt neovim`

## ⚡ Aliases (Comandos rápidos)
| Comando | Acción |
|---------|--------|
| `:o`    | Abrir URL (open) |
| `:t`    | Abrir en pestaña nueva (tabopen) |
| `:w`    | Abrir en ventana nueva (winopen) |
| `:bm`   | Guardar marcador (bmark) |
| `:h`    | Ayuda (help) |

## 🛠️ Utilidades
- `<leader>r`: Recargar configuración (`tridactylrc`).
- `Shift + Insert`: Alternar "Modo Ignore" (útil en Discord, Notion, Figma).
- `Ctrl + I`: Editar campo de texto con **Neovim**.

---
*Archivo generado para consulta rápida vía `cat docs/tridactyl-cheatsheet.md`*
