## Claude Code Features & Tools Reference
<!-- Last updated: 2026-03-22 -->

A living reference of Claude Code capabilities. Check for updates when planning complex workflows.

## Session Management
- `/branch` — Fork current conversation from this point. New session inherits full history, both evolve independently. Use for exploring alternative approaches.
- `/resume` — Switch between sessions (shows last 50, with git branch info + message counts)
- `/compact` — Compress conversation history to free context. Auto-triggers at ~98% usage. Lighter than handoff.
- `/clear` — Wipe current session context
- `--fork-session` flag — CLI flag for forking session programmatically

## Agent System

### Subagents (lightweight, single task)
- Run **within** parent's process, get fresh empty context
- Return summary only — intermediate work discarded (saves context)
- Can't spawn nested subagents (one level only)
- Types: Explore (haiku, read-only), Plan (read-only), General-purpose (all tools)
- `isolation: worktree` — agent works in temp git worktree, no file conflicts
- Background agents: `run_in_background: true` or Ctrl+B to background current task

### Agent Teams (heavyweight, collaborative) — Experimental
- Enable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json env
- Each teammate = **separate Claude instance** with own context window
- Communication: file-based JSON inboxes (`~/.claude/teams/{name}/inboxes/`)
- Task coordination: shared task list with flock() file locking
- Teammates can message each other directly (decentralized, no central broker)
- Display modes: in-process (Shift+Down to cycle) or split-pane (tmux/iTerm2)
- Cost: linear scaling — N teammates = ~N× token cost
- Best for: competing hypotheses, multi-perspective review, parallel exploration with discussion
- Limitation: split panes don't work in Ghostty (use tmux mode or in-process)

## Parallel Execution
- `/batch` — Research + plan large-scale changes, execute across 5-30 worktrees in parallel
- Agent teams — True collaborative parallel with communication
- Multiple subagents — Launch in same message for concurrent independent work

## Workflow Commands
- `/handoff` + `/reload` — Claude OS state save/restore (custom)
- `/loop 5m /command` — Run command on recurring interval (default 10m). Good for monitoring.
- `/plan [description]` — Enter plan mode with optional description
- `/effort low|medium|high` — Adjust model thinking depth
- `/simplify` — Review changed code for quality
- `/copy` — Interactive code block picker

## Context Management
- `/branch` → fork context for exploration, return to main if dead end
- `/compact` → compress when context heavy but don't want full handoff
- Subagents → isolate verbose work (tests, searches) from main context
- Agent teams → when tasks need discussion between workers

## Best Practices
- Use Explore agent (haiku) for searches — fast + cheap + doesn't pollute context
- Background long tasks (tests, builds) with Ctrl+B
- `/branch` before risky exploration — safe to abandon
- Agent teams: 3-5 teammates is sweet spot (cost vs coordination benefit)
- Write thorough prompts for agents — they don't inherit your context, only your prompt + CLAUDE.md
