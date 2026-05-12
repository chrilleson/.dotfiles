function tmux-dev
    set session (test -n "$argv[1]" && echo "$argv[1]" || echo "dev")
    set project_path (test -n "$argv[2]" && echo "$argv[2]" || echo "$HOME")
    bash ~/.local/bin/tmux-dev $session $project_path
end
