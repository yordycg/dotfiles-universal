--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.layer_rule({
	name = "rofi-popup",
	match = { namespace = "rofi" },
	animation = "slide top",
	dim_around = true,
})

hl.layer_rule({
	name = "notification-animations",
	match = { namespace = "swaync-control-center" },
	animation = "slide right",
	dim_around = true,
})

hl.window_rule({
	name = "workspace-workspaces-float",
	match = { class = "workspace-float" },
	float = true,
	center = true,
	size = "90% 90%",
})

-- ============================================
-- Opacidad dinámica por monitor (simétrica)
-- Requiere: decoration.active_opacity / inactive_opacity
-- ya definidos en tu config (ej: 0.97 / 0.8)
-- ============================================

-- Regla estática: ventanas con el tag "dimmed" quedan 100% opacas
hl.window_rule({
  name = "dimmed-monitor-opacity",
  match = { tag = "dimmed" },
  opacity = "1.0 override 1.0 override",
})

-- Al cambiar de ventana activa, taggeamos/destaggeamos según el monitor
hl.on("window.active", function(w)
  if not w or w.monitor == nil then return end
  local active_mon_id = w.monitor.id

  for _, win in ipairs(hl.get_windows()) do
    if win.address and win.monitor ~= nil then
      local sel = "address:" .. win.address
      if win.monitor.id == active_mon_id then
        -- Monitor activo -> sin tag -> usa decoration.active/inactive_opacity normal
        hl.dispatch(hl.dsp.window.tag({ tag = "-dimmed", window = sel }))
      else
        -- Monitor inactivo -> con tag -> opacidad forzada a 1.0
        hl.dispatch(hl.dsp.window.tag({ tag = "+dimmed", window = sel }))
      end
    end
  end
end)

-- PIP rule
hl.window_rule({
  name = "pip-auto-pin",
  match = { title = "^(Picture-in-Picture)$" },
  float = true,
  pin = true,
  size = "600 338",
  move = "100%-615 100%-353",
})

-- Dialogos y Selectores del Sistema
hl.window_rule({
  name = "system-dialogs-float",
  match = {
    class = "^(pavucontrol|blueman-manager|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1|hyprpolkitagent)$",
  },
  float = true,
  center = true,
})

-- Diálogos de Selección de Archivos (EN & ES)
hl.window_rule({
  name = "file-pickers-float",
  match = {
    title = "^(Open File|Save File|Save As|Select a File|Open Folder|Choose Files|Abrir archivo|Guardar como|Seleccionar archivos|Seleccionar carpeta).*$",
  },
  float = true,
  center = true,
  size = "900 600",
})

-- Gestor de Archivos Thunar (Ventana principal y subdiálogos)
hl.window_rule({
  name = "thunar-float",
  match = {
    class = "^(thunar)$",
  },
  float = true,
  center = true,
  size = "1000 650",
})

-- Gestores de Archivos Comprimidos
hl.window_rule({
  name = "archive-managers-float",
  match = {
    class = "^(file-roller|ark|xarchiver)$",
  },
  float = true,
  center = true,
  size = "800 500",
})

-- Descargas y Bibliotecas del Navegador (EN & ES)
hl.window_rule({
  name = "browser-downloads-float",
  match = {
    class = "^(firefox|google-chrome|brave-browser)$",
    title = "^(Downloads|Descargas|Library|Catálogo)$",
  },
  float = true,
  center = true,
  size = "800 500",
})

-- Ventanas de Autenticación, OAuth y Extensiones (Bitwarden, Google, etc.)
hl.window_rule({
  name = "auth-popups-float",
  match = {
    title = "^(Extension:.*Bitwarden.*|Bitwarden.*|Sign in - Google Accounts.*|Iniciar sesión.*|Autorizar.*)$",
  },
  float = true,
  center = true,
  size = "600 650",
})

-- Utilidades y Diálogos de Scripting
hl.window_rule({
  name = "script-dialogs-float",
  match = {
    class = "^(yad|zenity)$",
  },
  float = true,
  center = true,
})

-- Calculadoras de Escritorio (EN & ES)
hl.window_rule({
  name = "calculators-float",
  match = {
    class = "^(galculator|mate-calc|gnome-calculator|kcalc|qalculate-gtk)$",
  },
  float = true,
  center = true,
})

-- Duplicado de Pantalla (Android scrcpy)
hl.window_rule({
  name = "scrcpy-float",
  match = {
    class = "^(scrcpy)$",
  },
  float = true,
  center = true,
})

-- Reproductores y Visores Multimedia (imv, mpv, vlc)
hl.window_rule({
  name = "media-viewers-float",
  match = {
    class = "^(imv|mpv|vlc)$",
  },
  float = true,
  center = true,
  size = "960 540",
})

-- Gestores de Descargas / Torrent
hl.window_rule({
  name = "downloaders-float",
  match = {
    class = "^(org.qbittorrent.qBittorrent|transmission-gtk)$",
  },
  float = true,
  center = true,
  size = "900 600",
})

-- Portales de Selección de Archivos del Sistema
hl.window_rule({
  name = "portals-float",
  match = {
    class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde)$",
  },
  float = true,
  center = true,
})

-- KDE Connect (diálogos, app y selector)
hl.window_rule({
  name = "kdeconnect-float",
  match = {
    class = "^(org.kde.kdeconnect.*|kdeconnect-app|kdeconnect-indicator|kdeconnect.sms)$",
  },
  float = true,
  center = true,
})



-- Blur - capas UI
hl.layer_rule({
  name = "ui-layers-blur",
  match = { namespace = "^(rofi|swaync-control-center|swaync-notification-window|waybar)$" },
  blur = true,
})

-- Opacity - juegos y reproductores videos
hl.window_rule({
  name = "media-games-full-opacity",
  match = { class = "^(mpv|vlc|Steam|heroic)$" },
  opacity = "1.0 override 1.0 override",
})

-- Ruteo dinámico de terminales (primera en WS1, siguientes en WS activo)
hl.on("window.open", function(w)
  if not w then return end

  -- Si es la terminal por defecto (kitty)
  if w.class == "kitty" then
    local kitty_count = 0
    for _, win in ipairs(hl.get_windows()) do
      if win.class == "kitty" then
        kitty_count = kitty_count + 1
      end
    end

    -- Si es la primera terminal abierta en total, la movemos a WS1 silenciosamente
    if kitty_count == 1 then
      hl.dispatch(hl.dsp.window.move({ workspace = 1, follow = false, window = "address:" .. w.address }))
    end
  end
end)

-- Smart Borders: Quitar bordes y redondeado si solo hay 1 ventana tiled en el workspace (o está en fullscreen)
hl.window_rule({
  name = "smart-borders-single",
  match = { float = false, workspace = "w[t1]" },
  border_size = 0,
  rounding = 0,
})
hl.window_rule({
  name = "smart-borders-fullscreen",
  match = { workspace = "f[1]" },
  border_size = 0,
  rounding = 0,
})


