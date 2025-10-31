#!/usr/bin/env nu

print $"(ansi cyan_bold)=== Installing Node.js global packages ===(ansi reset)"

if (which npm | is-empty) {
    print $"(ansi red_bold)ERROR: npm not found. Install Node.js first.(ansi reset)"
    exit 1
}

let packages = [
    "@fsouza/prettierd"
    "eslint"
    "prettier"
    "typescript"
    "ts-node"
    "pnpm"
    "yarn"
    "opencode-ai"
]

print $"\n(ansi cyan)Installing global packages...(ansi reset)"
for package in $packages {
    let is_installed = (npm list -g --depth=0 $package | complete | get exit_code) == 0
    
    if $is_installed {
        print $"  Skipping ($package) - already installed"
    } else {
        try {
            print $"  Installing ($package)..."
            npm install -g $package --no-audit
        } catch {
            print $"(ansi yellow)Warning: Failed to install ($package)(ansi reset)"
        }
    }
}

print $"\n(ansi green_bold)✓ Node.js global packages installation complete(ansi reset)"
