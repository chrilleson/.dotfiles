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

# --- greeting: pending upgrades, from a count refreshed in the background ---
# checkupdates (pacman-contrib) syncs a temp copy of the db, so no root is needed.
# Refreshes at most every 6 hours, or right after packages change (the local db
# is newer than the count); an offline check keeps the previous count.
os_greeting() {
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/updates
  local -a mtime dbtime
  zmodload zsh/datetime
  zmodload -F zsh/stat b:zstat
  zstat -A mtime +mtime -- $cache 2>/dev/null
  zstat -A dbtime +mtime -- /var/lib/pacman/local 2>/dev/null
  local upgraded=$(( ${dbtime[1]:-0} > ${mtime[1]:-0} ))
  if (( upgraded || EPOCHSECONDS - ${mtime[1]:-0} > 6 * 3600 )) && (( $+commands[checkupdates] )); then
    mkdir -p ${cache:h}
    touch $cache  # claim the refresh so other new shells don't start one too
    (
      local repo aur
      repo=$(checkupdates 2>/dev/null)
      (( $? == 1 )) && exit  # offline or failed: keep the old count
      aur=$(paru -Qua 2>/dev/null)
      local -a pkgs=(${(f)repo} ${(f)aur})
      print $#pkgs > $cache.tmp && mv $cache.tmp $cache
    ) &!
  fi
  (( upgraded )) && return 0  # the cached count predates the last upgrade
  local n=$(<$cache 2>/dev/null)
  (( n > 0 )) && print -P "%F{yellow}↑%f $n package updates available: run %Bdotfiles upgrade --all%b"
  return 0
}
