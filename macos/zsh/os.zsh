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
