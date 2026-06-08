# Architect Operating Principles

System-level principles that govern agent lifecycle, state management, memory injection, error handling, and hand-offs across all architect agents. These principles are binding — enforced via schema validation, code hooks, and system prompt injection into each agent.

---

## Section A — Agent Lifecycle

### Spawn Triggers

| Agent | Trigger | Input | Output |
|-------|---------|-------|--------|
| Founder Intake | User runs `/architect` on new project | Product idea or blank | Mode selection + product clarity |
| Init | After Founder Intake mode confirmed | Project name + cwd | Scaffold (00-context.md, 00-state.md, etc.) |
| S01–S13 (Section agents) | Injector dispatches sequentially | Prior section's return block + brief | Section doc + return block |
| Brief Writer | After each section S01–S12 completes | Current section doc + next section title | 00-next-section-brief.md |
| Planner | After S13 completes | All 13 section docs + issues + pending work | plan.md + spec.md + prompt.md |
| Executor | After Planner `status: approved` and user confirms | Plan doc + checkpoint (if resuming) | Build tasks, one at a time |
| Tracker | After each section completes or on startup | Section return block (write) or none (retrieve) | 00-state.md + memory observations |
| Change Manager | When user describes change to locked decision during active section | Current section + change description | Re-route to affected section or Injector |
| Injector | On `/architect` resume or section completion | Project cwd + last_completed | Dispatch next section or route to Planner/Executor |

### Lifespan

- **Founder Intake, Init**: Once per project (first time only)
- **Section agents (S01–S13)**: Once per section (each runs to completion, no pausing mid-section)
- **Brief Writer**: Once per section except S13 (S01→brief for S02, S02→brief for S03, etc.)
- **Planner**: Once per project (runs after S13, produces three deliverables)
- **Executor**: Multiple runs (resumes via checkpoint if interrupted)
- **Tracker**: Called by Injector after each section completion + on startup
- **Change Manager**: Ad hoc (only if change detected mid-section)
- **Injector**: One per session (orchestrates pipeline unattended from startup until Planner or Executor)

### No Concurrent Agents Per Project

Only one agent per project at a time. Injector enforces single-agent rule: if a section agent is running and user invokes `/architect` from same cwd, Injector detects collision and routes to resumption or change detection, not parallel spawn.

---

## Section B — State Management: Three Layers

### Layer 1 — Files (Cache)

- `docs/architect/00-context.md` — project identity + decisions made + active constraints (human-readable, schema front matter)
- `docs/architect/00-state.md` — current progress + next section + issues count (machine-readable, YAML front matter)
- `docs/architect/[0-9][0-9]-*.md` — section documents (S01–S13, each agent writes one)
- `docs/architect/00-issues.md` — open and resolved issues (reconciled by Tracker after each section)
- `docs/architect/00-next-section-brief.md` — brief for next section (written by Brief Writer)

**Ownership**: All files are cache. Source of truth is Layer 2 (Memory).

**Staleness**: If file timestamp is older than most recent memory observation for same project, file is stale — reconstruct from memory (Tracker retrieve mode).

### Layer 2 — Memory (Source of Truth)

Observations stored in `~/.claude/projects/-Users-Ray--claude/memory/` via `memory_add` calls:

- `section_complete` observations (one per section)
- `decision` observations (one per locked decision, for graphify)
- `issue` observations (one per issue)
- `pending_work` observations (one per pending work item)
- `backward_update` observations (one per flagged revision)
- `planner_complete` observation (one per plan)

All observations must:
- Start with `[<project>]` namespace prefix (e.g. `[kleancost]`)
- Include required fields per observation type schema (`architect-schema.json`)
- Conform to status enums and validation rules
- Be validated before write (see **Step 2c** in architect-tracker.md)

**Ownership**: Tracker is sole writer. All other agents are read-only (query via `smart_search` or `query_corpus`).

### Layer 3 — Corpus (Fast Semantic Search)

Indexed copy of section docs + decisions + constraints for quick retrieval:

- Corpus ID: `architect-<project>` (e.g. `architect-kleancost`)
- Indexed content: decisions, constraints, legal flags, pending work, section summaries (excludes narratives, drafts, internal notes)
- Ownership: Tracker maintains corpus (calls `prime_corpus` after every `memory_add`)
- Staleness rule: If last prime timestamp < last Tracker write timestamp, corpus is stale — Tracker re-primes before next section agent spawns
- Query access: Section agents call `query_corpus` to ask about prior decisions, constraints, legal flags, issues

**Example corpus query** (Section agent asking about prior constraints):
```
query_corpus("architect-kleancost", "What constraints affect monetisation decisions?")
```

---

## Section C — Memory Injection: Start and Exit Hooks

### Start Hook: `architect-session-start.sh`

Fires on `SessionStart` event (when Claude Code starts or `/architect` is invoked).

