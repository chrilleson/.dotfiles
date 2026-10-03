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
│   ├── vscode/          # VS Code settings and keybindings
│   ├── bin/             # dotfiles CLI
│   └── nvim/            # LazyVim config
├── linux/               # Linux-specific configs
│   ├── zsh/             # Zsh OS-specific config (os.zsh)
│   ├── ghostty/         # Ghostty terminal config
│   ├── tmux/            # Tmux config
│   ├── .bashrc.d/       # bashrc fragments
│   └── install.sh       # Linux install script
├── macos/               # macOS-specific configs
│   ├── zsh/             # Zsh OS-specific config (os.zsh)
│   ├── ghostty/         # Ghostty terminal config
│   ├── tmux/            # Tmux config
│   └── install.sh       # macOS install script
├── windows/             # Windows-specific configs
│   ├── powershell/      # PowerShell 7 profile
│   ├── wezterm/         # WezTerm config
│   ├── bin/             # dotfiles.cmd wrapper for the dotfiles CLI
│   ├── install.ps1      # Windows install script
│   └── validate-prereqs.ps1
├── bootstrap.sh         # One-command setup for macOS/Linux (curl | bash)
├── bootstrap.ps1        # One-command setup for Windows (irm | iex)
├── install.conf.yaml    # Dotbot symlink config
└── tools.yaml           # Packages and setup per tool (used by the dotfiles CLI)
```

## Quick Start

On a new machine, one command checks the prerequisites (offering to install missing
ones), clones this repo to `~/dev/repositories/personal/.dotfiles` (asking before
creating `~/dev/repositories/personal` if it doesn't exist) and runs the install script
for your OS:

```bash
# macOS / Arch-based Linux
curl -fsSL https://raw.githubusercontent.com/chrilleson/.dotfiles/main/bootstrap.sh | bash
```

```powershell
# Windows (built-in PowerShell)
irm https://raw.githubusercontent.com/chrilleson/.dotfiles/main/bootstrap.ps1 | iex
```

Set `DOTFILES_DIR` to clone somewhere else, or `DOTFILES_SKIP_INSTALL=1` to only check
prerequisites and clone. Running it again updates the clone and re-runs the installer.
The clone uses HTTPS; switch to SSH to push (`git remote set-url origin git@github.com:chrilleson/.dotfiles.git`).

The sections below describe the manual route.

## Prerequisites

### Windows

1. **Git** - [git-scm.com](https://git-scm.com/)
2. **Python 3** - [python.org](https://www.python.org/) (includes the `py` launcher)
   - plus **PyYAML** (used by dotbot and the `dotfiles` command): `py -3 -m pip install pyyaml`
3. **Scoop** - Package manager
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
   ```
4. **Developer Mode** (Recommended) - Allows creating symlinks without admin privileges
   - Settings → Privacy & Security → For developers → Developer Mode

### Linux (Arch-based)

1. **Git** - `sudo pacman -S git`
2. **Python 3** - `sudo pacman -S python` (PyYAML is installed by the install script)
3. **paru** - AUR helper
   ```bash
   git clone https://aur.archlinux.org/paru-bin.git
   cd paru-bin && makepkg -si
   ```

### macOS

1. **Git** - included with Xcode Command Line Tools: `xcode-select --install`
2. **Python 3** - included with Xcode Command Line Tools (PyYAML is installed by the install script)
3. **Homebrew** - installed automatically by the install script if missing

## Installation

### Windows

1. Clone this repository:
   ```powershell
   git clone git@github.com:chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Create your machine-specific Git config:
   ```powershell
   cp shared/git/gitconfig-local.example ~/.gitconfig-local
   notepad ~/.gitconfig-local
   ```

3. Run the installer (works in the built-in Windows PowerShell; installs PowerShell 7):
   ```powershell
   .\windows\install.ps1
   ```

4. Restart your terminal, or launch WezTerm, which starts PowerShell 7.

### Linux (Arch-based)

1. Clone this repository:
   ```bash
   git clone git@github.com:chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Create your machine-specific Git config:
   ```bash
   cp shared/git/gitconfig-local.example ~/.gitconfig-local
   $EDITOR ~/.gitconfig-local
   ```

3. Run the installer (sets Zsh as your default shell):
   ```bash
   ./linux/install.sh
   ```

