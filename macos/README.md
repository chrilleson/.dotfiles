# macOS-Specific Documentation

This directory is a placeholder for macOS-specific configuration and package definitions.

## Current Status

macOS support is planned but not yet implemented. The dotfiles repository currently provides full support for:

- **Windows** - via Scoop package manager
- **Linux** - via pacman/AUR (Arch-based distributions)

## Planned Features

Future macOS support will include:

- **Homebrew** integration for package management
- macOS-specific configuration paths and symlinks
- Apple Silicon (M1/M2/M3) optimizations
- macOS-specific shell configurations (zsh by default)
- Integration with macOS-specific tools (e.g., Rectangle, Alfred)

## Current Workaround

If you're on macOS, you can use the cross-platform `install.sh` script which includes basic Homebrew support:

```bash
./install.sh
```

The `Brewfile` in the root directory provides package definitions that work on macOS:

```bash
brew bundle --file=Brewfile
```

## Contributing

If you'd like to contribute macOS support, please:

1. Create platform-specific scripts in this directory
2. Add macOS package definitions
3. Update platform detection in `scripts/detect-platform.nu`
4. Test on Apple Silicon and Intel Macs
5. Submit a pull request

## Package Management

macOS will use **Homebrew** as the primary package manager:

- **brew** - Command-line tools and libraries
- **cask** - GUI applications
- **mas** - Mac App Store applications (optional)

## Directory Structure (Planned)

```
macos/
├── README.md           # This file
├── packages.yaml       # Homebrew package definitions
├── install-packages.nu # Package installation script
├── setup-zsh.nu        # Zsh integration script
└── .zshrc.d/          # Zsh configuration snippets
```

## Resources

- [Homebrew Documentation](https://docs.brew.sh/)
- [macOS Developer Documentation](https://developer.apple.com/documentation/)

---

*Last updated: 2026-02-17*
