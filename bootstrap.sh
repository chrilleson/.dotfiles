#!/usr/bin/env bash
#
# Bootstrap dotfiles on a new macOS or Arch-based Linux machine:
# check prerequisites, clone (or update) the repo, then run the OS install script.
#
#   curl -fsSL https://raw.githubusercontent.com/chrilleson/.dotfiles/main/bootstrap.sh | bash
#
# Environment:
#   DOTFILES_DIR           where to clone (default: ~/dev/repositories/personal/.dotfiles)
#   DOTFILES_SKIP_INSTALL  set to 1 to only check prerequisites and clone
#
# Everything runs from main() at the bottom, so a partial download does nothing.

set -euo pipefail

REPO_URL="https://github.com/chrilleson/.dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dev/repositories/personal/.dotfiles}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

step() { echo -e "${YELLOW}→${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }
fail() { echo -e "${RED}✗ $*${NC}" >&2; exit 1; }

# With `curl | bash`, stdin is the script itself, so read answers from the terminal
ask() {
    local answer
    [ -r /dev/tty ] || fail "No terminal to ask on; install the prerequisites above and re-run"
    read -r -p "$1 [y/N] " answer < /dev/tty
    [[ "$answer" =~ ^[Yy]$ ]]
}

check_macos() {
    step "Checking Xcode Command Line Tools (git, python3)..."
    if ! xcode-select -p &> /dev/null; then
        xcode-select --install || true
        echo ""
        echo "  The Command Line Tools installer has opened in a separate window."
        echo "  Re-run this script once it has finished."
        exit 1
    fi
    ok "Command Line Tools installed"
}

check_arch() {
    command -v pacman &> /dev/null || fail "Only Arch-based Linux distros are supported (no pacman found)"

    step "Checking git, python and base-devel..."
    local missing=()
    for pkg in git python base-devel; do
        pacman -Qq "$pkg" &> /dev/null || missing+=("$pkg")
    done
    if [ ${#missing[@]} -ne 0 ]; then
        echo "  Missing: ${missing[*]}"
        ask "Install them with pacman?" || fail "Install them with: sudo pacman -S --needed ${missing[*]}"
        sudo pacman -S --needed "${missing[@]}" < /dev/tty
    fi
    ok "git, python and base-devel installed"

    step "Checking paru (AUR helper)..."
    if ! command -v paru &> /dev/null; then
        ask "paru is missing. Build and install it from the AUR (paru-bin)?" ||
            fail "Install paru: https://github.com/Morganamilo/paru#installation"
        local build_dir
        build_dir="$(mktemp -d)"
        git clone https://aur.archlinux.org/paru-bin.git "$build_dir/paru-bin"
        (cd "$build_dir/paru-bin" && makepkg -si < /dev/tty)
        rm -rf "$build_dir"
    fi
    ok "paru installed"
}

clone_repo() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        step "Updating existing clone in $DOTFILES_DIR..."
        git -C "$DOTFILES_DIR" pull --ff-only
    elif [ -e "$DOTFILES_DIR" ]; then
        fail "$DOTFILES_DIR exists but isn't a git clone; move it or set DOTFILES_DIR"
    else
        local parent
        parent="$(dirname "$DOTFILES_DIR")"
        if [ ! -d "$parent" ]; then
            ask "$parent doesn't exist. Create it?" || fail "Create $parent or set DOTFILES_DIR, then re-run"
            mkdir -p "$parent"
        fi
        step "Cloning dotfiles into $DOTFILES_DIR..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
    fi
    ok "Dotfiles in $DOTFILES_DIR"
}

main() {
    echo -e "${BLUE}Dotfiles bootstrap${NC}"
    echo ""

    local os
    case "$(uname -s)" in
        Darwin) os=macos; check_macos ;;
        Linux)  os=linux; check_arch ;;
        *)      fail "Unsupported OS: $(uname -s) (use bootstrap.ps1 on Windows)" ;;
    esac

    clone_repo

    if [ "${DOTFILES_SKIP_INSTALL:-}" = "1" ]; then
        ok "Skipping install (DOTFILES_SKIP_INSTALL=1). Run: $DOTFILES_DIR/$os/install.sh"
        return
    fi

    echo ""
    step "Running $os/install.sh..."
    # stdin from the terminal so sudo/paru/brew prompts work under `curl | bash`
    if [ -r /dev/tty ]; then
        "$DOTFILES_DIR/$os/install.sh" < /dev/tty
    else
        "$DOTFILES_DIR/$os/install.sh"
    fi
}

main "$@"
