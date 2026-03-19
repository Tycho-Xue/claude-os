# Obsidian Inbox Triage Pipeline

Trigger: user says "triage inbox" / "organize inbox", or session start when inbox has new content

## Flow

### 0. Sync
```
cd ~/claude_config && git pull --rebase
```
Ensure you have the latest notes from remote machines.

### 1. Read
```
Read {{vault_path}}/work/inbox.md
Read ~/claude_config/obsidian/inbox.md (user's own notes from remote machines)
Read ~/claude_config/obsidian/inbox_claude.md (Claude's notes from remote machines)
```

### 2. Parse
- Split into individual entries by `---` or blank lines
- For each entry, identify: type, related project, whether it contains an action item, date

### 3. Classify & Route
For each entry, decide where it goes (refer to CLAUDE.md classification rules):

| Type | Target File | Dual-write |
|------|-------------|------------|
| Action item | `TODO.md` | If it affects project status → also update CONTEXT.md |
| Project-related | `projects/{name}.md` | — |
| Technical experience / lesson | `knowledge.md` | → also `claude_config/learnings/` |
| Research idea | `ideas.md` | — |
| Journal / reflection | `log/YYYY-MM-DD.md` | — |
| Personal matter | `personal.md` | — |
| Credential / secret | Migrate to `claude_config/secrets/` | Remove from vault |

### 4. Write
- Append to target file, don't modify existing content
- Tag new content with source and date: `<!-- from inbox, YYYY-MM-DD -->`
- When updating TODO.md, maintain Work / Personal sections

### 5. Archive
- Move processed entries from inbox.md to `archive/YYYY-MM.md` (monthly archive)
- Clear processed portions of inbox.md
- Clear `claude_config/obsidian/` transit files after processing (keep file headers), then git commit + push

### 6. Report
- Tell user how many entries were processed and where each went
- If any classification is uncertain → list them for user confirmation

## Trust Modes
- **Early stage**: List classification suggestion for each entry → wait for user confirmation → execute
- **Auto mode**: After user explicitly says "auto-process", only ask about uncertain entries

## Rule Updates
- User corrects a classification → update classification rules in CLAUDE.md
- Discover new project name or classification pattern → append rule
