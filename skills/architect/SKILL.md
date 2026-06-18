---
name: architect
description: Entry point for the /architect design system. Auto-detects whether to start new, resume, or add to an existing project based on cwd state. No subcommands needed.
suppress_narration: true
auto_approve_subskills: true
---

# /architect

Entry point for the Architect design pipeline. Auto-detects current state (registry, cwd, prior projects). **All detection is silent — no tool output or narration. Only ask when user input is genuinely needed.**

---

## Silent Setup (Steps 0–1)

**On every load, FIRST display open actions:** Read `~/.claude/skills/architect/OPEN-ACTIONS.md` and show its "Pending (resume here)" table to the user before anything else. This is the only non-silent step in setup — it orients the user on where the build left off. If the file is missing, skip silently.

**Then run all of these silently with no terminal output:**

1. Capture optional product brief from command args (e.g. `/architect "A B2B SaaS..."`)
2. Check registry for active projects
3. Detect cwd state:
   - `docs/architect/00-state.md` exists → CONTINUE mode
   - `docs/architect/` missing + code files present → ADD mode
   - Neither → NEW mode
4. Handle CONTINUE → read state, prime corpus, invoke Injector (skip to CONTINUE mode section below — no user prompt)
5. Determine what prompt to show based on detection results

**Output: nothing. No "Detecting...", no tool results, no narration.**

---

## User Prompts (shown only after silent setup completes)

### Opening Menu (hardwired)

```
Hello there. Select what applies:

1. Start a new project with the Architect
2. Add the Architect to an existing project (no Architect yet)
3. Resume work on a project the Architect already started

(1, 2, or 3):
```

---

### Option 1: Start New Project

**Flow:**
1. Ask project name:
```
Project name:
```

2. Confirm cwd:
```
Working directory: <absolute path>
Confirm? (yes / no)
```

3. If confirmed → invoke Injector Step -1.5 (Founder Intake)

4. Injector asks:
```
Describe your product in 2-3 sentences.
Focus: what specific problem does it solve, and for whom?
```

5. Invoke S01 (Problem & Vision) — lock problem statement, market analysis, personas, competitive landscape

6. After S01 completes, display full mode selection table (columns: Section | Skills | Full | Lite | Recommended). Mark ✓ for sections critical to product type based on S01 findings. Then prompt:
```
Based on S01 analysis, select your path:

1. Full — All 13 sections
2. Lite — 7 core sections (S01–S04, S07–S09)
3. Custom — Pick which sections to run

(1, 2, or 3):
```

If user selects 3 (Custom): Show list of all 13 sections and ask which to include:
```
Select sections (comma-separated: "1,2,3,4,7,10,13" or type "all" for Full, "lite" for Lite):
```

7. Invoke Init (Step -2) — scaffold docs/architect/ with selected sections

8. Pipeline continues to S02

---

### Option 2: Add Architect to Existing Project

**Flow:**
1. List all directories with code files but NO `docs/architect/00-state.md`:

```
Which project to add Architect to?

1. <dir_path_1> (has package.json, src/)
2. <dir_path_2> (has requirements.txt, src/)
3. <dir_path_3> (has .git, README.md)

(1, 2, or 3):
```

2. When user picks one → cd to that directory

3. Deploy Architect scaffolding:
   - Create `docs/architect/` folder structure
   - Write initial `00-context.md`, `00-state.md`, `00-issues.md`

4. Architect reads existing project files (README, package.json, requirements.txt, Dockerfile, main source files):
   - Extract: what does this project do? what tech stack? what's the current state?
   - Generate initial context brief

5. Ask clarifications:
```
I read your existing code. Quick clarifications before we formalize the design:

1. Primary purpose of this project? (from your README, I see: <extract>. Correct?)
2. Current tech stack? (I see: <extract>. Complete?)
3. What's missing from the design? (features? architecture? testing strategy?)

Answer each (or skip):
```

