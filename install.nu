#!/usr/bin/env nu
# Dotfiles installation script

def main [...args: string] {
    const CONFIG = "install.conf.yaml"
    const DOTBOT_DIR = "dotbot"
    const DOTBOT_BIN = "bin/dotbot"

    let BASEDIR = $env.PWD

    cd $BASEDIR

    # Update dotbot submodule
    print "Updating dotbot submodule..."
    git -C $DOTBOT_DIR submodule sync --quiet --recursive
    git submodule update --init --recursive $DOTBOT_DIR

    # Find Python executable
    let python = (
        ['python', 'python3'] 
        | where {|cmd| (which $cmd | is-not-empty)} 
        | first
    )

    if ($python | is-empty) {
        print $"(ansi red_bold)Error: Cannot find Python.(ansi reset)"
        exit 1
    }

    # Run dotbot
    print $"Using ($python)..."
    let dotbot_path = ($BASEDIR | path join $DOTBOT_DIR | path join $DOTBOT_BIN)
    ^$python $dotbot_path -d $BASEDIR -p dotbot-scoop/scoop.py -c $CONFIG ...$args
}