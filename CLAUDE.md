# Le's Claude OS v2.2
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
- Must read CHANGELOG.md before modifying OS version (don't assume it doesn't exist — check Resource Map first)
- New files must be indexed immediately — no ghost files (OS-level → Resource Map, project-level → KNOWLEDGE.md)
- Put info in the right place: version changes → CHANGELOG, not RECORDS; OS-level doesn't need separate RECORDS
- Push claude_config changes immediately after modifying, don't wait for session end

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
2. `KNOWLEDGE.md`: Append new discoveries, compress when too long, outdated content → move to project RECORDS.md `## Archive` section (note reason + date)
3. `RECORDS.md`: Cold data, don't compress, write anything valuable, don't wait for handoff
   - Content: results, milestones, decision turning points, **failure analysis**
   - Format: `## YYYY-MM-DD HH:MM Title`, timestamped for review
4. `learnings/`: Cross-project reusable experience. Outdated content → move to `learnings/_archive.md` (note reason + date)
5. `pipelines/`: When discovering repeated workflows or multi-step reusable tasks, proactively suggest creating a pipeline
6. `secrets/credentials.md`: Update when credentials change
7. `CHANGELOG.md`: Write change summary on OS version bump (motivation + specific changes)
8. `DESIGN.md`: Update when OS design principles change (new/modified design principle)
9. `claude-code/`: Sync settings.json / statusline.sh / commands/ changes to repo
10. `dotfiles/`: Sync config file changes to repo (terminal, tmux, shell, etc.)
11. `obsidian/inbox_claude.md`: When user says "note this down" on a remote machine, append here
### File Contracts
- **CONTEXT.md**: Concise: status + next steps. No history, no commands, no setup
- **KNOWLEDGE.md**: `## ` sections, only keep current valid content. Must index all files in the project (including `resources/`)
- **RECORDS.md**: `## YYYY-MM-DD HH:MM Title` format, cold data, includes failure experiences
- **CHANGELOG.md**: `## YYYY-MM-DD HH:MM Title` format, reverse chronological, includes motivation + specific changes
- **resources/**: Project-level non-standard files (pipelines, scripts, trackers, etc.) go here; must be indexed in KNOWLEDGE.md
- **No ghost files**: When creating a new file, it must be registered in the corresponding index (OS-level → Resource Map, project-level → KNOWLEDGE.md). No unindexed files allowed
### Sync
- Primary machine: `~/claude_config/`; Remote machines: `~/claude_config/` + symlink
- **Session start**: `cd ~/claude_config && git pull --ff-only`
- **When claude_config files are modified**: immediately `git add -A && git commit && git push` (don't wait for session end — ensures other machines can use the changes)
- **Session end**: hook runs `git fetch origin && git rebase origin/main`, then `git add -A && git commit && git push` (background)
- **Why rebase**: when working on multiple machines in parallel, without rebase you'll overwrite another machine's updates with stale files
- **Conflicts**: `git fetch origin && git reset --hard origin/main`
- **settings.json**: Each machine has its own `~/.claude/settings.json`, not in the repo. Changing hook logic requires **updating each machine separately**
### Handoff
- User says "handoff", "save", "switch", etc. → execute handoff protocol
- Also available via `/handoff` slash command; restore with `/reload` or `/reload <project-name>`
- When context usage ≥70%, proactively remind user to handoff (statusline turns red)
- Handoff = write-back (CONTEXT + KNOWLEDGE + CHANGELOG) → git commit + push
- Commit message: `handoff(project/session): brief description (YYYY-MM-DD HH:MM timezone)`
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
### Obsidian Transit (`obsidian/`)
- `inbox.md` — Notes written by you on remote machines, synced to vault on triage
- `inbox_claude.md` — Notes written by Claude on remote machines, synced to vault on triage
### OS Meta
- `CHANGELOG.md` — OS version change log (must read before modifying OS version)
- `DESIGN.md` — OS design principles (read when improving the OS itself)
### Claude Code (`claude-code/`)
- `settings.json` — Claude Code shared config (symlinked to `~/.claude/settings.json`)
- `statusline.sh` — Statusline script (OS version + context %)
- `commands/` — Slash commands (symlinked to `~/.claude/commands/`)
### Scripts (`scripts/`)
| Script | File | Purpose |
|--------|------|---------|
| {{script}} | {{filename}} | {{purpose}} |
### Dotfiles (`dotfiles/`)
- `install.sh` — Symlink installer for all config files
- {{List your dotfile directories/files here}}

## Obsidian Management (Optional)

> This section is optional. Remove it if you don't use Obsidian.

Vault path: `{{~/path/to/your/vault/}}`, Local REST API port {{27124}}

### Structure (work/)
```
work/
├── inbox.md              ← The only place you need to write
├── TODO.md               ← Claude maintains the active TODO list (master list)
├── focus.md              ← Current focus: ≤3 items (use Hover Editor to float)
├── projects/             ← One file per project
├── knowledge.md          ← Technical knowledge, experience, insights
├── ideas.md              ← Research ideas
├── log/                  ← Daily log/journal (YYYY-MM-DD.md)
├── personal.md           ← Non-work items
└── archive/              ← Processed inbox entries
```

### VM → Local Sync (claude_config/obsidian/)
- `obsidian/inbox.md` — Notes you write on remote machines
- `obsidian/inbox_claude.md` — Notes Claude writes on remote machines (when you say "note this down")
- Remote machines can't access the Obsidian vault directly; sync via claude_config git
- During local triage, check both files, move content to vault, then clear them

### Classification Rules
- **Contains action item** (things to do) → extract to `TODO.md`
- **Project-related** → `projects/{name}.md`
- **Technical experience / lessons** → `knowledge.md`; if also useful for Claude → also write to `learnings/`
- **Research ideas** → `ideas.md`
- **Journal / reflection** → `log/YYYY-MM-DD.md`
- **Personal matters** → `personal.md`
- **Credentials / secrets** → migrate to `secrets/credentials.md`, don't store in vault

### Processing Principles
- No information loss — write more rather than less
- All entries must have a date tag: `<!-- YYYY-MM-DD -->` or `<!-- YYYY-MM-DD, from inbox -->`
- Processed inbox entries → move original to `archive/YYYY-MM.md` (monthly archive, don't delete)
- Early on, confirm classification for each item; automate gradually as trust builds
- When corrected on classification → immediately update rules in this section
- TODO.md has `## Work` and `## Personal` sections
- focus.md: max 3 items, picked from TODO (you decide or Claude suggests)
- Completing a focus item → mark `[x]` + completion date → write `log/YYYY-MM-DD.md` → remove from focus → add new one
- Month-end: batch archive completed TODO items to log

### Note-Taking (Remote Machines)
- You say "note this down" / "remember this" → Claude writes to `claude_config/obsidian/inbox_claude.md`
- You want to write it yourself → write to `claude_config/obsidian/inbox.md`
- Format: `- content <!-- YYYY-MM-DD -->`, append only

### Trigger
- You say "triage inbox" / "organize inbox" → execute `obsidian-triage` pipeline
- Session start: if inbox.md has new content → proactively notify
- Local triage also checks `claude_config/obsidian/` transit files

## Boot (execute on first interaction of each new session)
1. `cd ~/claude_config && git pull --ff-only`
2. Load current project files per Loading rules
3. Tell user: Loaded Le's Claude OS v2.2 + current project status summary

When improving the OS itself, read `~/claude_config/DESIGN.md`. Living document — update when new info is discovered.
