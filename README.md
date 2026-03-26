# Le's Claude OS v2.2

A persistent knowledge and workflow system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). It gives Claude long-term memory across sessions, structured project management, and automatic state sync across machines.

## The Problem

Claude Code starts every session with zero context. You re-explain your project, re-share your preferences, and lose all the knowledge Claude built up in the last conversation. Claude OS fixes this by giving Claude a git-backed brain that persists across sessions and machines.

## What You Get

- **Persistent context** — Claude remembers your projects, preferences, and past decisions
- **Structured knowledge** — Hot/warm/cold data separation so Claude loads only what it needs
- **Handoff protocol** — Save state mid-conversation, restore later with `/reload`
- **Multi-machine sync** — git-based sync with auto-commit on session end
- **Custom statusline** — Context usage bar, model info, cost tracking, OS version
- **Slash commands** — `/handoff` and `/reload` built in

## Quick Start

**Easiest way**: Copy the [bootstrap prompt](BOOTSTRAP.md) and paste it into Claude Code. It handles everything — clone, install, set up your private repo, and explains how the system works.

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
#    At minimum: your name, role, and machine description

# 5. Open Claude Code in any directory — it auto-loads your config
claude
```

> **Updating the OS**: To pull future updates, ask Claude to help upgrade — it will add the upstream remote, fetch, and selectively merge OS files without overwriting your personal data.

## Directory Structure

```
claude_config/
├── CLAUDE.md              # The brain — rules, protocol, preferences (auto-loaded)
├── DESIGN.md              # Why the system is designed this way
├── CHANGELOG.md           # Version history
├── claude-code/
│   ├── settings.json      # Permissions, hooks, statusline config
│   ├── statusline.sh      # Custom status bar script
│   └── commands/
│       ├── handoff.md      # /handoff slash command
│       └── reload.md       # /reload slash command
├── dotfiles/
│   └── install.sh         # Symlink installer
├── scripts/
│   └── vm-bootstrap.sh    # Remote VM setup (tools + config)
├── projects/
│   └── example-project/
│       ├── CONTEXT.md     # Current state (overwritten each handoff)
│       ├── KNOWLEDGE.md   # Project knowledge (append-only, section-loaded)
│       └── RECORDS.md     # Historical data (cold storage, never compressed)
├── learnings/             # Cross-project reusable insights
├── pipelines/             # Reusable multi-step workflows
└── secrets/               # Credentials (gitignored sensitive values)
```

## Core Concepts

### Three-File System (per project)

| File | Purpose | Loading | Write Pattern |
|------|---------|---------|---------------|
| `CONTEXT.md` | Current status + next steps | Always read in full | Overwrite each handoff |
| `KNOWLEDGE.md` | Project knowledge, gotchas, commands | Section-loaded on demand | Append new, archive old |
| `RECORDS.md` | Results, milestones, failure analysis | Grep headers, read on demand | Append only, never compress |

### Section Loading

Files use `## ` headers as section markers. Claude greps for headers to find what it needs, then reads only the relevant section. This saves 50-80% of context compared to reading entire files.

### Handoff & Reload

When you're done working (or context is getting full), say "handoff" or use `/handoff`. Claude writes back all project state and syncs via git. Next session, `/reload` restores everything.

### Multi-Machine Sync

A `SessionEnd` hook automatically commits and pushes changes. On session start, Claude pulls the latest. Uses rebase strategy to avoid stale overwrites when working from multiple machines.

## Default Preferences

These ship as defaults because they make Claude Code significantly more effective. You can customize any of them in `CLAUDE.md`.

### Behavioral
| Preference | Why |
|-----------|-----|
| **Just do it, don't just give instructions** | Claude should execute tasks, not explain how to do them. You're using an agent, not a chatbot. |
| **Don't summarize after every response** | Summaries waste tokens and slow you down. You can read the diff. |
| **Plan before non-trivial tasks (3+ steps)** | Prevents Claude from rushing into complex work and hitting dead ends. |
| **STOP and re-plan when complexity grows** | The #1 failure mode: Claude pushes through increasing complexity instead of stepping back. This rule catches that. |
| **Verify before reporting done** | Claude tends to say "done!" before actually confirming the result works. This forces verification. |
| **Write corrections to learnings immediately** | Without this, Claude repeats the same mistakes across sessions. |
| **Use subagents for complex tasks** | Keeps the main context window clean for the primary task. |

### Coding
| Preference | Why |
|-----------|-----|
| **Simplicity > abstraction** | Over-engineering is the default failure mode. This keeps code focused. |
| **Clean, runnable, iterable** | Ship working code first, refine later. |
| **Descriptive variable names** | `x`, `y`, `tmp` are debugging nightmares. |
| **Comment input/output shapes** | Critical for ML/data work, useful everywhere. |

### Protocol
| Preference | Why |
|-----------|-----|
| **Read before writing** | Prevents Claude from proposing changes to code it hasn't read. |
| **Scratch pad for temp code** | `claude_code_scratch_pad/` keeps experiments out of your project. |
| **Long commands to clipboard** | `echo '...' \| pbcopy` — easier than copy-pasting from terminal output. |

## What Ships by Default

The repo includes opinionated dotfiles that are symlinked on install (Mac only; VMs use inline configs via `vm-bootstrap.sh`). Here's everything that gets installed and why.

