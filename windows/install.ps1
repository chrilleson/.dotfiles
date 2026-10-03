# Windows installation script for dotfiles.
#
# Runs in Windows PowerShell 5.1 (preinstalled) or PowerShell 7, so keep it
# 5.1-compatible and ASCII-only (5.1 misreads UTF-8 files without a BOM).
#
#   .\windows\install.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

function Step($msg) { Write-Host "-> $msg" -ForegroundColor Yellow }
function Ok($msg) { Write-Host "OK $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "X  $msg" -ForegroundColor Red; exit 1 }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     Dotfiles Installation Script"         -ForegroundColor Cyan
Write-Host "              Windows"                     -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- prerequisites ---
& (Join-Path $PSScriptRoot "validate-prereqs.ps1")
if ($LASTEXITCODE -ne 0) { exit 1 }

# Prefer the py launcher; `python` may be the Microsoft Store placeholder
if (Get-Command py -ErrorAction SilentlyContinue) {
    $Python = @("py", "-3")
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $Python = @("python")
} else {
    Fail "Cannot find Python"
}
function Invoke-Python {
    $exe, $pre = $Python
    & $exe @pre @args
}

# --- environment ---
# Persistent user env changes only reach terminals started afterwards
$EnvChanged = $false

Step "Adding ~/.local/bin to your user PATH..."
$LocalBin = Join-Path $HOME ".local\bin"
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (($UserPath -split ";") -notcontains $LocalBin) {
    [Environment]::SetEnvironmentVariable("Path", "$LocalBin;$UserPath", "User")
    $EnvChanged = $true
}
if (($env:Path -split ";") -notcontains $LocalBin) {
    $env:Path = "$LocalBin;$env:Path"
}
Ok "~/.local/bin is on PATH"

# Neovim, lazygit and others read ~/.config when this is set (also when started outside a shell)
Step "Setting XDG_CONFIG_HOME..."
$ConfigHome = Join-Path $HOME ".config"
if ([Environment]::GetEnvironmentVariable("XDG_CONFIG_HOME", "User") -ne $ConfigHome) {
    [Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $ConfigHome, "User")
    $EnvChanged = $true
}
$env:XDG_CONFIG_HOME = $ConfigHome
Ok "XDG_CONFIG_HOME = $ConfigHome"

# --- packages and links (tools.yaml, install.conf.yaml) ---
Step "Installing tools and linking configs..."
Invoke-Python (Join-Path $RepoRoot "shared\bin\dotfiles") install --all --yes
if ($LASTEXITCODE -ne 0) { Fail "dotfiles install failed" }

# Documents is often redirected to OneDrive; link the profile where PowerShell 7 looks for it
$Documents = [Environment]::GetFolderPath("MyDocuments")
$ProfilePath = Join-Path $Documents "PowerShell\Microsoft.PowerShell_profile.ps1"
if (($Documents -ne (Join-Path $HOME "Documents")) -and -not (Test-Path $ProfilePath)) {
    Step "Linking PowerShell profile into $Documents..."
    New-Item -ItemType Directory -Force -Path (Split-Path $ProfilePath) | Out-Null
    New-Item -ItemType SymbolicLink -Path $ProfilePath -Target (Join-Path $RepoRoot "windows\powershell\profile.ps1") | Out-Null
    Ok "Linked $ProfilePath"
}

# --- Node.js ---
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    Step "Installing Node.js LTS via fnm..."
    fnm env --shell powershell | Out-String | Invoke-Expression
    fnm install --lts
    fnm default lts-latest
    fnm use lts-latest
    Ok "Node.js $(node --version)"

    Step "Installing global npm packages..."
    $installed = @()
    # via cmd: with ErrorAction Stop, 5.1 aborts on redirected native stderr
    $list = cmd /c "npm list -g --depth=0 --json 2>nul" | Out-String | ConvertFrom-Json
    if ($list.dependencies) { $installed = $list.dependencies.PSObject.Properties.Name }
    foreach ($pkg in @("@fsouza/prettierd", "eslint", "prettier", "typescript", "ts-node", "pnpm", "yarn")) {
        if ($installed -notcontains $pkg) {
            npm install -g $pkg --no-audit
        }
    }
    Ok "Global npm packages installed"
}

# --- done ---
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "       Installation Complete!"             -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
# Each next step is shown only when it still applies
$NextSteps = @()
$GitconfigLocal = Join-Path $HOME ".gitconfig-local"
if (-not (Test-Path $GitconfigLocal)) {
    $NextSteps += "Create ~/.gitconfig-local from shared/git/gitconfig-local.example and add your name and email"
} elseif (Select-String -Path $GitconfigLocal -Pattern 'Your Name|your\.email@example\.com' -Quiet) {
    $NextSteps += "Edit ~/.gitconfig-local with your name and email"
}
if ($EnvChanged) {
    $NextSteps += "Restart your terminal (picks up PATH and XDG_CONFIG_HOME)"
}
if (-not $env:WEZTERM_EXECUTABLE) {
    $NextSteps += "Launch WezTerm (starts PowerShell 7)"
}

if ($NextSteps.Count -eq 0) {
    Write-Host "Nothing left to do: you're all set." -ForegroundColor Green
} else {
    Write-Host "Next steps:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $NextSteps.Count; $i++) {
        Write-Host "  $($i + 1). $($NextSteps[$i])"
    }
}
Write-Host ""
