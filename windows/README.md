# Windows-Specific Documentation

This directory contains the Windows-specific configuration: the PowerShell 7 profile,
WezTerm config, the install script and the `dotfiles.cmd` wrapper.

## Stack

| Tool | Role |
|------|------|
| PowerShell 7 (`pwsh`) | Interactive shell |
| PSReadLine + PSFzf | Suggestions, highlighting, menu completion, fzf history search |
| Starship | Prompt |
| WezTerm | Terminal (starts `pwsh`) |
| Scoop | Package manager |

## Prerequisites

1. **Git** - https://git-scm.com/
2. **Python 3** - https://www.python.org/ (the installer includes the `py` launcher)
   - plus **PyYAML**: `py -3 -m pip install pyyaml`
3. **Scoop**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
   ```
4. **Developer Mode** (recommended) so symlinks work without admin:
   Settings → Privacy & Security → For developers → Developer Mode

PowerShell 7 itself doesn't need to be installed first: the installer runs in the
built-in Windows PowerShell and installs `pwsh` via Scoop.

## Installation

```powershell
.\windows\install.ps1
```

It checks prerequisites (`validate-prereqs.ps1`), adds `~/.local/bin` to your user
`PATH`, sets `XDG_CONFIG_HOME` to `~/.config`, runs `dotfiles install --all`, and
installs Node.js LTS plus global npm packages via fnm. Restart your terminal afterwards.

## Packages

Packages are listed per tool in `tools.yaml` at the repo root, under the `windows:` key.
Apps from other Scoop buckets are written as `bucket/app` (for example `extras/wezterm`);
the bucket is added automatically before installing.

To add one:

```yaml
your-tool:
  windows: [your-package-name]      # main bucket
  # windows: [extras/your-gui-app]  # other buckets
```

Then install it with `dotfiles install your-tool`. Use `dotfiles list` to see what's
installed, `dotfiles upgrade` to update, and `dotfiles reset your-tool` to remove it.

## The `dotfiles` command

`windows/bin/dotfiles.cmd` is linked to `~/.local/bin/dotfiles.cmd` and runs the Python
CLI with `py -3` (or `python`), so `dotfiles` works in PowerShell, cmd and WezTerm.
See the root README for the commands.

## Configuration

### PowerShell 7

`powershell/profile.ps1` is linked to `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`.
If your Documents folder is redirected (e.g. to OneDrive), `install.ps1` also links it there.

It mirrors the zsh setup on macOS/Linux:
- fish-style inline suggestions from history (→ to accept, Ctrl+→ for one word)
- syntax highlighting and Tab menu completion
- ↑/↓ search history for what you've typed
- Ctrl+R / Ctrl+T fzf history and file search (PSFzf)
- Starship, zoxide, fnm, and the `ls`/`la`/`ll`/`lt` eza aliases

### WezTerm

`wezterm/` is linked to `~/.config/wezterm/`; the default program is `pwsh`.

### Neovim

`shared/nvim` is linked to `~/.config/nvim`. Neovim reads it there because the installer
sets `XDG_CONFIG_HOME`.

### VS Code

VS Code settings live in `shared/vscode/` and are linked to `%APPDATA%\Code\User\`.

## Troubleshooting

### Running scripts is disabled

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Symlink creation failed

1. Enable Developer Mode (Settings → For developers), or run the installer as Administrator
2. Dotbot never overwrites real files: move existing files at the destination aside and run `dotfiles link`

### Commands not found after installing

Restart your terminal, or refresh `PATH` in the current session:

```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
```

### Scoop problems

```powershell
scoop update; scoop update *; scoop checkup
```
