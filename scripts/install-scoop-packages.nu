#!/usr/bin/env nu
# Install packages via Scoop

print $"(ansi cyan_bold)=== Installing Scoop packages ===(ansi reset)"

# Move to home directory to avoid Scoop interpreting local folders as buckets
let original_location = $env.PWD
cd $nu.home-path

try {
    # Check if Scoop is installed
    if (which scoop | is-empty) {
        print $"(ansi red_bold)ERROR: Scoop not installed. Install from https://scoop.sh(ansi reset)"
        exit 1
    }
    
    # Add buckets
    print $"\n(ansi cyan)Adding Scoop buckets...(ansi reset)"
    scoop bucket add extras err> /dev/null
    scoop bucket add nerd-fonts err> /dev/null
    
    # Install main bucket packages
    print $"\n(ansi cyan)Installing main bucket packages...(ansi reset)"
    scoop install git delta fzf zoxide bat ripgrep fd jq starship fnm nu
    
    # Install extras bucket packages
    print $"\n(ansi cyan)Installing extras bucket packages...(ansi reset)"
    scoop install wezterm
    
    # Install nerd-fonts bucket packages
    print $"\n(ansi cyan)Installing nerd-fonts bucket packages...(ansi reset)"
    scoop install JetBrainsMono-NF
    
    print $"\n(ansi green_bold)✓ Scoop installation complete(ansi reset)"
} catch {
    print $"(ansi red_bold)Error during installation(ansi reset)"
    cd $original_location
    exit 1
}

cd $original_location