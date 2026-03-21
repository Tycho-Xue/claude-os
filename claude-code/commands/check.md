Run a health check on the Claude OS installation. Verify everything is correctly configured and report results as a checklist.

## Checks to perform:

### 1. Symlinks
Check that these symlinks exist and point to valid targets:
- `~/.claude/CLAUDE.md` → `~/claude_config/CLAUDE.md`
- `~/.claude/settings.json` → `~/claude_config/claude-code/settings.json`
- `~/.claude/statusline.sh` → `~/claude_config/claude-code/statusline.sh`
- `~/.claude/commands/handoff.md` → `~/claude_config/claude-code/commands/handoff.md`
- `~/.claude/commands/reload.md` → `~/claude_config/claude-code/commands/reload.md`

### 2. Git Remote
- `cd ~/claude_config && git remote -v`
- Origin should point to the **user's own repo**, not `Tycho-Xue/claude-os`
- If origin is the upstream template, warn and offer to fix

### 3. Placeholders
- Check `~/claude_config/CLAUDE.md` for any remaining `{{` placeholders
- List which ones still need to be filled in

### 4. Directory Structure
Verify these directories exist:
- `~/claude_config/projects/`
- `~/claude_config/learnings/`
- `~/claude_config/pipelines/`
- `~/claude_config/secrets/`
- `~/claude_config/obsidian/`

### 5. Shell & Tools
- Check if running zsh or bash
- Check if these tools are available: `starship`, `zoxide`, `fzf`, `rg` (ripgrep), `fd`, `bat`, `tmux`, `nvim`
- Check if `~/.config/starship.toml` exists

### 6. Slash Commands
- Check if `/handoff` and `/reload` are available (files exist in `~/.claude/commands/`)

## Output Format

Print results as a checklist:
```
✓ CLAUDE.md symlink OK
✗ settings.json symlink MISSING — run: bash ~/claude_config/dotfiles/install.sh
✓ Git remote: github.com/username/claude-os (private)
⚠ 3 placeholders remaining in CLAUDE.md: {{Your Name}}, {{your role}}, {{your org}}
```

For any failures, provide the exact command to fix it.
