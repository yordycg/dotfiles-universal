#!/usr/bin/env bash
# =============================================================================
# wifi-menu.sh — Rofi WiFi Manager
# Uses nmcli and rofi to scan, connect, and toggle WiFi networks.
# =============================================================================
set -euo pipefail

ROFI_THEME="$HOME/.config/rofi/menu_compact.rasi"

notify-send "Wi-Fi" "Buscando redes Wi-Fi disponibles..." -t 2000 || true

# Get a list of available wifi connections and format into readable list
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list 2>/dev/null | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d" || echo "")

connected=$(nmcli -fields WIFI g 2>/dev/null || echo "")
if [[ "$connected" =~ "enabled" ]]; then
    toggle="󰖪  Desactivar Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
    toggle="󰖩  Activar Wi-Fi"
else
    toggle="󰖩  Activar Wi-Fi"
fi

# Use rofi to select wifi network
if [ -f "$ROFI_THEME" ]; then
    chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -theme "$ROFI_THEME" -selected-row 1 -p "Wi-Fi" || true)
else
    chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi" || true)
fi

if [ -z "$chosen_network" ]; then
    exit 0
fi

# Extract SSID
read -r chosen_id <<< "${chosen_network:3}"

if [ "$chosen_network" = "󰖩  Activar Wi-Fi" ]; then
    nmcli radio wifi on
    notify-send "Wi-Fi" "Wi-Fi activado."
elif [ "$chosen_network" = "󰖪  Desactivar Wi-Fi" ]; then
    nmcli radio wifi off
    notify-send "Wi-Fi" "Wi-Fi desactivado."
else
    # Success message
    success_message="Conectado exitosamente a la red Wi-Fi \"$chosen_id\"."
    
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection show 2>/dev/null || echo "")

    if echo "$saved_connections" | grep -wq "$chosen_id"; then
        nmcli connection modify "$chosen_id" connection.autoconnect yes >/dev/null 2>&1 || true
        if nmcli connection up id "$chosen_id"; then
            notify-send "Wi-Fi" "$success_message"
        fi
    else
        if [[ "$chosen_network" =~ "" ]]; then
            if [ -f "$ROFI_THEME" ]; then
                wifi_password=$(rofi -dmenu -i -theme "$ROFI_THEME" -p "Password ($chosen_id)" -password || true)
            else
                wifi_password=$(rofi -dmenu -p "Contraseña para $chosen_id: " -password || true)
            fi
        else
            wifi_password=""
        fi
        
        if [ -n "$wifi_password" ]; then
            if nmcli device wifi connect "$chosen_id" password "$wifi_password"; then
                notify-send "Wi-Fi" "$success_message"
            else
                notify-send "Wi-Fi Error" "Error al conectar a $chosen_id."
            fi
        else
            if nmcli device wifi connect "$chosen_id"; then
                notify-send "Wi-Fi" "$success_message"
            fi
        fi
    fi
fi
