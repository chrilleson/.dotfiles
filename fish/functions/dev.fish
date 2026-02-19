function dev --description "Open or attach to a tmux dev session for the current directory"
    set session (basename (pwd))

    if not tmux has-session -t $session 2>/dev/null
        tmux new-session -d -s $session -n editor
        tmux new-window -t $session -n server
        tmux new-window -t $session -n git
        tmux new-window -t $session -n misc
        tmux select-window -t $session:editor
    end

    if test -n "$TMUX"
        tmux switch-client -t $session
    else
        tmux attach -t $session
    end
end
