# Validate prerequisites before installation
$ErrorActionPreference = "Stop"

Write-Host "`n=== Validating Prerequisites ===`n" -ForegroundColor Cyan

$allChecksPassed = $true

# Check Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "✓ Git is installed" -ForegroundColor Green
} else {
    Write-Host "✗ Git is not installed" -ForegroundColor Red
    Write-Host "  Install from: https://git-scm.com/`n" -ForegroundColor Cyan
    $allChecksPassed = $false
}

# Check Python
$pythonFound = $false
foreach ($pythonCmd in @('python', 'python3')) {
    if (Get-Command $pythonCmd -ErrorAction SilentlyContinue) {
        $pythonFound = $true
        break
    }
}

if ($pythonFound) {
    Write-Host "✓ Python is installed" -ForegroundColor Green
} else {
    Write-Host "✗ Python is not installed" -ForegroundColor Red
    Write-Host "  Install from: https://www.python.org/`n" -ForegroundColor Cyan
    $allChecksPassed = $false
}

# Check Scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "✓ Scoop is installed" -ForegroundColor Green
} else {
    Write-Host "✗ Scoop is not installed" -ForegroundColor Red
    Write-Host "  Install with PowerShell:" -ForegroundColor Cyan
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
    Write-Host "  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression`n" -ForegroundColor Cyan
    $allChecksPassed = $false
}

# Check symlink permissions
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$devMode = $false
try {
    $regValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    if ($regValue.AllowDevelopmentWithoutDevLicense -eq 1) {
        $devMode = $true
    }
} catch {
    $devMode = $false
}

if ($isAdmin -or $devMode) {
    Write-Host "✓ Symlink permissions available" -ForegroundColor Green
} else {
    Write-Host "⚠ Symlink permissions may be limited" -ForegroundColor Yellow
    Write-Host "  Warning: You may need to enable Developer Mode or run as Administrator" -ForegroundColor Yellow
    Write-Host "  Enable Developer Mode: Settings → Privacy & Security → For developers → Developer Mode`n" -ForegroundColor Yellow
}

Write-Host ""

if ($allChecksPassed) {
    Write-Host "✓ All prerequisites are installed!`n" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Some prerequisites are missing. Please install them and try again.`n" -ForegroundColor Red
    exit 1
}