6. Pass answers + inferred context → Injector Step -1.5

7. Continue to S01

---

### Option 3: Resume Paused Project

**Flow:**
1. Query registry for projects with `status: in_progress`:

```
Which project to resume?

1. <Project Name> (paused at S07 — UX & Interface Design)
2. <Project Name> (paused at S03 — Feature Map)
3. <Project Name> (paused at S01 — Problem & Vision)

(1, 2, or 3):
```

2. When user picks one → read `docs/architect/00-state.md` from that project's cwd

3. Display tracker brief:

```
Resuming: <project name>
Status: <last_completed> / 13 sections
Last completed: <S<N> title>
Next: <S<N+1> title>
Open issues: <count>
Open blocker issues: <list or none>

Key decisions locked:
  - <top 3 from 00-context.md Decisions Made>

Continuing from S<N+1>...
```

4. Query memory (via Tracker retrieve mode) for corpus context

5. Prime corpus with project observations

6. Invoke Injector with: cwd, project name, last_completed, instruction "Resume pipeline from S<N+1>"

7. Injector continues autonomously from next section

---

## SCAFFOLD

Scaffold is handled entirely by the Init agent (`architect-init.md` / `architect-init-SKILL.md`). It confirms project identity, creates folder structure, writes `00-context.md`, `00-state.md`, `00-issues.md`, and `00-next-section-brief.md` templates, and runs the Skills Check.

### Skills Check (every new install and first use)

Before starting S01, check which recommended skills are installed. Glob for each path:

| Skill | Path to check | Impact if missing |
|---|---|---|
| `ecc:architect` | `~/.claude/plugins/cache/ecc/*/skills/architect/` | S09 produces no module structure — Planner architecture audit enforces nothing |
| `ecc:frontend-patterns` | `~/.claude/plugins/cache/ecc/*/skills/frontend-patterns/` | S08, S09 produce reduced frontend scaffold quality |
| `ecc:backend-patterns` | `~/.claude/plugins/cache/ecc/*/skills/backend-patterns/` | S09, S10 produce reduced API/service layer quality |
| `ecc:database-migrations` | `~/.claude/plugins/cache/ecc/*/skills/database-migrations/` | S10 has no migration strategy |
| `ecc:security-scan` | `~/.claude/plugins/cache/ecc/*/skills/security-scan/` | S11 has no automated security scan |
| `ecc:tdd-workflow` | `~/.claude/plugins/cache/ecc/*/skills/tdd-workflow/` | S13 testing strategy weakened |

**If all installed:** print `✓ All recommended skills installed.` and continue.

**If any missing:**

```
⚙ Recommended skills — install once for best results:

MISSING:
  - ecc:<skill> — <impact>
  ...

INSTALLED:
  - ecc:<skill> ✓
  ...

Install now? (one command installs all ECC skills)
  yes   → run: /plugin install ecc@ecc
  skip  → continue without (gaps logged as issues)
```

If yes: instruct founder to run `/plugin install ecc@ecc`. Wait for confirmation, re-check, then continue.
If skip: log each missing skill as an issue in `docs/architect/00-issues.md` and continue.

This check runs once per project. After it completes, write `skills_gate: complete` to `docs/architect/00-state.md`.

On CONTINUE path: if `skills_gate: complete` already set in `00-state.md` — skip this check entirely.

---

### Hand off to Founder Intake

Do NOT create scaffold files yet. Instead, invoke the Injector (`architect-injector.md` — autonomous orchestrator) as a subagent with:

- Project name (from user input)
- Absolute path to project root
- Instruction: "Start Step -1.5 Founder Intake. Collect product idea, ask clarifying questions if vague, offer council review, ask Full/Lite/Custom mode. Then proceed to Step -2 Init and S01."

The Injector will:
1. **Step -1.5:** Ask about product idea → clarity gate → optional council → mode selection
2. **Step -2:** Create scaffold (init agent)
3. **S01:** Run with answers collected in Step -1.5

