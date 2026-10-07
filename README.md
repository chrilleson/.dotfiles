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
- The clone uses HTTPS. The bootstrapper switches it to SSH when `~/.ssh/config` has a
  `github-personal` host (`DOTFILES_SSH_HOST` to change); otherwise, to push:
  `git remote set-url origin git@github-personal:chrilleson/.dotfiles.git`

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
[`install.conf.yaml`](install.conf.yaml). See [Adding a tool](#adding-a-tool).

## Adding a tool

`tools.yaml` is the only package list. The install scripts run `dotfiles install --all`,
so anything you add there is installed on every new machine.

1. **Add an entry to `tools.yaml`** that lists the package name for each OS you want it on.
   Leave out an OS to skip it there:
   ```yaml
   fastfetch:
     macos: [fastfetch]      # brew (casks and tap/formula work too)
     linux: [fastfetch]      # paru (official repos or AUR, e.g. foo-bin)
     windows: [fastfetch]    # scoop (bucket/app for non-main buckets, e.g. extras/foo)
   ```
   Look up the names with `brew search`, `paru -Ss` and `scoop search`, since they
   sometimes differ (e.g. `git-delta` vs `delta`).
2. **Install it:** `dotfiles install fastfetch` (`-n` previews first).
3. **Commit** `tools.yaml`, then run `dotfiles install <tool>` on your other machines.

**With a config file:** put it under `shared/<tool>/` (or `macos/`, `linux/`, `windows/`
if it's OS-specific), add a link to `install.conf.yaml`, and list the folder under
`links:` so `install`/`reset` handle the link together with the package:
```yaml
# install.conf.yaml, inside the first `- link:` block
    ~/.config/fastfetch/config.jsonc:
      path: shared/fastfetch/config.jsonc
      create: true

# tools.yaml
fastfetch:
  links: [shared/fastfetch]
  ...
```

**Without a package:** use per-OS `install:`, `upgrade:` and `reset:` shell commands
instead (see `fonts` and `pass-cli` in `tools.yaml`). Keep `install` commands idempotent,
because they run on every install. Add a per-OS `check:` command that succeeds once the
`install` commands are done, so `dotfiles install` skips them and the picker hides the tool.

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
