#!/usr/bin/env nu
# Dotfiles installation script for Windows

def main [] {
    # Derive repo root from this script's location (windows/install.nu → parent dir)
    let BASEDIR = ($env.CURRENT_FILE | path dirname | path dirname)

    cd $BASEDIR

    # Print banner
    print $"(ansi cyan_bold)╔════════════════════════════════════════╗(ansi reset)"
    print $"(ansi cyan_bold)║     Dotfiles Installation Script      ║(ansi reset)"
    print $"(ansi cyan_bold)║              Windows                  ║(ansi reset)"
    print $"(ansi cyan_bold)╚════════════════════════════════════════╝(ansi reset)\n"

    # Validate prerequisites
    nu ($env.CURRENT_FILE | path dirname | path join "validate-prerequisites.nu")

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

    # Install Scoop packages and link configs (defined in tools.yaml and install.conf.yaml)
    print $"\n(ansi cyan_bold)=== Installing tools and linking configs ===(ansi reset)"
    ^$python ($BASEDIR | path join "shared" "bin" "dotfiles") install --all --yes

    # Setup Node.js
    print $"\n(ansi cyan_bold)=== Setting up Node.js ===(ansi reset)"
    nu ($env.CURRENT_FILE | path dirname | path join "setup-fnm.nu")
    nu ($env.CURRENT_FILE | path dirname | path join "install-node-packages.nu")

    # Post-install check
    let gitconfig_local = ($nu.home-path | path join ".gitconfig-local")
    if not ($gitconfig_local | path exists) {
        print $"\n(ansi yellow_bold)⚠ ~/.gitconfig-local not found(ansi reset)"
        print $"  Copy the template: (ansi cyan)cp shared/git/gitconfig-local.example ~/.gitconfig-local(ansi reset)"
        print $"  Then edit with your name and email: (ansi cyan)notepad ~/.gitconfig-local(ansi reset)\n"
    }

    print $"\n(ansi green_bold)╔════════════════════════════════════════╗(ansi reset)"
    print $"(ansi green_bold)║       Installation Complete! 🎉       ║(ansi reset)"
    print $"(ansi green_bold)╚════════════════════════════════════════╝(ansi reset)\n"
    print $"(ansi cyan_bold)Next steps:(ansi reset)"
    print $"  1. Edit ~/.gitconfig-local with your name and email"
    print $"  2. Restart your terminal"
    print $"  3. Launch WezTerm\n"
}
