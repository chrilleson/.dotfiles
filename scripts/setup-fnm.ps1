# Setup script for fnm installation and Node.js

Write-Host "=== Setting up fnm and Node.js ===" -ForegroundColor Cyan

# Add Scoop shims to PATH
$env:Path = "$(Join-Path $env:USERPROFILE 'scoop\shims');$env:Path"

# Check if fnm is available
if (!(Get-Command fnm -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: fnm not found. Install it with: scoop install fnm" -ForegroundColor Red
    exit 1
}

Write-Host "fnm found at: $((Get-Command fnm).Source)" -ForegroundColor Green

# Initialize fnm environment
fnm env --shell power-shell | Out-String | Invoke-Expression

# Install and configure Node.js LTS
Write-Host "`nInstalling Node.js LTS..." -ForegroundColor Cyan
fnm install --lts
fnm default lts-latest
fnm use lts-latest

# Reload environment
fnm env --shell power-shell | Out-String | Invoke-Expression

# Install global npm packages
Write-Host "`nInstalling global Node packages..." -ForegroundColor Cyan
npm install -g typescript ts-node pnpm yarn eslint prettier @fsouza/prettierd

Write-Host "`n✓ Setup complete!" -ForegroundColor Green