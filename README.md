# Dotfiles

This is a repository containing installation for all of my dotfiles.

It utilizes the [Dotbot repository](https://github.com/anishathalye/dotbot) for managing dotfile installation (vendored directly, no submodules).

## Repository Structure

```
.dotfiles/
├── dotbot/              # vendored dotbot (no submodule)
├── shared/              # cross-platform configs
│   ├── git/             # gitconfig, gitignore, gitconfig-local.example
│   ├── starship/        # starship.toml
│   ├── node/            # npmrc, prettierrc, eslintrc
│   ├── opencode/        # opencode binary
│   └── nvim/            # LazyVim config
├── linux/               # Linux-specific configs
│   ├── fish/            # Fish shell config and conf.d/
│   ├── ghostty/         # Ghostty terminal config
│   ├── tmux/            # Tmux config
│   ├── packages.yaml    # paru package list
│   └── .bashrc.d/       # bashrc fragments
├── windows/             # Windows-specific configs
│   ├── nushell/         # Nushell config
│   ├── vscode/          # VS Code settings and keybindings
│   ├── wezterm/         # WezTerm config
│   ├── packages.json    # Scoop package list
│   ├── install-packages.nu
│   ├── install-node-packages.nu
│   ├── setup-fnm.nu
│   ├── validate-prerequisites.nu
│   └── validate-prereqs.ps1
├── macos/               # macOS placeholder
├── install.conf.yaml    # Dotbot symlink config
├── install.sh           # Linux/macOS install script
├── install.nu           # Windows install script (Nushell)
└── Brewfile             # Homebrew package list
```

## Prerequisites

### Windows

Before running the installation, you need to install the following on your system:

1. **Git** - Required for cloning the repository
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

4. **paru** - AUR helper
   - Install with:
     ```bash
     git clone https://aur.archlinux.org/paru-bin.git
     cd paru-bin && makepkg -si
     ```

### macOS

Before running the installation:

1. **Xcode Command Line Tools** - Required for Git and development tools
   - Install with: `xcode-select --install`

2. **Homebrew** (Recommended) - Package manager for macOS
   - Install from: https://brew.sh/

## Installation

### Windows

1. Clone this repository:
   ```powershell
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Set up your machine-specific Git configuration:
   ```powershell
   cp shared/git/gitconfig-local.example ~/.gitconfig-local
   notepad ~/.gitconfig-local
   ```

   Update the following values in `~/.gitconfig-local`:
   - Your name and email address
   - Your preferred editor

3. Run the installation script:
   ```nu
   nu install.nu
   ```

### Linux (Arch-based)

1. Clone this repository:
   ```bash
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Set up your machine-specific Git configuration:
   ```bash
   cp shared/git/gitconfig-local.example ~/.gitconfig-local
   $EDITOR ~/.gitconfig-local
   ```

3. Run the installation script:
   ```bash
   ./install.sh
   ```

4. Install packages via paru:
   ```bash
   paru -S fish starship ghostty tmux git-delta fzf zoxide bat ripgrep fd jq eza neovim lazygit github-cli dotnet-sdk fnm-bin
   ```

5. Set Fish as your default shell:
   ```bash
   chsh -s /usr/bin/fish
   ```

6. Install Node LTS and global packages (in a Fish session):
   ```fish
   fnm install --lts && fnm default lts-latest
   npm install -g typescript ts-node pnpm eslint prettier @fsouza/prettierd neovim
   ```

### macOS

1. Clone this repository:
   ```bash
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Set up your machine-specific Git configuration:
   ```bash
   cp shared/git/gitconfig-local.example ~/.gitconfig-local
   $EDITOR ~/.gitconfig-local
   ```

3. Run the installation script:
   ```bash
   ./install.sh
   ```

## What's Included

| Config | Windows | Linux | macOS |
|--------|---------|-------|-------|
| **Git** | ✓ | ✓ | ✓ |
| **Starship** | ✓ | ✓ | ✓ |
| **Neovim** (LazyVim) | ✓ | ✓ | ✓ |
| **Node.js** (fnm, eslint, prettier) | ✓ | ✓ | ✓ |
| **OpenCode** | | ✓ | ✓ |
| **VS Code** | ✓ | ✓ | |
| **Nushell** | ✓ | | |
| **WezTerm** | ✓ | | |
| **Fish** | | ✓ | |
| **Ghostty** | | ✓ | |
| **Tmux** | | ✓ | |

## Important Notes

### Platform Support

This dotfiles repository supports:
- **Windows** - Via Scoop package manager
- **Linux** - Arch-based distributions (CachyOS, Manjaro, Arch Linux, etc.) via pacman/AUR
- **macOS** - Via Homebrew

Use `install.nu` (Windows) or `install.sh` (Linux/macOS) for installation.

### Backup Files
The installation automatically backs up any existing configuration files before creating symlinks. Backup files are saved with a `.old` extension (e.g., `~/.gitconfig.old`). If you need to restore a previous configuration, simply rename the backup file.

### Machine-specific Git Config
The file `~/.gitconfig-local` holds your personal name, email, and editor. It is sourced by `shared/git/gitconfig` and is never committed to this repository. Copy `shared/git/gitconfig-local.example` as a starting point.
