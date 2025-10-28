# Setup script for fnm installation and Node.js

Write-Host "=== Setting up fnm and Node.js ===" -ForegroundColor Cyan

# Add Scoop shims to PATH
$scoopShims = Join-Path $env:USERPROFILE 'scoop\shims'
if (Test-Path $scoopShims) {
    $env:Path = "$scoopShims;$env:Path"
    Write-Host "Added Scoop shims to PATH: $scoopShims" -ForegroundColor Green
} else {
    Write-Host "WARNING: Scoop shims not found at $scoopShims" -ForegroundColor Yellow
}

Write-Host "`nLooking for fnm..." -ForegroundColor Cyan
$fnmCmd = Get-Command fnm -ErrorAction SilentlyContinue

if ($fnmCmd) {
    Write-Host "fnm found at: $($fnmCmd.Source)" -ForegroundColor Green
    
    # Check if it's the Scoop version
    if ($fnmCmd.Source -like "*scoop*") {
        Write-Host "Using Scoop-installed fnm" -ForegroundColor Green
    } else {
        Write-Host "WARNING: fnm is not from Scoop: $($fnmCmd.Source)" -ForegroundColor Yellow
    }
    
    # Load fnm environment FIRST
    Write-Host "`nInitializing fnm environment..." -ForegroundColor Cyan
    fnm env --shell power-shell | Out-String | Invoke-Expression
    
    Write-Host "`nInstalling Node.js LTS..." -ForegroundColor Cyan
    fnm install --lts
    
    Write-Host "`nSetting LTS as default..." -ForegroundColor Cyan
    fnm default lts-latest
    
    Write-Host "`nActivating LTS version..." -ForegroundColor Cyan
    fnm use lts-latest
    
    # Reload fnm environment after setting default
    fnm env --shell power-shell | Out-String | Invoke-Expression
    
    # Check for npm
    $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
    if ($npmCmd) {
        Write-Host "`nnpm found at: $($npmCmd.Source)" -ForegroundColor Green
        Write-Host "`nInstalling global Node packages..." -ForegroundColor Cyan
        npm install -g typescript ts-node pnpm yarn eslint prettier @fsouza/prettierd
        Write-Host "`nGlobal packages installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "`nERROR: npm not found after fnm setup" -ForegroundColor Red
        Write-Host "Node.js may not have been installed correctly" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "ERROR: fnm not found in PATH" -ForegroundColor Red
    Write-Host "`nPossible issues:" -ForegroundColor Yellow
    Write-Host "  1. fnm was not installed via Scoop" -ForegroundColor Yellow
    Write-Host "  2. Scoop shims are not in PATH" -ForegroundColor Yellow
    Write-Host "`nChecking fnm installation locations:" -ForegroundColor Yellow
    
    $possiblePaths = @(
        (Join-Path $env:USERPROFILE 'scoop\apps\fnm'),
        (Join-Path $env:USERPROFILE 'scoop\shims\fnm.exe')
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-Host "  Found: $path" -ForegroundColor Green
        } else {
            Write-Host "  Not found: $path" -ForegroundColor Red
        }
    }
    
    Write-Host "`nTry running: scoop install fnm" -ForegroundColor Cyan
    exit 1
}