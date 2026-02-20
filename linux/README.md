# Linux-Specific Configuration

This directory contains Linux-specific configuration and package definitions.

## Stack

| Tool | Role |
|------|------|
| Fish | Interactive shell |
| Starship | Prompt |
| Ghostty | Terminal |
| Tmux | Multiplexer |
| paru | AUR helper (CachyOS/Arch) |

## Package Management

`packages.yaml` defines packages for Arch-based distributions, split by source:

- **official** — installed via `pacman`
- **aur** — installed via `paru`
- **optional** — not auto-installed, listed for reference

## Supported Distributions

Optimised for **Arch-based** distros (CachyOS, Arch, Manjaro, EndeavourOS).

## Adding Packages

Edit `packages.yaml` and add to the appropriate section:

```yaml
official:
  - your-package

aur:
  - your-aur-package
```
