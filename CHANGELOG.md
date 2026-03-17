# Claude OS — Changelog

Record structural changes to the OS here. Not needed for daily work.

## v2.1 — Initial Public Release

- Single CLAUDE.md with all always-needed content inlined (~135 lines, ~2300 tokens)
- Three-file project system: CONTEXT.md + KNOWLEDGE.md + RECORDS.md
- Section loading protocol (Grep headers → read fragments, saves 50-80% context)
- SessionEnd hook for auto git sync (rebase strategy)
- Custom statusline with context usage bar (green → yellow → red at 70%)
- `/handoff` and `/reload` slash commands
- Dotfiles: ghostty, tmux, zsh, bash, vim with symlink installer
- VM bootstrap script with 9 CLI tools + no-sudo fallback
