#!/usr/bin/env nu
# Setup script for fnm installation and Node.js

print $"(ansi cyan_bold)=== Setting up fnm and Node.js ===(ansi reset)"

# Add Scoop shims to PATH
let scoop_shims = $"($nu.home-path)\\scoop\\shims"
$env.Path = ($env.Path | prepend $scoop_shims)

# Check if fnm is available
if (which fnm | is-empty) {
    print $"(ansi red_bold)ERROR: fnm not found. Install it with: scoop install fnm(ansi reset)"
    exit 1
}

print $"(ansi green)fnm found at: (which fnm | get path.0)(ansi reset)"

# Initialize fnm environment
fnm env --json | from json | load-env

# Install and configure Node.js LTS
print $"\n(ansi cyan)Installing Node.js LTS...(ansi reset)"
fnm install --lts
fnm default lts-latest
fnm use lts-latest

# Reload environment
fnm env --json | from json | load-env

# Install global npm packages
print $"\n(ansi cyan)Installing global Node packages...(ansi reset)"
npm install -g typescript ts-node pnpm yarn eslint prettier @fsouza/prettierd

print $"\n(ansi green_bold)✓ Setup complete!(ansi reset)"