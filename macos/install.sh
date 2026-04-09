#!/usr/bin/env bash
#
# macOS installation script for dotfiles
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
echo -e "${BLUE}║              macOS                    ║${NC}"
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
        echo "  Install Xcode Command Line Tools: xcode-select --install"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} All prerequisites met"
}

install_homebrew() {
    echo -e "${YELLOW}→${NC} Checking Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}→${NC} Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Add Homebrew to PATH for this session (Apple Silicon / Intel)
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo -e "${GREEN}✓${NC} Homebrew ready"
}

install_packages() {
    echo -e "${YELLOW}→${NC} Installing packages via Homebrew..."
    brew install \
        fish starship tmux \
        git-delta fzf zoxide bat ripgrep fd jq eza \
        neovim lazygit gh fnm \
        anomalyco/tap/opencode

    brew install --cask ghostty font-jetbrains-mono-nerd-font

    echo -e "${GREEN}✓${NC} Packages installed"
}

setup_fish_shell() {
    echo -e "${YELLOW}→${NC} Setting Fish as default shell..."
    FISH_PATH="$(command -v fish)"

    if ! grep -qF "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi

    if [ "$SHELL" != "$FISH_PATH" ]; then
        chsh -s "$FISH_PATH"
        echo -e "${GREEN}✓${NC} Default shell set to Fish"
    else
        echo -e "${GREEN}✓${NC} Fish is already the default shell"
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

final_setup() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Installation Complete!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit ~/.gitconfig-local with your name and email"
    echo "  2. Restart your terminal (Fish is now the default shell)"
    echo "  3. Launch Ghostty"
    echo ""
    echo -e "${BLUE}Installed tools:${NC}"
    command -v git      &> /dev/null && echo "  ✓ git $(git --version | cut -d' ' -f3)"
    command -v nvim     &> /dev/null && echo "  ✓ neovim $(nvim --version | head -n1 | cut -d' ' -f2)"
    command -v fish     &> /dev/null && echo "  ✓ fish $(fish --version)"
    command -v starship &> /dev/null && echo "  ✓ starship $(starship --version | cut -d' ' -f2)"
    command -v tmux     &> /dev/null && echo "  ✓ tmux $(tmux -V | cut -d' ' -f2)"
    echo ""
}

main() {
    check_prerequisites
    install_homebrew
    install_packages
    setup_fish_shell
    run_dotbot
    setup_git
    final_setup
}

if main "$@"; then
    exit 0
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
