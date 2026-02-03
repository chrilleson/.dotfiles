# Fast Node Manager (fnm) initialization
# This file is sourced by .bashrc

# Initialize fnm if available
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi
