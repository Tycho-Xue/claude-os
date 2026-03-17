# ~/.bash_profile — macOS login shell entry point
# macOS bash only reads .bash_profile, not .bashrc
# This ensures .bashrc gets sourced

[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
