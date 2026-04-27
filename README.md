# Le's Claude OS v2.5

**An operating system for AI coding agents.**

Claude Code is a powerful AI — but it's a CPU without an OS. Every session starts from zero: it doesn't know your projects, doesn't remember yesterday's debug, and will repeat last week's mistakes. You want it to do real work — the kind that spans days, multiple projects, multiple machines — and it structurally can't. Not because it isn't smart enough, but because it has no infrastructure.

**What it's missing isn't memory. It's an operating system.**

Memory is just one function of an OS. What an OS really provides is: turning stateless compute into a stateful, collaborative, self-correcting work environment. Claude OS is that operating system — built by an AI researcher through intensive daily use of Claude Code, iteratively discovered, not designed in one shot. Every mechanism exists because a real problem was hit in practice.

## Why "OS"?

Not a metaphor. Claude OS solves the same engineering problems that computer operating systems solve, just for AI agents:

| Computer OS | Claude OS | What it solves |
|-------------|-----------|----------------|
| Memory management | Three-tier context loading (hot / warm / cold) | Context window = RAM — limited and expensive. Page in on demand |
| File system | Structured knowledge files + indexing | Knowledge needs organization, not a blob of text |
| File integrity | Knowledge quality tags + graduation review | Wrong knowledge is worse than no knowledge |
| Process isolation | Task sections for parallel sessions | Multiple sessions can't overwrite each other |
| Security patches | Feedback system + behavioral hooks | Mistakes get permanently fixed, not repeated |
| Network sync | Git-based multi-machine sync | Same state everywhere you work |

CLAUDE.md is the **kernel** — ~2300 tokens, auto-loaded every session, defining how the agent works: methodology, knowledge management, communication, self-correction, and boot sequence. Everything else loads on demand through the protocols it defines.

> For a deeper technical breakdown (kernel architecture, bootloader, init system, syscalls), read [INTRODUCTION.md](INTRODUCTION.md).

## Get Started

Paste this into a new Claude Code session:

```
I want you to set up "Le's Claude OS v2.5" — an operating system for AI coding agents.
It turns Claude Code from a stateless tool into a stateful, self-correcting work environment
with persistent project knowledge, multi-machine sync, and knowledge quality controls.
Source repo: https://github.com/Tycho-Xue/claude-os

First, clone and install:

if [ -d ~/claude_config ]; then
    echo "~/claude_config already exists."
else
    git clone https://github.com/Tycho-Xue/claude-os.git ~/claude_config
fi
bash ~/claude_config/dotfiles/install.sh

Then help me create a private repo for syncing (check if gh CLI is available, if not help me
install it), fill in the {{placeholders}} in CLAUDE.md with my info, and give me a quick
overview of how the system works. See BOOTSTRAP.md in the repo for the full setup instructions.
```

After setup, **restart Claude Code** for slash commands to take effect.

**Daily workflow**:
```
/reload my-project     → Claude restores all project context
... work ...           → Claude follows the OS protocol automatically
handoff                → State saved, synced via git
                       → Next session, any machine: /reload → continues
```

<details>
<summary><b>Manual setup</b> (if you prefer not to use the bootstrap prompt)</summary>

```bash
# 1. Clone
git clone https://github.com/Tycho-Xue/claude-os.git ~/claude_config

# 2. Install (creates symlinks, detects your terminal)
bash ~/claude_config/dotfiles/install.sh

# 3. Create your own private repo (for syncing across machines)
cd ~/claude_config && git remote remove origin
gh repo create claude-os --private --source . --push

# 4. Customize CLAUDE.md — fill in the {{placeholders}} with your info

# 5. Restart Claude Code, then open it in any directory
claude
```
</details>

> **Updating the OS**: To pull future updates, ask Claude to help upgrade — it will add the upstream remote, fetch, and selectively merge OS files without overwriting your personal data.

## How It Works

### Three-File System (per project)

