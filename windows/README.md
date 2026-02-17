# Windows-Specific Documentation

This directory contains Windows-specific configuration and package definitions for the dotfiles repository.

## Package Management

### Package List (`packages.json`)

The `packages.json` file defines packages to be installed via Scoop:

- **buckets**: Additional Scoop buckets to install (extras, nerd-fonts)
- **main**: Core packages from the main Scoop bucket
- **extras**: GUI applications and additional tools from extras bucket
- **nerd-fonts**: Nerd Font variants
- **optional**: Additional packages that can be manually installed

### Package Installation

Packages are automatically installed when you run:
```powershell
.\install.ps1
```

Or using Nushell:
```powershell
nu install.nu
```

Or manually:
```powershell
nu windows/install-packages.nu
```

### Scoop Package Manager

Scoop is a command-line installer for Windows that provides:
- No UAC prompts or GUI wizards
- Prevents PATH pollution from installing lots of programs
- Installs programs in isolated locations
- Easy package updates and uninstalls

Learn more: https://scoop.sh

## Prerequisites

Before running the installer, ensure you have the following installed:

### Required

1. **Git**
   - Download from: https://git-scm.com/
   - Required for cloning repositories and Scoop functionality

2. **Python**
   - Download from: https://www.python.org/
   - Required for dotbot installation framework

3. **Scoop**
   - Install with PowerShell:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
     Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
     ```

### Symlink Permissions

Windows requires special permissions to create symbolic links. You have two options:

**Option 1: Enable Developer Mode (Recommended)**
1. Open Settings → Privacy & Security → For developers
2. Enable "Developer Mode"
3. Restart may be required

**Option 2: Run as Administrator**
- Right-click PowerShell → "Run as Administrator"
- Not recommended for regular use

The `validate-prereqs.ps1` script automatically checks for symlink permissions and warns if they're unavailable.

## Installed Packages

### Core Tools (main bucket)

- **git** - Version control system
- **delta** - Better git diff viewer
- **fzf** - Fuzzy finder
- **zoxide** - Smarter cd command
- **bat** - Cat clone with syntax highlighting
- **ripgrep** - Fast text search
- **fd** - User-friendly find alternative
- **jq** - JSON processor
- **starship** - Cross-shell prompt
- **fnm** - Fast Node Manager
- **neovim** - Modern vim
- **7zip** - File archiver

### GUI Applications (extras bucket)

- **wezterm** - GPU-accelerated terminal emulator
- **lazygit** - Terminal UI for git

### Fonts (nerd-fonts bucket)

- **JetBrainsMono-NF** - JetBrains Mono with Nerd Font icons

### Optional Packages

- **opencode** - AI-powered code editor
  - Install manually: `scoop install opencode`

## Terminal Configuration

### WezTerm

WezTerm configuration is symlinked to `%USERPROFILE%\.config\wezterm\` on Windows.

Configuration file: `wezterm/wezterm.lua`

### Nushell

Nushell configuration is symlinked to `%APPDATA%\nushell\` on Windows.

Configuration files:
- `nushell/config.nu` - Main configuration
- `nushell/env.nu` - Environment variables

### PowerShell

PowerShell profile is symlinked to your PowerShell profile location.

Configuration: `powershell/Microsoft.PowerShell_profile.ps1`

### VS Code

VS Code settings are symlinked to `%APPDATA%\Code\User\` on Windows.

## Troubleshooting

### Scoop Installation Issues

If Scoop fails to install packages:
```powershell
# Update Scoop
scoop update

# Update all packages
scoop update *

# Check for problems
scoop checkup
```

### Symlink Creation Failed

If symlinks fail to create:
1. Verify Developer Mode is enabled (Settings → For developers)
2. Or run PowerShell as Administrator
3. Check if files already exist at destination (remove them first)

### PowerShell Execution Policy

If you get execution policy errors:
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or for current session only
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### Git Configuration Missing

If `~/.gitconfig-local` is not created:
```powershell
# Copy the template
cp git/gitconfig-local.example ~/.gitconfig-local

# Edit with your details
notepad ~/.gitconfig-local
```

### PATH Not Updated

If newly installed commands aren't found:
1. Restart your terminal
2. Or refresh PATH manually:
   ```powershell
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   ```

### Font Not Appearing

If JetBrainsMono font doesn't appear in applications after installation:
1. Scoop installs fonts to `~/scoop/apps/`
2. You may need to restart applications
3. Verify font installation:
   ```powershell
   scoop list jetbrains
   ```

## Adding Custom Packages

To add your own packages to the installation:

1. Edit `windows/packages.json`
2. Add packages to the appropriate section:
   - `main`: For core command-line tools
   - `extras`: For GUI applications
   - `nerd-fonts`: For font variants
   - `optional`: For optional packages (not auto-installed)

Example:
```json
{
  "main": [
    "git",
    "your-package-name"
  ],
  "extras": [
    "your-gui-app"
  ]
}
```

Search for available packages:
```powershell
scoop search package-name
```

## Script Overview

### Core Scripts

- **install-packages.nu** - Main package installation script
- **validate-prereqs.ps1** - Prerequisite validation script

### Usage

All scripts are automatically called by `install.ps1` or `install.nu`. To run individual scripts:

```powershell
# Validate prerequisites only
powershell -ExecutionPolicy Bypass -File .\windows\validate-prereqs.ps1

# Install packages only
nu windows/install-packages.nu
```

## Next Steps After Installation

1. **Restart your terminal** to refresh PATH and environment variables

2. **Configure Git** (if not already done):
   ```powershell
   # Edit your local git config
   notepad ~/.gitconfig-local
   ```

3. **Launch WezTerm** for the configured terminal experience

4. **Start Nushell**:
   ```powershell
   nu
   ```

5. **Verify installations**:
   ```powershell
   # Check tool versions
   git --version
   nvim --version
   node --version
   starship --version
   ```

6. **Install optional packages** if needed:
   ```powershell
   scoop install opencode
   ```

## Updating Packages

Keep your tools up to date:

```powershell
# Update Scoop itself
scoop update

# Update all installed packages
scoop update *

# Update specific package
scoop update git
```

## Uninstalling Packages

Remove packages you no longer need:

```powershell
# Uninstall a package
scoop uninstall package-name

# Remove old versions
scoop cleanup *
```

## Contributing

If you encounter issues or have improvements for Windows support, please open an issue or pull request on GitHub.
