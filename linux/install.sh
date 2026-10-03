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

install_packages() {
    echo -e "${YELLOW}→${NC} Installing packages via paru..."
    paru -S --needed \
        zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions starship ghostty tmux \
        git-delta fzf zoxide bat ripgrep fd jq eza \
        neovim lazygit github-cli \
        fnm-bin opencode-bin dotnet-sdk \
        docker docker-compose docker-buildx
    echo -e "${GREEN}✓${NC} Packages installed"
}

setup_zsh_shell() {
    echo -e "${YELLOW}→${NC} Checking default shell..."
    ZSH_PATH="/usr/bin/zsh"

    # Check the login shell from the user database, not $SHELL: $SHELL
    # reflects the current session and can lag behind a recent chsh.
    local current_shell
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"

    if [ "$current_shell" != "$ZSH_PATH" ]; then
        chsh -s "$ZSH_PATH"
        echo -e "${GREEN}✓${NC} Default shell set to Zsh (log out and back in to apply)"
    else
        echo -e "${GREEN}✓${NC} Zsh is already the default shell"
    fi
}

run_dotbot() {
    echo -e "${YELLOW}→${NC} Running dotbot..."
    chmod +x dotbot/bin/dotbot
    SHELL=/bin/bash ./dotbot/bin/dotbot -d . -c install.conf.yaml
    echo -e "${GREEN}✓${NC} Dotbot complete"
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

setup_docker() {
    echo -e "${YELLOW}→${NC} Setting up Docker..."
    sudo systemctl enable --now docker.service

    if ! id -nG "$USER" | grep -qw docker; then
        sudo usermod -aG docker "$USER"
        echo -e "${GREEN}✓${NC} Added $USER to the docker group (log out and back in to apply)"
    else
        echo -e "${GREEN}✓${NC} $USER is already in the docker group"
    fi
}

install_fonts() {
    echo -e "${YELLOW}→${NC} Installing JetBrainsMono Nerd Font..."
    mkdir -p ~/.local/share/fonts
    if [ ! -f ~/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf ]; then
        curl -fLo /tmp/JetBrainsMono.zip \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
        rm /tmp/JetBrainsMono.zip
        fc-cache -f
    fi
    echo -e "${GREEN}✓${NC} Fonts installed"
}

final_setup() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Installation Complete!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit ~/.gitconfig-local with your name and email"
    echo "  2. Log out and back in (applies Zsh as default shell and docker group)"
    echo "  3. Launch Ghostty"
    echo ""
    echo -e "${BLUE}Installed tools:${NC}"
    command -v git      &> /dev/null && echo "  ✓ git $(git --version | cut -d' ' -f3)"
    command -v nvim     &> /dev/null && echo "  ✓ neovim $(nvim --version | head -n1 | cut -d' ' -f2)"
    command -v zsh      &> /dev/null && echo "  ✓ zsh $(zsh --version | cut -d' ' -f2)"
    command -v starship &> /dev/null && echo "  ✓ starship $(starship --version | cut -d' ' -f2)"
    command -v tmux     &> /dev/null && echo "  ✓ tmux $(tmux -V | cut -d' ' -f2)"
    command -v docker   &> /dev/null && echo "  ✓ docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
    echo ""
}

main() {
    check_prerequisites
    install_packages
    setup_zsh_shell
    run_dotbot
    setup_git
    setup_docker
    install_fonts
    final_setup
}

if main "$@"; then
    exit 0
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
