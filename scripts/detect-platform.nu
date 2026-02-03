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
