# Claude OS — Design Decisions

Read this file when iterating on or improving the claude_config structure. Not needed for daily work.

## Design Principles

1. **Minimum viable context** — Every token has a cost. Only load the minimum info needed for the current task
2. **Structured for selective read** — All files use `## ` sections, supporting Grep to locate + Read specific fragments
3. **Knowledge, not narrative** — Store insights and facts, not processes and stories
4. **Single source of truth** — Each piece of knowledge lives in exactly one place. Project-specific → KNOWLEDGE.md, cross-project → learnings/, workflows → pipelines/. Don't copy, only reference
5. **Self-compressing** — The system actively resists bloat. Outdated content demotes to Archive, redundancies merge, overlong content compresses
6. **Shared & portable** — git-based sync, any machine running Claude Code sees the same knowledge
7. **Absorb useful experience** — After completing a task, proactively judge: will this come up again? If reusable → write to the appropriate file. Not everything is worth recording — only store insights and reusable solutions
8. **First principles before adding complexity** — Before adding new design (files, layers, processes), ask: what's the core problem? What's the simplest solution? Can existing mechanisms handle it? Lesson: a three-layer index is over-engineering when a 5-line table already works

## Key Architecture Decisions

### Single CLAUDE.md (v2.1)
- `~/.claude/CLAUDE.md` symlink → `~/claude_config/CLAUDE.md`
- ~135 lines, globally effective — Claude Code auto-loads it in any directory
- Contains: identity, rules, protocol, environment, resource map, boot sequence
- Rationale: with 1M context window, ~2300 tokens is negligible. Inline everything that's always needed instead of splitting into multiple files that require a multi-step boot sequence

### CONTEXT.md + KNOWLEDGE.md Separation
- CONTEXT.md ≤ ~20 lines = current state, read every time
- KNOWLEDGE.md = project knowledge (setup/gotchas/results/commands), section-loaded on demand
- Rationale: a single large handoff file has poor signal-to-noise ratio. Splitting hot (CONTEXT) from warm (KNOWLEDGE) data optimizes context usage

### Section Loading
- KNOWLEDGE.md and learnings/ use standard `## ` headers
- Grep `^## ` to get headers + line numbers → Read only the needed section
- Saves 50-80% context compared to reading entire files

### Pipeline: Global vs Project-specific
- Global `pipelines/`: cross-project workflows (node-setup, evaluation, training)
- Project-level pipeline: put in `projects/<name>/resources/pipeline.md`
- **Global index rule**: project-level pipelines add a one-line pointer in global `pipelines/` (no content duplication) so cross-project search can discover them
- Project CONTEXT.md uses a `Pipelines:` field to link to relevant pipelines
- Pipelines are templates; KNOWLEDGE.md `## Commands` are instantiated parameters

### Learnings Design
- **Cold data, not preloaded** — CLAUDE.md Resource Map's Learnings table is the only index (read every session). When details are needed, grep or read the source file directly
- **Why not preload**: learnings are cross-project technical knowledge (500+ lines), most sessions don't need them. Preloading wastes context
- **Why no separate INDEX.md**: three-layer index (Resource Map → INDEX.md → source file) adds maintenance cost with little benefit. Resource Map table + grep source file — two layers suffice
- **Content boundary**: only technical knowledge ("how does this thing work"). Behavior rules ("what should you do") go in CLAUDE.md Feedback; project-specific knowledge goes in project KNOWLEDGE
- **Write-back**: when writing learnings, also update the Resource Map Learnings table

