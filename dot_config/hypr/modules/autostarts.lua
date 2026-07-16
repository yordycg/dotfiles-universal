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
	hl.exec_cmd("waybar")
	-- hl.exec_cmd("swaync")
	hl.exec_cmd("awww-daemon")
end)
