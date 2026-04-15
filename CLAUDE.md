# {{Your Name}}'s Claude OS v2.3
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
- Non-trivial tasks (3+ steps): plan first, don't just rush in. Use TaskCreate to build a roadmap so the user can track progress. Mark each step in_progress when starting, completed when done
- Getting more complex mid-task → STOP, step back and rethink, don't force it
- Simple tasks: just do it. Non-trivial: pause and ask — is there a simpler approach?
- Don't break existing behavior; breaking changes require confirmation
- Main project code changes require confirmation
- Verify before reporting done — don't assume OK
- When corrected → immediately write to learnings, don't make the same mistake twice
- Complex tasks → use subagents to keep main context clean
### Knowledge Quality
**Tag definitions and behavior rules** (every knowledge/finding entry must be tagged):
- `[fact]` — Verified fact (documentation, code confirmed, confirmed fix). **Safe to base decisions and reasoning on.** Graduation criteria: deterministic verification (changed X → Y disappeared) or authoritative source
- `[observation]` — Observed phenomenon + conditions when it occurred. **Phenomenon is trustworthy, but does not imply causation. Check if conditions match current scenario before using.**
- `[inference]` — Unverified inference, conclusion drawn from observations. **May be wrong. Do not use it to rule out other possibilities. Do not use it to override user judgment. When stuck, question these entries first.**
**Storage rules**:
- KNOWLEDGE only accepts `[fact]` and `[observation]`. `[inference]` stays in CONTEXT until confirmed and graduated to `[fact]`
- No causal claims in KNOWLEDGE: don't write "X caused Y" unless deterministically verified. Use "X correlated with Y" or "observed X when Y"
**Reference / Conditions**:
- `[fact]` → cite source (doc URL, code path, verification method)
- `[observation]` → note conditions (date, machine, GPU, config, commit, dataset — for reproducibility and applicability)
- `[inference]` (in CONTEXT) → must attach evidence (test scripts, output, commit)
**Eliminated hypotheses** (in CONTEXT): record test method + result + what the hypothesis depended on + when to reconsider
**Anti-cocoon**:
- Stuck >30min: list all related `[inference]` entries, ask "what if the opposite is true?" for each
- **User's new input takes priority > existing knowledge conclusions**. If user says "this might be X", even if knowledge says "X was ruled out", re-verify the elimination method
- `[eliminated]` entries' elimination methods should also be re-examined
**Write discipline**:
- Before writing, grep existing entries. Conflicts must be resolved (update or mark superseded) — no contradictions allowed
- Reference material (trackers, commands, scripts) → put in `resources/`, KNOWLEDGE maintains `## Resources Index`
### Agent & Branching Collaboration
- **Branching Context**: When working in parallel, CONTEXT.md switches from single mode to branching mode (see DESIGN.md for details)
- **Naming alignment**: tmux `claude/{project}/br_{name}`, CC session `{project}/br_{name}`, CONTEXT `## Branch: br_{name}`
- **Prefix recognition**: `br_` = branch, `agent_` = subagent, no prefix = master
- **Read/write isolation**: Read the entire CONTEXT.md (globally aware), only write your own section
- **Re-read**: In branching mode, re-read CONTEXT.md before starting work + at milestones, check for `[→ br_self]` updates from other branches
- **Two-layer cap**: session → `## Branch: br_xxx`, subagent → inline `[task: agent_xxx]` within branch
- **Branch merge**: knowledge → KNOWLEDGE.md, results → RECORDS.md, delete branch section, update Master
- **KNOWLEDGE write timing**: Only write `[fact]` + `[observation]` (same for single and branching). `[inference]` stays in CONTEXT section. On write, check: (1) duplicate? → update (2) stale/conflict? → resolve. Do graduation review on branch merge
- Subagent prompts should include project file paths so the agent reads CONTEXT.md + KNOWLEDGE.md to "inherit" context
- Subagents don't write to claude_config/ or execute handoff — only the branch owner / master session does write-back
- Worktree agents report their git branch name on completion; main session reviews/merges
### Coding — Python / ML
- Imports must actually exist — don't guess APIs
- Check library version compatibility (especially transformers, vllm, torch)
- Don't hardcode `.cuda()` — use `.to(device=device, dtype=dtype)`
- Eval paths use `torch.no_grad()`, release GPU memory
- Set random seeds: torch, numpy, random
- Handle edge cases: batch_size=1, empty input, shape mismatch
- Annotate O(n) complexity, avoid accidental O(n^2)
- JSONL for large datasets, JSON for configs
### Coding — Infra / Data
- When validating data/files, check integrity (size > 0, format, content readable) — not just exists()
- GPU/env issues: diagnose root cause first (check logs, memory, library paths) — don't blindly try parameters
- Before downloading on cloud VMs, anticipate common blockers (IP blocking, token expiry, gated repos)
- **VM root partitions are usually small — large files must go to shared/large storage**. Checkpoints, datasets, model weights, conda envs, logs should not go to `~/` on small-root machines. Always `df -h` first to confirm available space and mount points
### Coding — Style
- Simplicity > abstraction. Avoid boilerplate, over-engineering, unnecessary helpers
- Clean, runnable, iterable — prioritize code that runs
- Descriptive variable names, not x, y, tmp
- Comment input/output shapes for every function
- Explain non-obvious logic
### Feedback
- Tends to over-complicate. When hitting resistance → STOP and re-plan, don't push through
- RECORDS.md is easy to forget. When completing a task, solving a non-trivial problem, or making an architecture decision — must write RECORDS, not just KNOWLEDGE
- Must read CHANGELOG.md before modifying OS version (don't assume it doesn't exist — check Resource Map first)
- New files must be indexed immediately — no ghost files (OS-level → Resource Map, project-level → KNOWLEDGE.md). **Including files written by subagents, user-provided files, and tracker/csv data files** — any new file entering resources/ must be indexed immediately
- Put info in the right place: version changes → CHANGELOG, not RECORDS; OS-level doesn't need separate RECORDS
- Push claude_config changes immediately after modifying, don't wait for session end
- **Port conflicts (Address already in use): switch port immediately, don't kill+retry**. TCP TIME_WAIT is kernel behavior — killing the process doesn't free the port, you need to wait 60s. Correct approach: switch to a different port on first encounter. When writing server/debugger code, make ports configurable from the start (env var)
- **When a reference implementation works = proof it's feasible, use this to narrow the search space**: When a reference proves functionality works, don't blindly debug your own implementation. Ask three questions: (1) Does the target framework have an equivalent built-in? (2) Can you use the target framework's implementation instead of bridging the reference's internals? (3) Can custom code be replaced with framework calls?
- **When integrating new components, audit the framework's existing pieces first — don't write the pipeline from scratch**: Frameworks usually have tokenization, label shifting, loss masking, collation etc. with framework-specific conventions. Writing these from scratch = reinventing wheels + high probability of convention mismatches. Correct approach: (1) List existing framework components; (2) Find the minimum integration point (usually a data adapter); (3) Only write the adapter, use framework code for everything else
- **Don't use Claude Code's built-in memory system** (`~/.claude/projects/.../memory/`). All persistent info must go to the OS system: corrections → CLAUDE.md Feedback; project knowledge → KNOWLEDGE.md; cross-project experience → `learnings/`; results → RECORDS.md. The built-in memory system overlaps completely with the OS — using both creates confusion
- **Never enter plan mode yourself**. When user is in auto/bypass mode, don't call EnterPlanMode — the session will hang waiting for user input. If unsure, continue executing or ask in text
- **Communication should consider user bandwidth**: Users won't read every log line — proactively distill information. (1) For non-trivial tasks, create a task list upfront; mark completed/in_progress so the user can see progress at a glance; (2) Use concise status lines per phase: `done | next | ETA`; on error: `what failed | root cause 1 line | fix 1 line`; (3) When waiting, say what you're waiting for and how long; (4) Don't paste large logs — extract the relevant info; (5) Task lists should tell a narrative: "done → doing → remaining"
- **When encountering non-trivial framework/library errors (not simple OOM or typos), search first, don't guess**: If the error message contains internal function names (like `triton_per_fused_*`, `InductorError`, `nccl_*`) or explicit suggestions (like "Reducing block sizes may help"), this is likely a known framework bug or limitation. Search for 10 seconds > blind attempts for 30 minutes. Also check learnings/ — you may have hit this before