4. Install Node LTS and global packages (in a Zsh session):
   ```zsh
   fnm install --lts && fnm default lts-latest
   npm install -g typescript ts-node pnpm eslint prettier @fsouza/prettierd neovim
   ```

### macOS

1. Clone this repository:
   ```bash
   git clone git@github.com:chrilleson/.dotfiles.git
   cd .dotfiles
   ```

2. Run the installer (installs Homebrew if needed):
   ```bash
   ./macos/install.sh
   ```

3. Edit your machine-specific Git config:
   ```bash
   $EDITOR ~/.gitconfig-local
   ```

4. Install Node LTS and global packages (in a Zsh session):
   ```zsh
   fnm install --lts && fnm default lts-latest
   npm install -g typescript ts-node pnpm eslint prettier @fsouza/prettierd neovim
   ```

## The `dotfiles` command

### Getting the command

- **New machine:** run your OS's install script (see [Installation](#installation)).
  It links the command to `~/.local/bin/dotfiles`.
- **Already installed, but no `dotfiles` command yet:** link it from the repo, then
  open a new shell:
  ```bash
  ./shared/bin/dotfiles link        # Windows: py -3 shared\bin\dotfiles link
  ```
- **Without linking:** run it straight from the repo, e.g. `./shared/bin/dotfiles list`
  (on Windows: `py -3 shared\bin\dotfiles list`).

On macOS and Linux, `~/.local/bin` is added to your `PATH` by `shared/zsh/zshrc`.
On Windows, `windows/bin/dotfiles.cmd` is linked next to it and runs the script through
Python, and `install.ps1` adds `~/.local/bin` to your user `PATH`, so `dotfiles` works in
PowerShell, cmd and WezTerm.

### Usage

```bash
dotfiles install                # pick tools to install interactively
dotfiles install tmux vscode    # install specific tools (-n to preview)
dotfiles install --all          # install everything and link all configs
dotfiles link                   # re-run dotbot (symlinks only)
dotfiles list                   # show tools and what's linked/installed
dotfiles reset                  # pick tools to reset interactively
dotfiles reset tmux vscode      # reset specific tools (-n to preview)
dotfiles reset --all            # reset everything
dotfiles upgrade                # pick outdated tools to upgrade interactively
dotfiles upgrade --all          # upgrade everything
```

Without tool names, `install`, `reset` and `upgrade` open a picker (↑/↓ move, space
toggle, `a` all, enter confirm). They show what they'll do and ask before changing
anything (`-y` skips the question). Reset only removes symlinks pointing into this repo,
never real files.

`upgrade` runs `brew update` and offers only tools with updates on macOS, and
`scoop update` on Windows. On Arch it always runs `paru -Syu`, since Arch doesn't
support upgrading single packages.

`tools.yaml` is the only package list: each tool has its brew/paru/Scoop packages,
the configs it owns, and any setup commands to run after installing or before
resetting. The install scripts handle prerequisites (Homebrew, PyYAML, zsh as the
login shell) and then run `dotfiles install --all`. Prerequisites are never listed
in `tools.yaml`, so reset can't remove them.

## What's Included

| Config | Windows | Linux | macOS |
|--------|---------|-------|-------|
| **Git** | ✓ | ✓ | ✓ |
| **Starship** | ✓ | ✓ | ✓ |
| **Neovim** (LazyVim) | ✓ | ✓ | ✓ |
| **Node.js** (fnm, eslint, prettier) | ✓ | ✓ | ✓ |
| **VS Code** | ✓ | ✓ | ✓ |
| **Proton Pass CLI** (`pass-cli`) | ✓ | ✓ | ✓ |
| **PowerShell 7** | ✓ | | |
| **WezTerm** | ✓ | | |
| **Zsh** | | ✓ | ✓ |
| **Ghostty** | | ✓ | ✓ |
| **Tmux** | | ✓ | ✓ |

## Notes

### Machine-specific Git Config
`~/.gitconfig-local` holds your personal name, email, and editor. It is sourced by `shared/git/gitconfig` and is never committed to this repository. Copy `shared/git/gitconfig-local.example` as a starting point.

### Existing Config Files
Dotbot never overwrites a real file: if one already exists where a symlink should go, it reports it and skips that link. Move the file aside (e.g. `mv ~/.gitconfig ~/.gitconfig.old`) and run `dotfiles link`.
