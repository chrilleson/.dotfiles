# Dotfiles

This is a repository containing installation for all of my dotfiles.

It utilizes the [Dotbot repository](https://github.com/anishathalye/dotbot) for managing dotfile installation.

## Prerequisites

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

## Installation

1. Clone this repository:
   ```powershell
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Run the installation script:
   - **Using PowerShell:**
     ```powershell
     .\install.ps1
     ```
   - **Using Nushell:**
     ```nu
     nu install.nu
     ```

The installation will:
- Set up symbolic links for all configuration files
- Install development tools via Scoop (git, delta, fzf, zoxide, bat, ripgrep, fd, jq, starship, fnm)
- Install WezTerm terminal
- Install JetBrainsMono Nerd Font
- Set up fnm and install Node.js LTS
- Install global npm packages (typescript, ts-node, pnpm, yarn, eslint, prettier, prettierd)

## What's Included

- **Nushell** - Shell configuration
- **WezTerm** - Terminal emulator configuration
- **Git** - Git configuration and global gitignore
- **VS Code** - Settings and keybindings
- **Starship** - Shell prompt configuration
- **Node.js** - ESLint, Prettier, npm/pnpm configuration