#!/usr/bin/env bash
#
# Attach to a per-directory Claude Code session; run inside a display-popup.
# Adapted from https://github.com/RaoH/dotfiles/tree/main/tmux/.config/tmux
#
# The session is named claude-<dir>-<hash of the full path>, so each directory
# gets its own session that keeps running after the popup closes. The tmux
# binding detaches instead when pressed from inside one, which closes the popup.

set -euo pipefail

# Ask tmux for the directory of the pane under the popup. Don't use $PWD: when
# that directory was deleted or moved, tmux starts the popup in $HOME instead,
# and pane_current_path ends in " (deleted)".
dir=$(tmux display-message -p '#{pane_current_path}')
dir="${dir% (deleted)}"

# Refuse instead of opening in $HOME (not a trusted Claude dir)
if [[ -z "$dir" || ! -d "$dir" ]]; then
    tmux display-message "Claude popup: this pane's directory no longer exists"
    exit 0
fi
if [[ "$dir" -ef "$HOME" ]]; then
    tmux display-message "Claude popup: not opening in ~, cd into a project first"
    exit 0
fi

# cksum is on every Linux and macOS install (md5/md5sum are not)
hash=$(printf '%08x' "$(printf '%s' "$dir" | cksum | cut -d' ' -f1)")
name="claude-$(basename "$dir" | tr '.: ' '___')-$hash"

if ! tmux has-session -t "=$name" 2>/dev/null; then
    # The session command runs in a non-interactive shell that skips ~/.zshrc,
    # where ~/.local/bin (claude's install dir) is added to PATH. tmux gives new
    # panes the PATH of the client that created them, so set it here (-e PATH is ignored).
    PATH="$HOME/.local/bin:$PATH" tmux new-session -ds "$name" -c "$dir" \
        "claude; while echo 'Press Enter to restart Claude or Ctrl-d to close'; read -r; do claude; done"
fi

TMUX= exec tmux attach-session -t "=$name"
