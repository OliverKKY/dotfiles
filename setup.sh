#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

managed_entries=(
    hypr
    kitty
    rofi
    wal
    waybar
    zed
)

backup_created=0

log() {
    printf '[setup] %s\n' "$*"
}

realpath_safe() {
    local path="$1"

    if command -v realpath >/dev/null 2>&1; then
        realpath "$path"
    else
        readlink -f "$path"
    fi
}

backup_target() {
    local entry="$1"
    local target="$2"
    local backup_path="$backup_root/$entry"

    if [ "$backup_created" -eq 0 ]; then
        mkdir -p "$backup_root"
        backup_created=1
        log "created backup directory $backup_root"
    fi

    mkdir -p "$(dirname "$backup_path")"
    mv "$target" "$backup_path"
    log "backed up $target -> $backup_path"
}

link_entry() {
    local entry="$1"
    local source="$repo_root/$entry"
    local target="$config_root/$entry"
    local source_real
    local target_real

    if [ ! -e "$source" ]; then
        log "missing managed entry: $source"
        return 1
    fi

    mkdir -p "$(dirname "$target")"

    if [ -e "$target" ] || [ -L "$target" ]; then
        source_real="$(realpath_safe "$source")"
        target_real="$(realpath_safe "$target")"

        if [ "$source_real" = "$target_real" ]; then
            log "already linked: $target"
            return 0
        fi

        backup_target "$entry" "$target"
    fi

    ln -sfn "$source" "$target"
    log "linked $target -> $source"
}

main() {
    log "repo root: $repo_root"
    log "config root: $config_root"

    mkdir -p "$config_root"

    for entry in "${managed_entries[@]}"; do
        link_entry "$entry"
    done

    log "done"
}

main "$@"
