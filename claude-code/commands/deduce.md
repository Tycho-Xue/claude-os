---
name: deduce
description: Structured reasoning framework for hard problems. Hypothesis-driven elimination with iterative verification via autopilot loop. Creates deduce_{name}.md scratch file tracking hypotheses + evidence + resolution.
argument-hint: "[problem description or guidance]"
---

Structured reasoning framework for solving hard problems. Uses hypothesis-driven elimination with iterative verification.

Arguments: $ARGUMENTS

## How to parse arguments

$ARGUMENTS contains the problem description + optional user guidance. Parse for:
- **Problem statement**: what needs to be solved
- **User evidence/guidance**: any clues, experiment results, opinions the user provides
- **"just do it"**: skip audit, go straight to verification
- If no arguments, infer the problem from conversation context (recent errors, stuck points, user's last question). Do NOT ask — just frame your best understanding and let user correct in audit.

## Step 1: Frame the problem

**Prior knowledge scan** (before framing): grep `learnings/` for error keywords / domain terms from the problem. Check Resource Map Learnings table for relevant files. Also grep project KNOWLEDGE.md for the error pattern. Record any hits in `## Known Evidence` below.

Create a deduce file at `{project}/resources/deduce_{short_name}.md` (or `claude_code_scratch_pad/deduce_{short_name}.md` if no project). Index it in KNOWLEDGE.md.

Write the initial frame:

```markdown
# Deduce: {problem title}
<!-- started: YYYY-MM-DD HH:MM TZ -->

## Problem
{clearly define what needs to be solved}

## Essence *(optional)*
{abstract one level: what's the nature of the problem}

## Cannot Be *(optional)*
{known impossibilities — narrow the search space}
- {reason}

## Known Evidence
- {extracted from context, conversation, user-provided info}
- {experiment results, logs, known facts}

## Hypotheses
| # | Hypothesis | Likelihood | Verification Cost | Info Gain | Status |
|---|-----------|------------|-------------------|-----------|--------|
| 1 | ... | H/M/L | L/M/H | how many can it eliminate | pending |

## Log
(verification records)

## Resolution
(final conclusion)
```

## Step 2: Build hypotheses + plan

**Axis audit** (mandatory when >=2 hypotheses eliminated OR investigation >1 day):
Before adding more micro-hypotheses, list the full variable space:

| Variable | Current value | Varied? | Vary next? |
|----------|--------------|---------|------------|
| (e.g. model version, config setting, data source, environment, library version...) | | | |

Prioritize NOT-varied macro variables over new micro-hypotheses.

List all plausible hypotheses. For each one, define:
- Verification method (specific commands or steps)
- Expected result (if hypothesis is true vs false)
- Information gain (how many hypotheses can be simultaneously eliminated)

**Prioritize by: information gain > likelihood > verification cost**. Prefer experiments that can cut the hypothesis space in half (bisection).

Create TaskList for visualization:
- Each hypothesis = one task
- Status: pending → in_progress (verifying) → completed (verified)
- Task subject format: `H1: {hypothesis} [H/M/L]`

## Step 3: Audit (default) or execute

**Default**: Show the framed problem + hypotheses table to user, ask:
> "Here's my reasoning framework and verification plan. Want to adjust? Say 'go' to start autopilot."

**User responses**:
- "go" / "start" / "continue" → enter **autopilot mode**: iterate through all hypotheses automatically, one-line status after each step, don't stop unless user interrupts or all done
- "just do it" (in original arguments) → skip audit entirely, go straight to autopilot
- User gives feedback → adjust framework, re-show for audit
- User stays silent → wait for input (audit is a checkpoint)

## Step 4: Iterative verification loop (autopilot)

Runs continuously until: root cause found, all hypotheses exhausted, or user interrupts.

For each hypothesis (by priority order):

1. **Mark task in_progress** — user sees which hypothesis is being tested
2. **Execute verification** — run the commands/checks
3. **Record result** in deduce file `## Log`:
   ```
   - [H1] method: ... → result: ... → conclusion: eliminated / confirmed / needs deeper look
   ```
4. **Update state**:
   - Mark task completed
   - Add new evidence to `## Known Evidence`
   - If eliminated → update `## Cannot Be`
   - If new hypotheses emerge → add to table + create new tasks
   - Re-prioritize remaining hypotheses
5. **One-line status to user** (keep it short — user is monitoring, not reading):
   ```
   H1 eliminated (LR matches) | H2 verifying | 3 hypotheses remaining
   ```
6. **Continue immediately** to next hypothesis — do NOT wait for user input
7. **If user sends a message during autopilot** → pause, process their input (new evidence, redirect, stop), then resume

**Autopilot guardrails**:
- If 3 consecutive hypotheses all eliminated with no new leads → pause and re-frame the problem with user
- If a verification step requires a destructive/risky action → pause and ask
- If root cause found → stop autopilot, present Resolution for user confirmation

## Step 5: Resolution

When root cause is found:
1. Write `## Resolution` in deduce file
2. Update task list — all done
3. Report to user: root cause + proposed fix
4. If fix is code change → ask user to confirm before applying (unless "just do it")
5. Write-back: key findings → project KNOWLEDGE.md, if cross-project → learnings/

## User interaction during deduce

- User can interrupt anytime with new evidence, guidance, or corrections
- User comments → incorporate into `## Known Evidence`, re-evaluate hypotheses
- User says "skip H3" → mark as skipped, move on
- User says "I think it's X" → reprioritize X to top
- User says "stop" → write current state to deduce file, can resume later

## Key principles

- **Bisection > linear**: choose experiments that split the hypothesis space in half
- **Evidence over intuition**: update beliefs based on data, not gut feeling
- **Iterate fast**: quick cheap experiments first, expensive ones last
- **Always update the file**: deduce file is the single source of truth for the investigation
- **Communicate progress**: task list + one-line status after each verification
- **Don't tunnel vision**: if 3 verifications all fail, step back and re-frame the problem
