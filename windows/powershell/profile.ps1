# PowerShell 7 profile (Windows). Mirrors shared/zsh/zshrc where it makes sense.
# Linked to ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.

# --- paths ---
$localBin = Join-Path $HOME ".local\bin"
if (($env:Path -split ";") -notcontains $localBin) {
    $env:Path = "$localBin;$env:Path"
}

# --- XDG-compliant tool locations (nvim, lazygit, ... read ~/.config) ---
$env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
$env:NUGET_PACKAGES = Join-Path $HOME ".cache\NuGet\packages"

# --- line editing: fish-style suggestions, highlighting, menu completion ---
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -MaximumHistoryCount 50000
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -Colors @{
        Command          = "#89b4fa"
        Parameter        = "#94e2d5"
        String           = "#a6e3a1"
        Number           = "#fab387"
        Variable         = "#f5e0dc"
        Operator         = "#89dceb"
        Comment          = "#6c7086"
        Keyword          = "#cba6f7"
        Error            = "#f38ba8"
        InlinePrediction = "#6c7086"
    }

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete         # like zsh `menu select`
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord   # accept next word of suggestion
}

# --- tools ---
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
}
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}
# Ctrl+R history search and Ctrl+T file search via fzf (Install-Module PSFzf)
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider "Ctrl+t" -PSReadlineChordReverseHistory "Ctrl+r"
}

# --- aliases ---
# modern ls via eza (functions, since PowerShell aliases can't take arguments)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza -al --color=always --group-directories-first --icons=always @args }
    function la { eza -a --color=always --group-directories-first --icons=always @args }
    function ll { eza -l --color=always --group-directories-first --icons=always @args }
    function lt { eza -aT --color=always --group-directories-first --icons=always @args }
}
# cd navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }

# --- greeting: system info on every new shell ---
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch
}
