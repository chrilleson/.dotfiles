# fzf shell integration — key bindings and completion
# Requires fzf >= 0.48 (supports --fish flag)
if command -q fzf
    fzf --fish | source
end
