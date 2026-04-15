/refactor — Audit and clean up OS files

Arguments: $ARGUMENTS (fuzzy match: project name → that project's files, `os` → CLAUDE.md + DESIGN.md, no argument → current project. If ambiguous, ask user)

## Phase 1: Read-only Audit

1. Determine scope (fuzzy match argument → Resource Map project name / file name)
2. Read target files (CLAUDE.md or project KNOWLEDGE/CONTEXT/RECORDS)
3. Check against the checklist below
4. Output a graded report:
   - HIGH: conflicting/misleading entries (specific lines + problem)
   - MED: untagged/stale/conditions changed
   - LOW: duplicates/formatting/index gaps
   - UNCERTAIN: ask user to decide
5. If nothing found → "all clean", make no changes

## Phase 2: Execute after user review

- User says "fix all" / "only fix HIGH" / confirms per-item
- Don't delete — archive instead (`## Archive` section + RECORDS pointer)
- Before editing, grep for `[[]]` references and update broken links
- After changes, commit and push claude_config

## CLAUDE.md Checklist

1. Feedback duplicates/contradictions
2. Rule conflicts (different sections recommend opposite actions)
3. Resource Map outdated (wrong project status, missing new projects)
4. Environment outdated (machines/accounts changed)
5. Total line count (whether compression is needed)
6. Feedback already internalized (mistakes no longer made, can demote or remove)

## Project Checklist

**HIGH (potentially misleading):**
1. Conflicting entries — same topic, two contradictory conclusions
2. `[inference]` mixed into KNOWLEDGE — should be in CONTEXT or archive
3. Stale entries — superseded by later fixes but not updated (check against RECORDS fixes)
4. Eliminated hypotheses with flawed elimination methods

**MED:**
5. Untagged entries — missing `[fact]`/`[observation]` tags
6. Observation conditions changed — machine/GPU/config changed, observation may not apply
7. Dead references — referenced file paths/function names don't exist (grep codebase to verify)
8. Cross-project conflict — contradicts parent/sibling project KNOWLEDGE
9. CLAUDE.md Feedback detached — feedback based on problems that have since been fixed

**LOW:**
10. Duplicates — same information repeated within the same file
11. CONTEXT outdated — still lists solved problems as "investigating"
12. Resources Index gaps — files in resources/ but not indexed
13. Broken links — `[[]]` pointing to nonexistent sections
14. Archive bloat — >20 entries, consider cleanup

## Principles

- **Read-only audit first** — report before making any changes
- **Conservative** — mark uncertain items for user decision, don't act unilaterally
- **Archive, don't delete** — Archive section + RECORDS pointer, always recoverable
- **Priority ordering** — report top issues, don't dump everything
- **Check references** — grep for links before editing, prevent broken references
