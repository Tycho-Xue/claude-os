Execute Handoff Protocol:

1. **Write-back project files** (`~/claude_config/projects/<project>/`):
   - `CONTEXT.md`: Overwrite with current status + next steps
   - `KNOWLEDGE.md`: Append new discoveries (if any)
   - `RECORDS.md`: Write quantifiable results or milestones (if any)

2. **Write-back CLAUDE.md** (if changed):
   - Feedback: new corrections or preferences
   - Resource Map: new projects, learnings, pipelines
   - Environment: new accounts or machine changes

3. **Git sync**:
   ```bash
   cd ~/claude_config && git add -A && git commit -m "handoff $(date +%Y-%m-%d-%H%M)" && git push
   ```

4. **Notify user**:
   - Handoff complete (list which files were updated)
   - Can `/clear` to free context, then `/reload` to restore

Note: Recognize when the user says "handoff", "save", "switch", "wrap up", etc. and execute this flow.
