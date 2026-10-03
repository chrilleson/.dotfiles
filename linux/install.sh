#!/usr/bin/env bash
#
# Linux (Arch-based) installation script for dotfiles
#

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Dotfiles Installation Script      ║${NC}"
echo -e "${BLUE}║              Linux                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Next steps shown at the end; each is added only when it still applies
NEXT_STEPS=()
next_step() { NEXT_STEPS+=("$1"); }

gitconfig_needs_editing() {
    [ ! -f ~/.gitconfig-local ] || grep -qE 'Your Name|your\.email@example\.com' ~/.gitconfig-local
}

# Ghostty sets GHOSTTY_RESOURCES_DIR, which survives inside tmux (TERM_PROGRAM doesn't)
in_ghostty() {
    [ "${TERM_PROGRAM:-}" = "ghostty" ] || [ -n "${GHOSTTY_RESOURCES_DIR:-}" ]
}

print_next_steps() {
    if [ ${#NEXT_STEPS[@]} -eq 0 ]; then
        echo -e "${GREEN}Nothing left to do: you're all set.${NC}"
        return
    fi
    echo -e "${BLUE}Next steps:${NC}"
    local i
    for i in "${!NEXT_STEPS[@]}"; do
        echo "  $((i + 1)). ${NEXT_STEPS[$i]}"
    done
}

check_prerequisites() {
    echo -e "${YELLOW}→${NC} Checking prerequisites..."
    local missing=()

    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi

    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}✗ Missing prerequisites: ${missing[*]}${NC}"
        echo "  sudo pacman -S --needed ${missing[*]}"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} All prerequisites met"
}

ensure_pyyaml() {
    if ! python3 -c 'import yaml' &> /dev/null; then
        echo -e "${YELLOW}→${NC} Installing PyYAML (needed by dotbot and the dotfiles CLI)..."
        sudo pacman -S --needed python-yaml
    fi
    echo -e "${GREEN}✓${NC} PyYAML ready"
}

# Packages, links and per-tool setup (docker, fonts) are defined in tools.yaml
install_tools() {
    echo -e "${YELLOW}→${NC} Installing tools and linking configs..."
    ./shared/bin/dotfiles install --all --yes
}

setup_zsh_shell() {
    echo -e "${YELLOW}→${NC} Checking default shell..."
    ZSH_PATH="/usr/bin/zsh"

    # zsh is a prerequisite, not a tool, so `dotfiles reset` never removes the login shell
    paru -S --needed zsh

    # Check the login shell from the user database, not $SHELL: $SHELL
    # reflects the current session and can lag behind a recent chsh.
    local current_shell
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"

    if [ "$current_shell" != "$ZSH_PATH" ]; then
        chsh -s "$ZSH_PATH"
        echo -e "${GREEN}✓${NC} Default shell set to Zsh (log out and back in to apply)"
        SHELL_CHANGED=1
    else
        echo -e "${GREEN}✓${NC} Zsh is already the default shell"
    fi
}

setup_git() {
    if [ ! -f ~/.gitconfig-local ]; then
        echo -e "${YELLOW}→${NC} Creating ~/.gitconfig-local..."
        cp shared/git/gitconfig-local.example ~/.gitconfig-local
        echo -e "${GREEN}✓${NC} Created ~/.gitconfig-local"
        echo -e "${BLUE}ℹ${NC} Please edit ~/.gitconfig-local with your name and email"
    else
        echo -e "${GREEN}✓${NC} ~/.gitconfig-local already exists"
    fi
}

final_setup() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Installation Complete!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    gitconfig_needs_editing && next_step "Edit ~/.gitconfig-local with your name and email"

    # Group changes only reach new sessions: compare the user database with this session
    local relog=()
    [ "${SHELL_CHANGED:-}" = "1" ] && relog+=("Zsh as default shell")
    if id -nG "$USER" | grep -qw docker && ! id -nG | grep -qw docker; then
        relog+=("docker group")
    fi
    if [ ${#relog[@]} -ne 0 ]; then
        local joined
        joined="$(printf '%s and ' "${relog[@]}")"
        next_step "Log out and back in (applies ${joined% and })"
    fi

    in_ghostty || next_step "Launch Ghostty"
    print_next_steps
    echo ""
    echo -e "${BLUE}Installed tools:${NC}"
    command -v git      &> /dev/null && echo "  ✓ git $(git --version | cut -d' ' -f3)"
    command -v nvim     &> /dev/null && echo "  ✓ neovim $(nvim --version | head -n1 | cut -d' ' -f2)"
    command -v zsh      &> /dev/null && echo "  ✓ zsh $(zsh --version | cut -d' ' -f2)"
    command -v starship &> /dev/null && echo "  ✓ starship $(starship --version | head -n1 | cut -d' ' -f2)"
    command -v tmux     &> /dev/null && echo "  ✓ tmux $(tmux -V | cut -d' ' -f2)"
    command -v docker   &> /dev/null && echo "  ✓ docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
    echo ""
}

main() {
    check_prerequisites
    ensure_pyyaml
    setup_zsh_shell
    install_tools
    setup_git
    final_setup
}

if main "$@"; then
    exit 0
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
