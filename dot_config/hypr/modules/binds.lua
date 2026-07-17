---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "kitty"
local fileManager = "thunar" -- dolphin
local menu = "./.config/rofi/type-2/launcher.sh"

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("/home/yordycg/.config/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Notification Center
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + CONTROL + SHIFT + A", hl.dsp.exec_cmd("swaync-client -R && swaync-client -rs"))

-- Browser
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("brave"))

-- Screenshot
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + SHIFT + F12", hl.dsp.exec_cmd("hyprshot -m region"))

-- Calculator (rofi-calc)
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort"))

-- Interactive Kill
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("hyprctl kill"))

-- Color Picker
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("hyprpicker -a"))

-- Logout Menu (wlogout)
hl.bind("CONTROL + ALT + Delete", hl.dsp.exec_cmd("pkill wlogout || wlogout -l .config/wlogout/layout -C .config/wlogout/theme.css -b 5 -p layer-shell -B 400 -T 400"))

-- Zoom factor controls
local superMod = "SUPER"
hl.bind(superMod .. " + mouse_down", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"))
hl.bind(superMod .. " + mouse_up", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"))
hl.bind(superMod .. " + SHIFT + mouse_up", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor 1"))
hl.bind(superMod .. " + SHIFT + mouse_down", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor 1"))
hl.bind(superMod .. " + SHIFT + 0", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor 1"))

-- Bars
local hyprbars = "/home/yordycg/.local/share/hyprland-plugins/hyprbars.so"
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("hyprctl plugin load " .. hyprbars))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("hyprctl plugin unload " .. hyprbars))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("hyprctl dispatch hyprexpo:expo toggle"))

-- Selector TAB
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("snappy-switcher next"))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.exec_cmd("snappy-switcher prev"))
