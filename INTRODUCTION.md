# What is Claude OS

**Claude Code is a CPU without an operating system.**

It's powerful — it can write code, debug, search, and reason. But every time it starts, it's a bare machine: it doesn't know who you are, what project you're working on, where yesterday's debug left off, or what mistakes it made last week. You want it to do real work — the kind that spans days, multiple projects, multiple machines — and it structurally can't. Not because it isn't smart enough, but because it has no infrastructure.

**What it's missing isn't memory. It's an operating system.**

Memory is just one function of an OS. What an OS really provides is: turning stateless compute into a stateful, collaborative, self-correcting work environment.

Claude OS is that operating system. It was built by an AI researcher through intensive daily use of Claude Code for research work — iteratively discovered, not designed in one shot. Every mechanism exists because a real problem was hit in practice.

## Architecture

Claude OS solves the same set of problems that computer operating systems solve, just for AI agents instead of hardware:

| Computer OS | Claude OS | Problem Solved |
|-------------|-----------|----------------|
| Memory management | CONTEXT / KNOWLEDGE / RECORDS — three-tier hot/warm/cold separation | Context window = RAM: limited and expensive. Page in on demand, don't load everything |
| File system | File contracts + Resource Map + No ghost file rule | Knowledge needs structured storage, indexing, and format specs |
| File integrity | Knowledge quality (fact / observation / inference tagging + graduation review) | Wrong knowledge is more dangerous than no knowledge — prevent bad data from corrupting long-term storage |
| Process isolation | Task sections (shared reads, isolated writes) | Parallel sessions on the same project can't overwrite each other |
| Security patches | Feedback system + Structure > Rules principle | Mistakes get permanently patched; rules that keep getting violated are upgraded from prose to hooks |
| Network sync | Git + rebase strategy | Same state across multiple machines, conflicts auto-resolved |

## Kernel

Claude Code itself is the **hardware + BIOS** — it has one hardcoded behavior: on startup, it automatically reads `~/.claude/CLAUDE.md`. This is the BIOS loading the bootloader from a fixed address.

CLAUDE.md contains both the **bootloader and the kernel** in a single file:

- `## Boot` is the **bootloader**: `git pull` → load project files according to Loading rules → report status. The startup sequence that decides what to mount next
- Rules + Protocol + Resource Map are the **kernel**: always resident in memory, defining all behavior and managing all resource scheduling. Never paged out

Combining them into one file was a deliberate design decision — they used to be separate (PROTOCOL.md, MEMORY.md, coding-rules.md…), essentially kernel modules loaded independently. The realization was that under a 1M context window, ~2300 tokens is negligible — better to build a **monolithic kernel**, load everything at once, and skip the complexity of multi-step boot.

Going further:

- **init system** = Loading protocol (decides what to mount based on context: project work → mount CONTEXT+KNOWLEDGE, technical questions → mount learnings/ on demand)
- **syscalls** = slash commands (`/handoff` = sync+shutdown, `/reload` = mount+init, `/deduce` = gdb, `/refactor` = fsck)
- **user space** = project files, learnings, pipelines — application-layer data, read and written through protocols defined by the kernel

## Result

With the OS installed, Claude is no longer a tool that loses its memory on every restart. It becomes an agent with a working methodology — it knows how to pick up a project, how to manage the reliability of its accumulated knowledge, how to communicate progress, how to self-correct from mistakes, and how to save state at session end so the next session continues seamlessly.

And the system is alive — it grows not just from your own use (every correction becomes a permanent behavioral patch, every hard-won lesson becomes a rule), but also naturally absorbs best practices from the community. When a good pattern appears — like Karpathy's autoresearch append-only log and baseline ratchet — you evaluate it, adapt it, and it slots into the OS's existing structure. The OS isn't a fixed set of rules. It's a framework for continuously absorbing experience and evolving.

It doesn't depend on additional infrastructure — the foundation is just markdown files and git. The real complexity is in the protocol design: what to load, what to persist, how to guarantee knowledge quality, how to maintain consistency across sessions. These designs weren't conceived in one sitting — they were figured out by an AI researcher using Claude Code for daily research work, one lesson at a time, one iteration at a time.

---

> **Most AI agents today operate without an operating system — every user is programming on bare metal. Claude OS is a solution that grew out of daily AI research practice.**
