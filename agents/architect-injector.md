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

**Section ordering** (handles non-integer sections):
```
section_order = [1, 2, 2.1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
next_section = section_order[section_order.index(last_completed) + 1]
```

S02.1 is mandatory — never skip it regardless of mode.

**Lite mode filtering:**
```
IF mode == "lite":
  next_section IN [1, 2, 2.1, 3, 4, 5, 9]
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

# Section 2.1 guard: if last_completed == 2 and 2.1 not in state, run 2.1 next
IF current_section == 2 AND "2.1" NOT IN completed_sections:
  next_section = 2.1
```

## Step 1b — Dependency Audit (run once per session)

Before the pipeline loop starts, verify all skill references in the upcoming section agents resolve to installed tools. This catches ghost skills before they cause silent failures.

```bash
# Check for known ghost patterns
grep -rn \
  "ecc:a11y-architect\|ecc:tdd-guide\|ecc:architect\b\|ecc:database-reviewer\|ecc:e2e-runner\|legal-advisor\|gsd-ui-ux-pro-max" \
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

### 5a.5 — Completion-verification gate (REQUIRED)

A written file is NOT proof of a complete section. Before marking any section
complete, verify its content covers what the section was required to produce.
Borrowed from the `verification-before-completion` pattern: evidence before claims.

**Iron rule: no section is "complete" until this gate passes. File existence is not evidence.**

```
required = registry.sections[next_section].required_outputs
doc = read(docs/architect/<NN>-<slug>.md)

FOR each item in required:
  Confirm the doc contains real, specific content addressing it.
  An item FAILS if it is: absent, a placeholder ("consider X", "TBD",
  "to be decided", "[…]"), or a vague restatement of the prompt with no decision.

coverage = (items addressed) / (total required)

IF coverage < 1.0 (any required output missing or hollow):
  Build a HOLLOW REPORT listing each missing/placeholder item.
  Retry ONCE — re-invoke the section agent with:
    "Section incomplete. These required outputs are missing or are placeholders:
     <list>. Produce concrete, buildable content for each. No 'consider X'."
  Re-run this gate on the new output.

  IF still < 1.0 after retry:
    PAUSE. Surface to founder:
      "S<N> is incomplete after retry. Missing: <list>.
       Options: (a) I draft the gaps now, (b) you provide input, (c) accept as-is and log debt."
    Log each unmet item in 00-issues.md tagged [INCOMPLETE-SECTION].
    Do NOT silently mark complete. Only proceed on explicit founder choice.

IF coverage == 1.0:
  Record gate result for Tracker: `gate: pass, coverage: <n>/<n>`.
  Proceed to 5b.
```

This gate enforces Global Lesson #1 (never confirm completeness by structure alone)
and Brief Writer Directive #3 (a developer must be able to build from the doc).
The gate reads only the one section doc just written — no extra context cost beyond ~1 file.

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
  - Pass the 5a.5 gate result (gate: pass | accepted-with-debt, coverage: <n>/<n>)
  - Mark section as complete ONLY IF gate passed (or founder accepted debt)
  - Index section content for corpus
  - Log key decisions in 00-context.md
```

Never dispatch Tracker with "complete" for a section that failed the 5a.5 gate
and was not explicitly accepted by the founder.

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
