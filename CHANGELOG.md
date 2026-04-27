# Claude OS — Changelog

Record structural changes to the OS here. Not needed for daily work.

## v2.5 — Task Sections, Named Principles, Structured Records

Motivation: The v2.3 Branching Context Model was too heavy for real-world use — its Master/Branch hierarchy and merge ceremony were never actually needed. Meanwhile, core rules lacked clear naming and priority, RECORDS had no consistent structure for quick lookup, and feedback items grew without organization.

**New: Task Sections (replaces Branching Context Model)**
- CONTEXT.md uses flat `## task-name` sections instead of Master/Branch hierarchy
- Each parallel session writes only its own section — no merge ceremony needed
- Task completion: graduation review → delete section. No mode switching
- Much simpler than Branching Model while solving the same core problem (parallel session isolation)

**New: 5 Named Core Principles**
- Understand First, Structure > Rules, Minimal & Surgical, Verify & Record, Communicate Progress
- Each principle has concrete sub-rules explaining how to apply it
- "Structure > Rules" encourages using hooks/contracts/templates instead of adding more prose rules

**New: Structured RECORDS Format**
- Each entry starts with `**Result** / **Runs** / **Lesson**` header, narrative after `### Details`
- Enables quick lookup via `grep "^\*\*Result\*\*:"` without reading full entries

**New: File Ownership Table** (in DESIGN.md)
- Explicit owner and operation rules for every file type
- Three categories: immutable, mutable by Claude, human-governed

**Updated: Feedback**
- Reorganized into three categories: Behavioral, Quality Gates, OS Hygiene
- New items: auth failure → check credentials first; task switching → re-grep KNOWLEDGE; read docs before diving in; cross-branch code verification
- Removed verbose incident descriptions in favor of concise rules

**Updated: Parallel Sessions**
- Simplified naming: `claude/{project}/{task}` (no `br_` prefix)
- Removed: Master section, merge ceremony, branching/single mode distinction
- Kept: conversation tracking, subagent rules, KNOWLEDGE write timing

**Updated: DESIGN.md**
- Task Sections architecture decision (motivation for replacing Branching Model)
- File Ownership table with immutable/mutable/human-governed categories
- Knowledge Quality version updated to v2.4

## v2.3 — Branching Context Model + Knowledge Quality System

Motivation: Projects often have parallel workflows (training + debug + data prep) with multiple Claude Code sessions or subagents working simultaneously. They need independent context while remaining mutually aware, with clean wrap-up. Additionally, the lack of distinction between verified facts and unverified inferences in KNOWLEDGE caused wrong conclusions to persist and mislead later sessions.

**New: Branching Context Model**
- CONTEXT.md supports single/branching dual modes, backwards compatible — single session behavior unchanged
- Branching mode: `## Master` + `## Branch: br_xxx` sections, each session writes only its own section
- Three-point naming alignment: tmux `claude/{project}/br_{name}`, CC session `{project}/br_{name}`, CONTEXT `## Branch: br_{name}`
- Prefix recognition: `br_` = branch, `agent_` = subagent, no prefix = master
- Two-layer cap: session → branch, subagent → inline task within branch
- Full lifecycle: enter branching → read/write isolation during work → branch merge (knowledge→KNOWLEDGE, results→RECORDS) → cleanup → back to single mode
- Branch abort/handoff protocols: abandon deletes section; context exhaustion writes state for new session to continue
- Cross-branch communication via `[→ br_target]` tags
- Conversation tracking: `<!-- conv: {uuid} -->` in CONTEXT sections for crash recovery

**New: Knowledge Quality System**
- Tag system: `[fact]` (verified, safe to reason from), `[observation]` (phenomenon trustworthy, check conditions), `[inference]` (may be wrong, don't use to override user)
- Storage separation: KNOWLEDGE only accepts `[fact]` + `[observation]`; `[inference]` stays in CONTEXT until graduated
- Graduation review on handoff/branch merge: confirmed findings promote to KNOWLEDGE, unconfirmed carry forward
- Anti-cocoon measures: when stuck >30min flip hypotheses; user input always takes priority over existing conclusions
- Write discipline: grep before writing, conflicts must be resolved, no contradictions allowed
- Staged findings in CONTEXT: `### Observations`, `### Eliminated`, `### Active hypotheses`

**New: Slash Commands**
- `/connect {host}` — Establish ControlMaster SSH connection and operate on remote VM
- `/deduce {problem}` — Structured hypothesis-driven reasoning framework with autopilot mode
- `/refactor` — Read-only audit of OS/project files with graded report + conservative cleanup

**New: Coding Rules**
- Python / ML section: import validation, version compatibility, device handling, random seeds, edge cases, complexity annotations
- Infra / Data section: data integrity validation, GPU diagnostics, cloud download blockers, VM storage management

**Updated: Protocol**
- Loading: if KNOWLEDGE has `## Parent:` section, read parent's KNOWLEDGE.md first; learnings loaded on-demand via Resource Map
- Write-back: incremental writing for long tasks (>30 min); graduation review; expanded to 11 write-back targets
- File Contracts: CONTEXT.md branching mode support, staged findings format, conversation tracking; KNOWLEDGE.md section-precise reading pattern, Archive section details

**Updated: Feedback**
- Port conflicts: switch port immediately, don't kill+retry
- Reference implementations: narrow search space when reference works
- Framework integration: audit existing components before writing from scratch
- Don't use Claude Code's built-in memory system (conflicts with OS)
- Never enter plan mode yourself
- Communication: consider user bandwidth, use task lists and terse status lines

**Updated: Obsidian Management**
- Restructured vault: targets.md (battle map), projects/ (one per project), knowledge/ (one per topic), personal_todo.md
- Simplified triage with core principles

**Updated: DESIGN.md**
- New principle: "First principles before adding complexity"
- New sections: Knowledge Quality, KNOWLEDGE Write Design, Learnings Design, Branching Context Model (full specification)

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