| File | Role | Analogy |
|------|------|---------|
| `CONTEXT.md` | Current state + next steps | RAM — always loaded, overwritten each handoff |
| `KNOWLEDGE.md` | Project knowledge, verified facts, gotchas | Disk — section-loaded on demand, quality-controlled |
| `RECORDS.md` | Results, decisions, failure analysis | Cold storage — append-only, never compressed |

### Knowledge Quality

Every piece of knowledge is tagged:
- `[fact]` — verified, safe to reason from
- `[observation]` — phenomenon observed, no causation implied
- `[inference]` — unverified, stays in working memory until confirmed

Only verified knowledge enters long-term storage. This prevents wrong conclusions from persisting and misleading future sessions.

### Five Core Principles

1. **Understand First** — don't guess, ask. List assumptions for confirmation
2. **Structure > Rules** — when a rule keeps getting violated, upgrade it to a hook or contract
3. **Minimal & Surgical** — search before writing, don't touch unrelated code
4. **Verify & Record** — not done until verified, not valuable until recorded
5. **Communicate Progress** — task lists, terse status lines, no log dumps

### The System is Alive

The OS grows from use — every correction becomes a permanent behavioral patch, every lesson becomes a rule. It also naturally absorbs external best practices: when a good pattern appears in the community (like Karpathy's autoresearch append-only log), you evaluate it, adapt it, and it slots into the existing structure. Not a fixed set of rules, but a framework for continuously absorbing experience and evolving.

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
│       ├── CONTEXT.md     # Hot — always loaded
│       ├── KNOWLEDGE.md   # Warm — section-loaded on demand
│       └── RECORDS.md     # Cold — grep on demand
├── learnings/             # Cross-project reusable insights
├── pipelines/             # Reusable multi-step workflows
└── secrets/               # Credentials (gitignored)
```

## What Ships by Default

**Shell & Terminal**: zsh (10K history, zoxide, starship), tmux (`Ctrl+A`, auto-unsets Claude tokens), vim, Ghostty theme (optional, auto-detected)

**Claude Code**: auto-approved read-only tools, SessionEnd git sync hook, statusline with context usage bar (green → yellow → red at 70%)

**tmux keybindings** (Ghostty auto-configured; other terminals use hex codes):

| Shortcut | Action | Hex Codes |
|----------|--------|-----------|
| `Cmd+Alt+Left/Right` | prev/next window | `0x01 0x70` / `0x01 0x6e` |
| `Cmd+1` – `Cmd+5` | go to window 1–5 | `0x01 0x31`–`0x35` |
| `Cmd+S` | choose session | `0x01 0x73` |
| `Cmd+Z` | zoom pane | `0x01 0x7a` |

## Customization

1. **Fill in `{{placeholders}}`** in CLAUDE.md — at minimum your name and role
2. **Add coding rules** for your stack (examples already in CLAUDE.md for Python/ML)
3. **Create your first project**: `mkdir -p ~/claude_config/projects/my-project`
4. **Add dotfiles** — put your configs in `dotfiles/`, the installer handles symlinks
5. **Learnings and pipelines** grow organically — Claude suggests writing them as you work

## Remote Machines

```bash
git clone git@github.com:<your-username>/claude-os.git ~/claude_config
bash ~/claude_config/scripts/vm-bootstrap.sh
```

Installs: ripgrep, fd, bat, fzf, zoxide, starship, neovim, conda. Configures tmux/vim/shell/Claude Code.

## FAQ

**Will this conflict with my existing config?** — `install.sh` backs up existing files to `.bak`. Restore anytime.

**Do I need all the features?** — No. Minimum viable setup is just `CLAUDE.md` symlinked. Everything else is opt-in.

**Multiple machines?** — Yes. Git-based sync with auto-commit on session end.

**No remote machines?** — Ignore `vm-bootstrap.sh`. Everything else works locally.

## License

Apache 2.0 — see [LICENSE](LICENSE).

Created by [Le (Tycho) Xue](https://www.linkedin.com/in/le-tycho-xue-5abbb9157/). Built through daily use of Claude Code across ML research, agent development, and infrastructure work.
