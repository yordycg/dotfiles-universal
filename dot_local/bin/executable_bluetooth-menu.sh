#!/usr/bin/env bash
# =============================================================================
# bluetooth-menu.sh — Rofi Bluetooth Manager
# Interactivly manage bluetooth connections, power, scanning, and pairing using rofi.
# =============================================================================
set -euo pipefail

ROFI_THEME="$HOME/.config/rofi/menu_compact.rasi"
divider="---------"
goback="Volver"

rofi_cmd() {
    local prompt=$1
    if [ -f "$ROFI_THEME" ]; then
        rofi -dmenu -i -theme "$ROFI_THEME" -p "$prompt" || true
    else
        rofi -dmenu -i -p "$prompt" || true
    fi
}

power_on() {
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

toggle_power() {
    if power_on; then
        bluetoothctl power off >/dev/null 2>&1
        show_menu
    else
        if command -v rfkill &>/dev/null && rfkill list bluetooth | grep -q 'blocked: yes'; then
            rfkill unblock bluetooth && sleep 1
        fi
        bluetoothctl power on >/dev/null 2>&1
        show_menu
    fi
}

scan_on() {
    if bluetoothctl show 2>/dev/null | grep -q "Discovering: yes"; then
        echo "Escaneo: ON"
        return 0
    else
        echo "Escaneo: OFF"
        return 1
    fi
}

toggle_scan() {
    if scan_on >/dev/null; then
        kill $(pgrep -f "bluetoothctl --timeout 5 scan on") 2>/dev/null || true
        bluetoothctl scan off >/dev/null 2>&1 || true
        show_menu
    else
        bluetoothctl --timeout 5 scan on >/dev/null 2>&1 &
        notify-send "Bluetooth" "Escaneando dispositivos..." -t 2000 || true
        show_menu
    fi
}

pairable_on() {
    if bluetoothctl show 2>/dev/null | grep -q "Pairable: yes"; then
        return 0
    else
        return 1
    fi
}

toggle_pairable() {
    if pairable_on; then
        bluetoothctl pairable off >/dev/null 2>&1
        show_menu
    else
        bluetoothctl pairable on >/dev/null 2>&1
        show_menu
    fi
}

discoverable_on() {
    if bluetoothctl show 2>/dev/null | grep -q "Discoverable: yes"; then
        return 0
    else
        return 1
    fi
}

toggle_discoverable() {
    if discoverable_on; then
        bluetoothctl discoverable off >/dev/null 2>&1
        show_menu
    else
        bluetoothctl discoverable on >/dev/null 2>&1
        show_menu
    fi
}

device_menu() {
    local device=$1
    local mac=$(echo "$device" | awk '{print $NF}')
    local name=$(echo "$device" | awk '{$NF=""; print $0}')

    local connected state pair trusted
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        state="Desconectar"
    else
        state="Conectar"
    fi

    if bluetoothctl info "$mac" | grep -q "Paired: yes"; then
        pair="Desemparejar"
    else
        pair="Emparejar"
    fi

    if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
        trusted="Olvidar (Desconfiar)"
    else
        trusted="Confiar (Trust)"
    fi

    local options="$state\n$pair\n$trusted\n$goback"
    local chosen=$(echo -e "$options" | rofi_cmd "$name")

    case "$chosen" in
        "Conectar")
            bluetoothctl connect "$mac" && notify-send "Bluetooth" "Conectado a $name" || notify-send "Bluetooth Error" "Fallo al conectar a $name"
            ;;
        "Desconectar")
            bluetoothctl disconnect "$mac" && notify-send "Bluetooth" "Desconectado de $name"
            ;;
        "Emparejar")
            bluetoothctl pair "$mac" && notify-send "Bluetooth" "Emparejado con $name"
            ;;
        "Desemparejar")
            bluetoothctl remove "$mac" && notify-send "Bluetooth" "Removido $name"
            ;;
        "Confiar (Trust)")
            bluetoothctl trust "$mac" && notify-send "Bluetooth" "Confianza establecida para $name"
            ;;
        "Olvidar (Desconfiar)")
            bluetoothctl untrust "$mac" && notify-send "Bluetooth" "Confianza removida de $name"
            ;;
        "$goback")
            show_menu
            ;;
    esac
}

show_menu() {
    local power toggle scan pairable discoverable
    if power_on; then
        power="󰂯 Encendido: Apagar Bluetooth"
        if scan_on >/dev/null; then scan="󰂰 Detener escaneo"; else scan="󰂰 Iniciar escaneo"; fi
        if pairable_on; then pairable="󰂴 Emparejable: ON"; else pairable="󰂴 Emparejable: OFF"; fi
        if discoverable_on; then discoverable="󰂵 Visibilidad: ON"; else discoverable="󰂵 Visibilidad: OFF"; fi

        local paired_devices=$(bluetoothctl devices Paired 2>/dev/null | awk '{print $3 " " $2}' || echo "")
        local available_devices=$(bluetoothctl devices 2>/dev/null | awk '{print $3 " " $2}' || echo "")

        local devices=""
        if [ -n "$paired_devices" ]; then
            devices="Dispositivos Emparejados:\n$paired_devices"
        fi
        if [ -n "$available_devices" ]; then
            if [ -n "$devices" ]; then devices="$devices\n$divider\n$available_devices"; else devices="$available_devices"; fi
        fi

        local options="$power\n$scan\n$pairable\n$discoverable\n$divider\n$devices"
        local chosen=$(echo -e "$options" | rofi_cmd "Bluetooth")

        case "$chosen" in
            "$power") toggle_power ;;
            "$scan") toggle_scan ;;
            "$pairable") toggle_pairable ;;
            "$discoverable") toggle_discoverable ;;
            "" | "$divider" | "Dispositivos Emparejados:") exit 0 ;;
            *) device_menu "$chosen" ;;
        esac
    else
        power="󰂲 Apagado: Encender Bluetooth"
        local chosen=$(echo -e "$power" | rofi_cmd "Bluetooth")
        if [ "$chosen" = "$power" ]; then
            toggle_power
        fi
    fi
}

show_menu
