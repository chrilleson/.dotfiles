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

Packages are listed per tool in `tools.yaml` at the repo root (the `linux:` key),
and installed via `paru` by `dotfiles install`. `install.sh` sets up prerequisites
(PyYAML, zsh as the login shell) and then runs `dotfiles install --all`, which also
sets up Docker and the JetBrainsMono Nerd Font.

## Supported Distributions

Optimised for **Arch-based** distros (CachyOS, Arch, Manjaro, EndeavourOS).
