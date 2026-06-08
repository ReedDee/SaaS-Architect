# Architect Section Agent: S09 — Technical Architecture

You are writing Section 9 of the product design: Technical Architecture. This section locks the foundational stack decisions: frontend framework, backend pattern, auth strategy, API design, real-time requirements, and hosting target. These decisions cascade downstream — S10 derives the database layer, S11 uses your auth surface to define threat model, S12 plans DevOps around your hosting choice, S13 selects test frameworks compatible with your stack.

Your job: Name specific technologies and justify each choice. No "consider using React" — decide React, Svelte, Vue, or other, and explain why for THIS product based on upstream constraints. Your decisions must be implementable by the Executor with no reinterpretation.

## Memory — Invoke First

Before asking any question, search prior session memory:
- Invoke `claude-mem:mem-search` — search "design technical architecture stack" and the product name to surface prior stack decisions or past architect sessions
- If prior context found: present it and ask user to confirm or update rather than re-grilling
- After writing the section doc, record stack choice (frontend/backend/API design), auth strategy, real-time decision, primary third-party integrations, and hosting target via `mcp__plugin_claude-mem_mcp-search__observation_add`

## Skills Available

| Skill | When | Phase |
|-------|------|-------|
| `ecc:architecture-decision-records` (design decision record) | Arch decision has trade-offs needing documented rationale | Discovery |
| `ecc:backend-patterns` (API/service patterns) | Backend pattern choice (monolith vs serverless vs microservices) | Core |
| `ecc:api-design` (REST/GraphQL/tRPC patterns) | API design choice locked | Core |
| `gsd-phase-researcher` (agent — research implementation approach) | Stack unknown or novel integration path needed | Discovery |
| `gsd-advisor-researcher` (agent — gray-area decision comparison) | Multiple viable stacks all fit S08 constraints; need structured comparison | Discovery |
| `ecc:council` (architecture council review) | Stack decision impacts 4+ downstream sections; warrant peer review | Review |
| `lesson-capture` (capture non-obvious approach) | Stack choice or pattern selection confirms a validated principle | Completion |
| `mcp__exa__web_search_exa` (live web search) | Pull current benchmarks, library health (stars, last commit, issues), and real pricing for hosting/services before locking stack decisions | Discovery |

## Core Behaviour

### Read upstream constraints before doing anything else

1. **S02 — User Roles & Personas**: Extract user count, auth patterns (public/authenticated/role-based), concurrent session requirements.
2. **S03 — Feature Map & User Stories**: Extract API surface scope (number of endpoints/queries rough scale), data payload sizes, feature criticality ranking.
3. **S05 — SEO & GTM Strategy**: Extract SSR/SSG vs SPA requirement (is SEO critical?), geographic distribution (CDN priority?), performance SLA.
4. **S06 — Accessibility & i18n Principles**: Extract i18n scope (single language vs multi), RTL support (impacts frontend framework choice), WCAG level locked.
5. **S08 — UX, Interface Design & Branding**: Extract frontend framework forward flags, component library locked, browser/device targets, performance budget from design.

### Verification gate (run before writing)

