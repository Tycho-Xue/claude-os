#!/bin/bash
# dotfiles/install.sh — Create symlinks pointing to claude_config/ files
# Mac: Full symlinks (shell + terminal + Claude Code)
# VM/Linux: Claude Code symlinks only (shell config managed by vm-bootstrap.sh)

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$DIR/.." && pwd)"

link() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "  Backing up $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  ✓ $dst → $src"
}

is_mac() {
    [ "$(uname)" = "Darwin" ]
}

detect_terminal() {
    # 1. Check env vars (works when run from inside the terminal)
    if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
        echo "ghostty"; return
    elif [ "$TERM_PROGRAM" = "iTerm.app" ]; then
        echo "iterm2"; return
    elif [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
        echo "apple-terminal"; return
    elif [ "$TERM_PROGRAM" = "WezTerm" ]; then
        echo "wezterm"; return
    elif [ "$TERM_PROGRAM" = "Alacritty" ] || [ -n "$ALACRITTY_SOCKET" ]; then
        echo "alacritty"; return
    fi

    # 2. Fallback: check installed apps (works when run from Claude Code subprocess)
    if is_mac; then
        if [ -d "/Applications/Ghostty.app" ]; then
            echo "ghostty"; return
        elif [ -d "/Applications/iTerm.app" ]; then
            echo "iterm2"; return
        elif [ -d "/Applications/WezTerm.app" ]; then
            echo "wezterm"; return
        elif [ -d "/Applications/Alacritty.app" ]; then
            echo "alacritty"; return
        fi
    fi

    echo "unknown"
}

# ---- Shell & system dotfiles (Mac only) ----
if is_mac; then
    echo "==> [Mac] Installing shell dotfile symlinks..."
    link "$DIR/.zshrc"          "$HOME/.zshrc"
    link "$DIR/.zshenv"         "$HOME/.zshenv"
    link "$DIR/.bashrc"         "$HOME/.bashrc"
    link "$DIR/.bash_profile"   "$HOME/.bash_profile"
    link "$DIR/.shell_common"   "$HOME/.shell_common"
    link "$DIR/.tmux.conf"      "$HOME/.tmux.conf"
    link "$DIR/.vimrc"          "$HOME/.vimrc"
    link "$DIR/starship.toml"   "$HOME/.config/starship.toml"

    # ---- Terminal-specific config ----
    echo ""
    DETECTED=$(detect_terminal)
    echo "==> Detected terminal: $DETECTED"

    case "$DETECTED" in
        ghostty)
            echo "==> Installing Ghostty config (theme, font, keybindings)..."
            link "$DIR/ghostty/config"  "$HOME/.config/ghostty/config"
            link "$DIR/ghostty/themes/CatppuccinLatteSubtle" "$HOME/.config/ghostty/themes/CatppuccinLatteSubtle"
            ;;
        iterm2)
            echo ""
            echo "==> iTerm2 detected. Ghostty config skipped."
            echo "    tmux keybindings (Cmd+Alt+Arrow, Cmd+1-5, etc.) need to be configured in iTerm2."
            echo "    Claude can help you set these up — just ask during the setup session."
            echo ""
            ;;
        *)
            echo ""
            echo "==> Terminal '$DETECTED' detected. Ghostty config skipped."
            echo "    tmux keybindings need manual setup. See README.md 'Terminal Keybindings' for the hex code table."
            echo "    Claude can also help you configure these — just ask."
            echo ""
            ;;
    esac
else
    echo "==> [VM/Linux] Skipping shell dotfiles (managed by vm-bootstrap.sh)"
fi

# ---- Claude Code symlinks (all platforms) ----
echo ""
echo "==> Installing Claude Code symlinks..."

mkdir -p "$HOME/.claude"

# CLAUDE.md (global instructions)
link "$REPO/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# Slash commands
mkdir -p "$HOME/.claude/commands"
for cmd in "$REPO/claude-code/commands/"*.md; do
    [ -f "$cmd" ] || continue
    name="$(basename "$cmd")"
    link "$cmd" "$HOME/.claude/commands/$name"
done

# Statusline
link "$REPO/claude-code/statusline.sh" "$HOME/.claude/statusline.sh"

# Settings (hooks, permissions, statusline config)
# NOTE: If you need different settings per machine, don't symlink this.
# Instead, manually configure ~/.claude/settings.json on each machine.
link "$REPO/claude-code/settings.json" "$HOME/.claude/settings.json"

echo ""
echo "✓ All done. Edit files in ~/claude_config/ and changes take effect immediately."
echo ""
echo "Next steps:"
echo "  1. Edit ~/claude_config/CLAUDE.md — fill in the {{placeholders}}"
echo "  2. Run 'claude' in any directory to start using Claude OS"
