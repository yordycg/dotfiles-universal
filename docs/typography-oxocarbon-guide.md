# Guía de Tipografía y Tema Oxocarbon

Esta guía documenta la investigación forense, configuración y parámetros de renderizado de la tipografía **Liga SFMono Nerd Font** y el tema **Oxocarbon** a través de Neovide (entorno gráfico principal con Skia GPU) y terminales de soporte (Ghostty, Kitty, Foot). Sirve como fuente de verdad permanente para restaurar o replicar este entorno en cualquier momento.

---

## 1. Identidad de la Fuente

- **Nombre Fontconfig:** `Liga SFMono Nerd Font`
- **Autor del build:** Shaun Singh ([shaunsingh/SFMono-Nerd-Font-Ligaturized](https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized)).
- **Composición:**
  - **Base:** Apple SF Mono (versión v16 de macOS / iOS).
  - **Ligaduras:** Fira Code v3.1 ligaturizadas con precisión (flechas `->`, `=>`, comparaciones `==`, `!=`, `===`, `<=`, etc.).
  - **Glifos:** Nerd Fonts completos integrados (iconos de git, lenguajes, carpetas, diagnósticos).
- **Ruta en el sistema:** `~/.local/share/fonts/LigaSFMonoNerdFont/`
- **Automatización en Chezmoi:** Administrado en `.chezmoiscripts/run_once_after_10-install-fonts.sh.tmpl`, descargándose e instalándose de forma idempotente en Desktop (Node 2) y Laptop (Node N).

---

## 2. Los Secretos del Renderizado (El "look & feel" de la captura oficial)