### Shell (zsh)
- **History**: 10,000 entries, shared across terminals, deduplicated
- **Aliases**: `ll`, `la`, `l`, colorized `ls`/`grep`
- **Tool integrations**: [zoxide](https://github.com/ajeetdsouza/zoxide) (smart `cd`), [yazi](https://github.com/sxyazi/yazi) (file manager via `y`), [starship](https://starship.rs) prompt, conda auto-init
- **Plugins**: zsh-syntax-highlighting, zsh-autosuggestions (install via `brew install zsh-syntax-highlighting zsh-autosuggestions`)

### tmux
- **Prefix**: `Ctrl+A` (instead of default `Ctrl+B` — easier to reach)
- **Mouse scrolling**: enabled
- **Status bar**: dark background, green highlight on active window, time + date on right
- **Security**: auto-unsets Claude Code env vars to prevent token leakage into child sessions

### Vim
- Dark background, 4-space tabs, expandtab, smartindent

### Terminal Keybindings

These keybindings let you drive tmux from your terminal emulator using familiar shortcuts. They work by sending tmux prefix sequences (hex codes).

| Shortcut | Action | Hex Codes |
|----------|--------|-----------|
| `Cmd+Alt+Left` | tmux: previous window | `0x01 0x70` |
| `Cmd+Alt+Right` | tmux: next window | `0x01 0x6e` |
| `Cmd+1` – `Cmd+5` | tmux: go to window 1–5 | `0x01 0x31`–`0x35` |
| `Cmd+S` | tmux: choose session | `0x01 0x73` |
| `Cmd+Z` | tmux: zoom pane | `0x01 0x7a` |
| `Cmd+D` | Split right | native terminal split |
| `Cmd+Shift+D` | Split down | native terminal split |
| `Ctrl+Shift+Arrow` | Navigate splits | native terminal split |
| `Cmd+Shift+Enter` | Toggle split zoom | native terminal split |
| `` Ctrl+` `` | Quick terminal (dropdown) | native terminal feature |

**Ghostty**: Pre-configured in `dotfiles/ghostty/config`, symlinked automatically.

**iTerm2**: Needs manual configuration in Preferences → Keys → Key Bindings (action: "Send Hex Codes"). Claude can help you set these up during the setup session — just ask.

**Other terminals**: Check your terminal's docs for sending hex codes on key press. The tmux prefix is `0x01` (`Ctrl+A`), followed by the command byte. Claude can help configure these — just ask.

### Claude Code
- **Auto-approved**: Read, Glob, Grep, git status/diff/log, ls, cat, head, tail, wc, pwd, echo, which — reduces manual approval friction
- **SessionEnd hook**: auto git sync (fetch → rebase → commit → push)
- **Statusline**: context usage progress bar (green → yellow → red at 70%) + model + cost + OS version

### Ghostty Terminal (optional)
- **Theme**: CitrusZest (dark)
- **Font**: JetBrains Mono, size 18, thickened
- **Style**: opaque background, tab-style titlebar, bar cursor (no blink), mouse hides while typing
- Only installed if you use Ghostty. The install script will ask.

## Customization

### 1. Fill in your identity
Edit `CLAUDE.md` and replace `{{placeholders}}` with your actual info:
- Name, role, organization
- Email addresses and GitHub username
- Machine descriptions

### 2. Add your own coding rules
The `### Coding — Style` section in `CLAUDE.md` is intentionally generic. Add language-specific rules for your stack. Example for Python/ML:

```markdown
### Coding — Python / ML
- Never hardcode `.cuda()`, use `.to(device=device, dtype=dtype)`
- Eval paths use `torch.no_grad()`, release GPU memory
- Set random seeds: torch, numpy, random
- Handle batch_size=1, empty input, shape mismatch
```

### 3. Add your dotfiles
The `dotfiles/` directory has a commented-out section in `install.sh` for shell dotfiles. Uncomment and customize for your terminal, shell, and editor configs.

### 4. Create your first project
```bash
mkdir -p ~/claude_config/projects/my-project
```
Then let Claude create the CONTEXT.md and KNOWLEDGE.md during your first session — or copy from `projects/example-project/`.

### 5. Add learnings and pipelines
As you work, Claude will proactively suggest writing to `learnings/` (cross-project insights) and `pipelines/` (reusable workflows). You can also create them manually.

## Remote Machines (VM Setup)

For remote VMs accessed via SSH:

```bash
# On the remote machine (clone your private repo, not the upstream template):
git clone git@github.com:<your-username>/claude-os.git ~/claude_config
bash ~/claude_config/scripts/vm-bootstrap.sh
```

This installs: ripgrep, fd, bat, fzf, zoxide, starship, neovim, conda, and configures tmux/vim/shell/Claude Code.

## Settings

`claude-code/settings.json` includes:
- **Permissions**: Pre-approved read-only tools (Read, Glob, Grep, git status, ls, etc.) to reduce manual approvals
- **SessionEnd hook**: Auto-sync via git on session end
- **Statusline**: Context usage bar with color coding (green → yellow → red at 70%)

## FAQ

**Q: Will this conflict with my existing `~/.claude/` config?**
A: `install.sh` backs up existing files to `.bak` before symlinking. You can restore anytime.

**Q: Do I need to use all the features?**
A: No. The minimum viable setup is just `CLAUDE.md` symlinked. Everything else is opt-in.

**Q: Can I use this with multiple Claude Code instances?**
A: Yes. The git-based sync is designed for this. Each machine commits and rebases independently.

**Q: What if I don't have remote machines?**
A: Just ignore `scripts/vm-bootstrap.sh` and the Sync section. The rest works on a single machine.

## License

Apache 2.0 — see [LICENSE](LICENSE).

Created by [Le (Tycho) Xue](https://www.linkedin.com/in/le-tycho-xue-5abbb9157/). Built through daily use of Claude Code across ML research, agent development, and infrastructure work. Feel free to fork, modify, and share — just please add a reference back and keep the attribution per the Apache 2.0 license.
