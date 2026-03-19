# Claude OS — Changelog

Record structural changes to the OS here. Not needed for daily work.

## v2.2 — Obsidian Integration, Stricter File Hygiene, Extended Write-back

Motivation: After daily use, several gaps emerged — notes taken on remote machines had no path back to the knowledge base, outdated KNOWLEDGE content had no clear archive mechanism, and new files were often created without being indexed anywhere. v2.2 closes these gaps.

**New: Obsidian Management section (optional)**
- Vault structure: inbox, TODO, focus, projects/, knowledge, ideas, log/, personal, archive/
- Classification rules and processing principles (no info loss, date tags, monthly archive)
- TODO + focus linkage (max 3 focus items, completion flow)
- VM → local sync via `obsidian/inbox.md` + `inbox_claude.md` in claude_config
- Note-taking rules: "note this down" → inbox_claude.md
- Triage trigger and session-start notification

**Updated: Handoff**
- Commit message format now includes description + timestamp: `handoff(project/session): brief description (YYYY-MM-DD HH:MM timezone)`

**Updated: Sync**
- New rule: when claude_config files are modified → immediately git add + commit + push (don't wait for session end)

**Updated: Write-back (6 → 11 items)**
- Added items 7-11: CHANGELOG.md, DESIGN.md, claude-code/, dotfiles/, obsidian/inbox_claude.md
- KNOWLEDGE outdated content now archives to project RECORDS.md `## Archive` section
- learnings outdated content now archives to `learnings/_archive.md`

**Updated: File Contracts**
- KNOWLEDGE.md: "only keep current valid content" (removed "Archive at bottom"), must index all files including resources/
- Added: resources/ rule (project non-standard files go here, indexed in KNOWLEDGE.md)
- Added: No ghost file rule (new files must be indexed in Resource Map or project KNOWLEDGE.md)
- Added: CHANGELOG.md format description

**Updated: Resource Map**
- Added: Obsidian transit section (obsidian/)
- Added: OS Meta section (CHANGELOG.md, DESIGN.md)
- Added: Claude Code section (settings.json, statusline.sh, commands/)
- Expanded: Scripts and Dotfiles sections

**Updated: Feedback**
- Must read CHANGELOG before modifying OS version
- Must index new files immediately (no ghost files)
- Put info in the right place (version changes → CHANGELOG not RECORDS)
- Push claude_config changes immediately

## v2.1 — Initial Public Release

- Single CLAUDE.md with all always-needed content inlined (~135 lines, ~2300 tokens)
- Three-file project system: CONTEXT.md + KNOWLEDGE.md + RECORDS.md
- Section loading protocol (Grep headers → read fragments, saves 50-80% context)
- SessionEnd hook for auto git sync (rebase strategy)
- Custom statusline with context usage bar (green → yellow → red at 70%)
- `/handoff` and `/reload` slash commands
- Dotfiles: ghostty, tmux, zsh, bash, vim with symlink installer
- VM bootstrap script with 9 CLI tools + no-sudo fallback
