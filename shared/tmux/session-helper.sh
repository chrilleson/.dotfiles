#!/usr/bin/env bash
#
# Helper for session-switcher.sh: produces the fzf lists and handles selections.
# Adapted from https://github.com/RaoH/dotfiles/tree/main/tmux/.config/tmux
#
# Usage: session-helper.sh <action> [args]
#   sessions <current>          regular sessions, minus <current> and agent sessions
#   windows <current>           all windows outside <current>
#   projects                    project directories under $TMUX_PROJECTS_DIR
#   agents <prefix>             sessions whose name starts with <prefix> (claude-)
#   reload <current>            the list for the mode in $FZF_BORDER_LABEL (set by fzf)
#   kill <selection>            kill the selected session or window
#   switch <query> <selection>  switch to a session/window/directory, or create one

set -euo pipefail

PROJECTS_DIR="${TMUX_PROJECTS_DIR:-$HOME/dev/repositories}"
AGENT_SESSIONS='^claude-'

list_sessions() {
    tmux list-sessions -F '#{session_name}|#{session_path}|#{session_windows}w' | column -t -s'|'
}

# tmux rewrites "." and ":" in session names, so sanitize up front
session_name_for() {
    basename "$1" | tr '.: ' '___'
}

action="${1:-}"

case "$action" in
    sessions)
        current="${2:-}"
        list_sessions | awk -v cur="$current" -v agents="$AGENT_SESSIONS" '$1 != cur && $1 !~ agents'
        ;;

    windows)
        current="${2:-}"
        tmux list-windows -a -F '#{session_name}:#{window_index} #{window_name}' |
            awk -v cur="$current" -v agents="$AGENT_SESSIONS" '{ split($1, s, ":") } s[1] != cur && s[1] !~ agents'
        ;;

    projects)
        find "$PROJECTS_DIR" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | sort
        ;;

    agents)
        list_sessions | awk -v prefix="^${2:-}" '$1 ~ prefix'
        ;;

    reload)
        case "${FZF_BORDER_LABEL:-}" in
            *Windows*)  "$0" windows "${2:-}" ;;
            *Projects*) "$0" projects ;;
            *Zoxide*)   zoxide query -l 2>/dev/null | head -50 ;;
            *Claude*)   "$0" agents claude- ;;
            *)          "$0" sessions "${2:-}" ;;
        esac
        ;;

    kill)
        # Directories (projects / zoxide mode) have nothing to kill
        [[ -z "${2:-}" || -d "${2:-}" ]] && exit 0
        target="${2%% *}"
        if [[ "$target" == *:* ]]; then
            tmux kill-window -t "$target"
        else
            tmux kill-session -t "=$target"
        fi
        ;;

    switch)
        query="${2:-}"
        selection="${3:-}"

        # Directory (projects / zoxide mode): open or reuse a session there
        if [[ -n "$selection" && -d "$selection" ]]; then
            name=$(session_name_for "$selection")
            tmux has-session -t "=$name" 2>/dev/null || tmux new-session -ds "$name" -c "$selection"
            tmux switch-client -t "=$name"
            exit 0
        fi

        # Session or window: first column ("name" or "session:index")
        target="${selection%% *}"
        if [[ -n "$target" ]]; then
            if [[ "$target" == *:* ]]; then
                tmux switch-client -t "$target"
            else
                tmux switch-client -t "=$target"
            fi
            exit 0
        fi

        # Nothing matched: create a session named after the query
        [[ -z "$query" ]] && exit 0
        name=$(printf '%s' "$query" | tr '.: ' '___')
        tmux has-session -t "=$name" 2>/dev/null || tmux new-session -ds "$name"
        tmux switch-client -t "=$name"
        ;;

    *)
        echo "usage: $(basename "$0") sessions|windows|projects|agents|switch [args]" >&2
        exit 1
        ;;
esac
