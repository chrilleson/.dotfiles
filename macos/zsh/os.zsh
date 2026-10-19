# Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Brew-installed completions (must be on fpath before compinit)
[[ -n $HOMEBREW_PREFIX ]] && fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $HOMEBREW_PREFIX/share/zsh-completions $fpath)

# Plugins (brew install zsh-autosuggestions zsh-syntax-highlighting)
ZSH_AUTOSUGGEST_PATH=$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_SYNTAX_HL_PATH=$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pnpm (location set by `pnpm setup`)
export PNPM_HOME=~/Library/pnpm
path=($PNPM_HOME/bin $path)

# --- greeting: pending upgrades, from a count refreshed in the background ---
# Counts only tools.yaml packages (what `dotfiles upgrade --all` upgrades).
# Refreshes at most every 6 hours, or right after packages change (brew's locks
# dir is touched by every install/upgrade, not by `brew update`); a failed check
# keeps the previous count.
os_greeting() {
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/updates
  local -a mtime brewtime
  zmodload zsh/datetime
  zmodload -F zsh/stat b:zstat
  zstat -A mtime +mtime -- $cache 2>/dev/null
  zstat -A brewtime +mtime -- $HOMEBREW_PREFIX/var/homebrew/locks 2>/dev/null
  local upgraded=$(( ${brewtime[1]:-0} > ${mtime[1]:-0} ))
  if (( upgraded || EPOCHSECONDS - ${mtime[1]:-0} > 6 * 3600 )) && (( $+commands[dotfiles] )); then
    mkdir -p ${cache:h}
    touch $cache  # claim the refresh so other new shells don't start one too
    (
      local out
      out=$(dotfiles outdated 2>/dev/null) || exit  # offline or failed: keep the old count
      local -a pkgs=(${(f)out})
      print $#pkgs > $cache.tmp && mv $cache.tmp $cache
    ) &!
  fi
  (( upgraded )) && return 0  # the cached count predates the last upgrade
  local n=$(<$cache 2>/dev/null)
  (( n > 0 )) && print -P "%F{yellow}↑%f $n package updates available: run %Bdotfiles upgrade --all%b"
  return 0
}