### Knowledge Quality (v2.4)
- **KNOWLEDGE = long-term memory (verified)**, CONTEXT = working memory (may contain unverified)
- **Tag system**: `[fact]` (trustworthy, safe to reason from), `[observation]` (phenomenon trustworthy, no causation, check conditions), `[inference]` (may be wrong, don't use to rule out possibilities or override user)
- **Storage separation**: KNOWLEDGE only accepts `[fact]` + `[observation]`. `[inference]` stays in CONTEXT until confirmed and graduated to `[fact]` (graduation review triggered on handoff / task completion)
- **Traceability**: Every knowledge entry must have reference/conditions. Untraceable = untrustworthy. `[observation]` must record conditions (machine, config, data) so you can judge if it applies to the current scenario
- **Information cocoon is the biggest risk**: Wrong knowledge that goes unchallenged → going in circles. Solutions: confidence tagging + flip hypotheses when stuck + user input takes priority over existing conclusions
- **Motivation**: Previously, inference and fact were stored together in KNOWLEDGE with no distinction. Wrong debug conclusions were treated as facts by later sessions, causing repeated debugging in wrong directions

### KNOWLEDGE Write Design
- **Only write `[fact]` + `[observation]`, same for any task section** — knowledge discovered in one task should be immediately visible to others
- **`[inference]` never enters KNOWLEDGE** — stays in CONTEXT's staged findings. On handoff, carry forward all findings from active investigations. Only after confirmation through graduation review does it enter KNOWLEDGE
- **Check for duplicates/stale/conflicts before writing** — grep section headers to locate relevant paragraphs, only read that segment. Conflicts must be resolved
- **Reference material** (trackers, commands, scripts) → put in `resources/`, KNOWLEDGE maintains `## Resources Index`

### Archive Design
- KNOWLEDGE.md: outdated content demotes to bottom `## Archive` section (one line per entry, date + conclusion). Not deleted, not separated into files — section loading naturally isolates it. Clean up when it grows past ~100 lines, don't split
- learnings/: outdated content moves to `learnings/_archive.md` (with reason + date)
- RECORDS.md: cold data — never compressed, never archived, preserve full detail

### RECORDS.md
- Project-level historical data (benchmark results, performance data, milestones)
- Cold data, not loaded proactively — Grep headers for on-demand reading
- Never compressed — cold data doesn't consume context, preserve full detail
- v2.5: structured header format (`**Result** / **Runs** / **Lesson**` + `### Details`) for quick grep-based lookup

### Task Sections (v2.5, replaces Branching Context Model)

**Motivation**: Projects often have parallel workflows (training + debug + data prep) with multiple Claude Code sessions. They need independent context without overwriting each other. The v2.3 Branching Model designed a full Master/Branch hierarchy, merge ceremony, and prefix naming, but turned out to be too heavy in practice.

**Solution**: CONTEXT.md uses flat `## task-name` sections, each session writes only its own. No Master, no merge ceremony, no mode switching.

**CONTEXT.md format**:
```markdown
## training
<!-- conv: abc123 -->
model-v2 iter 5000/30000, job #772
next: eval at iter 10000

## debug-packing
<!-- conv: def456 -->
cu_seqlens: zero-length seq at index 15
next: check packer output
```

**Rules**:
- Read: entire CONTEXT (aware of all tasks)
- Write: only your own section, don't touch others
- New task: add `## section`
- Complete: graduation review (confirmed → KNOWLEDGE, results → RECORDS) → delete section
- Abandon: delete section; write partial results to RECORDS first if valuable
- Subagent: doesn't write CONTEXT, results go to session owner
- Conversation tracking: `<!-- conv: {uuid} -->` per section, for crash recovery via `claude --resume {uuid}`

**Why it replaced the Branching Model**:
- No Master section — section headers themselves are the dashboard
- No merge ceremony — just delete the section
- No `br_` prefix — use descriptive task names
- No mode switching — one task = one section, naturally grows and shrinks
- Single task = single section, identical to pre-v2.3 behavior

### File Ownership (v2.5)

Explicit owner and operation rules for each file:

| File | Owner | Operation Rules |
|------|-------|----------------|
| CLAUDE.md | User | Claude proposes changes, user confirms before applying |
| CONTEXT.md | Claude | Overwrite, session owner only |
| KNOWLEDGE.md | Claude | Append `[fact]`/`[observation]`. Breaking changes need confirmation |
| RECORDS.md | Claude | Append-only, don't edit old entries |
| DESIGN.md | User | Update on architecture changes, Claude proposes user confirms |
| CHANGELOG.md | Claude | Append-only, reverse chronological |
| learnings/*.md | Claude | Cross-project technical knowledge, can update. Behavior rules don't go here |

Categories:
- **Immutable**: RECORDS.md (old entries), CHANGELOG.md (old entries)
- **Mutable by Claude**: CONTEXT.md, KNOWLEDGE.md
- **Human-governed**: CLAUDE.md, DESIGN.md

### Dotfiles Management
- `dotfiles/` directory stores all config files (terminal, tmux, shell, etc.)
- Primary machine: `install.sh` creates symlinks — repo is the source of truth
- Remote VMs: `vm-bootstrap.sh` embeds minimal configs inline (no symlink dependency)

### Sync Mechanism
- git-based multi-machine sync with rebase strategy
- SessionEnd hook: `git fetch && rebase && add && commit && push` (background)
- Why rebase over merge: prevents stale files from overwriting parallel updates
- settings.json stays per-machine (not in repo) since hook config may differ

### CHANGELOG.md
- Records each OS iteration: what changed, why, motivation
- Cold data, not read daily — only referenced when iterating on the OS
- DESIGN.md covers "why it's designed this way", CHANGELOG covers "what changed"

## Open Questions / Future Work

### Obsidian Integration
- Possible integration paths: notes as knowledge source, daily notes as context
- Need to think through boundaries with existing learnings/ system

### Cross-project Collaboration — Project Inheritance
- KNOWLEDGE.md uses `## Parent: <project-name>` to declare inheritance
- Loading reads parent KNOWLEDGE.md first, then the project's own
- No content duplication, only pointers (follows single source of truth)
- Parent updates are automatically inherited by child projects

### KNOWLEDGE.md Bloat and Information Preservation
- Current approach: layered (active vs Archive movement, no deletion); purge only when project is Done (freeze)
- KNOWLEDGE doesn't compress — uses Archive section for outdated content

### RECORDS Cross-project Search
- When projects multiply, `grep -r "^## " projects/*/RECORDS.md` may not be fast enough
- Consider a RECORDS INDEX.md aggregating all project record titles
- Not needed yet while project count is small

## Evolution Log
- 2026-04-27: **v2.5** Task Sections + Structured Records — Branching Model replaced with flat task sections (no Master/merge ceremony), RECORDS.md gets structured header format (`**Result**/**Runs**/**Lesson**` + `### Details`), File Ownership table (immutable/mutable/human-governed). Core rules upgraded to 5 Named Principles (Understand First, Structure > Rules, Minimal & Surgical, Verify & Record, Communicate Progress). Feedback reorganized into Behavioral/Quality Gates/OS Hygiene categories
- 2026-03-27: **v2.3** Branching Context Model + Knowledge Quality — CONTEXT.md supports single/branching dual modes, parallel sessions each write their own branch section, prefix naming (br_/agent_), two-layer cap, full merge/abort/handoff lifecycle. Knowledge Quality system — tag definitions ([fact]/[observation]/[inference]), storage separation, graduation review, anti-cocoon measures
- 2026-03-20: Project Inheritance pattern — `## Parent:` in KNOWLEDGE.md, Loading auto-loads parent
- 2026-03-16: **v2.1** — Merged into single CLAUDE.md (deleted 7 redundant files, ~135 lines ~2300 tokens)
- 2026-03-16: claude-code/ directory added to git (settings.json, statusline.sh, commands/)
- 2026-03-16: statusline showing OS version + context % progress bar (>=70% turns red)
- 2026-03-15: dotfiles/ added to repo, Mac uses symlinks, VM uses bootstrap-embedded configs
- 2026-03-15: RECORDS.md added to each project (cold data historical results, never compressed)
- 2026-03-15: CHANGELOG.md for OS iteration tracking
- 2026-03-14: Merged Cowork + claude_code repos into unified claude_config
- 2026-03-14: HANDOFF/HISTORY/LEARNINGS/PROJECT → CONTEXT + KNOWLEDGE two-file system
- 2026-03-14: Introduced section loading protocol
- 2026-03-14: Introduced bootloader pattern (CLAUDE.md symlink)
- 2026-03-14: SessionEnd hook for automatic git sync (background push)
