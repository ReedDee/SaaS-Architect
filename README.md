# SaaS Architect

**A 13-agent AI blueprint pipeline for Claude Code.**

Describe your product idea. The system interviews you, makes decisions, and produces a complete implementation plan — with architecture, legal exposure, monetisation, security, DevOps, and a fully specified executor prompt — ready to build.

→ **[See it in action](https://reeddee.github.io/architect-agent-infographic/)**

---

## What it does

You start with an idea. You end with a production-ready blueprint.

The pipeline runs 13 specialist agents in sequence, each building on the last. An autonomous orchestrator drives the pipeline forward without waiting for your input between sections. It only pauses when it needs something only you know.

Every decision is locked, documented, and propagated downstream. The planner synthesises all 13 sections into three deliverables the executor uses to build:

- `plan.md` — phased implementation plan, task by task
- `spec.md` — unified product specification
- `prompt.md` — self-contained executor brief for a fresh Claude session

---

## The pipeline

| # | Section | What it produces |
|---|---------|-----------------|
| S01 | Problem & Vision | Problem statement, success definition, competitive moat |
| S02 | User Roles & Personas | Role model, permission matrix, provisioning model |
| S03 | Feature Map & User Stories | MVP features, acceptance criteria, third-party dependencies |
| S04 | Cost, Monetisation & Stripe | Pricing model, Stripe objects, refund policy, payment flows |
| S05 | SEO & GTM Strategy | Keyword clusters, URL structure, launch plan, sales motion |
| S06 | Accessibility & i18n | WCAG level, language support, RTL strategy, i18n library |
| S07 | Analytics & Tracking | Event taxonomy, consent gate, funnel definitions, attribution |
| S08 | UX, Interface Design & Branding | Design direction, screen inventory, component decisions |
| S09 | Technical Architecture | Stack, module structure, API design, integration map |
| S10 | Data Architecture | Schema, multi-tenancy model, migrations, RLS policies |
| S11 | Security & Compliance | Threat model, auth hardening, OWASP mitigations, pen test plan |
| S12 | DevOps & Hosting | Hosting architecture, CI/CD pipeline, cost estimates |
| S13 | Testing & QA | Test strategy, coverage targets, QA gates |

**Support agents:**

| Agent | Role |
|-------|------|
| Injector | Autonomous orchestrator — drives the pipeline, handles contradictions, routes change requests |
| Planner | Synthesises all 13 sections into plan, spec, and executor prompt |
| Executor | Implements the plan task by task using TDD and spec compliance review |
| Brief Writer | Prepares context brief for each section agent before it runs |
| Change Management | Handles pivots mid-blueprint — propagates changes, flags affected tasks |
| Tracker | Writes pipeline state after each section so work survives session resets |

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/ReedDee/SaaS-Architect/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/ReedDee/SaaS-Architect.git
cp SaaS-Architect/agents/*.md ~/.claude/agents/
```

---

## Usage

From any project directory in Claude Code:

```
/architect
```

The pipeline auto-detects whether you are starting fresh, resuming a session, or have an approved plan ready to execute.

**Modes:**

| Mode | Sections | Best for |
|------|----------|---------|
| Full | All 13 | Multi-role products, B2B, regulated markets, SEO-dependent |
| Lite | S01–S05 + S09 | Solo MVP, single user type, no integrations beyond Stripe |
| Custom | Your choice | Skip sections explicitly, with gap consequences shown |

---

## How it works

```
/architect
    └── Injector (orchestrator)
            ├── S01 → S02 → S03 → ... → S13   (autonomous loop)
            ├── Brief Writer                    (context brief before each section)
            ├── Tracker                         (state written after each section)
            └── Planner
                    ├── plan.md
                    ├── spec.md
                    └── prompt.md
                            └── Executor
                                    └── your product, built
```

The orchestrator runs without stopping. It pauses only when:
- A section agent needs input only the founder can provide
- A critical contradiction between sections must be resolved
- The plan approval gate is reached (before the executor starts)

---

## Design principles

**Ask vs. derive.** Agents ask only what they cannot answer from domain knowledge. WCAG levels, consent gate types, data residency rules — derived automatically. Vision, pricing intent, risk appetite — asked once.

**Locked decisions propagate.** Every decision made in an early section constrains the sections that follow. The orchestrator enforces this. No section relitigates what is already decided.

**Legal in the planner.** Legal exposure is flagged section-by-section in Advisory Notes. The Planner synthesises all flags into a consolidated obligation map and injects T&C, privacy, and compliance tasks directly into the build plan.

**Executor-ready output.** Every section doc must pass one test: could a developer with no prior context read this and know exactly what to build? Specific file paths, schema shapes, config values. No "consider X."

---

## Requirements

**Required:**
- [Claude Code](https://claude.ai/code)
- Agents placed in `~/.claude/agents/`

**Strongly recommended — unlocks full pipeline capability:**

| Plugin / Tool | Install | Used by |
|---------------|---------|---------|
| [ECC](https://github.com/affaan-m/everything-claude-code) | `/plugin install ecc@ecc` | All agents — specialist skills for security, DB, frontend, testing, architecture |
| [Superpowers](https://github.com/anthropics/claude-plugins-official) | `/plugin install superpowers@claude-plugins-official` | Executor, Planner — TDD, subagent-driven development, writing plans |
| [GSD](https://www.npmjs.com/package/get-shit-done-cc) | `npx get-shit-done-cc@latest` | Planner, Executor — discuss, plan, verify, ship workflow |
| [claude-mem](https://github.com/thedotmack/claude-mem) | `/plugin install claude-mem@thedotmack` | All section agents — memory search across sessions |
| [diagram-design](https://github.com/cathrynlavery/diagram-design) | `/plugin install diagram-design@diagram-design` | S09, S10, S11 — architecture and ERD diagrams |
| [frontend-design](https://github.com/anthropics/claude-plugins-official) | `/plugin install frontend-design@claude-plugins-official` | S08 — frontend design patterns |
| [context7](https://github.com/anthropics/claude-plugins-official) | `/plugin install context7@claude-plugins-official` | S04, S06, S09 — live library documentation lookup |

**S08 (UX & Design) specific:**

| Tool | Install | Purpose |
|------|---------|---------|
| [design-taste skill](https://github.com/Leonxlnx/taste-skill) | `npx skills add https://github.com/Leonxlnx/taste-skill` | Anti-slop design enforcement |
| [21st.dev Magic MCP](https://21st.dev) | Via MCP config | Component generation and inspiration |
| [Google Stitch](https://stitch.withgoogle.com) | Google account required | Full-screen mockup generation |
| [v0.dev](https://v0.dev) | No install | Fallback for mockup generation if Stitch unavailable |

**S05 (SEO & GTM) specific:**

| Plugin | Install | Purpose |
|--------|---------|---------|
| [claude-seo](https://github.com/AgriciDaniel/claude-seo) | `/plugin install AgriciDaniel/claude-seo` | Technical SEO patterns |
| [ai-marketing-claude](https://github.com/zubair-trabzada/ai-marketing-claude) | `/plugin install zubair-trabzada/ai-marketing-claude` | GTM playbook, landing page CRO, social calendar |
| [ai-sales-team-claude](https://github.com/zubair-trabzada/ai-sales-team-claude) | `/plugin install zubair-trabzada/ai-sales-team-claude` | B2B ICP, outreach sequences, objection handling |

**Legal (Planner phase):**

| Plugin | Install | Purpose |
|--------|---------|---------|
| [claude-for-legal](https://github.com/anthropics/claude-for-legal) | `/plugin install commercial-legal@claude-for-legal` | Legal synthesis — T&C, privacy, compliance obligations |

> All plugins are optional. The pipeline runs without them and applies built-in fallbacks where tools are missing. ECC and Superpowers deliver the most coverage across the entire system.

---

## License

MIT
