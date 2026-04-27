# Bootstrap Prompt

Copy everything below the line and paste it into a new Claude Code session. It will clone the repo, install everything, and walk you through setup.

---

I want you to set up "Le's Claude OS v2.5" — an operating system for AI coding agents. It turns Claude Code from a stateless tool into a stateful, self-correcting work environment with persistent project knowledge, multi-machine sync, and knowledge quality controls. Source repo: https://github.com/Tycho-Xue/claude-os

> For background on what this is and why, read `INTRODUCTION.md` in the repo after cloning.

## Step 1: Install

```bash
if [ -d ~/claude_config ]; then
    echo "~/claude_config already exists."
else
    git clone https://github.com/Tycho-Xue/claude-os.git ~/claude_config
fi
bash ~/claude_config/dotfiles/install.sh
```

After install, the user needs their own **private** GitHub repo for syncing personal config across machines. Help them set this up:

1. Check if `gh` CLI is available (`which gh`). If not, offer to install (`brew install gh && gh auth login`), or guide them to create a repo manually on GitHub.
2. Create a private repo and update the remote:
```bash
cd ~/claude_config
git remote remove origin
gh repo create claude-os --private --source . --push
# Or manually: create a private repo on GitHub, then:
# git remote add origin git@github.com/<their-username>/claude-os.git && git push -u origin main
```
3. Verify: `git remote -v` — origin must point to the user's own repo.

> **Note**: To pull future OS updates, the user can ask Claude to help upgrade. Claude should add the upstream remote (`git remote add upstream https://github.com/Tycho-Xue/claude-os.git`), fetch, and selectively merge OS files (CLAUDE.md structure, DESIGN.md, claude-code/, dotfiles/, scripts/) without overwriting user's personal data (projects/, learnings/, secrets/).

Check what terminal was detected from the install output. If it's **not Ghostty**, offer to help configure tmux keybindings for their terminal (e.g., for iTerm2: Preferences → Keys → Key Bindings → "Send Hex Codes"). User can skip this.

**Important**: After install, tell the user to **restart Claude Code** (exit and reopen `claude`) for custom slash commands (`/handoff`, `/reload`) to take effect. They won't work in the current session since they were just symlinked.

## Step 2: Health Check

Run the checks from `claude-code/commands/check.md` inline (don't use the `/check` slash command — it won't work until restart). Verify symlinks, git remote, placeholders, directory structure, shell tools. Report results as a checklist with fix commands for any failures.

## Step 3: Knowledge Transfer (if applicable)

If we have conversation history in this session:
- Review what you already know about me (projects, preferences, technical stack, workflow habits)
- Write project-specific info to `projects/<name>/CONTEXT.md` and `KNOWLEDGE.md`
- Write cross-project technical learnings to `learnings/`
- Write reusable workflows to `pipelines/`

This ensures no knowledge is lost during the transition. If no history exists, skip this step.

## Step 4: Personalize CLAUDE.md

Open `~/claude_config/CLAUDE.md` and replace `{{placeholder}}` values. **All of these are optional — the system works with placeholders, and you can come back anytime.** Ask me for:
- Name, role, organization
- Email addresses and GitHub username
- Machine description(s)
- Focus areas
- Any language-specific coding rules to add (e.g., Python/ML, Rust, Go — there's an example in the README)

## Step 5: Overview

After setup, give a concise overview. Keep it brief — the user can explore details later. Cover:

### How It Works (the essentials)
- **The OS analogy**: CLAUDE.md is the kernel (always loaded, defines all behavior). Project files are user space. Slash commands are syscalls. Git is the network stack.
- **Three-file system** per project: CONTEXT.md (current state — hot, always loaded), KNOWLEDGE.md (project knowledge — warm, section-loaded on demand), RECORDS.md (historical data — cold, grep on demand)
- **Handoff/reload cycle**: say "handoff" or `/handoff` to save state → `/reload` to restore next session. Context usage ≥70% → statusline turns red, Claude reminds you to handoff
- **Git-based sync**: SessionEnd hook auto-commits and pushes; session start pulls latest
- **Knowledge quality**: every piece of knowledge is tagged `[fact]`, `[observation]`, or `[inference]` — only verified knowledge enters long-term storage

### Key Commands
| Command | What it does |
|---------|-------------|
| `/handoff` | Save all project state + git sync |
| `/reload` or `/reload <project>` | Restore context from files |
| `/deduce <problem>` | Structured hypothesis-driven debugging |
| `/refactor` | Audit and clean OS/project files |
| `/check` | Health check on the installation |

### What Was Installed
Summarize based on the actual install output:
- **Terminal detected**: which one, and whether config was auto-installed or keybindings need manual setup
- **Shell configs**: zsh, bash, tmux (Ctrl+A prefix), vim — symlinked on Mac, embedded on VMs
- **Claude Code**: auto-approved read-only tools, SessionEnd git sync hook, statusline with context usage bar (green → yellow → red at 70%)

### Quick Start
1. Fill in a few `{{placeholders}}` in CLAUDE.md (at minimum: your name)
2. Create your first project: `mkdir -p ~/claude_config/projects/my-project`
3. Start working — Claude will create CONTEXT.md and KNOWLEDGE.md as you go
4. Say "handoff" when you're done. Next session: `/reload my-project`
5. Learnings, pipelines, and feedback will grow organically as you use the system
