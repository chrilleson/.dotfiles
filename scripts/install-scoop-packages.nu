#!/usr/bin/env nu
# Install packages via Scoop

print $"(ansi cyan_bold)=== Installing Scoop packages ===(ansi reset)"

# Move to home directory to avoid Scoop interpreting local folders as buckets
let original_location = $env.PWD
cd $nu.home-path

# Check if Scoop is installed
if (which scoop | is-empty) {
    print $"(ansi red_bold)ERROR: Scoop not installed. Install from https://scoop.sh(ansi reset)"
    cd $original_location
    exit 1
}

# Add buckets
print $"\n(ansi cyan)Adding Scoop buckets...(ansi reset)"
scoop bucket add extras err> /dev/null
scoop bucket add nerd-fonts err> /dev/null

# Install main bucket packages (skip already installed)
print $"\n(ansi cyan)Installing main bucket packages...(ansi reset)"
let main_packages = [git delta fzf zoxide bat ripgrep fd jq starship fnm neovim 7zip]
for package in $main_packages {
    try {
        scoop install $package err> /dev/null
    } catch {
        # Silently continue - package is likely already installed
    }
}

# Install extras bucket packages
print $"\n(ansi cyan)Installing extras bucket packages...(ansi reset)"
let extras_packages = [wezterm lazygit]
for package in $extras_packages {
    try {
        scoop install $package err> /dev/null
    } catch {
        # Silently continue - package is likely already installed
    }
}

# Install nerd-fonts bucket packages
print $"\n(ansi cyan)Installing nerd-fonts...(ansi reset)"
try {
    scoop install JetBrainsMono-NF err> /dev/null
} catch {
    print $"(ansi yellow)Warning: Font installation may have failed. Install manually with: scoop install JetBrainsMono-NF(ansi reset)"
}

print $"\n(ansi green_bold)✓ Scoop installation complete(ansi reset)"

cd $original_location