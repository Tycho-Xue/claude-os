#!/bin/bash
# vm-bootstrap.sh — Run once after SSH-ing into any VM to set up a consistent environment
# Usage: curl -sL <url> | bash  OR  scp it over then: bash vm-bootstrap.sh

set -e

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

# ---- Tool Installation ----
echo "==> Installing CLI tools..."

# apt basics (requires sudo, skips if unavailable)
if sudo -n true 2>/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq ripgrep fd-find bat htop jq curl git unzip > /dev/null 2>&1
    echo "  ✓ apt: ripgrep, fd-find, bat, htop, jq, curl, git"
    # Ubuntu uses different binary names
    [ ! -e ~/.local/bin/fd ] && ln -sf "$(which fdfind 2>/dev/null || true)" ~/.local/bin/fd 2>/dev/null && echo "  ✓ fd → fdfind" || true
    [ ! -e ~/.local/bin/bat ] && ln -sf "$(which batcat 2>/dev/null || true)" ~/.local/bin/bat 2>/dev/null && echo "  ✓ bat → batcat" || true
else
    echo "  ⚠ No sudo access, skipping apt install (ripgrep, fd, bat, etc.)"
    echo "    Manual install: sudo apt-get install -y ripgrep fd-find bat htop jq curl git unzip"
    # Fallback: download prebuilt binaries
    if ! command -v rg &>/dev/null; then
        echo "  Installing ripgrep (prebuilt)..."
        RG_VER=$(curl -sSf https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') 2>/dev/null || RG_VER="14.1.1"
        curl -sSLo /tmp/rg.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/ripgrep-${RG_VER}-x86_64-unknown-linux-musl.tar.gz" 2>/dev/null
        tar xzf /tmp/rg.tar.gz -C /tmp/ 2>/dev/null && mv /tmp/ripgrep-*/rg ~/.local/bin/ 2>/dev/null && echo "  ✓ ripgrep" || echo "  ⚠ ripgrep install failed"
        rm -rf /tmp/rg.tar.gz /tmp/ripgrep-*
    fi
    if ! command -v fd &>/dev/null; then
        echo "  Installing fd (prebuilt)..."
        FD_VER=$(curl -sSf https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') 2>/dev/null || FD_VER="v10.2.0"
        curl -sSLo /tmp/fd.tar.gz "https://github.com/sharkdp/fd/releases/download/${FD_VER}/fd-${FD_VER}-x86_64-unknown-linux-musl.tar.gz" 2>/dev/null
        tar xzf /tmp/fd.tar.gz -C /tmp/ 2>/dev/null && mv /tmp/fd-*/fd ~/.local/bin/ 2>/dev/null && echo "  ✓ fd" || echo "  ⚠ fd install failed"
        rm -rf /tmp/fd.tar.gz /tmp/fd-*
    fi
    if ! command -v bat &>/dev/null; then
        echo "  Installing bat (prebuilt)..."
        BAT_VER=$(curl -sSf https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.tag_name') 2>/dev/null || BAT_VER="v0.25.0"
        curl -sSLo /tmp/bat.tar.gz "https://github.com/sharkdp/bat/releases/download/${BAT_VER}/bat-${BAT_VER}-x86_64-unknown-linux-musl.tar.gz" 2>/dev/null
        tar xzf /tmp/bat.tar.gz -C /tmp/ 2>/dev/null && mv /tmp/bat-*/bat ~/.local/bin/ 2>/dev/null && echo "  ✓ bat" || echo "  ⚠ bat install failed"
        rm -rf /tmp/bat.tar.gz /tmp/bat-*
    fi
fi

# fzf (git clone — apt version is too old)
if ! command -v fzf &>/dev/null; then
    echo "  Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null || true
    ~/.fzf/install --bin --no-key-bindings --no-completion --no-update-rc >/dev/null 2>&1
    ln -sf ~/.fzf/bin/fzf ~/.local/bin/fzf
    echo "  ✓ fzf"
fi

# zoxide (smart cd)
if ! command -v zoxide &>/dev/null; then
    echo "  Installing zoxide..."
    curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >/dev/null 2>&1
    echo "  ✓ zoxide"
fi

# starship (prompt)
if ! command -v starship &>/dev/null; then
    echo "  Installing starship..."
    curl -sSf https://starship.rs/install.sh | sh -s -- --yes >/dev/null 2>&1
    echo "  ✓ starship"
fi

# neovim (appimage — apt version is too old)
if ! command -v nvim &>/dev/null; then
    echo "  Installing neovim..."
    curl -sSLo /tmp/nvim-linux-x86_64.appimage https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
    chmod +x /tmp/nvim-linux-x86_64.appimage
    if /tmp/nvim-linux-x86_64.appimage --version &>/dev/null; then
        mv /tmp/nvim-linux-x86_64.appimage ~/.local/bin/nvim
    else
        cd /tmp && /tmp/nvim-linux-x86_64.appimage --appimage-extract >/dev/null 2>&1
        mv /tmp/squashfs-root ~/.local/nvim-squashfs
        ln -sf ~/.local/nvim-squashfs/usr/bin/nvim ~/.local/bin/nvim
    fi
    echo "  ✓ neovim"
fi

# conda (miniconda)
if ! command -v conda &>/dev/null && [ ! -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    echo "  Installing miniconda..."
    curl -sSLo /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3" >/dev/null 2>&1
    rm -f /tmp/miniconda.sh
    echo "  ✓ miniconda3"
fi

# ---- Config Files ----
echo ""
echo "==> Configuring tmux (prefix = Ctrl+A)..."
cat > ~/.tmux.conf << 'TMUXEOF'
# Prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Terminal
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:Tc"

# Mouse
set -g mouse on
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"

# Status bar
set -g status-position bottom
set -g status-style "bg=colour234,fg=colour250"
set -g status-left "#[fg=colour48,bold] #S #[fg=colour240]│ "
set -g status-left-length 30
set -g status-right "#[fg=colour240]│ #[fg=colour245]%H:%M │ %m-%d"
set -g status-right-length 30
set -g window-status-format "#[fg=colour245] #I:#W "
set -g window-status-current-format "#[fg=colour48,bold] #I:#W "
set -g window-status-separator ""

# Prevent Claude Code env vars from leaking into tmux sessions
set-environment -g -u CLAUDECODE
set-environment -g -u CLAUDE_CODE_OAUTH_TOKEN

# Pane borders
set -g pane-border-style "fg=colour240"
set -g pane-active-border-style "fg=colour48"
TMUXEOF

echo "==> Configuring vim..."
cat > ~/.vimrc << 'EOF'
syntax on
set background=dark
if has('termguicolors') && ($COLORTERM == 'truecolor' || $TERM =~ '256color')
    set termguicolors
endif
set ts=4 sw=4 expandtab smartindent
set number
EOF

echo "==> Configuring shell..."
cat > ~/.shell_common << 'SHELLEOF'
# ~/.shell_common — shared config for bash and zsh (vm-bootstrap generated)

# ---- Clean inherited env ----
unset CLAUDECODE CLAUDE_CODE_OAUTH_TOKEN 2>/dev/null

# ---- Colors ----
export COLORTERM=truecolor
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b)"
fi

# ---- Aliases ----
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ssh='TERM=xterm-256color ssh'

# ---- PATH ----
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.fzf/bin" ]] && export PATH="$HOME/.fzf/bin:$PATH"

# ---- Conda ----
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/anaconda3/etc/profile.d/conda.sh"
elif [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
    . "/opt/conda/etc/profile.d/conda.sh"
fi

# ---- Zoxide (smart cd) ----
if command -v zoxide &>/dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        eval "$(zoxide init zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        eval "$(zoxide init bash)"
    fi
fi

# ---- Starship prompt ----
if command -v starship &>/dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        eval "$(starship init zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        eval "$(starship init bash)"
    fi
fi

# ---- fzf ----
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
SHELLEOF

# Ensure .bashrc sources .shell_common
MARKER="# --- vm-bootstrap ---"
END_MARKER="# --- end vm-bootstrap ---"
if grep -q "$MARKER" ~/.bashrc 2>/dev/null; then
    sed -i "/$MARKER/,/$END_MARKER/d" ~/.bashrc
    echo "  → Removed old vm-bootstrap block"
fi
cat >> ~/.bashrc << 'EOF'

# --- vm-bootstrap ---
[[ -f "$HOME/.shell_common" ]] && source "$HOME/.shell_common"
# --- end vm-bootstrap ---
EOF
echo "  ✓ .bashrc updated to source .shell_common"

echo "==> Reloading tmux (if running)..."
tmux source-file ~/.tmux.conf 2>/dev/null && echo "  ✓ tmux reloaded" || echo "  → tmux not running, will take effect on next start"

echo ""
echo "==> Configuring Claude Code..."
mkdir -p ~/.claude/commands
if [ -d "$HOME/claude_config" ]; then
    REPO="$HOME/claude_config"

    ln -sf "$REPO/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    echo "  ✓ ~/.claude/CLAUDE.md"

    for cmd in "$REPO/claude-code/commands/"*.md; do
        [ -f "$cmd" ] || continue
        name="$(basename "$cmd")"
        ln -sf "$cmd" "$HOME/.claude/commands/$name"
        echo "  ✓ ~/.claude/commands/$name"
    done

    ln -sf "$REPO/claude-code/statusline.sh" "$HOME/.claude/statusline.sh"
    echo "  ✓ ~/.claude/statusline.sh"

    ln -sf "$REPO/claude-code/settings.json" "$HOME/.claude/settings.json"
    echo "  ✓ ~/.claude/settings.json"
else
    echo "  → ~/claude_config not found. Clone first:"
    echo "     git clone <repo> ~/claude_config && bash ~/claude_config/scripts/vm-bootstrap.sh"
fi

echo ""
echo "✓ VM bootstrap complete! Open a new shell or run: source ~/.bashrc"
echo ""
echo "Installed: ripgrep, fd, bat, fzf, zoxide, starship, neovim, conda"
echo "Configured: tmux, vim, shell aliases/colors, Claude Code"
