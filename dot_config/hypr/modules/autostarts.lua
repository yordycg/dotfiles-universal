-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- on() - funcion para escuchar el evento 'on'
hl.on("hyprland.start", function()
	-- exec_cmd() - funcion para ejecutar comandos
	hl.exec_cmd("waybar") -- waybar
	-- hl.exec_cmd("hyprpm reload") -- plugins
	hl.exec_cmd("awww-daemon") -- wallpaper daemon
	-- hl.exec_cmd("udiskie") -- auto-mount devices
	-- hl.exec_cmd("hypridle") -- idle daemon
	hl.exec_cmd("swaync") -- notification daemon
	-- cursor...
	-- hl.exec_cmd("wl-paste --type text --watch cliphist store") -- clipboard
	-- hl.exec_cmd("wl-clip-persist --clipboard both") -- clipboard persist
	-- hl.exec_cmd("mpris-proxy") -- mpris-proxy
end)
