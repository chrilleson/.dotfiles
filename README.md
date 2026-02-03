# Dotfiles

This is a repository containing installation for all of my dotfiles.

It utilizes the [Dotbot repository](https://github.com/anishathalye/dotbot) for managing dotfile installation.

## Prerequisites

### Windows

Before running the installation, you need to install the following on your system:

1. **Git** - Required for cloning the repository and managing submodules
   - Download from: https://git-scm.com/

2. **Python 3** - Required by Dotbot
   - Download from: https://www.python.org/ or the Microsoft Store

3. **Scoop** - Package manager for Windows
   - Install with:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
     Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
     ```

4. **Nushell** - Required to run the installation scripts
   - Install with: `scoop install nu`

5. **Windows Developer Mode** (Recommended) - Allows creating symbolic links without administrator privileges
   - Go to: Settings → Privacy & Security → For developers → Developer Mode
   - Toggle "Developer Mode" to ON
   - Alternative: Run the installation script as Administrator

### Linux (Arch-based distributions)

Before running the installation, you need to install the following:

1. **Git** - Required for cloning the repository
   - Install with: `sudo pacman -S git`

2. **Python 3** - Required by Dotbot
   - Install with: `sudo pacman -S python`

3. **Base Development Tools** - Required for building AUR packages
   - Install with: `sudo pacman -S base-devel`

4. **Nushell** (Optional) - For using the unified install.nu script
   - Install with: `sudo pacman -S nushell`
   - Alternative: Use the `install.sh` bash script instead

### macOS

Before running the installation:

1. **Xcode Command Line Tools** - Required for Git and development tools
   - Install with: `xcode-select --install`

2. **Homebrew** (Recommended) - Package manager for macOS
   - Install from: https://brew.sh/

3. **Nushell** (Optional) - For using the unified install.nu script
   - Install with: `brew install nushell`
   - Alternative: Use the `install.sh` bash script instead

## Installation

### Windows

1. Clone this repository:
   ```powershell
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Set up your machine-specific Git configuration:
   ```powershell
   # Copy the template to your home directory
   cp git/gitconfig-local.example ~/.gitconfig-local
   
   # Edit with your personal details
   notepad ~/.gitconfig-local
   ```
   
   Update the following values in `~/.gitconfig-local`:
   - Your name and email address
   - Your preferred editor

3. Run the installation script:
   - **Using PowerShell:**
     ```powershell
     .\install.ps1
     ```
   - **Using Nushell:**
     ```nu
     nu install.nu
     ```

The installation will:
- Validate all prerequisites are installed
- Back up any existing configuration files (with `.old` extension)
- Set up symbolic links for all configuration files
- Install development tools via Scoop (git, delta, fzf, zoxide, bat, ripgrep, fd, jq, starship, fnm)
- Install WezTerm terminal
- Install JetBrainsMono Nerd Font
- Set up fnm and install Node.js LTS
- Install global npm packages (typescript, ts-node, pnpm, yarn, eslint, prettier, prettierd)
- Verify Git configuration is set up correctly

### Linux (Arch-based)

1. Clone this repository:
   ```bash
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Set up your machine-specific Git configuration:
   ```bash
   # Copy the template to your home directory
   cp git/gitconfig-local.example ~/.gitconfig-local
   
   # Edit with your personal details
   $EDITOR ~/.gitconfig-local
   ```
   
   Update the following values in `~/.gitconfig-local`:
   - Your name and email address
   - Your preferred editor

3. Run the installation script:
   - **Using Nushell (Recommended):**
     ```bash
     nu install.nu
     ```
   - **Using Bash:**
     ```bash
     ./install.sh
     ```

The installation will:
- Validate all prerequisites are installed
- Update package database (pacman)
- Install development tools via pacman (git, delta, fzf, zoxide, bat, ripgrep, fd, jq, starship, neovim, nodejs, wezterm, nushell, lazygit, github-cli)
- Set up yay AUR helper
- Install AUR packages (fnm)
- Back up any existing configuration files (with `.old` extension)
- Set up symbolic links for all configuration files
- Install JetBrainsMono Nerd Font
- Set up bash integration for tools (fnm, zoxide, starship, fzf)
- Set up fnm and install Node.js LTS
- Install global npm packages (typescript, ts-node, pnpm, yarn, eslint, prettier, prettierd)
- Verify Git configuration is set up correctly

### macOS

1. Clone this repository:
   ```bash
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Set up your machine-specific Git configuration:
   ```bash
   # Copy the template to your home directory
   cp git/gitconfig-local.example ~/.gitconfig-local
   
   # Edit with your personal details
   $EDITOR ~/.gitconfig-local
   ```

3. Run the installation script:
   ```bash
   ./install.sh
   ```

The installation will:
- Validate all prerequisites are installed
- Optionally install Homebrew if not present
- Install packages via Homebrew using Brewfile
- Back up any existing configuration files (with `.old` extension)
- Set up symbolic links for all configuration files
- Install WezTerm terminal
- Install JetBrainsMono Nerd Font
- Set up fnm and install Node.js LTS
- Install global npm packages
- Verify Git configuration is set up correctly

## What's Included

- **Nushell** - Shell configuration
- **WezTerm** - Terminal emulator configuration
- **Git** - Git configuration and global gitignore
- **VS Code** - Settings and keybindings
- **Starship** - Shell prompt configuration
- **Node.js** - ESLint, Prettier, npm/pnpm configuration
- **OpenCode** - AI coding assistant configuration

## Important Notes

### Platform Support

This dotfiles repository supports:
- **Windows** - Via Scoop package manager
- **Linux** - Arch-based distributions (CachyOS, Manjaro, Arch Linux, etc.) via pacman/AUR
- **macOS** - Via Homebrew

The `install.nu` script provides a unified cross-platform installation experience. Alternatively, use `install.sh` (Linux/macOS) or `install.ps1` (Windows) for platform-specific features.

### Backup Files
The installation automatically backs up any existing configuration files before creating symlinks. Backup files are saved with a `.old` extension (e.g., `~/.gitconfig.old`). If you need to restore a previous configuration, simply rename the backup file.