# Zsh plugin paths (pacman: zsh-autosuggestions, zsh-syntax-highlighting)
ZSH_AUTOSUGGEST_PATH=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_SYNTAX_HL_PATH=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Arch/pacman aliases ---
alias update='sudo cachyos-rate-mirrors && sudo pacman -Syu'
alias mirror='sudo cachyos-rate-mirrors'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias fixpacman='sudo rm /var/lib/pacman/db.lck'
alias grubup='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias jctl='journalctl -p 3 -xb'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'
alias apt='man pacman'
alias apt-get='man pacman'

# --- tmux-dev: forward all args to the script (session, path, then extras) ---
# The Fish wrapper only passed 2 args; forward the rest so future flags reach it.
tmux-dev() {
  bash ~/.local/bin/tmux-dev "${1:-dev}" "${2:-$HOME}" "${@:3}"
}