**Sequence:**

1. Query memory for active architect projects: `smart_search("[<project>] Design state")`
2. For each active project found:
   - Extract `last_completed` + `pending_actions` from observation
   - Prime corpus: `prime_corpus("architect-<project>")`
   - Build context injection block:
     ```
     ARCHITECT CONTEXT LOADED
     Project: <name> | Last: <section> | Next: <section> | Issues: <N> open
     Corpus: architect-<project> primed
     Pending: <action 1>, <action 2>...
     ```
3. Pass injection block to Injector (silent injection to context, no terminal output per user request)
4. If no active project found: print `ARCHITECT READY — no active project`

**Outcome**: When section agent spawns, it has full prior state available in context without re-querying memory.

### Exit Hook: `architect-session-end.sh`

Fires on `Stop` event (when Claude Code session ends or user stops current work).

**Sequence:**

1. Detect if architect files were written this session (check modification timestamps on `docs/architect/*.md`)
2. If yes:
   - Emit session-end observation to memory:
     ```
     [<project>] Session end. Files written: <list>. Pending: <from 00-state.md>.
     ```
   - Flush pending Tracker writes (if `00-state.md` timestamp > last memory observation, record the gap as pending)
3. Print: `ARCHITECT SESSION END — state persisted`

**Outcome**: Session state is captured in memory so next session can resume accurately.

### Graphify Integration

Section agents record structured decision observations (e.g., `[kleancost] Decision S04.1: ...`). These observations are queryable by `/graphify` to build a decision graph on demand:

```
/graphify [kleancost] decision graph
```

Output: Knowledge graph with decisions as nodes, dependencies as edges. No automatic graph generation — only on explicit user `/graphify` request.

---

## Section D — Error Handling

Error handling and crash recovery: see `architect-tracker.md` Crash Recovery section and Section G below.

---

## Section E — Communication Protocol

### Hand-off Mechanism

Section agents communicate via:

1. **File-based hand-off** — Each section agent reads prior section docs, writes its own section doc
2. **Return block** — Agent returns structured block with key metadata (issues count, backward updates needed, forward flags)
3. **Memory observations** — Tracker records section completion + decisions in memory
4. **Brief files** — Brief Writer writes `00-next-section-brief.md` for next section agent to consume

### Return Block Format

Every section agent returns:

```
SECTION RETURN
──────────────
Section: S<N> — <Title>
Status: complete
Open issues: <count>
Backward update needed: <yes/no>
Forward flags: <summary of constraints/decisions for next section>
Next section: S<N+1> — <Title>
Pending actions: <list if any>
```

**Example**:
```
SECTION RETURN
──────────────
Section: S04 — Cost & Monetisation
Status: complete
Open issues: 2 (Stripe integration scope unclear, geo-specific pricing rules for APAC)
Backward update needed: no
Forward flags: Billing model locked as usage-based. Impacts S10 (data metering), S12 (DevOps billing infrastructure).
Next section: S05 — SEO & GTM
Pending actions: Resolve Stripe scope before S05 (affects GTM timeline).
```

### Section Hand-off Flow

S(N) writes output → Tracker records completion + updates state → Brief Writer reads prior section + infers next section needs → Brief Writer writes 00-next-section-brief.md → S(N+1) reads brief + prior docs + verifies via corpus → S(N+1) writes output → loop.

---

## Section F — Agent Constraints

### Permission Table

| Agent | Can read files | Can read memory | Can write files | Can write memory | Can query corpus | Can spawn agents |
|-------|---|---|---|---|---|---|
| S01–S13 (Sections) | Yes (priors + brief) | Via query_corpus | Section docs only | No | Yes | No |
| Brief Writer | Yes (current section, next title) | No | 00-next-section-brief.md only | No | No | No |
| Planner | Yes (all 13 + issues + pending) | Yes (all decisions) | plan.md, spec.md, prompt.md | Via Tracker handoff | Yes | No |
| Executor | Yes (plan.md + checkpoint) | No | Build artifacts only | No | No | No |
| Tracker | Yes (all) | Yes (query for duplicates) | 00-state.md, 00-issues.md | Yes (write observations) | Yes (prime after write) | No |
| Change Manager | Yes (current section + prior decision) | Via query_corpus | No (read-only gate) | Via Tracker handoff | Yes | No |
| Injector | Yes (00-state.md, 00-context.md) | Via query_corpus (for state retrieval) | No (read-only orchestrator) | No | Yes | Yes (spawns section agents) |

### Forbidden Actions

