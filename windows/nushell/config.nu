# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

$env.config.shell_integration.osc133 = false

# nushell/env.nu additions

# Detect OS
let os_type = (sys).host.name

# Set config paths based on OS
$env.XDG_CONFIG_HOME = if $os_type == "Windows" {
    $"($env.APPDATA)"
} else {
    $"($env.HOME)/.config"
}

$env.XDG_DATA_HOME = if $os_type == "Windows" {
    $"($env.LOCALAPPDATA)"
} else {
    $"($env.HOME)/.local/share"
}

# Add to PATH
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | append ($env.XDG_DATA_HOME + "/nvim/mason/bin")
    | append ($env.HOME + "/.local/bin")
    | uniq
)
