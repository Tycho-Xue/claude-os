# Le's Claude OS v2.1
# symlink: ~/.claude/CLAUDE.md → ~/claude_config/CLAUDE.md (global)
# Version is manually controlled: bump when structural changes are made

## Identity & Preferences
- {{Your Name}}, {{your role}} @ {{your org}}
- Focus: {{your focus areas}}
- Be direct: just do it, don't just give instructions; don't ask if you can do it
- Don't summarize at the end of every response
- Prioritize fast iteration, parallel projects, tmux + Claude Code
- Temp code, tools, test scripts → `claude_code_scratch_pad/`, don't pollute the main project
- Use subagents for complex tasks to keep main context clean
- Long commands → `echo '...' | pbcopy`

## Rules
### Core
- Read before writing: Read → understand → propose → confirm → apply
- Non-trivial tasks (3+ steps): plan first, don't just rush in
- Getting more complex mid-task → STOP, step back and rethink, don't force it
- Simple tasks: just do it. Non-trivial: pause and ask — is there a simpler approach?
- Don't break existing behavior; breaking changes require confirmation
- Main project code changes require confirmation
- Verify before reporting done — don't assume OK
- When corrected → immediately write to learnings, don't make the same mistake twice
### Coding — Style
- Simplicity > abstraction. Avoid boilerplate, over-engineering, unnecessary helpers
- Clean, runnable, iterable — prioritize code that runs
- Descriptive variable names, not x, y, tmp
- Comment input/output shapes for every function
- Explain non-obvious logic
### Feedback
- Tends to over-complicate. When hitting resistance → STOP and re-plan, don't push through

## Protocol
### Loading (hot data: read all; cold data: on-demand)
1. **Project work**: Read project `CONTEXT.md` + `KNOWLEDGE.md` in full
2. **Technical questions**: Read relevant `learnings/` files in full
3. **Repeated tasks**: Read the specific `pipelines/` pipeline in full
4. **Historical data**: `RECORDS.md` on-demand — Grep `^## ` for headers → read relevant section → read full only when needed
5. **Cross-project search**: `grep -r "^## " projects/*/KNOWLEDGE.md` to locate, then read relevant files
### Write-back
- Write more rather than less, compress later. Better to over-record than miss useful info. But keep language concise — no filler.
- Trigger: when completing a task / solving a problem / getting results / discovering new insight — proactively decide what to write
- When corrected → immediately write to `learnings/` or CLAUDE.md Feedback
1. `CONTEXT.md`: Overwrite with current state only (keep concise, just enough)
2. `KNOWLEDGE.md`: Append new discoveries, compress when too long, outdated content → Archive
3. `RECORDS.md`: Cold data, don't compress, write anything valuable, don't wait for handoff
   - Content: results, milestones, decision turning points, **failure analysis**
   - Format: `## YYYY-MM-DD HH:MM Title`, timestamped for review
4. `learnings/`: Cross-project reusable experience
5. `pipelines/`: When discovering repeated workflows or multi-step reusable tasks, proactively suggest creating a pipeline
6. `secrets/credentials.md`: Update when credentials change
### File Contracts
- **CONTEXT.md**: Concise: status + next steps. No history, no commands, no setup
- **KNOWLEDGE.md**: `## ` sections, Archive at the bottom
- **RECORDS.md**: `## YYYY-MM-DD HH:MM Title` format, cold data, includes failure experiences
### Sync
- Primary machine: `~/claude_config/`; Remote machines: `~/claude_config/` + symlink
- **Session start**: `cd ~/claude_config && git pull --ff-only`
- **Session end**: hook runs `git fetch origin && git rebase origin/main`, then `git add -A && git commit && git push` (background)
- **Why rebase**: when working on multiple machines in parallel, without rebase you'll overwrite another machine's updates with stale files
- **Conflicts**: `git fetch origin && git reset --hard origin/main`
- **settings.json**: Each machine has its own `~/.claude/settings.json`, not in the repo. Changing hook logic requires **updating each machine separately**
### Handoff
- User says "handoff", "save", "switch", etc. → execute handoff protocol
- Also available via `/handoff` slash command; restore with `/reload` or `/reload <project-name>`
- When context usage ≥70%, proactively remind user to handoff (statusline turns red)
- Handoff = write-back (CONTEXT + KNOWLEDGE + RECORDS) → git commit + push
- SessionEnd hook auto-executes sync

## Environment
### Accounts
- Personal: {{your-email@example.com}}
- Work: {{work-email@example.com}}
- GitHub: {{your-github-username}}
### Machines
- Primary: {{your machine description}}
- Remote: {{your remote machines, if any}}
### SSH + tmux Rules
- When user mentions a VM → read SSH config to confirm host name, then `ssh <host>`
- Claude-opened tmux sessions use `claude/<task>` naming (e.g., `claude/training`) to distinguish AI/human operations
- Long-running tasks must run inside tmux to survive disconnects

## Resource Map
### Projects
| Project | Status | One-liner | Machine |
|---------|--------|-----------|---------|
| {{project-name}} | {{Active/Paused/Done}} | {{description}} | {{machine}} |
### Learnings (`learnings/`)
| Topic | File | Summary |
|-------|------|---------|
| {{topic}} | {{filename}}.md | {{brief summary}} |
### Pipelines (`pipelines/`)
| Pipeline | File | When to Use |
|----------|------|-------------|
| {{pipeline}} | {{filename}}.md | {{when to use}} |
### Secrets (`secrets/`)
- `credentials.md` — API keys, tokens, SSH keys (gitignored sensitive values)

## Boot (execute on first interaction of each new session)
1. `cd ~/claude_config && git pull --ff-only`
2. Load current project files per Loading rules
3. Tell user: Loaded Le's Claude OS v2.1 + current project status summary

When improving the OS itself, read `~/claude_config/DESIGN.md`. Living document — update when new info is discovered.
