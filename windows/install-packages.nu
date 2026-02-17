#!/usr/bin/env nu
# Install packages via Scoop on Windows

def main [] {
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
    
    # Load package definitions
    let packages_file = ([$original_location "windows" "packages.json"] | path join)
    
    if not ($packages_file | path exists) {
        print $"(ansi red)ERROR: packages.json not found at ($packages_file)(ansi reset)"
        cd $original_location
        exit 1
    }
    
    let packages = (open $packages_file)
    
    # Add buckets
    print $"\n(ansi cyan)Adding Scoop buckets...(ansi reset)"
    for bucket in $packages.buckets {
        try {
            scoop bucket add $bucket err> /dev/null
        } catch {
            # Silently continue - bucket may already be added
        }
    }
    
    # Install main bucket packages
    print $"\n(ansi cyan)Installing main bucket packages...(ansi reset)"
    for package in $packages.main {
        try {
            scoop install $package err> /dev/null
            print $"  (ansi green)✓(ansi reset) ($package)"
        } catch {
            # Silently continue - package is likely already installed
        }
    }
    
    # Install extras bucket packages
    print $"\n(ansi cyan)Installing extras bucket packages...(ansi reset)"
    for package in $packages.extras {
        try {
            scoop install $package err> /dev/null
            print $"  (ansi green)✓(ansi reset) ($package)"
        } catch {
            # Silently continue - package is likely already installed
        }
    }
    
    # Install nerd-fonts bucket packages
    print $"\n(ansi cyan)Installing nerd-fonts...(ansi reset)"
    for package in $packages."nerd-fonts" {
        try {
            scoop install $package err> /dev/null
            print $"  (ansi green)✓(ansi reset) ($package)"
        } catch {
            print $"  (ansi yellow)⚠(ansi reset) ($package) - Install manually if needed: scoop install ($package)"
        }
    }
    
    print $"\n(ansi green_bold)✓ Scoop installation complete(ansi reset)"
    
    cd $original_location
}
