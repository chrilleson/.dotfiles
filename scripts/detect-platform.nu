#!/usr/bin/env nu

export def main [] {
    let os = (sys).host.name
    
    match $os {
        "Windows" => "windows",
        "Linux" => "linux",
        "Darwin" => "macos",
        _ => "unknown"
    }
}

export def "main is-windows" [] {
    (main) == "windows"
}

export def "main is-linux" [] {
    (main) == "linux"
}

export def "main is-macos" [] {
    (main) == "macos"
}

# Detect Linux distribution
export def "main linux-distro" [] {
    if (main) != "linux" {
        return "not-linux"
    }
    
    let os_release_path = "/etc/os-release"
    
    if not ($os_release_path | path exists) {
        return "unknown"
    }
    
    # Parse /etc/os-release
    let os_release = (open $os_release_path | lines | where {|line| $line =~ "^[A-Z_]+=.*"} | each {|line|
        let parts = ($line | split row "=")
        let key = ($parts | first)
        let value = ($parts | last | str trim -c '"')
        {key: $key, value: $value}
    } | reduce -f {} {|it, acc| $acc | insert $it.key $it.value})
    
    # Return the distribution ID
    if ($os_release.ID? | is-not-empty) {
        $os_release.ID
    } else if ($os_release.ID_LIKE? | is-not-empty) {
        $os_release.ID_LIKE | split row " " | first
    } else {
        "unknown"
    }
}

# Check if running on Arch-based distribution
export def "main is-arch-based" [] {
    if (main) != "linux" {
        return false
    }
    
    let distro = (main linux-distro)
    $distro in ["arch", "cachyos", "manjaro", "endeavouros", "garuda"]
}
