#!/usr/bin/env nu
# Setup yay AUR helper

def main [] {
    # Check if yay is already installed
    if (which yay | is-not-empty) {
        print $"(ansi green)✓ yay is already installed(ansi reset)"
        return
    }
    
    print $"(ansi cyan)Installing yay AUR helper...(ansi reset)"
    
    # Check prerequisites
    if (which git | is-empty) {
        print $"(ansi red)ERROR: git is required to install yay(ansi reset)"
        exit 1
    }
    
    if (which base-devel | is-empty) and (pacman -Q base-devel | complete | get exit_code) != 0 {
        print $"(ansi yellow)Installing base-devel (required for building AUR packages)...(ansi reset)"
        try {
            sudo pacman -S --noconfirm --needed base-devel
        } catch {
            print $"(ansi red)ERROR: Failed to install base-devel(ansi reset)"
            exit 1
        }
    }
    
    # Create temporary directory for building
    let tmp_dir = (mktemp -d)
    print $"(ansi cyan)Building yay in ($tmp_dir)...(ansi reset)"
    
    try {
        # Clone yay repository
        git clone https://aur.archlinux.org/yay-bin.git $"($tmp_dir)/yay-bin"
        
        # Build and install
        cd $"($tmp_dir)/yay-bin"
        makepkg -si --noconfirm --needed
        
        # Clean up
        cd $env.PWD
        rm -rf $tmp_dir
        
        print $"(ansi green_bold)✓ yay installed successfully(ansi reset)"
    } catch {
        print $"(ansi red)ERROR: Failed to install yay(ansi reset)"
        print $"Please install yay manually:"
        print $"  git clone https://aur.archlinux.org/yay-bin.git"
        print $"  cd yay-bin"
        print $"  makepkg -si"
        
        # Clean up on failure
        rm -rf $tmp_dir
        exit 1
    }
}
