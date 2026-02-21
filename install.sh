#!/usr/bin/env bash
#
# Linux/macOS installation script for dotfiles
# This replaces the Windows-specific install.ps1
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS
OS="unknown"
DISTRO="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    DISTRO="macos"
fi

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Dotfiles Installation Script      ║${NC}"
echo -e "${BLUE}║            for $OS                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
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
        echo ""
        echo "Please install them first:"
        
        case "$DISTRO" in
            ubuntu|debian)
                echo "  sudo apt update && sudo apt install -y ${missing[*]}"
                ;;
            fedora)
                echo "  sudo dnf install -y ${missing[*]}"
                ;;
            arch|manjaro)
                echo "  sudo pacman -S --needed ${missing[*]}"
                ;;
            macos)
                echo "  Install Xcode Command Line Tools:"
                echo "  xcode-select --install"
                ;;
        esac
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} All prerequisites met"
}

# Install Homebrew (optional but recommended)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}→${NC} Homebrew not found"
        echo -e "  Homebrew provides a consistent package experience across platforms."
        read -p "  Install Homebrew? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}→${NC} Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add to PATH
            if [ "$OS" = "linux" ]; then
                echo -e "${YELLOW}→${NC} Adding Homebrew to PATH..."
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                
                # Install build dependencies on Linux
                sudo apt-get install -y build-essential || \
                sudo dnf groupinstall -y 'Development Tools' || \
                sudo pacman -S --needed base-devel
            elif [ "$OS" = "macos" ]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
            
            echo -e "${GREEN}✓${NC} Homebrew installed"
        else
            echo -e "${BLUE}ℹ${NC} Skipping Homebrew installation"
        fi
    else
        echo -e "${GREEN}✓${NC} Homebrew already installed"
    fi
}

# Install packages using Homebrew
install_with_homebrew() {
    if ! command -v brew &> /dev/null; then
        return 1
    fi
    
    echo -e "${YELLOW}→${NC} Installing packages via Homebrew..."
    
    # Create Brewfile if it doesn't exist
    if [ ! -f "Brewfile" ]; then
        cat > Brewfile << 'EOF'
# Core utilities
brew "git"
brew "git-delta"
brew "fzf"
brew "fd"
brew "ripgrep"
brew "bat"
brew "zoxide"
brew "jq"
brew "eza"

# Development
brew "neovim"
brew "starship"
brew "node"
brew "fnm"

# Additional tools
brew "lazygit"
brew "gh"
EOF
    fi
    
    brew bundle --file=Brewfile || true
    echo -e "${GREEN}✓${NC} Homebrew packages installed"
    return 0
}

# Install packages using native package managers
install_native_packages() {
    echo -e "${YELLOW}→${NC} Installing packages via system package manager..."
    
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y \
                git git-delta fzf fd-find ripgrep bat \
                neovim nodejs npm curl wget \
                build-essential python3-pip
            
            # Some packages need different names or manual installation
            if ! command -v zoxide &> /dev/null; then
                echo -e "${YELLOW}→${NC} Installing zoxide via cargo..."
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source "$HOME/.cargo/env"
                cargo install zoxide
            fi
            
            if ! command -v starship &> /dev/null; then
                echo -e "${YELLOW}→${NC} Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
            
        fedora)
            sudo dnf install -y \
                git git-delta fzf fd-find ripgrep bat zoxide \
                neovim nodejs npm curl wget \
                gcc gcc-c++ make python3-pip
            
            if ! command -v starship &> /dev/null; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
            
        arch|manjaro)
            sudo pacman -S --needed \
                git delta fzf fd ripgrep bat zoxide \
                neovim nodejs npm curl wget \
                base-devel python-pip starship
            ;;
            
        *)
            echo -e "${YELLOW}⚠${NC} Unknown distribution. Please install packages manually."
            return 1
            ;;
    esac
    
    echo -e "${GREEN}✓${NC} System packages installed"
}

# Install packages
install_packages() {
    if command -v brew &> /dev/null; then
        install_with_homebrew
    else
        install_native_packages
    fi
}

# Run dotbot
run_dotbot() {
    echo -e "${YELLOW}→${NC} Running dotbot installation..."
    
    # Make dotbot executable
    chmod +x dotbot/bin/dotbot
    
    # Run dotbot
    ./dotbot/bin/dotbot -d . -c install.conf.yaml
    
    echo -e "${GREEN}✓${NC} Dotbot installation complete"
}

# Setup Git config
setup_git() {
    if [ ! -f ~/.gitconfig-local ]; then
        echo -e "${YELLOW}→${NC} Creating Git local configuration..."
        cp shared/git/gitconfig-local.example ~/.gitconfig-local
        echo -e "${GREEN}✓${NC} Created ~/.gitconfig-local"
        echo -e "${BLUE}ℹ${NC} Please edit ~/.gitconfig-local with your name and email"
    else
        echo -e "${GREEN}✓${NC} Git local configuration already exists"
    fi
}

# Install Node.js and global packages
install_node() {
    echo -e "${YELLOW}→${NC} Setting up Node.js..."
    
    # Install fnm if not present
    if ! command -v fnm &> /dev/null; then
        if command -v brew &> /dev/null; then
            brew install fnm
        else
            curl -fsSL https://fnm.vercel.app/install | bash
            export PATH="$HOME/.local/share/fnm:$PATH"
            eval "$(fnm env)"
        fi
    fi
    
    # Install and use LTS Node
    fnm install --lts
    fnm use lts-latest
    
    echo -e "${YELLOW}→${NC} Installing global npm packages..."
    npm install -g \
        typescript ts-node \
        pnpm yarn \
        eslint prettier prettierd \
        neovim
    
    echo -e "${GREEN}✓${NC} Node.js setup complete"
}

# Install Nerd Fonts
install_fonts() {
    echo -e "${YELLOW}→${NC} Installing JetBrainsMono Nerd Font..."
    
    if [ "$OS" = "macos" ]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
    elif [ "$OS" = "linux" ]; then
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts
        
        if [ ! -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
            curl -fLo "JetBrainsMonoNerdFont.zip" \
                https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
            unzip -o JetBrainsMonoNerdFont.zip -d JetBrainsMono
            rm JetBrainsMonoNerdFont.zip
            fc-cache -f -v
        fi
        
        cd - > /dev/null
    fi
    
    echo -e "${GREEN}✓${NC} Fonts installed"
}

# Final setup
final_setup() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    Installation Complete! 🎉          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit ~/.gitconfig-local with your name and email"
    echo "  2. Launch Ghostty"
    echo "  3. Start Fish: chsh -s $(which fish)"
    echo ""
    echo -e "${BLUE}Installed tools:${NC}"
    command -v git && echo "  ✓ git $(git --version | cut -d' ' -f3)"
    command -v nvim && echo "  ✓ neovim $(nvim --version | head -n1 | cut -d' ' -f2)"
    command -v fish && echo "  ✓ fish $(fish --version)"
    command -v starship && echo "  ✓ starship $(starship --version | cut -d' ' -f2)"
    command -v node && echo "  ✓ node $(node --version)"
    command -v tmux && echo "  ✓ tmux $(tmux -V | cut -d' ' -f2)"
    echo ""
}

# Main installation flow
main() {
    check_prerequisites
    install_homebrew
    install_packages
    run_dotbot
    setup_git
    install_node
    install_fonts
    final_setup
}

# Run with error handling
if main "$@"; then
    exit 0
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
