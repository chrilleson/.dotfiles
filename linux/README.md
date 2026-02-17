# Linux-Specific Documentation

This directory contains Linux-specific configuration and package definitions for the dotfiles repository.

## Package Management

### Package List (`packages.yaml`)

The `packages.yaml` file defines packages to be installed on Arch-based Linux distributions:

- **official**: Packages from official Arch repositories (installed via pacman)
- **aur**: Packages from the Arch User Repository (installed via yay)
- **optional**: Additional packages that can be manually installed

### Package Installation

Packages are automatically installed when you run:
```bash
nu install.nu
```

Or manually:
```bash
nu linux/install-packages.nu
```

### Supported Distributions

The Linux support is optimized for **Arch-based distributions**:
- Arch Linux
- CachyOS
- Manjaro
- EndeavourOS
- Garuda Linux

For other distributions, use the `install.sh` script which has broader compatibility.

## Bash Integration

### `.bashrc.d/` Structure

The dotfiles create bash integration files in `~/.bashrc.d/`:

- **00-env.sh** - Environment variables (XDG paths, PATH modifications)
- **01-fnm.sh** - Fast Node Manager initialization
- **02-tools.sh** - Tool integrations (zoxide, starship, fzf) and modern command aliases

These files are automatically sourced by your `.bashrc` when you run the installer.

### Tool Aliases

The following modern tool aliases are set up (if tools are installed):

- `ls` → `eza` (modern ls)
- `ll` → `eza -l` (long listing)
- `la` → `eza -la` (all files, long listing)
- `tree` → `eza --tree` (tree view)
- `cat` → `bat --paging=never` (syntax highlighting)
- `grep` → `rg` (ripgrep)

## AUR Helper (yay)

The installer automatically sets up `yay` as the AUR helper if it's not already installed.

### Manual yay Setup

If you need to install yay manually:

```bash
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

### Using yay

Install AUR packages:
```bash
yay -S package-name
```

Search AUR:
```bash
yay -Ss search-term
```

Update all packages (including AUR):
```bash
yay -Syu
```

## Fonts

JetBrainsMono Nerd Font is automatically installed to `~/.local/share/fonts/` and the font cache is rebuilt.

### Manual Font Installation

If automatic installation fails:

1. Download JetBrainsMono from: https://github.com/ryanoasis/nerd-fonts/releases
2. Extract to `~/.local/share/fonts/JetBrainsMono/`
3. Rebuild font cache: `fc-cache -f -v`

## Terminal Configuration

### WezTerm

WezTerm configuration is symlinked to `~/.config/wezterm/` on Linux (following XDG Base Directory specification).

### Nushell

Nushell configuration is symlinked to `~/.config/nushell/` on all platforms.

### VS Code

VS Code settings are symlinked to `~/.config/Code/User/` on Linux.

## Troubleshooting

### Pacman Key Issues

If you encounter GPG key issues:
```bash
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Sy archlinux-keyring
```

### Missing Dependencies

If a package fails to install due to missing dependencies:
```bash
# Update system first
sudo pacman -Syu

# Install the failed package manually
sudo pacman -S package-name
```

### Permission Issues

If you encounter permission issues with symlinks:
```bash
# Check ownership of config directories
ls -la ~/.config

# Fix ownership if needed
sudo chown -R $USER:$USER ~/.config
```

### Font Not Appearing

If fonts don't appear in applications after installation:
```bash
# Rebuild font cache
fc-cache -f -v

# Verify font is installed
fc-list | grep JetBrains

# Restart applications
```

## Adding Custom Packages

To add your own packages to the installation:

1. Edit `linux/packages.yaml`
2. Add packages to the appropriate section:
   - `official`: For pacman packages
   - `aur`: For AUR packages
   - `optional`: For optional packages (not auto-installed)

Example:
```yaml
official:
  - git
  - neovim
  - your-package-name

aur:
  - your-aur-package
```

## XDG Base Directory Specification

This dotfiles setup follows the XDG Base Directory specification:

- **XDG_CONFIG_HOME**: `~/.config` - User-specific configuration files
- **XDG_DATA_HOME**: `~/.local/share` - User-specific data files
- **XDG_CACHE_HOME**: `~/.cache` - User-specific non-essential data
- **XDG_STATE_HOME**: `~/.local/state` - User-specific state files

These are automatically set up in `00-env.sh`.

## Script Overview

### Core Scripts

- **install-packages.nu** - Main package installation script
- **setup-yay.nu** - AUR helper installation
- **install-fonts.nu** - Font installation script
- **setup-bash.nu** - Bash integration setup

### Usage

All scripts are automatically called by `install.nu`. To run individual scripts:

```bash
# Install packages only
nu linux/install-packages.nu

# Install fonts only
nu linux/install-fonts.nu

# Setup bash integration only
nu linux/setup-bash.nu
```

## Next Steps After Installation

1. **Restart your terminal** or source your bashrc:
   ```bash
   source ~/.bashrc
   ```

2. **Launch WezTerm** for the configured terminal experience

3. **Start Nushell**:
   ```bash
   nu
   ```

4. **Verify installations**:
   ```bash
   # Check tool versions
   git --version
   nvim --version
   node --version
   starship --version
   ```

5. **Configure Git** (if not already done):
   ```bash
   # Edit your local git config
   $EDITOR ~/.gitconfig-local
   ```

## Contributing

If you encounter issues or have improvements for Linux support, please open an issue or pull request on GitHub.