## Protocol
### Loading (hot data: read all; cold data: on-demand)
1. **Project work**: Read project `CONTEXT.md` + `KNOWLEDGE.md` in full; if KNOWLEDGE has `## Parent:` section, read parent's KNOWLEDGE.md first
2. **Technical questions**: Read relevant `learnings/` files on demand (don't preload). Trigger: check Resource Map Learnings table to identify which file is relevant, then read or grep it
3. **Repeated tasks**: Read the specific `pipelines/` pipeline in full
4. **Historical data**: `RECORDS.md` on-demand — Grep `^## ` for headers → read relevant section
5. **Cross-project search**: `grep -r "^## " projects/*/KNOWLEDGE.md` to locate, then read relevant files
### Write-back
- Write more rather than less, compress later. Better to over-record than miss useful info. But keep language concise — no filler.
- Trigger: when completing a task / solving a problem / getting results / discovering new insight — proactively decide what to write
- **Incremental writing**: For long tasks (>30 min), periodically update CONTEXT.md mid-task — don't wait for handoff. Write on each milestone so progress isn't lost if the session unexpectedly ends
- When corrected → immediately write: cross-project experience → `learnings/`; OS behavior/rule corrections → CLAUDE.md Feedback; project-specific → project KNOWLEDGE.md
1. `CONTEXT.md`: Overwrite with current state only (keep concise, just enough). Add `<!-- last saved: YYYY-MM-DD HH:MM TZ -->` on each write
2. `KNOWLEDGE.md`: Only accepts `[fact]` + `[observation]`, must include reference/conditions. `[inference]` stays in CONTEXT
   - **Graduation review on handoff**: Check if CONTEXT has confirmed items that can graduate → confirmed root cause becomes `[fact]` + reference, generalizable observation becomes `[observation]` + conditions, unconfirmed inference stays in CONTEXT carry-forward
   - Branch merge: same graduation review — confirmed → KNOWLEDGE, still investigating → Master CONTEXT, abandoned → discard
   - Before writing, grep section headers to locate relevant section, only read that segment to check for duplicates/stale/conflicts (don't read the whole file). Duplicate → update; stale → mark outdated; conflict → resolve. Outdated content → move to project RECORDS.md `## Archive` section
   - **Resources Index maintenance**: When adding resources/ files, update `## Resources Index` at bottom of KNOWLEDGE
3. `RECORDS.md`: **Must write** when completing a task / getting results / making key decisions / hitting failures — don't wait for handoff
   - Content: results, milestones, decision turning points, **failure analysis** (especially bugs that took >10 min to debug)
   - KNOWLEDGE answers "how to do it", RECORDS answers "what was done and why it was decided that way"
   - Format: `## YYYY-MM-DD HH:MM Title`
4. `CHANGELOG.md`: Write change summary on OS version bump (motivation + specific changes). Format: `## YYYY-MM-DD HH:MM Title`, reverse chronological
5. `DESIGN.md`: Update when OS design principles change (new/modified design principle)
6. `learnings/`: Cross-project reusable **technical knowledge** (not behavior rules — those go in Feedback). Update Resource Map Learnings table after writing. Outdated content → move to `learnings/_archive.md` (note reason + date)
7. `pipelines/`: When discovering repeated workflows or multi-step reusable tasks, proactively suggest creating a pipeline
8. `secrets/credentials.md`: Update when credentials change
9. `claude-code/`: Sync settings.json / statusline.sh / commands/ changes to repo
10. `dotfiles/`: Sync config file changes to repo (terminal, tmux, shell, etc.)
11. `obsidian/inbox_claude.md`: When user says "note this down" on a remote machine, append here
### File Contracts
- **CONTEXT.md**: Concise: status + next steps. No history, no commands, no setup. Add `<!-- last saved: YYYY-MM-DD HH:MM TZ -->` on each write. Supports two modes:
  - Single mode (default): Only `## Master`
  - Branching mode (when parallel): `## Master` + `## Branch: br_xxx` sections, each session writes only its own section
  - Branches can hold temporary data (tables, eval results); move to KNOWLEDGE/RECORDS on merge
  - Cleanup: on merge, delete branch section + remove from active list; when last branch merges, return to single mode
  - **Conversation tracking**: Each section records `<!-- conv: {uuid} -->` (CC conversation ID). Added on first write; kept on incremental writes; overwritten when new session takes over; deleted on branch merge. After crash, read conv ID → `claude --resume {uuid}` to recover
  - **Staged findings**: `[inference]` and `[eliminated]` only live in CONTEXT, never in KNOWLEDGE. **On handoff, all staged findings from active investigations must carry forward** — don't discard just because they're unconfirmed. Only completed/abandoned investigation findings can be dropped. Format (when active investigation exists):
    `### Observations` — phenomena + conditions (when/where/setup)
    `### Eliminated` — ruled-out hypotheses (test method + result + dependencies + when to reconsider)
    `### Active hypotheses` — current hypotheses (marked unconfirmed + evidence)
  - Branching: staged findings live in each branch's CONTEXT section. Graduation review on branch merge
- **KNOWLEDGE.md**: `## ` sections, only keep current valid content. Each entry tagged `[fact]`/`[observation]`. Must index all files in the project (including `resources/`). Maintain `## Records Index` + `## Resources Index` at bottom — auto-update on handoff
  - **Section-precise reading** (don't read the whole file): `grep -n "^## TARGET" FILE` → get start line → `grep -n "^## " FILE | awk -F: '$1 > start {print $1; exit}'` → get next line → `Read(offset=start, limit=next-start)`. If last section (next is empty), omit limit (read to EOF)
  - **Archive section**: `## Archive` at bottom of KNOWLEDGE — one-line summary per outdated entry + RECORDS pointer (e.g., `see RECORDS 2026-04-05 12:40`). Same section-precise reading pattern to jump to RECORDS
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
- When context usage >=70%, proactively remind user to handoff (statusline turns red)
- Handoff = write-back (CONTEXT + KNOWLEDGE + CHANGELOG) → git commit + push
- Branching mode handoff: write your own branch section + Master summary; if last branch, execute merge cleanup
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
- tmux naming: `claude/{project}` (master), `claude/{project}/br_{name}` (branch), `claude/{project}/br_{name}/agent_{task}` (subagent)
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
> **Note**: Vault path and REST API are only needed on the machine where Obsidian runs (typically your local machine).
> On remote VMs, note-taking works out of the box via the `obsidian/` transit files — no Obsidian install or API needed.

### Structure (work/)
```
work/
├── targets.md              ← Your battle map (pinned on screen, links to projects/ and knowledge/)
├── inbox.md                ← Capture entry point (drop anything here, Claude triages)
├── projects/               ← One file per project (context on top + notes)
├── knowledge/              ← Cross-project knowledge (one file per topic)
├── personal_todo.md        ← Work misc + personal items (completed items archive to bottom)
├── secrets.md              ← Credentials (local only, no sync)
├── claude_config/          ← OS repo (git repo, ~/claude_config symlinks here)
└── archive/                ← Processed inbox entries (monthly archive)
```

### VM → Local Sync (claude_config/obsidian/)
- `obsidian/inbox.md` — Notes you write on remote machines
- `obsidian/inbox_claude.md` — Notes Claude writes on remote machines (when you say "note this down")
- Remote machines can't access the Obsidian vault directly; sync via claude_config git
- During local triage, check both files, move content to vault, then clear them

### Triage
- Detailed flow in `pipelines/obsidian-triage.md`
- Core principles: **don't rewrite original text** (only move + link), **archive before clearing**, **scan all sources** (including standalone files in obsidian/ directory), **infer correct project**
- Timestamps in your timezone: `<!-- YYYY-MM-DD HH:MM TZ -->`

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
3. Tell user: Loaded {{Your Name}}'s Claude OS v2.3 + current project status summary

When improving the OS itself, read `~/claude_config/DESIGN.md`. Living document — update when new info is discovered.