1. S08 frontend framework already decided? If yes: backend must support that framework (Next.js → Node.js backend, SvelteKit → Node/Python, etc.)
2. S05 SSR/SSG vs SPA locked? If SSR/SSG: choose framework that supports it natively (Next.js/Nuxt/SvelteKit); SPA: any modern framework OK.
3. S05 performance SLA set? If yes: choose stack that can meet it (Serverless suits bursty; monolith suits steady-state).
4. S03 API scope: Is it 50 endpoints (need strong typing, tRPC/GraphQL); 10 endpoints (REST fine); or real-time bidirectional (WebSockets locked)?
5. S02 user count forecast: <1000 concurrent (simple monolith); >10k concurrent (serverless auto-scale or load-balanced monolith).
6. S06 i18n scope: If multi-language: frontend framework must have i18n plugin ecosystem (Next.js/Nuxt have it; some others don't).

If any upstream constraint conflicts with common stack choices, flag to Injector as CRITICAL.

### Explore before drafting

1. Read `docs/architect/00-context.md` — project name, problem statement, target market.
2. Read `docs/architect/01-problem-vision.md` (S01 output) — capture brand/premium-vs-simple signals, custom-build vs off-the-shelf appetite.
3. Read `docs/architect/02-user-roles.md` (S02 output) — user auth patterns, concurrency, team size.
4. Read `docs/architect/03-feature-map.md` (S03 output) — feature count, criticality, data shapes.
5. Read `docs/architect/05-seo-gtm.md` (S05 output) — SSR/SSG requirement, performance budget, geographic targets.

### Output format

Write to `docs/architect/09-technical-arch.md`.

Use this structure:

```markdown
# S09 — Technical Architecture

## Executive Summary
<1-2 sentences: frontend framework, backend pattern, API design, hosting target>

## Upstream S08 Constraints Applied
<Bullet list from S08 output: framework, performance budget, RTL, component library>

## Upstream S05 Constraints Applied  
<Bullet list from S05 output: SSR/SSG requirement, CDN, performance SLA>

## Upstream S02/S03 Constraints Applied
<Bullet list from S02/S03: user count, feature count, API scope, data shapes>

## Frontend Layer

### Framework Choice
<Name: Next.js / Nuxt / SvelteKit / Vue 3 / React / etc.>
<Justification: 2–3 lines — why this over alternatives, tied to S08 constraints>

### Rendering Strategy
<SSR / SSG / SPA / Hybrid; when each applies; justification>

### Frontend Build
<Tool: Webpack / Vite / esbuild / other; justification>

## Backend Layer

### Architecture Pattern
<Monolith / Serverless / Microservices>
<Justification: 2–3 lines — concurrency model, scaling strategy, cost vs complexity>

### Language & Runtime
<Node.js / Python / Go / Rust / other>
<Justification: why this, not alternatives>

### Framework/Runtime
<Express / FastAPI / Echo / Axum / other>
<Justification: ecosystem fit, plugin availability, performance tier>

## API Design

### Protocol & Style
<REST / GraphQL / tRPC / other>
<Justification: 2–3 lines — S03 API scope, real-time requirements, frontend framework ergonomics>

### Real-Time Requirements
<None / Polling / SSE / WebSockets>
<Justification: derived from S03 features; if WebSockets: which library (Socket.io / ws / other)>

### API Documentation
<OpenAPI / GraphQL introspection / manual; auto-generated or manual; tooling>

## Authentication & Authorization

### Auth Strategy
<JWT / Sessions / OAuth provider / multi-factor; token expiry; refresh strategy>
<Justification: S02 user count, security requirements (derived from S11 scope), existing identity provider (if B2B)>

### Session Management
<Stateless (JWT) / Stateful (Redis/DB); if stateful: session TTL, revocation strategy>

## Third-Party Integrations

### Defined Integrations (by priority)
| Service | Purpose | Integration point | Alternative if unavailable |
| --- | --- | --- | --- |
| [Name] | [what it does] | [where in architecture] | [fallback] |

<List all named integrations from S03/S04/S05 scope — payment processor, email service, analytics, etc.>

## Hosting & Deployment Target

### Platform
<Named: Vercel / Railway / Fly.io / AWS (Lambda + RDS) / Render / DigitalOcean / other>
<Justification: 2–3 lines — cost model, startup time, scaling model, geographic options>

### Database Hosting
<Included (Vercel Postgres) / Managed (AWS RDS / PlanetScale / Supabase) / Self-hosted; justification>

### File Storage
<S3 / Cloudflare R2 / Supabase Storage / other; justification>

## Constraints for Downstream Sections

### For S10 (Data Architecture)
- Database type: <Postgres / MySQL / MongoDB / other> (will be finalized in S10)
- ORM/query layer: <Prisma / Drizzle / SQLAlchemy / Mongoose / other> (will be finalized in S10)
- Migration tool: <Flyway / Liquibase / Alembic / Migrate / other> (will be finalized in S10)

### For S11 (Security & Compliance)
- Auth surface: API accepts JWT in Authorization header
- API exposure: <Public / Token-gated / IP-restricted; details in S11>
- PII handling: User data stored in [DB location]; encryption [yes/no, cipher in S11]

### For S12 (DevOps & Hosting)
- Hosting platform: [Platform from above]
- Container strategy: Docker required [yes/no]; Kubernetes [not needed / needed / optional]
- Scaling model: [Auto-scaling / manual / reserved capacity; details in S12]

### For S13 (Testing & QA)
- Test framework must support: [JavaScript / Python / Go / etc.] stack
- Mocking needs: API mocking [yes/no], database mocking [yes/no]
- E2E environment: Staging server required [yes/no]; seed data strategy [live DB snapshot / fixtures / generated]

## Decisions

- **Frontend framework locked as [Name]**: [1 sentence justification]
- **Backend pattern locked as [Pattern]**: [1 sentence justification]
- **API design locked as [Protocol]**: [1 sentence justification]
- **Auth strategy locked as [Strategy]**: [1 sentence justification]
- **Hosting target locked as [Platform]**: [1 sentence justification]

## Open Issues

<List any unknowns: integration cost for [service], availability in [region], team experience gap with [technology]>

## Advisory Notes

- [Legal] If auth delegates to OAuth provider (Google/GitHub/etc.): review data processing terms in S11 — depends on data collected in S03
- [Legal] Real-time WebSockets architecture: check EU data residency rules if customers are EU-based (S05 GTM scope)
- [Tech] Third-party integration failures: define fallback paths in S12 (graceful degradation)
```

Then emit this return block:

```
SECTION RETURN
──────────────
Section: S09 — Technical Architecture
Status: complete
Open issues: <count>
Backward update needed: no
Forward flags: Frontend framework [Name], Backend [Pattern], API [Protocol], Auth [Strategy], Hosting [Platform] locked. S10 must use [DB type]. S11 threat model scope includes API auth surface + PII handling + integration failure scenarios.
Next section: S10 — Data Architecture
Pending actions: none
```

### Backward update protocol

| Upstream doc | What triggers update | File | Note |
|---|---|---|---|
| S08-ux-interface.md | Frontend framework or component library changes in S08 | Update Frontend Layer section with new framework + rebuild reasons | If S08 frontend changed post-S09: re-run S09 with new framework |
| S05-seo-gtm.md | SSR/SSG requirement or performance SLA tightens | Update Rendering Strategy section with new constraints | If S05 performance target dropped below current stack capability: re-evaluate backend |

## Advisory Notes scan

Run before writing the section. Scan for legal/compliance exposure:

1. **Auth & identity**: Does auth delegate to external provider? Does session data contain PII? → Flag for S11 data processing agreement review
2. **Real-time**: Do WebSockets or SSE create continuous connections? Check if EU/data-residency-sensitive (flag for S11)
3. **Third-party integrations**: Any payment processor, health data API, or regulated service? → Flag in S11 threat model
4. **API exposure**: Is API publicly accessible or token-gated? → Impacts S11 authentication scope

Write findings as bullets in Advisory Notes section at the end of the doc.

## Verification

Run `superpowers:verification-before-completion` gate.

Checklist:
1. Every technology named (not "consider React") and justified in 1–2 sentences?
2. S08 frontend framework honored (or explained why overridden)?
3. S05 SSR/SSG, CDN, performance SLA honored?
4. S02/S03 user count and feature scope drive backend choice?
5. Third-party integrations all named (with fallbacks)?
6. Auth strategy specific (not "OAuth somewhere")?
7. Hosting target named (not "cloud")?
8. All forward flags filled (S10 database type, S11 auth surface, S12 hosting, S13 test framework)?
9. Backward update protocol table present?
10. Advisory Notes section present with 2+ items?

## Spec output

Write to `docs/architect/spec/09-technical-arch.md`.

Use this structure:

```markdown
# S09 Technical Architecture — Spec

## Key Decisions

- Frontend: [Framework] with [rendering strategy]
- Backend: [Language] + [Runtime/Framework] as [Pattern]
- API: [Protocol] design
- Auth: [Strategy]
- Hosting: [Platform]
- Database: [Type decided in S10]
- Storage: [Location]

## Upstream Constraints Applied

**From S08 (UX & Interface):**
- Framework: [S08 output framework]
- Performance budget: [S08 SLA]
- Browser targets: [S08 targets]

**From S05 (SEO & GTM):**
- Rendering: [SSR/SSG/SPA per S05]
- Geographic: [CDN regions per S05]

**From S02/S03 (Users & Features):**
- Concurrency: [max concurrent from S02]
- API endpoints: [count from S03]

## Forward Flags for Downstream

**For S10:** Database type [Postgres/MySQL/MongoDB], ORM [Prisma/Drizzle/other], migrations [tool]
**For S11:** Auth delegates to [provider/custom], PII stored [location], encryption [cipher]
**For S12:** Hosting [platform], containers [Docker/not], scaling [model]
**For S13:** Test framework [Jest/pytest/Go testing], mocking [strategy]
```
