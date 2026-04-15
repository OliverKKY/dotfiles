# dotfiles

This repository tracks a selected subset of `~/.config`:

- `hypr`
- `kitty`
- `rofi`
- `wal`
- `waybar`
- `zed`

## Setup

Clone the repo anywhere and run:

```sh
./setup.sh
```

The script will:

- symlink the managed config directories into `~/.config`
- back up conflicting existing config into `~/.dotfiles-backups/<timestamp>/`
- leave already-correct links untouched

It is safe to run more than once.

## Hyprland Monitors

This repo follows the Omarchy-style split for monitor config:

- `hypr/hyprland.conf` keeps the main compositor config
- `hypr/monitors.conf` holds monitor layout rules

The current default in `hypr/monitors.conf` keeps your existing automatic
monitor detection behavior:

```ini
monitor = , preferred, auto, 1
```
