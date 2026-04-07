#!/usr/bin/env bash

set -u

launch() {
    setsid -f "$@" >/dev/null 2>&1
}

launch_shell() {
    setsid -f sh -lc "$1" >/dev/null 2>&1
}

toggle_nm_radio() {
    local kind="$1"
    local state
    state="$(nmcli radio "$kind" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    if [[ "$state" == "enabled" ]]; then
        nmcli radio "$kind" off >/dev/null 2>&1
    else
        nmcli radio "$kind" on >/dev/null 2>&1
    fi
}

toggle_bluetooth() {
    local powered
    powered="$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}')"
    if [[ "$powered" == "yes" ]]; then
        bluetoothctl power off >/dev/null 2>&1
    else
        bluetoothctl power on >/dev/null 2>&1
    fi
}

open_network_settings() {
    if command -v gnome-control-center >/dev/null 2>&1; then
        launch_shell 'gnome-control-center wifi || gnome-control-center network || gnome-control-center'
    elif command -v nm-connection-editor >/dev/null 2>&1; then
        launch nm-connection-editor
    fi
}

open_bluetooth_settings() {
    if command -v gnome-control-center >/dev/null 2>&1; then
        launch_shell 'gnome-control-center bluetooth || gnome-control-center'
    fi
}

open_sound_settings() {
    if command -v gnome-control-center >/dev/null 2>&1; then
        launch_shell 'gnome-control-center sound || gnome-control-center'
    fi
}

open_power_settings() {
    if command -v gnome-control-center >/dev/null 2>&1; then
        launch_shell 'gnome-control-center power || gnome-control-center'
    fi
}

case "${1:-}" in
    launch-overview)
        if command -v rofi >/dev/null 2>&1; then
            launch rofi -show drun
        fi
        ;;
    calendar)
        if command -v gnome-calendar >/dev/null 2>&1; then
            launch gnome-calendar
        fi
        ;;
    datetime-settings)
        if command -v gnome-control-center >/dev/null 2>&1; then
            launch_shell 'gnome-control-center datetime || gnome-control-center'
        fi
        ;;
    toggle-wifi)
        if command -v nmcli >/dev/null 2>&1; then
            toggle_nm_radio wifi
        fi
        ;;
    network-settings)
        open_network_settings
        ;;
    toggle-bluetooth)
        if command -v bluetoothctl >/dev/null 2>&1; then
            toggle_bluetooth
        fi
        ;;
    bluetooth-settings)
        open_bluetooth_settings
        ;;
    toggle-mute)
        if command -v wpctl >/dev/null 2>&1; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1
        fi
        ;;
    sound-settings)
        open_sound_settings
        ;;
    power-settings)
        open_power_settings
        ;;
    system-settings)
        if command -v gnome-control-center >/dev/null 2>&1; then
            launch gnome-control-center
        fi
        ;;
    lock)
        loginctl lock-session >/dev/null 2>&1
        ;;
    suspend)
        systemctl suspend >/dev/null 2>&1
        ;;
    restart)
        systemctl reboot >/dev/null 2>&1
        ;;
    poweroff)
        systemctl poweroff >/dev/null 2>&1
        ;;
esac
