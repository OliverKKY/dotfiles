#!/usr/bin/env bash

set -u

mode="${1:-quick-settings}"
/home/oliver/.config/waybar/popup_toggle.sh "$mode" sticky
