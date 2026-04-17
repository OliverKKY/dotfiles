#!/usr/bin/env bash

set -u

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

json_escape() {
    local text="${1//\\/\\\\}"
    text="${text//\"/\\\"}"
    text="${text//$'\n'/\\n}"
    printf '%s' "$text"
}

audio_icon="󰕾"
audio_tip="Audio unavailable"
audio_class=""

if has_cmd wpctl; then
    audio_out="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
    if [[ -n "$audio_out" ]]; then
        if [[ "$audio_out" == *"MUTED"* ]]; then
            audio_icon="󰝟"
            audio_tip="Audio: muted"
            audio_class="muted"
        else
            audio_volume="$(awk '/Volume:/ {printf "%d", $2 * 100}' <<<"$audio_out")"
            if [[ -z "${audio_volume:-}" ]]; then
                audio_volume="0"
            fi

            if (( audio_volume == 0 )); then
                audio_icon="󰕿"
            elif (( audio_volume < 35 )); then
                audio_icon="󰖀"
            else
                audio_icon="󰕾"
            fi

            audio_tip="Audio: ${audio_volume}%"
        fi
    fi
fi

network_icon="󰤮"
network_tip="Network unavailable"
network_class="disconnected"

if has_cmd nmcli; then
    wifi_enabled="$(nmcli -t -f WIFI general 2>/dev/null | head -n1)"
    active_wifi="$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1 == "yes" {print $2; exit}')"
    active_eth="$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null | awk -F: '$2 == "ethernet" && $3 == "connected" {print $4; exit}')"

    if [[ -n "$active_wifi" ]]; then
        network_icon="󰤨"
        network_tip="Wi-Fi: $active_wifi"
        network_class="connected"
    elif [[ -n "$active_eth" ]]; then
        network_icon="󰈀"
        network_tip="Ethernet: $active_eth"
        network_class="connected"
    elif [[ "$wifi_enabled" == "enabled" ]]; then
        network_icon="󰤯"
        network_tip="Wi-Fi: on, not connected"
    else
        network_icon="󰤮"
        network_tip="Wi-Fi: off"
    fi
fi

bluetooth_icon="󰂲"
bluetooth_tip="Bluetooth unavailable"

if has_cmd bluetoothctl; then
    bluetooth_power="$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}')"
    if [[ "$bluetooth_power" == "yes" ]]; then
        bluetooth_icon="󰂯"
        bluetooth_tip="Bluetooth: on"
    elif [[ "$bluetooth_power" == "no" ]]; then
        bluetooth_icon="󰂲"
        bluetooth_tip="Bluetooth: off"
    fi
fi

battery_icon=""
battery_tip=""
battery_class=""
battery_parts=()

for bat in /sys/class/power_supply/BAT*; do
    if [[ -d "$bat" ]]; then
        battery_parts+=("$bat")
    fi
done

if (( ${#battery_parts[@]} > 0 )); then
    battery_path="${battery_parts[0]}"
    battery_capacity="$(cat "$battery_path/capacity" 2>/dev/null || printf '')"
    battery_status="$(cat "$battery_path/status" 2>/dev/null || printf '')"

    if [[ -n "$battery_capacity" ]]; then
        case "$battery_status" in
            Charging)
                battery_icon="󰂄"
                ;;
            Full)
                battery_icon="󰁹"
                ;;
            *)
                if (( battery_capacity >= 90 )); then
                    battery_icon="󰁹"
                elif (( battery_capacity >= 70 )); then
                    battery_icon="󰂀"
                elif (( battery_capacity >= 50 )); then
                    battery_icon="󰁿"
                elif (( battery_capacity >= 30 )); then
                    battery_icon="󰁾"
                elif (( battery_capacity >= 15 )); then
                    battery_icon="󰁻"
                    battery_class="warning"
                else
                    battery_icon="󰂎"
                    battery_class="critical"
                fi
                ;;
        esac

        if [[ -n "$battery_status" ]]; then
            battery_tip="Battery: ${battery_capacity}% (${battery_status})"
        else
            battery_tip="Battery: ${battery_capacity}%"
        fi
    fi
fi

text_parts=("$network_icon" "$audio_icon" "$bluetooth_icon")
tooltip_parts=("$network_tip" "$audio_tip" "$bluetooth_tip")
classes=("$network_class")

if [[ -n "$audio_class" ]]; then
    classes+=("$audio_class")
fi

if [[ -n "$battery_icon" ]]; then
    text_parts+=("$battery_icon")
    tooltip_parts+=("$battery_tip")
fi

if [[ -n "$battery_class" ]]; then
    classes+=("$battery_class")
fi

text="$(printf '%s ' "${text_parts[@]}")"
text="${text% }"
tooltip="$(printf '%s\n' "${tooltip_parts[@]}")"
tooltip="${tooltip%$'\n'}"
class_json="["

for class_name in "${classes[@]}"; do
    if [[ -n "$class_name" ]]; then
        if [[ "$class_json" != "[" ]]; then
            class_json+=","
        fi
        class_json+="\"$(json_escape "$class_name")\""
    fi
done

class_json+="]"

printf '{"text":"%s","tooltip":"%s","class":%s}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$tooltip")" \
    "$class_json"
