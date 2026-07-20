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

-- Dialogos y Selectores - archivos flotantes
hl.window_rule({
  name = "system-dialogs-float",
  match = {
    class = "^(pavucontrol|blueman-manager|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1|hyprpolkitagent)$",
  },
  float = true,
  center = true,
})

hl.window_rule({
  name = "file-pickers-float",
  match = {
    title = "^(Open File|Save File|Select a File|Open Folder).*$",
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
