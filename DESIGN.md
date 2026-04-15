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

### Knowledge Quality (v2.3)
- **KNOWLEDGE = long-term memory (verified)**, CONTEXT = working memory (may contain unverified)
- **Tag system**: `[fact]` (trustworthy, safe to reason from), `[observation]` (phenomenon trustworthy, no causation, check conditions), `[inference]` (may be wrong, don't use to rule out possibilities or override user)
- **Storage separation**: KNOWLEDGE only accepts `[fact]` + `[observation]`. `[inference]` stays in CONTEXT until confirmed and graduated to `[fact]` (graduation review triggered on handoff / branch merge)
- **Traceability**: Every knowledge entry must have reference/conditions. Untraceable = untrustworthy. `[observation]` must record conditions (machine, config, data) so you can judge if it applies to the current scenario
- **Information cocoon is the biggest risk**: Wrong knowledge that goes unchallenged → going in circles. Solutions: confidence tagging + flip hypotheses when stuck + user input takes priority over existing conclusions
- **Motivation**: Previously, inference and fact were stored together in KNOWLEDGE with no distinction. Wrong debug conclusions were treated as facts by later sessions, causing repeated debugging in wrong directions

### KNOWLEDGE Write Design
- **Only write `[fact]` + `[observation]`, same for single and branching** — branches exist to share knowledge and isolate context. A gotcha discovered by the training branch should be immediately visible to the eval branch
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

### Branching Context Model (v2.3)

**Motivation**: The same project often has parallel workflows (training + debug + data prep). Multiple Claude Code sessions or subagents work simultaneously. They need independent context while remaining aware of each other, with clean wrap-up.

**Core idea**: One CONTEXT.md file, two modes that switch automatically. Backwards compatible — single session behavior is unchanged.

**Modes**:
- **Single mode (default)**: `## Master` only — identical to pre-v2.3 behavior
- **Branching mode (when parallel)**: `## Master` + multiple `## Branch: br_xxx` sections

**CONTEXT.md format (branching mode)**:
```markdown
## Master
project-v2: training in progress, simultaneously debugging OOM + preparing data
active: br_training, br_debug, br_data

## Branch: br_training
owner: session "project/br_training"
- cosine LR schedule, step 12000/30000
- [task: agent_eval] running, evaluating checkpoint-10000
next: eval at step 15000

## Branch: br_debug
owner: session "project/br_debug"
- OOM on 8xGPU bs=4, gradient checkpointing config key was wrong
- [→ br_training] after fix, training needs relaunch
next: fix config, small test to verify
```

**Three-point naming alignment (prefix recognition, not hierarchy)**:
```
Type        tmux session                    CC session name             CONTEXT.md
────────────────────────────────────────────────────────────────────────────────────
Master      claude/{project}                {project}                   ## Master
Branch      claude/{project}/br_{name}      {project}/br_{name}         ## Branch: br_{name}
Subagent    claude/{project}/br_{name}/agent_{task}  (or Agent tool inline)  [task: agent_{task}]
```
- See `br_` → branch, see `agent_` → subagent, no prefix → master
- Most subagents are Agent tool inline; only long-running ones get their own session

**Full lifecycle**:

1. **Single → Branching**: When user opens a second parallel session, Master becomes an overview, each session creates its own `## Branch: br_xxx`
2. **During work**:
   - Read: entire CONTEXT.md (naturally aware of all branches)
   - Re-read timing: must read once before starting; during long tasks (after handoff reload, at milestones), proactively re-read to check for updates from other branches (especially `[→ br_self]` markers)
   - Write: only your own `## Branch: br_xxx` section
   - Subagent: inline `[task: agent_xxx]` within parent branch — two-layer cap
   - Subagent completes → branch owner merges results into branch body, deletes `[task: agent_xxx]` block
   - Subagent unexpectedly exits → `[task: agent_xxx]` remains in branch. Branch owner handles on next read: check actual task state, mark done or relaunch, then clean up
   - Cross-branch communication: write in your own branch, tag `[→ br_target]`
   - Temporary data (tables, eval results, conclusions) can live in your branch section
3. **Branch complete → Merge**:
   - Knowledge → append to KNOWLEDGE.md
   - Results/decisions → RECORDS.md
   - Update `## Master` (add outcome summary)
   - Delete your `## Branch: br_xxx` section
   - Remove from Master's `active:` list
4. **Branching → Single**: When the last branch merges, only `## Master` remains — back to single mode

**Read/write matrix**:
| | Read | Write | KNOWLEDGE writes |
|---|---|---|---|
| Single session | entire file | Master | anytime |
| Branch session | entire file | own Branch only | anytime (check duplicates/stale before writing) |
| Subagent | entire file | inline within parent Branch | don't write — hand off to owner |

**Cleanup checklist (on branch merge)**:
1. Valuable findings → KNOWLEDGE.md
2. Results/decisions → RECORDS.md
3. Update Master summary
4. Delete Branch section (including all inline tasks)
5. Remove from active list
6. Verify CONTEXT.md is clean (no orphan branches, no stale tasks)

**Branch abort (abandoning a branch)**:
- User says to drop it → delete branch section + remove from active, don't do knowledge merge
- If there are partial results worth keeping → write to RECORDS first, then delete

**Branch handoff (session runs out of context but task isn't done)**:
- Write current branch state to CONTEXT.md → git push
- New session reads the branch and continues, owner auto-inherits

**What we don't do**:
- No subdirectories or multi-file — one CONTEXT.md is enough
- No branch nesting — session → branch, subagent → inline task, two layers max
- No auto-creating branches — user triggers explicitly

**Conversation tracking (crash recovery)**:

CC conversations live in `~/.claude/projects/{project-hash}/{uuid}.jsonl`. Recording the conv ID in CONTEXT.md enables recovery after crashes.

Format: each section includes `<!-- conv: {uuid} -->`
```markdown
## Master
<!-- last saved: 2026-03-28 14:20 PST -->
<!-- conv: b8b6f0a1-7f68-4643-9803-457c486d77d3 -->
project-v2 training in progress

## Branch: br_training
<!-- conv: def456... -->
owner: session "project/br_training"
```

Lifecycle:
| Event | Action |
|-------|--------|
| Session first writes CONTEXT | Add `<!-- conv: {uuid} -->` |
| Incremental write / handoff | Keep conv ID unchanged |
| New session takes over same branch | Overwrite with new conv ID |
| Branch merge | Delete with section |
| Crash recovery | Read conv ID → `claude --resume {uuid}` or read .jsonl for context |

Prerequisite: `~/.claude/` must be on persistent storage. If lost (e.g., node replacement), conversations can't be recovered — but CONTEXT.md is preserved via git, so progress isn't lost.

**Compatibility with existing OS**:
- Single mode = pre-v2.3 behavior, unchanged
- Handoff: each session writes its own branch + Master summary, git commit push
- Loading: unchanged — read CONTEXT.md + KNOWLEDGE.md, branches are visible for global awareness
- Subagent rules: branch owner = lead, only owner does write-back

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
- 2026-03-27: **v2.3** Branching Context Model — CONTEXT.md supports single/branching dual modes, parallel sessions each write their own branch section, prefix naming (br_/agent_), two-layer cap, full merge/abort/handoff lifecycle. Knowledge Quality system — tag definitions ([fact]/[observation]/[inference]), storage separation, graduation review, anti-cocoon measures
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
