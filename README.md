# Claude OS v2.5

An operating system for AI coding agents. [What does that mean?](INTRODUCTION.md)

Claude Code is a powerful AI — but it's a CPU without an OS. Every session starts from zero: no project context, no accumulated knowledge, no lessons from past mistakes. Claude OS gives it the missing infrastructure to do real, sustained work.

## What It Provides

| Computer OS | Claude OS | What it solves |
|-------------|-----------|----------------|
| Memory management | Three-tier context loading (hot / warm / cold) | Context window is limited — load only what's needed |
| File system | Structured knowledge files + indexing | Knowledge needs organization, not a blob of text |
| File integrity | Knowledge quality tags + graduation review | Wrong knowledge is worse than no knowledge |
| Process isolation | Task sections for parallel sessions | Multiple sessions can't overwrite each other |
| Security patches | Feedback system + behavioral hooks | Mistakes get permanently fixed, not repeated |
| Network sync | Git-based multi-machine sync | Same state everywhere you work |

Plus: custom statusline, slash commands (`/handoff`, `/reload`, `/deduce`, `/refactor`, `/check`), dotfiles, and a VM bootstrap script.

## Quick Start

**Easiest way**: Copy the [bootstrap prompt](BOOTSTRAP.md) and paste it into Claude Code. It handles everything — clone, install, private repo setup, and a guided walkthrough.

**Manual setup**:
```bash
# 1. Clone the template
git clone https://github.com/Tycho-Xue/claude-os.git ~/claude_config

# 2. Run install script (creates symlinks, detects your terminal)
bash ~/claude_config/dotfiles/install.sh

# 3. Create your own private repo (for syncing across machines)
cd ~/claude_config && git remote remove origin
gh repo create claude-os --private --source . --push

# 4. Customize CLAUDE.md — fill in the {{placeholders}} with your info

# 5. Restart Claude Code, then open it in any directory
claude
```

**Daily workflow**:
```
/reload my-project     → Claude restores all project context
... work ...           → Claude follows the OS protocol automatically
handoff                → State saved, synced via git
                       → Next session, any machine: /reload → continues
```

> **Updating the OS**: To pull future updates, ask Claude to help upgrade — it will add the upstream remote, fetch, and selectively merge OS files without overwriting your personal data.

## Architecture

```
claude_config/
├── CLAUDE.md              # Kernel — rules, protocol, boot sequence (auto-loaded)
├── DESIGN.md              # Architecture decisions and design principles
├── CHANGELOG.md           # Version history
├── claude-code/
│   ├── settings.json      # Permissions, hooks, statusline config
│   ├── statusline.sh      # Custom status bar script
│   └── commands/          # Slash commands (/handoff, /reload, /deduce, etc.)
├── dotfiles/
│   └── install.sh         # Symlink installer (detects terminal)
├── scripts/
│   └── vm-bootstrap.sh    # Remote VM setup (9 CLI tools + config)
├── projects/
│   └── example-project/
│       ├── CONTEXT.md     # Current state (hot — always loaded)
│       ├── KNOWLEDGE.md   # Project knowledge (warm — section-loaded on demand)
│       └── RECORDS.md     # Historical data (cold — grep on demand)
├── learnings/             # Cross-project reusable insights
├── pipelines/             # Reusable multi-step workflows
└── secrets/               # Credentials (gitignored)
```

**CLAUDE.md is the kernel** — ~2300 tokens, auto-loaded every session via `~/.claude/CLAUDE.md` symlink. It defines Claude's methodology, knowledge management protocol, communication rules, and boot sequence. Everything else loads on demand through the protocol it defines.

## Core Concepts

### Three-File System (per project)

| File | Role | Analogy |
|------|------|---------|
| `CONTEXT.md` | Current state + next steps | RAM — always loaded, overwritten each handoff |
| `KNOWLEDGE.md` | Project knowledge, gotchas, verified facts | Disk — section-loaded on demand, quality-controlled |
| `RECORDS.md` | Results, decisions, failure analysis | Cold storage — append-only, never compressed |

### Knowledge Quality

