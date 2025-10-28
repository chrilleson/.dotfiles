# Install packages via Scoop

Write-Host "=== Installing Scoop packages ===" -ForegroundColor Cyan

# Move to home directory to avoid Scoop interpreting local folders as buckets
$OriginalLocation = Get-Location
try {
    Set-Location $env:USERPROFILE
    
    # Check if Scoop is installed
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: Scoop not installed. Install from https://scoop.sh" -ForegroundColor Red
        exit 1
    }
    
    # Add buckets
    Write-Host "`nAdding Scoop buckets..." -ForegroundColor Cyan
    scoop bucket add extras 2>$null
    scoop bucket add nerd-fonts 2>$null
    
    # Install main bucket packages
    Write-Host "`nInstalling main bucket packages..." -ForegroundColor Cyan
    scoop install git delta fzf zoxide bat ripgrep fd jq starship fnm nu
    
    # Install extras bucket packages
    Write-Host "`nInstalling extras bucket packages..." -ForegroundColor Cyan
    scoop install wezterm
    
    # Install nerd-fonts bucket packages
    Write-Host "`nInstalling nerd-fonts bucket packages..." -ForegroundColor Cyan
    scoop install JetBrainsMono-NF
    
    Write-Host "`n✓ Scoop installation complete" -ForegroundColor Green
}
finally {
    Set-Location $OriginalLocation
}