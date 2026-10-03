# Dotfiles

My dotfiles for macOS, Arch-based Linux and Windows, linked with a vendored copy of
[Dotbot](https://github.com/anishathalye/dotbot) and managed with a small `dotfiles` CLI.

## Install

On a new machine, run:

```bash
# macOS / Arch-based Linux
curl -fsSL https://raw.githubusercontent.com/chrilleson/.dotfiles/main/bootstrap.sh | bash
```

```powershell
# Windows (built-in PowerShell)
irm https://raw.githubusercontent.com/chrilleson/.dotfiles/main/bootstrap.ps1 | iex
```

It checks prerequisites (offering to install missing ones), clones this repo to
`~/dev/repositories/personal/.dotfiles` and runs the install script for your OS.
Running it again updates the clone and re-runs the installer. Options:
`DOTFILES_DIR=<path>` to clone elsewhere, `DOTFILES_SKIP_INSTALL=1` to only clone.

**Manually:** clone the repo anywhere and run `./macos/install.sh`, `./linux/install.sh`
or `.\windows\install.ps1`.

**Afterwards:**
- Put your name and email in `~/.gitconfig-local` (created from
  `shared/git/gitconfig-local.example`; never committed).
- On macOS/Linux, install Node and global packages (Windows does this for you):
  ```zsh
  fnm install --lts && fnm default lts-latest
  npm install -g typescript ts-node pnpm eslint prettier @fsouza/prettierd neovim
  ```
- The clone uses HTTPS. To push: `git remote set-url origin git@github.com:chrilleson/.dotfiles.git`

## The `dotfiles` command

The installer links it to `~/.local/bin`, so it works from anywhere:

```bash
dotfiles list                   # tools, and what's linked/installed
dotfiles install [TOOL...]      # install packages and link configs
dotfiles upgrade [TOOL...]      # upgrade installed packages
dotfiles reset [TOOL...]        # unlink configs and uninstall packages
dotfiles link                   # re-create all symlinks
dotfiles dotbot [--update]      # check for (or install) a newer vendored Dotbot
dotfiles dotbot 1.23.1          # pin Dotbot to a version (--list shows them)
```

Without tool names, `install`, `upgrade` and `reset` open a picker; use `--all` for
everything. They preview what they'll do and ask first (`-n` preview only, `-y` don't ask).
On Arch, `upgrade` always runs `paru -Syu`, since Arch doesn't support partial upgrades.

Packages live in [`tools.yaml`](tools.yaml) (brew, paru and Scoop per tool) and links in
[`install.conf.yaml`](install.conf.yaml). To add a tool, add it to `tools.yaml` and run
`dotfiles install <tool>`.

## What's Included

| | macOS | Linux | Windows |
|---|:-:|:-:|:-:|
| Git, Starship, Neovim (LazyVim), Node (fnm), VS Code, Proton Pass CLI | ✓ | ✓ | ✓ |
| Zsh, Ghostty, Tmux | ✓ | ✓ | |
| Docker | OrbStack | Docker | |
| PowerShell 7, WezTerm | | | ✓ |

## Layout

```
shared/     configs for every OS (git, zsh, nvim, starship, vscode, node) and the dotfiles CLI
macos/      macOS configs and install.sh
linux/      Linux configs and install.sh            (see linux/README.md)
windows/    PowerShell profile, WezTerm, install.ps1 (see windows/README.md)
dotbot/     vendored Dotbot
```

## Notes

- **Existing files:** Dotbot never overwrites a real file; it skips that link. Move the
  file aside (e.g. `mv ~/.gitconfig ~/.gitconfig.old`) and run `dotfiles link`.
- **Windows:** enable Developer Mode (Settings → For developers) so symlinks work without admin.