Every piece of knowledge is tagged:
- `[fact]` — verified, safe to reason from
- `[observation]` — phenomenon observed, no causation implied
- `[inference]` — unverified, stays in working memory until confirmed

Only `[fact]` and `[observation]` enter long-term storage (KNOWLEDGE.md). Inferences stay in CONTEXT until confirmed through a graduation review. This prevents wrong conclusions from persisting across sessions.

### Handoff & Reload

Say "handoff" or `/handoff` → Claude saves all state + syncs via git. Next session: `/reload` restores everything. Context usage ≥70% → statusline turns red, Claude reminds you.

### Five Core Principles

1. **Understand First** — don't guess, ask. List assumptions for confirmation
2. **Structure > Rules** — when a rule keeps getting violated, upgrade it to a hook or contract
3. **Minimal & Surgical** — search before writing, don't touch unrelated code
4. **Verify & Record** — not done until verified, not valuable until recorded
5. **Communicate Progress** — task lists, terse status lines, no log dumps

## What Ships by Default

### Shell & Terminal
- **zsh**: 10K shared history, case-insensitive completion, zoxide/starship/conda integration
- **tmux**: `Ctrl+A` prefix, mouse scrolling, auto-unsets Claude Code tokens for security
- **vim**: dark background, 4-space tabs
- **Ghostty** (optional): CitrusZest theme, JetBrains Mono 18, pre-configured keybindings
- **Other terminals**: hex code table provided for tmux keybindings ([see below](#terminal-keybindings))

### Claude Code
- **Auto-approved tools**: Read, Glob, Grep, git status/diff/log, ls, cat, head, tail, wc — reduces approval friction
- **SessionEnd hook**: auto git sync (fetch → rebase → commit → push)
- **Statusline**: context usage bar (green → yellow → red at 70%) + model + cost + OS version

### Terminal Keybindings

| Shortcut | Action | Hex Codes |
|----------|--------|-----------|
| `Cmd+Alt+Left/Right` | tmux: prev/next window | `0x01 0x70` / `0x01 0x6e` |
| `Cmd+1` – `Cmd+5` | tmux: go to window 1–5 | `0x01 0x31`–`0x35` |
| `Cmd+S` | tmux: choose session | `0x01 0x73` |
| `Cmd+Z` | tmux: zoom pane | `0x01 0x7a` |

**Ghostty**: auto-configured. **iTerm2**: set up in Preferences → Keys → "Send Hex Codes". **Other terminals**: Claude can help configure these during setup.

## Customization

1. **Fill in `{{placeholders}}`** in CLAUDE.md — at minimum your name and role
2. **Add coding rules** for your stack (Python/ML, Rust, Go — examples in CLAUDE.md)
3. **Create your first project**: `mkdir -p ~/claude_config/projects/my-project`
4. **Add dotfiles** — put your configs in `dotfiles/`, the symlink installer handles the rest
5. **Learnings and pipelines** grow organically as you work — Claude suggests writing them when appropriate

## Remote Machines

```bash
# On the remote machine (clone your private repo):
git clone git@github.com:<your-username>/claude-os.git ~/claude_config
bash ~/claude_config/scripts/vm-bootstrap.sh
```

Installs: ripgrep, fd, bat, fzf, zoxide, starship, neovim, conda. Configures tmux/vim/shell/Claude Code.

## FAQ

**Will this conflict with my existing `~/.claude/` config?**
`install.sh` backs up existing files to `.bak` before symlinking. You can restore anytime.

**Do I need to use all the features?**
No. The minimum viable setup is just `CLAUDE.md` symlinked. Everything else is opt-in.

**Can I use this with multiple machines?**
Yes. Git-based sync with auto-commit on session end. Each machine rebases independently.

**What if I don't have remote machines?**
Ignore `vm-bootstrap.sh` and the Sync section. Everything else works on a single machine.

## License

Apache 2.0 — see [LICENSE](LICENSE).

Created by [Le (Tycho) Xue](https://www.linkedin.com/in/le-tycho-xue-5abbb9157/). Built through daily use of Claude Code across ML research, agent development, and infrastructure work. Feel free to fork, modify, and share — just please add a reference back and keep the attribution per the Apache 2.0 license.