Al investigar el repositorio fuente del creador ([nyoom-engineering/nyoom.nvim](https://github.com/nyoom-engineering/nyoom.nvim)) y la captura original de alta resolución (`oxocarbon_preview.png` / `206819503-736cbede-fdf2-4be3-baaa-d640c8498abf.png`, con resolución compuesta de **3028 x 10547 píxeles**), localizamos la configuración exacta detrás de la captura oficial:

```fennel
;; Desde nyoom.nvim/fnl/core/init.fnl (Shaun Singh)
(set! guifont "Liga SFMono Nerd Font:h14")
(let! neovide_padding_top 45)
(let! neovide_padding_left 38)
(let! neovide_padding_right 38)
(let! neovide_padding_bottom 20)
```

### Factores Críticos de Renderizado en Neovide:

1. **La captura fue tomada en Neovide sobre Retina HiDPI:** No en una terminal clásica de Linux, sino en Neovide bajo macOS Monterey con pantalla Retina de alta densidad (>220 DPI, factor de escala 2.0). A esta densidad, la cuadrícula de píxeles ofrece el doble de resolución horizontal y vertical por glifo.
2. **Supresión Absoluta de Hinting (`#h-none`):** Apple jamás fuerza el snapping de glifos a la cuadrícula de píxeles en macOS CoreText, preservando las curvas Bézier orgánicas. En Neovide sobre Linux (motor Skia + FreeType), pasar `:#h-none` en `guifont` evita que FreeType quiebre o deforme los trazos circulares de SF Mono.
3. **Antialiasing y Color Fringing (`#e-antialias` vs `#e-subpixelantialias`):**
   - `#e-antialias` (Grayscale puro): Elimina cualquier franja de color (*color fringing*) producida por subpíxeles RGB sobre el fondo oscuro (`#161616`) de Oxocarbon. Replica el rasterizado contemporáneo de macOS.
   - `#e-subpixelantialias` (con `g:neovide_pixel_geometry = "RGBH"`): Maximiza el detalle subpíxel horizontal en paneles LCD estándar.
4. **FreeType y Stem Darkening (CFF):** En fuentes OpenType PostScript como SF Mono, FreeType debe mantener `cff:no-stem-darkening=0` (activado) para evitar que las letras se vean anémicas o delgadas en fondos oscuros por irradiación lumínica. Esto se inyecta a nivel de sesión en `~/.config/environment.d/10-freetype.conf`.
5. **Tamaño Base Óptimo:** `13.0` (`:h13`). Brinda paridad dimensional con Ghostty, Kitty y Foot, ofreciendo un equilibrio ideal entre nitidez de curvas y densidad de columnas visibles.
6. **Padding Perimetral Equilibrado:** Un espaciado perimetral (`top=36`, `left=28`, `right=28`, `bottom=20`) que enmarca el código con elegancia editorial sin desaprovechar espacio de pantalla.
7. **Profundidad de Ventanas Flotantes (Skia GPU):** Sombras difusas (`neovide_floating_shadow = true`, `neovide_floating_z_height = 10`) y desenfoque GPU (`neovide_floating_blur_amount_* = 2.0`) en popups, Telescope y diagnósticos.
8. **Renderizado Nativo de Box-Drawing:** Modo `mode = "native"` en `~/.config/neovide/config.toml` para que los divisores de ventana y árboles de archivos se tracen con vectores directos de Skia, sin cortes verticales.

---

## 3. Matriz de Configuración por Aplicación

### A. Neovide (`dot_config/nvim-personal/lua/config/options.lua` y `config.toml`)
```lua
-- Neovide GUI Settings (Skia / Hardware rendering)
if vim.g.neovide then
  vim.opt.guifont = 'Liga SFMono Nerd Font:h13:#h-none:#e-antialias'
  vim.g.neovide_pixel_geometry = 'RGBH'
  vim.g.neovide_text_gamma = 0.0
  vim.g.neovide_text_contrast = 0.5

  -- Padding perimetral equilibrado
  vim.g.neovide_padding_top = 36
  vim.g.neovide_padding_left = 28
  vim.g.neovide_padding_right = 28
  vim.g.neovide_padding_bottom = 20

  -- Profundidad GPU en ventanas flotantes
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_floating_corner_radius = 8.0
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0

  -- Animaciones fluidas
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_size = 0.5
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_scroll_animation_length = 0.2

  -- Zoom dinámico interactivo con teclado
  vim.g.neovide_scale_factor = 1.0
  local change_scale = function(delta)
    vim.g.neovide_scale_factor = math.max(0.5, math.min(2.0, (vim.g.neovide_scale_factor or 1.0) + delta))
  end
  vim.keymap.set({ 'n', 'v' }, '<C-=>', function() change_scale(0.05) end, { desc = 'Neovide Zoom In' })
  vim.keymap.set({ 'n', 'v' }, '<C-->', function() change_scale(-0.05) end, { desc = 'Neovide Zoom Out' })
  vim.keymap.set({ 'n', 'v' }, '<C-0>', function() vim.g.neovide_scale_factor = 1.0 end, { desc = 'Neovide Reset Zoom' })
end
```

Y en `dot_config/neovide/config.toml.tmpl`:
```toml
vsync = true

[box-drawing]
mode = "native"

[box-drawing.sizes]
default = [2, 4]
```

### B. Ghostty (`dot_config/ghostty/config.tmpl`)
```ini
# --- Font & Layout ---
font-family = "Liga SFMono Nerd Font"
font-style = "Regular"
font-style-bold = "Bold"
font-style-italic = "Italic"
font-style-bold-italic = "Bold Italic"
font-size = 13.0
font-thicken = false
adjust-cell-height = 12%

# Desactiva hinting y autohint forzados para curvas Bézier puras
freetype-load-flags = no-hinting,no-autohint

# Ligaduras habilitadas
font-feature = +calt
font-feature = +liga

# Padding y decoración
window-padding-x = 24
window-padding-y = 24
window-decoration = false

# Tema
theme = Oxocarbon
```

### C. Kitty (`dot_config/kitty/kitty.conf.tmpl`)
```conf
include colors/oxocarbon.conf

# Font
font_family      Liga SFMono Nerd Font Regular
bold_font        Liga SFMono Nerd Font Bold
italic_font      Liga SFMono Nerd Font Italic
bold_italic_font Liga SFMono Nerd Font Bold Italic
font_size        13.0
modify_font      cell_height 112%

# Mayor solidez y contraste tipográfico en fondos oscuros
text_composition_strategy legacy

# Window layout
window_padding_width 24
hide_window_decorations yes
```

### D. Foot (`dot_config/foot/foot.ini.tmpl`)
```ini
font=Liga SFMono Nerd Font:size=13
font-bold=Liga SFMono Nerd Font:style=Bold:size=13
font-italic=Liga SFMono Nerd Font:style=Italic:size=13
font-bold-italic=Liga SFMono Nerd Font:style=Bold Italic:size=13
pad=24x24

# Nota Foot 1.28+: La sección para el tema oscuro es [colors-dark]
[colors-dark]
background=161616
foreground=ffffff

regular0=161616
regular1=78a9ff
regular2=ff7eb6
regular3=42be65
regular4=08bdba
regular5=82cfff
regular6=33b1ff
regular7=dde1e6

bright0=525252
bright1=78a9ff
bright2=ff7eb6
bright3=42be65
bright4=08bdba
bright5=82cfff
bright6=33b1ff
bright7=ffffff

selection-foreground=161616
selection-background=ee5396
```

---

## 4. Estilo Tipográfico en Neovim

En `oxocarbon.nvim`:
- **Comentarios:** Configurados canónicamente con `italic = true`.
- **Markdown:** Énfasis con cursiva y negrita (`@markup.italic`, `@markup.strong`).
- **Palabras Clave (Keywords):** En Oxocarbon son **romanas (rectas)**, no cursivas, para mantener la neutralidad de IBM Carbon.
- **Modeline y Ventanas:**
  - Separadores verticales suaves (`WinSeparator` con mismo color de fondo).
  - `fillchars = { eob = " " }` para ocultar virgulillas (`~`).

---

## 5. Procedimiento para Cambiar de Fuente o Restaurar

Si en el futuro cambias a otra tipografía (ej. JetBrains Mono, Geist Mono) y deseas volver a este setup:

1. **Verificar que la fuente esté instalada:**
   ```bash
   fc-list "Liga SFMono Nerd Font" style
   ```
2. **En caso de necesitar reinstalarla:**
   Ejecutar el script automatizado:
   ```bash
   ~/.local/share/chezmoi/.chezmoiscripts/run_once_after_10-install-fonts.sh.tmpl
   ```
3. **Aplicar los templates de Chezmoi:**
   ```bash
   chezmoi apply ~/.config/nvim-personal/lua/config/options.lua ~/.config/neovide/config.toml ~/.config/ghostty/config ~/.config/kitty/kitty.conf ~/.config/foot/foot.ini
   ```
4. **Reiniciar Neovide o la terminal activa** para disfrutar del renderizado exacto.

