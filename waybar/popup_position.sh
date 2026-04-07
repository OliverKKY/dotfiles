#!/usr/bin/env bash

set -u

mode="${1:-quick-settings}"
popup_pid="${2:-}"
monitor_name="DP-4"

if [[ "$mode" == "clock" ]]; then
    title='Waybar GNOME Clock'
    width=800
    height=590
else
    title='Waybar GNOME Quick Settings'
    width=360
    height=520
fi

get_monitor_json() {
    hyprctl -j monitors 2>/dev/null | jq -c --arg name "$monitor_name" 'map(select(.name == $name)) | .[0] // (map(select(.focused == true)) | .[0]) // .[0]'
}

monitor_json="$(get_monitor_json)"

if [[ -n "$monitor_json" ]] && [[ "$monitor_json" != "null" ]]; then
    mon_x="$(jq -r '.x // 0' <<<"$monitor_json")"
    mon_y="$(jq -r '.y // 0' <<<"$monitor_json")"
    mon_w="$(jq -r '.width // 2560' <<<"$monitor_json")"
else
    mon_x=0
    mon_y=0
    mon_w=2560
fi

if [[ "$mode" == "clock" ]]; then
    pos_x=$((mon_x + (mon_w - width) / 2))
    pos_y=$((mon_y + 30))
else
    pos_x=$((mon_x + mon_w - width - 10))
    pos_y=$((mon_y + 26))
fi

for _ in $(seq 1 40); do
    sleep 0.1

    if [[ -n "$popup_pid" ]] && ! kill -0 "$popup_pid" 2>/dev/null; then
        exit 0
    fi

    if hyprctl -j clients 2>/dev/null | jq -e --arg title "$title" '.[] | select(.title == $title)' >/dev/null; then
        hyprctl dispatch resizewindowpixel exact "$width" "$height",title:^"${title}"$ >/dev/null 2>&1 || true
        hyprctl dispatch movewindowpixel exact "$pos_x" "$pos_y",title:^"${title}"$ >/dev/null 2>&1 || true
        exit 0
    fi
done
