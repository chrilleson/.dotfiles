#!/usr/bin/env bash
#
# Fast tmux session switcher (fzf in a display-popup).
# Adapted from https://github.com/RaoH/dotfiles/tree/main/tmux/.config/tmux
#
# Keybindings:
#   enter    = switch to session/window/directory, or create a session from the query
#   ctrl-d   = kill session (window in window mode)
#   ctrl-r   = rename session
#   ctrl-w   = window mode
#   ctrl-p   = projects mode ($TMUX_PROJECTS_DIR, default ~/dev/repositories/*/*)
#   ctrl-z   = zoxide mode
#   ctrl-o   = opencode sessions
#   ctrl-n   = claude sessions
#   ctrl-b   = back to sessions
#   esc      = quit

CURRENT=$(tmux display-message -p '#S')
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$SCRIPT_DIR/session-helper.sh"

SESSIONS_LABEL=' C-d:kill  C-r:rename  C-w:windows  C-p:projects  C-z:zoxide  C-o:opencode  C-n:claude ─╮'
BACK_LABEL=' C-b:back ─╮'
KILL_BACK_LABEL=' C-d:kill  C-b:back ─╮'

# Catppuccin Mocha, matching the status bar
COLORS='bg+:#313244,fg+:#cdd6f4,pointer:#89b4fa,prompt:#89b4fa,border:#7f849c,label:#cdd6f4,input-border:#f9e2af,list-border:#7f849c,header:#6c7086,input-label:#f9e2af,gutter:-1'

"$HELPER" sessions "$CURRENT" | fzf \
    --prompt=' ' \
    --layout=default \
    --no-preview \
    --no-info \
    --highlight-line \
    --border=rounded \
    --border-label=' Sessions ' \
    --border-label-pos=0 \
    --input-border=rounded \
    --input-label="$SESSIONS_LABEL" \
    --input-label-pos=-1 \
    --list-border=rounded \
    --padding=1 \
    --margin=0 \
    --color="$COLORS" \
    --pointer='▌' \
    --gutter=' ' \
    --bind="enter:become('$HELPER' switch {q} {})" \
    --bind="ctrl-d:execute-silent('$HELPER' kill {})+reload('$HELPER' reload '$CURRENT')" \
    --bind="ctrl-r:execute(printf 'New name: ' >&2; read -r name </dev/tty; [ -n \"\$name\" ] && tmux rename-session -t ={1} \"\$name\")+reload('$HELPER' reload '$CURRENT')" \
    --bind="ctrl-w:change-border-label( Windows )+reload('$HELPER' windows '$CURRENT')+change-prompt(  )+change-input-label($KILL_BACK_LABEL)" \
    --bind="ctrl-p:change-border-label( Projects )+reload('$HELPER' projects)+change-prompt(  )+change-input-label($BACK_LABEL)" \
    --bind="ctrl-z:change-border-label( Zoxide )+reload(zoxide query -l 2>/dev/null | head -50)+change-prompt(  )+change-input-label($BACK_LABEL)" \
    --bind="ctrl-o:change-border-label( Opencode )+reload('$HELPER' agents opencode-)+change-prompt(  )+change-input-label($KILL_BACK_LABEL)" \
    --bind="ctrl-n:change-border-label( Claude )+reload('$HELPER' agents claude-)+change-prompt(  )+change-input-label($KILL_BACK_LABEL)" \
    --bind="ctrl-b:change-border-label( Sessions )+reload('$HELPER' sessions '$CURRENT')+change-prompt( )+change-input-label($SESSIONS_LABEL)" \
    --bind='esc:abort' \
    || true
