#!/usr/bin/env bash

set -u

config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
mode="${1:-quick-settings}"
"$config_root/waybar/popup_toggle.sh" "$mode" sticky
