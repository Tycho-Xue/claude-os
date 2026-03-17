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
- Project `pipelines/`: project-specific workflows
- Project CONTEXT.md uses a `Pipelines:` field to link to relevant pipelines
- Pipelines are templates; KNOWLEDGE.md `## Commands` are instantiated parameters

### Archive Design
- KNOWLEDGE.md bottom `## Archive` section
- One line per entry: date + conclusion
- When compressing, outdated content demotes to Archive rather than being deleted
- Separate section = won't be accidentally loaded during section loading

### RECORDS.md
- Project-level historical data (benchmark results, performance data, milestones)
- Cold data, not loaded proactively — Grep headers for on-demand reading
- Never compressed — cold data doesn't consume context, preserve full detail

### Sync Mechanism
- git-based multi-machine sync with rebase strategy
- SessionEnd hook: `git fetch && rebase && add && commit && push` (background)
- Why rebase over merge: prevents stale files from overwriting parallel updates
- settings.json stays per-machine (not in repo) since hook config may differ

### Dotfiles Management
- `dotfiles/` directory stores all config files (terminal, tmux, shell, etc.)
- Primary machine: `install.sh` creates symlinks — repo is the source of truth
- Remote VMs: `vm-bootstrap.sh` embeds minimal configs inline (no symlink dependency)
