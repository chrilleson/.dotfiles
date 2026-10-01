# Linux-Specific Configuration

This directory contains Linux-specific configuration.

## Stack

| Tool | Role |
|------|------|
| Zsh | Interactive shell |
| Starship | Prompt |
| Ghostty | Terminal |
| Tmux | Multiplexer |
| paru | AUR helper (CachyOS/Arch) |

## Package Management

Packages are installed by `install.sh` via `paru`; its inline `paru -S` list
is the single source of truth. Add or remove packages by editing that list.

## Supported Distributions

Optimised for **Arch-based** distros (CachyOS, Arch, Manjaro, EndeavourOS).
