# Guía de Tipografía y Tema Oxocarbon

Esta guía documenta la investigación, configuración y parámetros de renderizado de la tipografía **Liga SFMono Nerd Font** y el tema **Oxocarbon** a través de Neovim, Ghostty, Kitty y Foot. Sirve como fuente de verdad permanente para restaurar o replicar este entorno en cualquier momento.

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

Al investigar el repositorio fuente del creador ([nyoom-engineering/nyoom.nvim](https://github.com/nyoom-engineering/nyoom.nvim)), localizamos la configuración exacta detrás de la captura oficial de Oxocarbon (`oxocarbon_preview.png`):

```fennel
;; Desde nyoom.nvim/fnl/core/init.fnl
(set! guifont "Liga SFMono Nerd Font:h14")
(let! neovide_padding_top 45)
(let! neovide_padding_left 38)
(let! neovide_padding_right 38)
(let! neovide_padding_bottom 20)
```

### Factores Críticos de Renderizado:

1. **La captura fue tomada en Neovide:** No en una terminal clásica de Linux, sino en Neovide (cliente gráfico GUI con aceleración GPU Skia, antialiasing subpixel y padding perimetral muy amplio).
2. **Desactivar `font-thicken`:** En Ghostty, la opción `font-thicken = true` engorda artificialmente todos los trazos. Dado que SF Mono es una fuente esbelta y geométrica, `font-thicken` la empasta y arruina el contraste con el texto en negrita (**bold**). Debe mantenerse en `false`.
3. **Altura de línea (`cell-height`):** Shaun Singh aplica en sus terminales (`alacritty.yml`) un desplazamiento vertical (`offset: y: 10`) para que las líneas respiren. En Ghostty esto equivale a `adjust-cell-height = 12%`, y en Kitty a `modify_font cell_height 112%`.
4. **Mapeo Explícito de Variantes:** El paquete de la fuente provee 12 archivos (`Light`, `Regular`, `Medium`, `SemiBold`, `Bold`, `Heavy` y sus cursivas). Declarar explícitamente `Regular`, `Bold`, `Italic` y `Bold Italic` previene que Fontconfig o el motor de la terminal elija `Medium` como fuente base por error.
5. **Tamaño óptimo:** `14.0` (`h14`). A este tamaño, la cuadrícula de píxeles encaja con las proporciones nativas de SF Mono y los símbolos de las ligaduras.
6. **Padding perimetral:** Un padding de `24px` a `27px` en las terminales elimina la sensación claustrofóbica y replica la estética de Neovide/Foot.
7. **FreeType y Stem Darkening (CFF):** En fuentes OpenType PostScript como SF Mono, FreeType debe mantener `cff:no-stem-darkening=0` (activado) para evitar que las letras se vean anémicas o delgadas en fondos oscuros. Esto se inyecta a nivel de sesión en `~/.config/environment.d/10-freetype.conf`.
8. **Grayscale Antialiasing (`rgba=none`):** En fondos oscuros (`#161616`), el subpíxel RGB puede introducir *color fringing*. Forzar escala de grises pura (`rgba=none`) unifica la nitidez y elimina artefactos en Kitty, Ghostty y Foot.
9. **Impacto de la Densidad de Píxeles (DPI):** En monitores de 27" 1080p (~81 DPI), la cuadrícula rígida de las terminales expone la pixelación. El motor Skia de Neovide suaviza esto mediante posicionamiento subpíxel vectorial continuo en coma flotante.

---

## 3. Matriz de Configuración por Terminal

### A. Ghostty (`dot_config/ghostty/config.tmpl`)
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

### B. Kitty (`dot_config/kitty/kitty.conf.tmpl`)
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

### C. Foot (`dot_config/foot/foot.ini.tmpl`)
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
   chezmoi apply ~/.config/ghostty/config ~/.config/kitty/kitty.conf ~/.config/foot/foot.ini
   ```
4. **Recargar la terminal activa** o abrir una nueva ventana para disfrutar del renderizado exacto.
