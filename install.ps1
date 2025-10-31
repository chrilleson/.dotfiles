$ErrorActionPreference = "Stop"

$CONFIG = "install.conf.yaml"
$DOTBOT_DIR = "dotbot"

$DOTBOT_BIN = "bin/dotbot"
$BASEDIR = $PSScriptRoot

Set-Location $BASEDIR

# Validate prerequisites
Write-Host "Checking prerequisites..."
& powershell -ExecutionPolicy Bypass -File .\scripts\validate-prerequisites.ps1
if ($LASTEXITCODE -ne 0) {
    exit 1
}

git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --recursive $DOTBOT_DIR

foreach ($PYTHON in ('python', 'python3')) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (& { $ErrorActionPreference = "SilentlyContinue"
            ![string]::IsNullOrEmpty((&$PYTHON -V))
            $ErrorActionPreference = "Stop" }) {
        &$PYTHON $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN) -d $BASEDIR -p dotbot-scoop/scoop.py -c $CONFIG $Args
        
        # Post-install validation
        Write-Host "`n"
        $gitconfigLocal = Join-Path $env:USERPROFILE ".gitconfig-local"
        if (Test-Path $gitconfigLocal) {
            Write-Host "✓ Git configuration is set up correctly" -ForegroundColor Green
        } else {
            Write-Host "⚠ WARNING: ~/.gitconfig-local not found!" -ForegroundColor Yellow
            Write-Host "Please create this file with your personal Git settings:" -ForegroundColor Yellow
            Write-Host "  1. Copy the template: cp git/gitconfig-local.example ~/.gitconfig-local" -ForegroundColor Cyan
            Write-Host "  2. Edit with your details: notepad ~/.gitconfig-local`n" -ForegroundColor Cyan
        }
        
        Write-Host "✓ Installation complete!`n" -ForegroundColor Green
        return
    }
}
Write-Error "Error: Cannot find Python."
