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
│   ├── .bashrc.d/       # bashrc fragments
│   └── install.sh       # Linux install script
├── windows/             # Windows-specific configs
│   ├── nushell/         # Nushell config
│   ├── vscode/          # VS Code settings and keybindings
│   ├── wezterm/         # WezTerm config
│   ├── packages.json    # Scoop package list
│   ├── install.nu       # Windows install script (Nushell)
│   ├── install-packages.nu
│   ├── install-node-packages.nu
│   ├── setup-fnm.nu
│   ├── validate-prerequisites.nu
│   └── validate-prereqs.ps1
└── install.conf.yaml    # Dotbot symlink config
```

## Prerequisites

### Windows

1. **Git** - [git-scm.com](https://git-scm.com/)
2. **Python 3** - [python.org](https://www.python.org/) or the Microsoft Store
3. **Scoop** - Package manager
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
   ```
4. **Nushell** - `scoop install nu`
5. **Developer Mode** (Recommended) - Allows creating symlinks without admin privileges
   - Settings → Privacy & Security → For developers → Developer Mode

### Linux (Arch-based)

1. **Git** - `sudo pacman -S git`
2. **Python 3** - `sudo pacman -S python`
3. **paru** - AUR helper
   ```bash
   git clone https://aur.archlinux.org/paru-bin.git
   cd paru-bin && makepkg -si
   ```

## Installation

### Windows

1. Clone this repository:
   ```powershell
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Create your machine-specific Git config:
   ```powershell
   cp shared/git/gitconfig-local.example ~/.gitconfig-local
   notepad ~/.gitconfig-local
   ```

3. Run the installer:
   ```nu
   nu windows/install.nu
   ```

### Linux (Arch-based)

1. Clone this repository:
   ```bash
   git clone https://github.com/chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Create your machine-specific Git config:
   ```bash
   cp shared/git/gitconfig-local.example ~/.gitconfig-local
   $EDITOR ~/.gitconfig-local
   ```

3. Run the installer:
   ```bash
   ./linux/install.sh
   ```

4. Set Fish as your default shell:
   ```bash
   chsh -s /usr/bin/fish
   ```

5. Install Node LTS and global packages (in a Fish session):
   ```fish
   fnm install --lts && fnm default lts-latest
   npm install -g typescript ts-node pnpm eslint prettier @fsouza/prettierd neovim
   ```

## What's Included

| Config | Windows | Linux |
|--------|---------|-------|
| **Git** | ✓ | ✓ |
| **Starship** | ✓ | ✓ |
| **Neovim** (LazyVim) | ✓ | ✓ |
| **Node.js** (fnm, eslint, prettier) | ✓ | ✓ |
| **OpenCode** | | ✓ |
| **VS Code** | ✓ | ✓ |
| **Nushell** | ✓ | |
| **WezTerm** | ✓ | |
| **Fish** | | ✓ |
| **Ghostty** | | ✓ |
| **Tmux** | | ✓ |

## Notes

### Machine-specific Git Config
`~/.gitconfig-local` holds your personal name, email, and editor. It is sourced by `shared/git/gitconfig` and is never committed to this repository. Copy `shared/git/gitconfig-local.example` as a starting point.

### Backup Files
Dotbot backs up existing config files before creating symlinks, saving them with a `.old` extension (e.g. `~/.gitconfig.old`).
