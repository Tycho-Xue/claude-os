# ~/.zshrc

# ---- History ----
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY          # share history across terminals
setopt HIST_IGNORE_DUPS       # deduplicate
setopt HIST_IGNORE_SPACE      # commands starting with space are not recorded

# ---- Completion ----
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive completion

# ---- Shared config (aliases, PATH, conda, zoxide, yazi) ----
[[ -f "$HOME/.shell_common" ]] && source "$HOME/.shell_common"

# ---- Plugins (install via brew: zsh-syntax-highlighting, zsh-autosuggestions) ----
[[ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---- Starship Prompt ----
command -v starship &>/dev/null && eval "$(starship init zsh)"
