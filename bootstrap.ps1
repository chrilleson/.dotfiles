# Bootstrap dotfiles on a new Windows machine: check prerequisites, clone (or update)
# the repo, then run windows\install.ps1.
#
#   irm https://raw.githubusercontent.com/chrilleson/.dotfiles/main/bootstrap.ps1 | iex
#
# Environment:
#   DOTFILES_DIR           where to clone (default: ~\dev\repositories\personal\.dotfiles)
#   DOTFILES_SKIP_INSTALL  set to 1 to only check prerequisites and clone
#
# Runs in Windows PowerShell 5.1 or PowerShell 7; 5.1-compatible and ASCII-only.
# Everything runs from Main at the bottom, so a partial download does nothing.

function Main {
    $ErrorActionPreference = "Stop"

    $RepoUrl = "https://github.com/chrilleson/.dotfiles.git"
    $DotfilesDir = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME "dev\repositories\personal\.dotfiles" }

    function Step($msg) { Write-Host "-> $msg" -ForegroundColor Yellow }
    function Ok($msg) { Write-Host "OK $msg" -ForegroundColor Green }
    function Fail($msg) { Write-Host "X  $msg" -ForegroundColor Red; throw $msg }
    function Ask($question) { (Read-Host "$question [y/N]") -match '^[Yy]$' }
    function Has($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
    function Refresh-Path {
        $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    }
    function Install-WithWinget($id, $name) {
        if (-not (Has winget)) { Fail "$name is missing and winget isn't available; install $name manually" }
        if (-not (Ask "$name is missing. Install it with winget ($id)?")) { Fail "Install $name and re-run" }
        winget install --id $id --exact --source winget --accept-source-agreements --accept-package-agreements
        Refresh-Path
    }

    Write-Host "Dotfiles bootstrap" -ForegroundColor Cyan
    Write-Host ""

    # Script execution: install.ps1 and the PowerShell profile need RemoteSigned
    Step "Checking PowerShell execution policy..."
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if (@("RemoteSigned", "Unrestricted", "Bypass") -notcontains $policy) {
        if (-not (Ask "Execution policy is '$policy'. Set it to RemoteSigned for your user?")) {
            Fail "Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
        }
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    }
    Ok "Execution policy allows local scripts"

    Step "Checking git..."
    if (-not (Has git)) { Install-WithWinget "Git.Git" "Git" }
    if (-not (Has git)) { Fail "git still not found; open a new terminal and re-run" }
    Ok "git installed"

    Step "Checking Python..."
    if (-not ((Has py) -or (Has python))) { Install-WithWinget "Python.Python.3.12" "Python" }
    if (Has py) { $Python = @("py", "-3") } elseif (Has python) { $Python = @("python") } else {
        Fail "Python still not found; open a new terminal and re-run"
    }
    Ok "Python installed"

    Step "Checking PyYAML..."
    $exe, $pre = $Python
    # 5.1 turns redirected native stderr into errors, which "Stop" would make fatal
    $ErrorActionPreference = "Continue"
    & $exe @pre -c "import yaml" 2>&1 | Out-Null
    $ErrorActionPreference = "Stop"
    if ($LASTEXITCODE -ne 0) {
        if (-not (Ask "PyYAML is missing. Install it with pip?")) { Fail "Run: $($Python -join ' ') -m pip install pyyaml" }
        & $exe @pre -m pip install --user pyyaml
    }
    Ok "PyYAML installed"

    Step "Checking Scoop..."
    if (-not (Has scoop)) {
        if (-not (Ask "Scoop is missing. Install it (get.scoop.sh)?")) { Fail "Install Scoop: https://scoop.sh" }
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Refresh-Path
    }
    Ok "Scoop installed"

    # Clone or update
    if (Test-Path (Join-Path $DotfilesDir ".git")) {
        Step "Updating existing clone in $DotfilesDir..."
        git -C $DotfilesDir pull --ff-only
    } elseif (Test-Path $DotfilesDir) {
        Fail "$DotfilesDir exists but isn't a git clone; move it or set DOTFILES_DIR"
    } else {
        $parent = Split-Path -Parent $DotfilesDir
        if (-not (Test-Path $parent)) {
            if (-not (Ask "$parent doesn't exist. Create it?")) { Fail "Create $parent or set DOTFILES_DIR, then re-run" }
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        Step "Cloning dotfiles into $DotfilesDir..."
        git clone $RepoUrl $DotfilesDir
    }
    if ($LASTEXITCODE -ne 0) { Fail "git failed" }
    Ok "Dotfiles in $DotfilesDir"

    if ($env:DOTFILES_SKIP_INSTALL -eq "1") {
        Ok "Skipping install (DOTFILES_SKIP_INSTALL=1). Run: $DotfilesDir\windows\install.ps1"
        return
    }

    Write-Host ""
    Step "Running windows\install.ps1..."
    & (Join-Path $DotfilesDir "windows\install.ps1")
}

Main
