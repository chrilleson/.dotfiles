#!/usr/bin/env nu
# Dotfiles installation script

def main [...args: string] {
    const CONFIG = "install.conf.yaml"
    const DOTBOT_DIR = "dotbot"
    const DOTBOT_BIN = "bin/dotbot"

    let BASEDIR = $env.PWD

    cd $BASEDIR

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
    print $"Using ($python)..."
    let dotbot_path = ($BASEDIR | path join $DOTBOT_DIR | path join $DOTBOT_BIN)
    ^$python $dotbot_path -d $BASEDIR -p dotbot-scoop/scoop.py -c $CONFIG ...$args
    
    # Post-install validation
    print "\n"
    let gitconfig_local = ($nu.home-path | path join ".gitconfig-local")
    if ($gitconfig_local | path exists) {
        print $"(ansi green)✓ Git configuration is set up correctly(ansi reset)"
    } else {
        print $"(ansi yellow_bold)⚠ WARNING: ~/.gitconfig-local not found!(ansi reset)"
        print $"(ansi yellow)Please create this file with your personal Git settings:(ansi reset)"
        print $"  1. Copy the template: (ansi cyan)cp git/gitconfig-local.example ~/.gitconfig-local(ansi reset)"
        print $"  2. Edit with your details: (ansi cyan)notepad ~/.gitconfig-local(ansi reset)\n"
    }
    
    print $"(ansi green_bold)✓ Installation complete!(ansi reset)\n"
}