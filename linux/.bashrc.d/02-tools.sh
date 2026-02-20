# Development tools integration
# This file is sourced by .bashrc

# Zoxide (smart cd) initialization
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# Starship prompt initialization
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# FZF key bindings and completion
if command -v fzf &> /dev/null; then
    # Try to source FZF scripts from common locations
    if [ -f /usr/share/fzf/key-bindings.bash ]; then
        source /usr/share/fzf/key-bindings.bash
    fi
    if [ -f /usr/share/fzf/completion.bash ]; then
        source /usr/share/fzf/completion.bash
    fi
fi

# Aliases for modern tools
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -l'
    alias la='eza -la'
    alias tree='eza --tree'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
fi