Pipeline pauses only for founder input and mode selection after S01.

---

## CONTINUE mode

### Validate cwd anchor

Read `cwd` from `00-state.md` front matter. Compare to actual cwd.

If they do not match:
```
Warning: this design phase was started in <recorded cwd> but you are currently in <actual cwd>.

Proceed anyway? (yes / no)
```

Do not proceed silently if cwd does not match.

### Route to next section

Read `last_completed` and Next Section from `00-state.md`.

If design sections are still in progress (next section is S01–S13): invoke the Injector (`architect-injector.md` — autonomous orchestrator) as a subagent with:
- Absolute path to `docs/architect/`
- Absolute path to project root
- `last_completed` value from `00-state.md`
- Instruction: "Resume pipeline from <next section>. Run autonomously from here."

The Injector will invoke the correct section agent and continue the pipeline unattended.

If all 13 sections complete and plan not started → route to Planner.

If all 13 sections complete and `plan_status: pending_approval` → tell user:
```
Plan is written but awaiting your approval.
Run the Planner to review and approve: use @architect-planner agent.
```

If `plan_status: approved` and `executor_status: not_started` → present confirmation gate:
```
Plan approved. Ready to build.

Product: <product name>
Plan: docs/superpowers/plans/<product_name>-plan.md
Spec: docs/superpowers/plans/<product_name>-spec.md

Start building now? (yes / no)
```

**yes** → tell user exactly:
```
Starting Executor.

Use @architect-executor agent in this directory.
Executor prompt: docs/superpowers/plans/<product_name>-prompt.md

The Executor will pick up from the approved plan and build the product task by task.
```

**no** → tell user:
```
Build paused. Run /architect from this directory when ready to start.
```

If `executor_status: in_progress` → tell user:
```
Execution in progress.
Resume the Executor in this directory:

  Use @architect-executor agent. Executor prompt: docs/superpowers/plans/<product_name>-prompt.md

It will detect the checkpoint and resume from the last completed task.
```

If `plan_status: approved` and `executor_status: not_started` but a `.executor-checkpoint.md` file exists in `docs/architect/` → the Executor started but never updated `executor_status`. Treat as stalled:
```
Executor appears stalled — checkpoint file exists but status was never updated.

Checkpoint: docs/architect/.executor-checkpoint.md
Last task completed: <read from checkpoint file>

Resume the Executor:
  Use @architect-executor agent. Executor prompt: docs/superpowers/plans/<product_name>-prompt.md

It will detect the checkpoint and resume from the last completed task.
```

If `executor_status: complete` → tell user the product build is complete and point them to the First Moves doc at `docs/architect/00-first-moves.md`.

---

## Guardrails

- Never create scaffold files outside the confirmed cwd
- Never skip the identity confirmation step
- Never invoke a section agent if cwd mismatch is unconfirmed
- If `00-state.md` is corrupt or unreadable: stop, tell user, do not overwrite
- If `docs/architect/` has section docs but `00-state.md` is missing: warn, offer to reconstruct state by reading which section files exist

---

## Change detection

Change management is handled automatically by the Injector (architect-injector.md) — not by a separate command. If a user describes a change to something already decided during an active section, the Injector detects it and routes to the Change Management Agent (architect-change-mgmt.md).

---

## Related agents

| Agent | Role |
|---|---|
| `architect-s01-problem-vision.md` | S01 — Problem & Vision |
| `architect-injector.md` | Autonomous orchestrator — drives S01→S13→Planner without waiting for user instruction; pauses only on founder questions and CRITICAL conflicts |
| `architect-planner.md` | Phase 2 — turns all 13 sections into an implementation plan |
| `architect-tracker.md` | Maintains `00-state.md` state file and records memory observations |
| `architect-change-mgmt.md` | Handles product pivots after blueprint decisions are locked |
| `architect-principles.md` | Operating directives — governs all pipeline agents |
