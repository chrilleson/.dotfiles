# env.nu
#
# Installed by:
# version = "0.103.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

use std "path add"

# Add Scoop shims to PATH to ensure fnm is available
let scoop_shims = $"($env.USERPROFILE)\\scoop\\shims"
if ($scoop_shims | path exists) {
    $env.Path = ($env.Path | prepend $scoop_shims)
}

# fnm (Fast Node Manager)
# Check if fnm is available before trying to use it
if (which fnm | is-not-empty) {
    # Load fnm environment
    try {
        let fnm_env = (fnm env --json | from json)
        
        # Set FNM environment variables
        $env.FNM_MULTISHELL_PATH = $fnm_env.FNM_MULTISHELL_PATH
        $env.FNM_VERSION_FILE_STRATEGY = $fnm_env.FNM_VERSION_FILE_STRATEGY
        $env.FNM_DIR = $fnm_env.FNM_DIR
        $env.FNM_LOGLEVEL = $fnm_env.FNM_LOGLEVEL
        $env.FNM_NODE_DIST_MIRROR = $fnm_env.FNM_NODE_DIST_MIRROR
        $env.FNM_COREPACK_ENABLED = $fnm_env.FNM_COREPACK_ENABLED
        $env.FNM_RESOLVE_ENGINES = $fnm_env.FNM_RESOLVE_ENGINES
        $env.FNM_ARCH = $fnm_env.FNM_ARCH
        
        # Add fnm's Node.js binaries to PATH (prepend to override other Node installations)
        $env.Path = ($env.Path | prepend $env.FNM_MULTISHELL_PATH)
    } catch {
        # If fnm env fails, just skip it silently
    }
}