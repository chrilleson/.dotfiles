#!/usr/bin/env nu
# Install packages on Linux using native package managers

use ../scripts/detect-platform.nu

def main [] {
    print $"(ansi cyan_bold)=== Installing Linux packages ===(ansi reset)"
    
    let platform = (detect-platform)
    
    if $platform != "linux" {
        print $"(ansi red)ERROR: This script is for Linux only(ansi reset)"
        exit 1
    }
    
    # Detect distribution
    let distro = (detect-linux-distro)
    print $"(ansi cyan)Detected distribution: ($distro)(ansi reset)\n"
    
    match $distro {
        "arch" | "cachyos" | "manjaro" => {
            install-arch-packages
        },
        _ => {
            print $"(ansi yellow)Warning: Unsupported distribution '($distro)'(ansi reset)"
            print $"This script is optimized for Arch-based distributions."
            print $"Please install packages manually or use install.sh"
            exit 1
        }
    }
}

def detect-linux-distro [] {
    let os_release = (open /etc/os-release | from nuon -s)
    
    if ($os_release.ID? | is-not-empty) {
        $os_release.ID
    } else if ($os_release.ID_LIKE? | is-not-empty) {
        $os_release.ID_LIKE | split row " " | first
    } else {
        "unknown"
    }
}

def install-arch-packages [] {
    # Check if pacman is available
    if (which pacman | is-empty) {
        print $"(ansi red)ERROR: pacman not found(ansi reset)"
        exit 1
    }
    
    # Get the dotfiles root directory (parent of linux/)
    let dotfiles_root = ($env.PWD | path dirname)
    
    # Load package list
    let packages_file = ([$dotfiles_root "linux" "packages.yaml"] | path join)
    
    if not ($packages_file | path exists) {
        print $"(ansi red)ERROR: packages.yaml not found at ($packages_file)(ansi reset)"
        exit 1
    }
    
    let packages = (open $packages_file)
    
    # Update package database
    print $"\n(ansi cyan)Updating package database...(ansi reset)"
    try {
        sudo pacman -Sy --noconfirm
    } catch {
        print $"(ansi yellow)Warning: Failed to update package database(ansi reset)"
    }
    
    # Install official packages
    print $"\n(ansi cyan)Installing official repository packages...(ansi reset)"
    let official_packages = $packages.official
    
    for package in $official_packages {
        try {
            # Check if already installed
            let is_installed = (pacman -Q $package | complete | get exit_code) == 0
            
            if $is_installed {
                print $"  (ansi green)✓(ansi reset) ($package) (already installed)"
            } else {
                print $"  (ansi yellow)→(ansi reset) Installing ($package)..."
                sudo pacman -S --noconfirm --needed $package
                print $"  (ansi green)✓(ansi reset) ($package) installed"
            }
        } catch {
            print $"  (ansi red)✗(ansi reset) Failed to install ($package)"
        }
    }
    
    # Setup yay for AUR packages
    print $"\n(ansi cyan)Setting up AUR helper (yay)...(ansi reset)"
    nu ([$dotfiles_root "linux" "setup-yay.nu"] | path join)
    
    # Install AUR packages
    if (which yay | is-not-empty) {
        print $"\n(ansi cyan)Installing AUR packages...(ansi reset)"
        let aur_packages = $packages.aur
        
        for package in $aur_packages {
            try {
                # Check if already installed
                let is_installed = (pacman -Q $package | complete | get exit_code) == 0
                
                if $is_installed {
                    print $"  (ansi green)✓(ansi reset) ($package) (already installed)"
                } else {
                    print $"  (ansi yellow)→(ansi reset) Installing ($package)..."
                    yay -S --noconfirm --needed $package
                    print $"  (ansi green)✓(ansi reset) ($package) installed"
                }
            } catch {
                print $"  (ansi red)✗(ansi reset) Failed to install ($package)"
            }
        }
    } else {
        print $"(ansi yellow)Warning: yay not available, skipping AUR packages(ansi reset)"
    }
    
    print $"\n(ansi green_bold)✓ Package installation complete(ansi reset)"
}
