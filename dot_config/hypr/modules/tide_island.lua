-- =============================================================================
-- Tide-Island Module (Quickshell IPC Integration)
-- =============================================================================

local mainMod = "SUPER"
local qs = "/usr/bin/quickshell"
local tide = "-p /usr/share/tide-island"

-- Autostart Tide-Island
hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'pgrep -x tide-island >/dev/null || tide-island >/dev/null 2>&1 &'")
end)

-- Tide-Island IPC Bindings
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call overview toggle"))
hl.bind(mainMod .. " + Right", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide swipeRight"))
hl.bind(mainMod .. " + Left", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide swipeLeft"))
hl.bind(mainMod .. " + Down", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide showClock"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide togglePlayer"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide toggleControlCenter"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide toggleNotificationCenter"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide toggleWallpaperPicker"))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call tide toggleApplicationLauncher"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(qs .. " ipc --any-display " .. tide .. " call island toggle"))
