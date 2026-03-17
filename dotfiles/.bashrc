# ~/.bashrc

# ---- History ----
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend

# ---- Completion ----
if [ -f /opt/homebrew/etc/bash_completion ]; then
    . /opt/homebrew/etc/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ---- Shared config (aliases, PATH, conda, zoxide, yazi) ----
[[ -f "$HOME/.shell_common" ]] && source "$HOME/.shell_common"
