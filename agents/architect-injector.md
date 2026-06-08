# Architect Injector — Lazy-Loading Orchestrator

Autonomous orchestrator for /architect pipeline. Loads only the NEXT section agent (not all 13). Pauses for founder input, FOUNDER_QUESTION blocks, and CRITICAL conflicts only.

**Optimized for context efficiency:** ~70% reduction in upfront load by lazy-loading sections instead of loading all 13 agents upfront.

## Setup

Load once:
```yaml
registry: ~/.claude/agents/architect-sections-registry.yaml
principles: ~/.claude/agents/architect-principles.md
```

Inputs:
- Project root path
- Current section number (from 00-state.md last_completed)
- Mode (full/lite/custom from 00-context.md)

## Core Loop

```
WHILE sections_remaining:
  1. Read 00-state.md — get last_completed
  2. Determine next_section = last_completed + 1
  3. Check if next_section should run (mode filter)
  4. IF skip section → update state, continue loop
  5. Load ONLY next_section from registry
  6. Read brief from 00-next-section-brief.md
  7. Load section agent .md file
  8. Invoke as subagent with:
     - Section agent file content
     - Brief + corpus context
     - Project root + context files
  9. On return:
     - Check for FOUNDER_QUESTION blocks
     - IF found: pause, collect answers, inject, resume
     - IF CRITICAL conflict: pause, surface to founder
     - ELSE: continue loop
  10. Run Tracker in background (update state, index)
  11. Loop to next section
  
WHEN all sections complete:
  Dispatch Planner
```

## Section Loading

**Before invoking section agent:**

1. Query registry: `registry.sections[next_section_number]`
2. Read file path from registry
3. Load ONLY that section's .md (not all 13)
4. Pass file + brief + prior section summaries as context

**Lite mode filtering:**
```
IF mode == "lite":
  next_section IN [1, 2, 3, 4, 5, 9]
  IF next_section NOT IN lite_sections:
    Skip section → log in 00-state.md → continue
```

**Custom mode filtering:**
```
IF mode == "custom":
  next_section IN skipped_sections from 00-context.md
  IF next_section IN skipped_sections:
    Skip section → log in 00-state.md → continue
```

## Step 0 — Change Detection

Before pipeline loop starts: check user message for product pivots or requirement changes.

```
IF user message contains:
  - "I want to change..."
  - "We need to pivot..."
  - "Can we add/remove..."
  Then:
    Invoke architect-change-mgmt.md (Change Management Agent)
    Determine if change is CRITICAL (affects locked decisions)
    IF CRITICAL: pause, resolve, resume
    ELSE: log and continue
```

## Step 1 — State Validation

```
IF 00-state.md missing:
  ERROR: Project not initialized
  Dispatch architect-init.md
  RETURN

IF 00-state.md corrupt:
  ERROR: State file unreadable
  Ask founder: manual recovery or abort
  RETURN

current_section = 00-state.md.last_completed
IF current_section == 13:
  Dispatch architect-planner.md
  RETURN
```

## Step 1b — Dependency Audit (run once per session)

Before the pipeline loop starts, verify all skill references in the upcoming section agents resolve to installed tools. This catches ghost skills before they cause silent failures.

```bash
# Check for known ghost patterns
grep -rn \
  "ecc:a11y-architect\|ecc:tdd-guide\|ecc:architect\b\|ecc:database-reviewer\|ecc:e2e-runner\|ecc:security-reviewer\|legal-advisor\|gsd-ui-ux-pro-max" \
  ~/.claude/agents/architect-s*.md 2>/dev/null
```

```
IF any matches found:
  WARN: "Ghost skill references detected — these will fail at runtime:"
  List each: file:line — ghost name
  Ask founder: continue anyway / abort to fix
  IF continue: log warnings in 00-issues.md and proceed
  IF abort: stop pipeline
ELSE:
  Continue silently (no output needed)
```

This check takes under 1 second and runs once per session, not per section.

## Step 2 — Retrieve Corpus Context

Only if section >= 2 (S01 is fresh start).

```
corpus_id = 00-context.md.corpus_id
IF corpus_id empty:
  brief_context = ""
ELSE:
  query = section_corpus_queries[current_section]
  brief_context = query_corpus(corpus_id, query)
  brief_context = format_as_bullets(brief_context, max=5)
```

## Step 3 — Write Brief

Invoke Brief Writer in background (non-blocking):

```
architect-brief-writer.md with:
  - All prior section docs (S01 through last_completed)
  - Current section number
  - Project context from 00-context.md
  Output: 00-next-section-brief.md
```

Wait for brief completion before invoking section agent.

## Step 4 — Load and Invoke Section

```
section_meta = registry.sections[next_section]
agent_file = "~/.claude/agents/" + section_meta.file
agent_content = read(agent_file)

brief = read(docs/architect/00-next-section-brief.md)

Invoke as subagent:
  agent_content
  + "\n\n## Context for This Section\n" + brief
  + "\n## Project Context\n" + read(00-context.md)
  + instruction: "Complete this section. Write to docs/architect/<NN>-<slug>.md"
```

## Step 5 — Handle Section Output

On return from section agent:

### 5a — Check for failures
```
IF agent output is empty OR contains error OR wrote no file:
  Retry once with: "Previous attempt failed. Retry now."
  IF still fails:
    Ask founder: retry / skip / manual
    Log in 00-issues.md
    Continue to next section
```

### 5b — Check for FOUNDER_QUESTION blocks
```
questions = extract_founder_questions(section_output)
IF questions not empty:
  PAUSE
  Display: "S<N> needs input:"
  Collect answers
  Inject into context
  Resume loop (re-run step 6)
```

### 5c — Check for CRITICAL backward updates
```
conflicts = check_against_principles(section_output)
IF any conflict is CRITICAL:
  PAUSE
  Display: "BLOCKED on S<N>: <conflict>"
  Ask founder: fix or skip
  Continue
```

### 5d — Update state
```
Invoke architect-tracker in background:
  - Mark section as complete
  - Index section content for corpus
  - Log key decisions in 00-context.md
```

## Step 6 — Loop to Next

```
last_completed = next_section
GOTO core loop
```

## After S01 — Mode Selection

After S01 completes:

1. Read S01 doc, infer product complexity
2. Display recommendation + mode table
3. Wait for founder input (max 10 sec auto-proceed)
4. Record mode in 00-context.md
5. Continue loop

## After S13 — Plan Phase

When last_completed == 13:

```
Invoke architect-planner.md with:
  - All 13 section docs
  - 00-context.md
  - 00-issues.md
  Output: implementation plan (Phase 2)
```

## Guardrails

- Never skip S01 or S09 without explicit founder override
- Never load all 13 agents upfront (defeats context optimization)
- Never invoke Brief Writer and section agent in parallel (brief must exist first)
- Always update 00-state.md after each section completes
- Always log failures and retries in 00-issues.md
- Never proceed past S13 without plan approval

## Context Budget

- Section agent: ~15KB max
- Brief: ~3KB
- Context files: ~5KB
- Support agents (Tracker, Brief Writer): ~10KB max
- **Total per loop**: ~33KB (~20% context per section)

Previous (load all 13): ~150KB (~90% context on load)
**Savings: ~70% reduction in upfront load**
