#!/usr/bin/env nu
# Install Nerd Fonts on Linux

def main [] {
    print $"(ansi cyan_bold)=== Installing Nerd Fonts ===(ansi reset)"
    
    let fonts_dir = ([$nu.home-path ".local" "share" "fonts"] | path join)
    
    # Create fonts directory if it doesn't exist
    if not ($fonts_dir | path exists) {
        print $"(ansi cyan)Creating fonts directory: ($fonts_dir)(ansi reset)"
        mkdir $fonts_dir
    }
    
    # Install JetBrainsMono Nerd Font
    install-jetbrains-mono $fonts_dir
    
    # Rebuild font cache
    print $"\n(ansi cyan)Rebuilding font cache...(ansi reset)"
    try {
        fc-cache -f -v | complete
        print $"(ansi green)✓ Font cache rebuilt(ansi reset)"
    } catch {
        print $"(ansi yellow)Warning: Failed to rebuild font cache(ansi reset)"
    }
    
    print $"\n(ansi green_bold)✓ Font installation complete(ansi reset)"
}

def install-jetbrains-mono [fonts_dir: string] {
    let font_name = "JetBrainsMono"
    let font_file = $"($font_name)NerdFont-Regular.ttf"
    let font_path = ([$fonts_dir $font_file] | path join)
    
    # Check if already installed
    if ($font_path | path exists) {
        print $"(ansi green)✓ JetBrainsMono Nerd Font already installed(ansi reset)"
        return
    }
    
    print $"(ansi yellow)→(ansi reset) Installing JetBrainsMono Nerd Font..."
    
    # Create temporary directory
    let tmp_dir = (mktemp -d)
    
    try {
        # Download the latest release
        let download_url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        let zip_file = ([$tmp_dir $"($font_name).zip"] | path join)
        
        print $"  Downloading from GitHub..."
        http get $download_url | save -f $zip_file
        
        # Extract to fonts directory
        print $"  Extracting fonts..."
        unzip -o $zip_file -d ([$fonts_dir $font_name] | path join) | complete
        
        # Clean up
        rm -rf $tmp_dir
        
        print $"(ansi green)✓ JetBrainsMono Nerd Font installed(ansi reset)"
    } catch {
        print $"(ansi red)✗ Failed to install JetBrainsMono Nerd Font(ansi reset)"
        print $"  You can install it manually:"
        print $"  1. Download from: https://github.com/ryanoasis/nerd-fonts/releases"
        print $"  2. Extract to: ($fonts_dir)"
        print $"  3. Run: fc-cache -f -v"
        
        # Clean up on failure
        rm -rf $tmp_dir
    }
}
