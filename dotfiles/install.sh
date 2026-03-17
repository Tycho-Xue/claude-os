#!/bin/bash
# dotfiles/install.sh — Create symlinks pointing to claude_config/ files
# Mac: Full symlinks (shell + terminal + Claude Code)
# VM/Linux: Claude Code symlinks only (shell config managed by vm-bootstrap.sh)

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$DIR/.." && pwd)"

link() {
    local src="$DIR/$1"
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

# ---- Shell & system dotfiles (Mac only) ----
if is_mac; then
    echo "==> [Mac] Installing shell dotfile symlinks..."
    link ".zshrc"          "$HOME/.zshrc"
    link ".zshenv"         "$HOME/.zshenv"
    link ".bashrc"         "$HOME/.bashrc"
    link ".bash_profile"   "$HOME/.bash_profile"
    link ".shell_common"   "$HOME/.shell_common"
    link ".tmux.conf"      "$HOME/.tmux.conf"
    link ".vimrc"          "$HOME/.vimrc"
    link "ghostty/config"  "$HOME/.config/ghostty/config"
    link "ghostty/themes/CatppuccinLatteSubtle" "$HOME/.config/ghostty/themes/CatppuccinLatteSubtle"
    # Add your own dotfiles here
else
    echo "==> [VM/Linux] Skipping shell dotfiles (managed by vm-bootstrap.sh)"
fi

# ---- Claude Code symlinks (all platforms) ----
echo ""
echo "==> Installing Claude Code symlinks..."

mkdir -p "$HOME/.claude"

# CLAUDE.md (global instructions)
ln -sf "$REPO/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
echo "  ✓ ~/.claude/CLAUDE.md → $REPO/CLAUDE.md"

# Slash commands
mkdir -p "$HOME/.claude/commands"
for cmd in "$REPO/claude-code/commands/"*.md; do
    [ -f "$cmd" ] || continue
    name="$(basename "$cmd")"
    ln -sf "$cmd" "$HOME/.claude/commands/$name"
    echo "  ✓ ~/.claude/commands/$name → $cmd"
done

# Statusline
ln -sf "$REPO/claude-code/statusline.sh" "$HOME/.claude/statusline.sh"
echo "  ✓ ~/.claude/statusline.sh → $REPO/claude-code/statusline.sh"

# Settings (hooks, permissions, statusline config)
# NOTE: If you need different settings per machine, don't symlink this.
# Instead, manually configure ~/.claude/settings.json on each machine.
ln -sf "$REPO/claude-code/settings.json" "$HOME/.claude/settings.json"
echo "  ✓ ~/.claude/settings.json → $REPO/claude-code/settings.json"

echo ""
echo "✓ All config symlinked. Edit files in the repo and changes take effect immediately."
