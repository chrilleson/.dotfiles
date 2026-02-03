#!/usr/bin/env nu
# Setup bash integration for various tools

def main [] {
    print $"(ansi cyan_bold)=== Setting up bash integration ===(ansi reset)"
    
    let bashrc_d = ([$nu.home-path ".bashrc.d"] | path join)
    
    # Create .bashrc.d directory if it doesn't exist
    if not ($bashrc_d | path exists) {
        print $"(ansi cyan)Creating .bashrc.d directory(ansi reset)"
        mkdir $bashrc_d
    }
    
    # Check if .bashrc sources .bashrc.d
    let bashrc = ([$nu.home-path ".bashrc"] | path join)
    
    if ($bashrc | path exists) {
        let bashrc_content = (open $bashrc)
        
        if not ($bashrc_content | str contains ".bashrc.d") {
            print $"(ansi yellow)Adding .bashrc.d integration to .bashrc(ansi reset)"
            
            let integration_code = "
# Source .bashrc.d files (added by dotfiles installer)
if [ -d ~/.bashrc.d ]; then
    for file in ~/.bashrc.d/*.sh; do
        [ -r \"$file\" ] && . \"$file\"
    done
    unset file
fi
"
            $integration_code | save --append $bashrc
            print $"(ansi green)✓ Updated .bashrc(ansi reset)"
        } else {
            print $"(ansi green)✓ .bashrc already sources .bashrc.d(ansi reset)"
        }
    } else {
        print $"(ansi yellow)Note: .bashrc not found, will be created on first bash launch(ansi reset)"
    }
    
    print $"\n(ansi green_bold)✓ Bash integration setup complete(ansi reset)"
    print $"(ansi cyan)Integration files are symlinked from: linux/.bashrc.d/(ansi reset)"
}
