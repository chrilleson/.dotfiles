#!/usr/bin/env nu
# Dotfiles installation script - Cross-platform

use scripts/detect-platform.nu

def main [...args: string] {
    const CONFIG = "install.conf.yaml"
    const DOTBOT_DIR = "dotbot"
    const DOTBOT_BIN = "bin/dotbot"

    let BASEDIR = $env.PWD
    let platform = (detect-platform)

    cd $BASEDIR

    # Print banner
    print $"(ansi cyan_bold)╔════════════════════════════════════════╗(ansi reset)"
    print $"(ansi cyan_bold)║     Dotfiles Installation Script      ║(ansi reset)"
    print $"(ansi cyan_bold)║            Platform: (char -u '0020')($platform | str pad 19)║(ansi reset)"
    print $"(ansi cyan_bold)╚════════════════════════════════════════╝(ansi reset)\n"

    # Validate prerequisites
    print "Checking prerequisites..."
    nu ./scripts/validate-prerequisites.nu
    if ($env.LAST_EXIT_CODE != 0) {
        exit 1
    }

    # Update dotbot submodule
    print "Updating dotbot submodule..."
    git -C $DOTBOT_DIR submodule sync --quiet --recursive
    git submodule update --init --recursive $DOTBOT_DIR

    # Platform-specific package installation
    if $platform == "windows" {
        # Install Scoop packages
        nu ./windows/install-packages.nu
    } else if $platform == "linux" {
        # Install Linux packages
        nu ./linux/install-packages.nu
        
        # Install fonts
        nu ./linux/install-fonts.nu
        
        # Setup bash integration
        nu ./linux/setup-bash.nu
    } else if $platform == "macos" {
        print $"(ansi yellow)Note: macOS package installation via Homebrew(ansi reset)"
        print $"Use install.sh for full macOS support or install packages manually\n"
    }

    # Find Python executable
    let python = (
        ['python', 'python3'] 
        | where {|cmd| (which $cmd | is-not-empty)} 
        | first
    )

    if ($python | is-empty) {
        print $"(ansi red_bold)Error: Cannot find Python.(ansi reset)"
        exit 1
    }

    # Run dotbot
    print $"\n(ansi cyan_bold)=== Running dotbot configuration ===(ansi reset)"
    print $"Using ($python)..."
    let dotbot_path = ($BASEDIR | path join $DOTBOT_DIR | path join $DOTBOT_BIN)
    
    if $platform == "windows" {
        ^$python $dotbot_path -d $BASEDIR -p dotbot-scoop/scoop.py -c $CONFIG ...$args
    } else {
        ^$python $dotbot_path -d $BASEDIR -c $CONFIG ...$args
    }
    
    # Setup Node.js
    print $"\n(ansi cyan_bold)=== Setting up Node.js ===(ansi reset)"
    nu ./scripts/setup-fnm.nu
    nu ./scripts/install-node-packages.nu
    
    # Post-install validation
    print "\n"
    let gitconfig_local = ($nu.home-path | path join ".gitconfig-local")
    if ($gitconfig_local | path exists) {
        print $"(ansi green)✓ Git configuration is set up correctly(ansi reset)"
    } else {
        print $"(ansi yellow_bold)⚠ WARNING: ~/.gitconfig-local not found!(ansi reset)"
        print $"(ansi yellow)Please create this file with your personal Git settings:(ansi reset)"
        print $"  1. Copy the template: (ansi cyan)cp git/gitconfig-local.example ~/.gitconfig-local(ansi reset)"
        
        if $platform == "windows" {
            print $"  2. Edit with your details: (ansi cyan)notepad ~/.gitconfig-local(ansi reset)\n"
        } else {
            print $"  2. Edit with your details: (ansi cyan)$EDITOR ~/.gitconfig-local(ansi reset)\n"
        }
    }
    
    print $"(ansi green_bold)╔════════════════════════════════════════╗(ansi reset)"
    print $"(ansi green_bold)║    Installation Complete! 🎉          ║(ansi reset)"
    print $"(ansi green_bold)╚════════════════════════════════════════╝(ansi reset)\n"
    
    # Platform-specific next steps
    if $platform == "linux" {
        print $"(ansi cyan_bold)Next steps:(ansi reset)"
        print $"  1. Edit ~/.gitconfig-local with your name and email"
        print $"  2. Restart your terminal or run: (ansi cyan)source ~/.bashrc(ansi reset)"
        print $"  3. Launch WezTerm"
        print $"  4. Run 'nu' to start Nushell\n"
    } else if $platform == "windows" {
        print $"(ansi cyan_bold)Next steps:(ansi reset)"
        print $"  1. Edit ~/.gitconfig-local with your name and email"
        print $"  2. Restart your terminal"
        print $"  3. Launch WezTerm"
        print $"  4. Run 'nu' to start Nushell\n"
    }
}