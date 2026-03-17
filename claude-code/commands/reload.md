Restore project context. Arguments: $ARGUMENTS (optional, project name)

1. **Pull latest**: `cd ~/claude_config && git pull --ff-only`
2. **Determine project**:
   - If a project name is specified ("$ARGUMENTS"), read `~/claude_config/projects/$ARGUMENTS/`
   - If not specified, infer from current working directory, or read the most recently updated project CONTEXT.md via git log
3. **Load project files**:
   - Read `CONTEXT.md` (current status + next steps)
   - Read `KNOWLEDGE.md` (project knowledge)
4. **Report**: Tell user "Le's Claude OS v2.1 loaded" + which project was restored, current status, next steps
