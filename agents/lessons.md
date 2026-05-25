# Agent Lessons

A living rule set. Updated after every correction. Reviewed at every session start.

## Protocol

**After ANY correction from the user:**
1. Write a rule that prevents the exact mistake — not vague, not general
2. Add it under the relevant theme below with the correct `applies:` tag
3. If the same mistake recurs, the rule was not sharp enough — rewrite it, don't add a duplicate
4. Ruthlessly iterate until mistake rate drops

**At session start:**
- Read themes relevant to the current task before acting
- If a rule feels stale or wrong, flag it and update

**Escalation:**
- Same mistake in a second session → also write to `~/.claude/CLAUDE.md` (global)
- When escalating, remove the lower-tier entry to avoid duplication

---

## Theme Index

| Theme | Applies to |
|-------|-----------|
| `identifier-naming` | all |
| `subagent-usage` | orchestrator, planner, executor, injector |
| `completeness-auditing` | orchestrator, all |

---

## Identifier Naming
> applies: all

| # | Rule | Why | Applies when |
|---|------|-----|--------------|
| 1 | When referencing any agent, subagent, section, skill, or tool by identifier, always include its full title and one-line function inline — never the identifier alone. This applies in ALL output forms: prose, tables, audit summaries, lists, closing lines, and transition prompts. Example: "S11 (Accessibility & Internationalisation — WCAG compliance and i18n strategy)" not "S11". If writing a table row that names an S* agent, the cell must include the name — "S11 (Accessibility & Internationalisation — WCAG compliance and i18n strategy)" not just "S11" | Rule already existed; still violated in a summary table. The rule must be followed in every output form without exception | Everywhere: prose, tables, lists, summaries, closing lines, transitions — no exceptions |

---

## Completeness Auditing
> applies: all

| # | Rule | Why | Applies when |
|---|------|-----|--------------|
| 1 | When auditing architect agents for completeness, verify content correctness against current requirements — not just structural presence of headings. A file with all standard sections can still be wrong: a new section absent from a relevance map, stale sequential logic, or a missing protocol are invisible to a structural scan. Check what the content says, not just what sections exist | Declared all agents complete after a surface scan; gaps only found when content was checked against actual requirements | Any completeness audit of agent files, orchestrator logic, or relevance maps |

## Ambiguity Handling
> applies: all

| # | Rule | Why | Applies when |
|---|------|-----|--------------|
| 1 | When a request is ambiguous, ask clarifying questions before doing anything — no agents, no tools, no exploration. A single clarifying question costs near zero; a misread request can waste tens of thousands of tokens on the wrong task. | Launched a full plan-mode exploration for a request that was never properly understood, wasting 84K tokens. | Any time the goal, scope, or target is unclear |

---

## Module and Component Boundaries
> applies: all

| # | Rule | Why | Applies when |
|---|------|-----|--------------|
| 1 | When defining boundaries between modules, components, sections, or services, default to public-interface communication — not total isolation. Components must connect; the constraint is HOW they connect (through declared public interfaces only, never internal imports or direct internal access). Overcorrecting to total isolation blocks legitimate cross-boundary communication and creates a different class of problem. | Rule written as "no cross-module calls" — which would have blocked the executor every time one module needed data from another. User caught it before it shipped. | Any time writing boundary rules, coupling constraints, isolation requirements, or inter-component communication rules in any plan, agent, or architecture doc |

---

## Subagent Usage
> applies: orchestrator, planner, executor, injector

| # | Rule | Why | Applies when |
|---|------|-----|--------------|
| 1 | Use subagents liberally to keep the main context window clean | Main context bloat degrades output quality across long sessions | Whenever work can be delegated to a focused agent |
| 2 | Offload research, exploration, and parallel analysis to subagents | These tasks consume context without producing decisions — keep them out of the main thread | Before grilling, before writing, before reviewing |
| 3 | For complex problems, throw more compute at it via subagents — spawn more, not fewer | Underuse of subagents forces the main agent to degrade; compute is cheaper than context | Any multi-step analysis, contradiction checking, or cross-section validation |
| 4 | One task per subagent for focused execution — never bundle unrelated work into one dispatch | Mixed-task subagents produce mixed-quality output; isolation produces precision | Every subagent dispatch without exception |
