# Validate prerequisites before installation (called by install.ps1).
# 5.1-compatible and ASCII-only, like install.ps1.

Write-Host "=== Validating Prerequisites ===" -ForegroundColor Cyan
Write-Host ""

$allChecksPassed = $true

function Pass($msg) { Write-Host "OK $msg" -ForegroundColor Green }
function Miss($msg, $hint) {
    Write-Host "X  $msg" -ForegroundColor Red
    Write-Host "   $hint" -ForegroundColor Cyan
    $script:allChecksPassed = $false
}

# Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    Pass "Git is installed"
} else {
    Miss "Git is not installed" "Install from: https://git-scm.com/"
}

# Python (required by dotbot and the dotfiles CLI)
$python = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
    $python = @("py", "-3")
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $python = @("python")
}

if ($python) {
    Pass "Python is installed"

    # PyYAML
    $exe, $pre = $python
    & $exe @pre -c "import yaml" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Pass "PyYAML is installed"
    } else {
        Miss "PyYAML is not installed" "Install with: $($python -join ' ') -m pip install pyyaml"
    }
} else {
    Miss "Python is not installed" "Install from: https://www.python.org/ (includes the py launcher)"
}

# Scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Pass "Scoop is installed"
} else {
    Miss "Scoop is not installed" "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
}

# Symlink permissions (Developer Mode or admin)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$devMode = $false
$regValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
if ($regValue -and $regValue.AllowDevelopmentWithoutDevLicense -eq 1) { $devMode = $true }

if ($isAdmin -or $devMode) {
    Pass "Symlink permissions available"
} else {
    Write-Host "!  Symlink permissions may be limited" -ForegroundColor Yellow
    Write-Host "   Enable Developer Mode: Settings > Privacy & Security > For developers > Developer Mode" -ForegroundColor Yellow
}

Write-Host ""
if ($allChecksPassed) {
    Write-Host "All prerequisites met" -ForegroundColor Green
    Write-Host ""
    exit 0
}
Write-Host "Some prerequisites are missing. Install them and try again." -ForegroundColor Red
Write-Host ""
exit 1
