# Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -f /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

# Local paths
fish_add_path ~/.local/bin
fish_add_path ~/.opencode/bin

# XDG-compliant tool locations
set -gx BUN_INSTALL ~/.local/share/bun
fish_add_path ~/.local/share/bun/bin
set -gx NUGET_PACKAGES ~/.cache/NuGet/packages

# SSH agent
set -g SSH_KEY_PATH ~/.ssh/id_ed25519
