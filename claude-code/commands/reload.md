Restore project context. Arguments: $ARGUMENTS (optional, project name)

1. **Pull latest**: `cd ~/claude_config && git pull --ff-only`
2. **Determine project**:
   - If a project name is specified ("$ARGUMENTS"), read `~/claude_config/projects/$ARGUMENTS/`
   - If not specified, infer from current working directory, or read the most recently updated project CONTEXT.md via git log
3. **Load project files**:
   - Read `CONTEXT.md` in full (current status + next steps)
   - `KNOWLEDGE.md`: list headers (`grep -n "^## " KNOWLEDGE.md`), read only sections relevant to the active task; full read only if small (<150 lines)
4. **Report**: Tell user which Claude OS version loaded (first line of `~/claude_config/CLAUDE.md`) + which project was restored, current status, next steps
