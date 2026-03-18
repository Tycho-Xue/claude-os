# Bootstrap Prompt

Copy everything below the line and paste it into a new Claude Code session. It will fork the repo, install everything, and walk you through setup.

---

I want you to set up "Le's Claude OS v2.1" — a persistent knowledge and workflow system that gives you long-term memory, structured project management, and multi-machine sync. Source repo: https://github.com/Tycho-Xue/claude-os

## Step 1: Install

Check if `gh` CLI is available (`which gh`). If not, offer two options: install it (`brew install gh && gh auth login`), or do it manually (fork on GitHub website, then `git clone`).

```bash
if [ -d ~/claude_config ]; then
    echo "~/claude_config already exists."
else
    gh repo fork Tycho-Xue/claude-os ~/claude_config --clone
fi
bash ~/claude_config/dotfiles/install.sh
```

After install, verify the git remote points to the user's fork (not upstream): `cd ~/claude_config && git remote -v`. Origin must be `github.com/<their-username>/...` for multi-machine sync to work.

Check what terminal was detected from the install output. If it's **not Ghostty**, offer to help configure tmux keybindings for their terminal (e.g., for iTerm2: Preferences → Keys → Key Bindings → "Send Hex Codes"). User can skip this.

## Step 2: Knowledge Transfer (if applicable)

If we have conversation history in this session:
- Review what you already know about me (projects, preferences, technical stack, workflow habits)
- Write project-specific info to `projects/<name>/CONTEXT.md` and `KNOWLEDGE.md`
- Write cross-project technical learnings to `learnings/`
- Write reusable workflows to `pipelines/`

This ensures no knowledge is lost during the transition. If no history exists, skip this step.

## Step 3: Personalize CLAUDE.md

Open `~/claude_config/CLAUDE.md` and replace `{{placeholder}}` values. **All of these are optional — the system works with placeholders, and you can come back anytime.** Ask me for:
- Name, role, organization
- Email addresses and GitHub username
- Machine description(s)
- Focus areas
- Any language-specific coding rules to add (e.g., Python/ML, Rust, Go — there's an example in the README)

## Step 4: Overview

After setup, give a concise overview of:

### 1. How It Works
- **Three-file system**: CONTEXT.md (current state, overwritten each handoff), KNOWLEDGE.md (project knowledge, section-loaded), RECORDS.md (cold storage, append-only)
- **Section loading**: Files use `## ` headers; Claude greps headers and reads only what's needed (saves 50-80% context)
- **Handoff/reload cycle**: say "handoff" or `/handoff` to save state → `/reload` to restore next session
- **Git-based sync**: SessionEnd hook auto-commits and pushes; session start pulls latest

### 2. Key Commands
- `/handoff` — save all project state + git sync
- `/reload` or `/reload <project>` — restore context from files
- Context usage ≥70% → statusline turns red, Claude reminds you to handoff

### 3. What Was Installed
Summarize based on the actual install output:
- **Terminal detected**: which one, and whether Ghostty config was auto-installed or keybindings need manual setup
- **Shell configs**: zsh (10K shared history, case-insensitive completion, zoxide/yazi/starship/conda integration), bash, tmux (Ctrl+A prefix, mouse scrolling, dark status bar with green highlights, auto-unsets Claude tokens for security), vim (dark, 4-space tabs)
- **Claude Code**: auto-approved read-only tools (Read, Glob, Grep, git status/diff/log, ls, cat, head, tail, wc, pwd, echo, which), SessionEnd git sync hook, statusline with context usage bar (green→yellow→red at 70%) + model + cost + OS version

### 4. Default Preferences (and why)

**Behavioral:**
| Preference | Why |
|-----------|-----|
| Just do it, don't just give instructions | You're using an agent, not a chatbot |
| Don't summarize after every response | Saves tokens, you can read the diff |
| Plan before non-trivial tasks (3+ steps) | Prevents rushing into dead ends |
| STOP when complexity grows mid-task | The #1 failure mode — pushing through instead of stepping back |
| Verify before reporting done | Prevents false "done!" without checking |
| Write corrections to learnings immediately | No repeated mistakes across sessions |
| Use subagents for complex tasks | Keeps main context clean |

**Coding:**
| Preference | Why |
|-----------|-----|
| Simplicity > abstraction | Over-engineering is the default failure mode |
| Clean, runnable, iterable | Ship working code first |
| Descriptive variable names | No `x`, `y`, `tmp` |
| Comment input/output shapes | Critical for data work, useful everywhere |

**Protocol:**
| Preference | Why |
|-----------|-----|
| Read before writing | No blind edits to code you haven't seen |
| Scratch pad for temp code | `claude_code_scratch_pad/` keeps experiments out of your project |
| Long commands to clipboard | `echo '...' \| pbcopy` — easier than copying from terminal |

### 5. What to Customize
- Add language-specific coding rules for your stack
- Create your first project: `mkdir -p ~/claude_config/projects/<name>`
- Add your dotfiles or modify the existing ones
- Learnings and pipelines will grow organically as you work

### 6. Best Practices
- **Handoff** when context usage hits ~70% or when switching tasks
- **One project = one directory** under `projects/` with its own CONTEXT/KNOWLEDGE/RECORDS
- Claude auto-writes to knowledge files when it learns something reusable — let it
- Use `learnings/` for cross-project insights (e.g., "PyTorch pitfalls")
- Use `pipelines/` for repeatable multi-step workflows
- RECORDS.md is for cold data — write failures and decisions there, not just successes
