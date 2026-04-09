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