| Action | Why | Who is blocked |
|--------|-----|---|
| Section agent modifies `00-state.md` | State is Tracker's responsibility only — prevents conflicting writes | S01–S13, Brief Writer, Executor |
| Non-Tracker writes to memory | Duplicate observations, inconsistent namespacing, schema violations | S01–S13, Brief Writer, Executor, Change Manager |
| Executor modifies section docs | Section docs are locked after section completion — prevents invalidating Planner assumptions | Executor |
| Agent spawns another agent mid-section | Concurrency rule — single agent per project at a time | All except Injector |
| Change Manager modifies locked decisions directly | Decisions are source of truth in prior section docs — changes routed through Tracker for observation recording | Change Manager |

---

## Section G — Rollback and Recovery

### Section Failure

**Option 1 — Re-run Section**:
1. User invokes `/architect` from same project cwd
2. Injector detects state = partial + last_completed = <prior section>
3. Injector offers: "Section S<N> appears incomplete. Re-run? (yes / no)"
4. If yes: dispatch section agent again from start
5. If no: offer "Skip and move to next section? (yes / no)" — proceed to S<N+1>

**Option 2 — Skip Section**:
1. Injector marks section as `skipped` in `sections_pending`
2. Updates `00-context.md` with `skipped_sections: [<list>]`
3. Proceeds to next section
4. Planner reads `skipped_sections` and adjusts plan accordingly

### Planner Failure

**Symptom**: Planner runs but crashes before writing all three deliverables.

**Recovery**:
1. State preserved: `plan_status` remains in `00-state.md` (not overwritten)
2. Any partial files (e.g., plan.md written, spec.md not) are preserved
3. On next `/architect`, Injector detects `plan_status: pending_approval` and routes to Planner again
4. Planner resumes from checkpoint (reads partial files, completes what is missing)

### Executor Failure

**Symptom**: Executor crashes mid-build.

**Recovery**:
1. Checkpoint file at `docs/architect/.executor-checkpoint.md` preserves last completed task + next task
2. On next invocation, Executor reads checkpoint: `last_completed_task: <name>, next_task: <name>`
3. Executor resumes from next_task (does not re-run last completed task)
4. Build continues unattended

---

## Section H — Concurrency and Isolation

### Single-Agent-Per-Project Guarantee

Only one agent per project runs at a time. Injector enforces via state lock:

1. On startup, Injector reads `00-state.md`
2. If `status: in_progress` and `last_updated` < 5 minutes ago: agent is running, route to resume/change detection
3. If `status: in_progress` and `last_updated` > 5 minutes ago: assume agent crashed, offer recovery
4. Only one dispatch per session

### Cross-Project Isolation

Multiple projects can run in parallel (across sessions), but memory/corpus must not mix:

1. All observations prefixed with `[<project>]` — prevents queries from other projects
2. Corpus IDs scoped as `architect-<project>` — each project has separate index
3. Session start hook queries `smart_search("[<project>] Design state")` — only loads specified project

**Example**: Running KleanCost S04 and Job Hunt S02 in parallel:
- KleanCost observations: `[kleancost] Design S04 complete. ...`
- Job Hunt observations: `[job-hunt] Design S02 complete. ...`
- Corpus: `architect-kleancost` and `architect-job-hunt` separate
- Each session start loads only its project's context

---

## Section I — Schema Versioning

### Schema Version

Stored in `00-context.md` front matter:

```yaml
---
project: kleancost
cwd: /Users/Ray/projects/kleancost
schema_version: "1.0"
created: 2026-05-28
---
```

### Migration Rules

If schema version changes (e.g., from 1.0 to 1.1), Tracker detects mismatch on startup:

1. Read `schema_version` from `00-context.md`
2. Compare to `architect-schema.json` version
3. If mismatch: apply migration logic before writing any observations
4. Supported migrations: field additions (backward compatible), enum expansions, new observation types
5. Unsupported: field removals, enum contractions (require manual intervention — notify user)

---

## Section J — System Prompts for Agent Injection

Each agent type has its own system prompt defined in its file:

- **Injector**: architect-injector.md — core responsibilities, state management, corpus context injection, autonomous operation loop
- **Section Agents**: architect-s01.md through architect-s13.md — context available, output format, constraints, corpus pattern
- **Brief Writer**: architect-brief-writer.md — decision extraction, semantic context generation, corpus query
- **Tracker**: architect-tracker.md — write mode (state updates, memory record, schema validation, corpus index), retrieve mode (startup recovery)
- **Planner**: architect-planner.md — consolidation, legal synthesis (Phase B), plan/spec output, hand-off to Executor
- **Change Manager**: architect-change-mgmt.md — conflict detection, semantic impact search, backward update resolution
- **Executor**: architect-executor.md — task execution, checkpoint management, spec validation, completion hand-off

Injector injects relevant system context from each agent file when spawning. Refer to individual agent files for full prompt details.
---

## End of Operating Principles

These principles are binding. Extend only with explicit decision to add new sections — do not modify existing sections without documented rationale in memory.

Last updated: 2026-05-28
Version: 1.0
