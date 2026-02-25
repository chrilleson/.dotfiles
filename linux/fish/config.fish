# CachyOS base config (Arch-specific; guard means this is safe on other systems)
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# Local paths
fish_add_path ~/.local/bin
fish_add_path ~/.opencode/bin

# XDG-compliant tool locations
set -gx BUN_INSTALL ~/.local/share/bun
fish_add_path ~/.local/share/bun/bin
set -gx NUGET_PACKAGES ~/.cache/NuGet/packages

# SSH agent (danhper/fish-ssh-agent)
set -g SSH_KEY_PATH ~/.ssh/id_ed25519
