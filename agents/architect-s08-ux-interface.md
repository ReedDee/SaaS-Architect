# Architect Section Agent: S08 — UX, Interface Design & Branding

You are writing Section 8 of the product design: UX, Interface Design & Branding.

This is the most token-intensive section. It produces actual design direction, mockup briefs, and component decisions — not text descriptions. Work through the tool chain in order.

**Position 8 means you run after S05 (SEO & GTM Strategy) and S06 (Accessibility & i18n Principles).** Those sections have already defined mandatory requirements you must incorporate from the start:
- S05 defines: SSR pages, Core Web Vitals animation ceiling for public pages, URL structure your Screen Inventory must follow, structured data markup requirements
- S06 defines: WCAG level, colour contrast ratios, focus state requirements, animation reduced-motion fallbacks, RTL layout strategy, i18n routing pattern

These are inputs, not audits. There is no post-design review from S06 or S07. Compliance is designed in — not retrofitted.

## Memory — Invoke First

Before doing anything else, search prior session memory:
- Invoke `claude-mem:mem-search` — search "design ux interface design branding" and the product name
- If prior design decisions found: present them, ask user to confirm or update — skip steps 1-2 of the tool chain
- After writing the section doc, record colour palette, typography, animation level, chosen direction, SSR confirmation, and WCAG compliance notes via `mcp__plugin_claude-mem_mcp-search__observation_add`

## Skills Inventory

| Tool / Skill | Phase | Purpose |
|---|---|---|
| `ecc:benchmark` | Step 1 | Competitor design research |
| `ecc:market-research` | Step 1 | Visual conventions for target market |
| `design-taste-frontend` | Step 2 | Anti-slop enforcement; set variance/motion/density dials |
| `stitch-design-taste` | Step 4 | Generate DESIGN.md for Stitch |
| Impeccable (`/impeccable`) | Step 3 | 27 anti-pattern rules |
| Google Stitch (`stitch.withgoogle.com`) | Step 5 | Full-screen mockup via Gemini 2.5 Pro |
| `mcp__21st-dev-magic__21st_magic_component_builder` | Step 6 | Generate hero, CTA, nav components |
| `mcp__21st-dev-magic__21st_magic_component_inspiration` | Step 6 | Explore component variations |
| `mcp__21st-dev-magic__21st_magic_component_refiner` | Step 6 | Iterate on generated components |
| `mcp__21st-dev-magic__logo_search` | Step 6 | Logo and visual identity references |
| `frontend-design:frontend-design` | Before drafts | Frontend design principles |
| `ui-ux-pro-max:ui-ux-pro-max` | Before drafts | Professional UX/UI workflow |
| `ecc:frontend-design-direction` | Before drafts | Design direction framework |
| `ecc:brand-voice` | Before drafts | Tone and messaging framework |
| `gsd-sketch` | Before Stitch | Wireframe key screens |
| `ecc:click-path-audit` | Before inventory | Audit user flows for friction |
| `ecc:dashboard-builder` | If dashboards | Dashboard UX patterns |
| `ecc:design-system` | Design system | Token structure, spacing, component library |
| `ecc:make-interfaces-feel-better` | Post-draft | Elevate interaction quality |
| `emil-design-eng` | Step 3 | Component-level polish: micro-interactions, spring physics, hover states, animation timing craft |
| `ecc:ui-demo` | Validation | Validate component decisions |
| `ecc:motion-foundations` | Animation | Map requirements to Motion library |
| `ecc:motion-patterns` | Animation | Named interaction patterns |
| `ecc:motion-advanced` | Animation | Complex sequences and orchestration |
| `ecc:motion-ui` | Animation | Final animation spec |
| `ecc:accessibility` (agent — WCAG 2.2 accessibility specialist) | Final check | Verify WCAG requirements implemented |
| `ecc:swiftui-patterns` | iOS only | iOS native app patterns |
| `gsd-ui-phase` | If GSD UI phase | Entry point → spawns `gsd-ui-researcher` (agent — UI-SPEC.md design contract) + `gsd-ui-checker` (agent — BLOCK/FLAG/PASS verdicts) |
| `gsd-ui-review` | Post-Stitch | Entry point → spawns `gsd-ui-auditor` (agent — scored UI-REVIEW.md) |
| `lesson-capture` | Any correction | Capture at right storage tier |

## Dependency Check — Run Before Anything Else

Before memory search or any other action, verify which design tools are available. Run these checks once per session.

### Step A: Check 21st.dev Magic MCP
Available if `mcp__21st-dev-magic__21st_magic_component_builder` appears in your tool list.

### Step B: Check ECC plugin
```bash
ls ~/.claude/plugins/cache/ecc 2>/dev/null && echo "ECC: installed" || echo "ECC: missing"
```

### Step C: Check design-taste + stitch-design-taste skills
```bash
npx skills list 2>/dev/null | grep -iE "design-taste|stitch-design" || echo "taste skills: missing"
```
Install (both): `npx skills add https://github.com/Leonxlnx/taste-skill`

### Step D: Check Impeccable
```bash
ls ~/.claude/skills/impeccable* 2>/dev/null | head -1 || find ~/.claude/plugins -name "*impeccable*" 2>/dev/null | head -1 || echo "impeccable: missing"
```

### Step E: Check gsd-sketch
```bash
ls ~/.claude/skills/gsd-sketch* 2>/dev/null | head -1 || find ~/.claude/plugins -name "*gsd-sketch*" 2>/dev/null | head -1 || echo "gsd-sketch: missing"
```

### Step F: Check emil-design-eng
```bash
npx skills list 2>/dev/null | grep -i "emil-design-eng" || echo "emil-design-eng: missing"
```
Install: `npx skills add emilkowalski/skill`

### Present findings and proceed

Report findings in this format:

```
Design Tool Status:
  21st.dev Magic MCP      ✅/❌
  ECC plugin              ✅/❌
  design-taste skills     ✅/❌
  Impeccable              ✅/❌
  gsd-sketch              ✅/❌
  emil-design-eng         ✅/❌
```

For each ❌: apply the fallback from the table below automatically — do not wait for user response. The pipeline runs autonomously; missing tools activate fallbacks, not pauses.

| Tool missing | Fallback (apply automatically) |
|---|---|
| 21st.dev Magic MCP | Describe components as detailed text specs. Reference shadcn/ui and Radix UI by name. |
| ECC plugin | Use built-in knowledge for competitor benchmarking and design direction. Skip all `ecc:*` skill invocations — replicate intent inline. |
| design-taste-frontend | Apply manual anti-slop rules: no AI purple/blue gradient defaults, no generic Inter/Roboto/Poppins choices, minimum 3 typographic levels, no default card-grid layouts. |
| stitch-design-taste | Skip `DESIGN.md` generation. Embed design constraints directly in the Stitch brief. |
| Impeccable | Skip all `/impeccable` steps. Apply the 27 anti-pattern rules manually. |
| gsd-sketch | Replace wireframes with structured text: screen name, layout grid, component list, primary and secondary actions. |
| Google Stitch | Use v0.dev as fallback. Reformat the Stitch brief accordingly. |
| emil-design-eng | Apply Emil's principles manually: spring-based transitions, meaningful hover states, no instant state changes, animation communicates causality. |

Emit one `FOUNDER_QUESTION:` block only if a tool requires user credentials or a paid account not yet confirmed:

```
FOUNDER_QUESTION: Do you have a Google Stitch account (stitch.withgoogle.com)?
CONTEXT: Stitch requires a Google account with Gemini 2.5 Pro access — cannot be auto-installed.
DEFAULT_IF_SKIPPED: Use v0.dev as fallback for full-screen mockup generation.
```

Proceed immediately to Step 1 after emitting any FOUNDER_QUESTIONs — do not wait inline.

---

## Core Behaviour

### Read upstream constraints before doing anything else

Before running the dependency check, memory search, or any research:

1. `docs/architect/05-seo-gtm.md` — S05 (SEO & GTM Strategy — SEO, GTM, and sales motion): read the **Forward Flags to S09** section. Extract:
   - SSR pages list (public pages that must be server-side rendered)
   - Animation ceiling for public pages (max animation level for Core Web Vitals compliance)
   - URL structure and slug format (Screen Inventory must follow this exactly)
   - Content hierarchy requirements (keyword-driven above-the-fold content)
   - Structured data markup requirements (FAQ, pricing, feature pages)

2. `docs/architect/06-accessibility-i18n.md` — S06 (Accessibility & i18n Principles — WCAG compliance and i18n architecture): read the **Forward Flags to S09** section. Extract:
   - WCAG level committed (AA or AAA)
   - Colour contrast ratios (minimum ratios for normal and large text)
   - Focus state requirement (every interactive component needs one)
   - Animation reduced-motion fallback requirement (every named animation)
   - RTL layout strategy (if required: use logical CSS properties)
   - i18n routing pattern (URL locale prefix format)

These constraints are **mandatory inputs** — record them internally before proceeding. No design decision contradicts them.

### S05/S06 Compliance Verification Gate (run before writing the doc)

Before writing `08-ux-interface.md`, verify each constraint is reflected in your design decisions. Do not write until all pass:

- [ ] Every public screen in the Screen Inventory uses SSR (matches S05 SSR pages list)
- [ ] Animation level on public pages does not exceed S05 Core Web Vitals ceiling
- [ ] Every screen URL slug matches S05 URL structure exactly
- [ ] Colour palette verified against S06 contrast ratios (normal text AND large text)
- [ ] Every interactive component has a focus state defined (S06)
- [ ] Every named animation has a `prefers-reduced-motion` fallback (S06)
- [ ] RTL strategy applied if S06 requires it (logical CSS properties used throughout)
- [ ] i18n routing pattern matches S06 URL locale prefix format

If any item fails: resolve it before writing. Log unresolved items as open issues in `00-issues.md` with severity CRITICAL.

### Explore before drafting
1. Read `docs/architect/00-context.md`
2. Read `docs/architect/01-problem-vision.md`, `02-user-roles.md`, `03-feature-map.md`
3. Read `Note: brand claim restrictions are assessed by the Planner legal synthesis` — — flag any brand claims that may carry legal exposure in the Advisory Notes
4. Read `docs/architect/04-monetisation.md` — S04 (Cost, Monetisation & Stripe — pricing, billing, and payment flow design): pricing tiers that need screens
5. Do not ask the user anything until the tool chain steps 1-2 are complete

### Draft-first protocol
Do not ask the user cold. Research first, draft options, then let the user react.

### Output format
Write to `docs/architect/08-ux-interface.md`:

```
# Section 8: UX, Interface Design & Branding

## Summary

## Upstream SEO & Accessibility Constraints Applied
<S06 constraints incorporated: SSR pages, animation ceiling, URL structure, content hierarchy, structured data requirements>
<S07 constraints incorporated: WCAG level, colour contrast ratios, focus states, animation reduced-motion fallbacks, RTL decision, i18n routing>

## Design Direction
<Personality, tone, visual references>

## Branding Decisions
<Colour palette (hex values) — all text/background combinations verified against S07 contrast ratios. Typography (font names and weights) — verified against S07 character set requirements. Logo direction, visual tone.>

## Screen Inventory
<Full list of screens per user role. URL slug for each screen must match S06 URL structure — no deviation. Mark each as public or auth-gated. Public screens feed S10 (Technical Architecture) SSR scope.>

## User Flows
<Key flows: onboarding, core loop, admin management — step by step>

## CSS Design System Foundations
<Token names, spacing scale, component library approach. Tokens include: focus-ring colour and width (WCAG focus state), reduced-motion breakpoint, logical property conventions if RTL required.>

## Hero Section Brief
<Hero communicates: [keyword-aligned headline from S06 content hierarchy]. Layout, primary CTA, visual treatment. Animation level: ≤ [S06 animation ceiling] on public pages.>

## Animation Requirements
<Named list: interaction name | type (spring/ease/scroll-triggered) | intent | reduced-motion fallback (required per S07 for every entry)>

## Stitch Brief
<Exact prompt to paste into stitch.withgoogle.com. Must include: S07 WCAG level and contrast ratios, S06 animation ceiling, S07 RTL requirement if applicable.>

## Component Decisions
<Key components. Every interactive component must include focus state in its design spec.>

## S09 Forward Flags
<Outputs S09 (Technical Architecture — stack, auth strategy, and integrations) will consume directly:>
- Animation level: <1-5 — confirms or refines S06 animation ceiling for Core Web Vitals>
- Public screens: <final list — determines SSR and sitemap scope; must match S06 SSR pages list>
- SSR confirmed: <yes/no — confirms S06 SSR requirement>
- Third-party embeds: <any embedded widgets that affect CSP or load performance>
- i18n routing: <URL locale pattern confirmed — S10 must implement this routing in the stack>

## Decisions
## Open Issues
## Research Notes
```

After writing, return:
```
Section 8 complete.
Doc written: docs/architect/08-ux-interface.md
Open issues: <count>
Backward update needed: <yes/no — list affected sections and reason>
S10 forward flags: <animation level, public screens confirmed, SSR confirmed, i18n routing>
```

### Backward update protocol

If `Backward update needed: yes`, state what changed and which doc is affected before proceeding to S09 (Technical Architecture — stack, module boundaries, and coupling rules):

| Upstream doc | What triggers update | File | Note |
|---|---|---|---|
| S01 (Problem & Vision — product scope and commercial viability) | Design reveals brand/tone contradiction | `01-problem-vision.md` | Resolve before S09 |
| S02 (User Roles & Personas — permission model and role definitions) | Design reveals uncaptured user type | `02-user-roles.md` | Resolve before S09 |
| S03 (Feature Map & User Stories — MVP features and acceptance criteria) | Screen requires feature not in MVP set | `03-feature-map.md` | Resolve before S09 |
| S05 (SEO & GTM Strategy — SEO, GTM, and sales motion) | URL structure deviation needed | `05-seo-gtm.md` | S05 takes precedence unless explicitly overridden |
| S06 (Accessibility & i18n Principles — WCAG compliance and i18n architecture) | Design element cannot meet contrast ratios | `06-accessibility-i18n.md` | Document accepted tradeoff |

## Tool Chain — Run in This Order

### 1. Research — understand the design space

Before asking the user anything, run:
- `ecc:benchmark` — analyse 3-5 direct competitors. Extract: colour palette conventions, typography patterns, UI density, animation level, what they do well. *(Skip if ECC not installed — research manually.)*
- `ecc:market-research` — visual conventions for this market segment. *(Skip if ECC not installed.)*
- `mcp__21st-dev-magic__logo_search` — visual identity references. *(Skip if 21st.dev MCP not installed.)*

Synthesise into a research summary (internal).

### 2. Generate design system and draft three directions

**Step 2a — `ui-ux-pro-max` design system (run first):**

```bash
python3 ~/.claude/skills/ui-ux-pro-max/scripts/search.py "<product_type> <industry> <keywords from S01>" --design-system --persist -p "<product name>"
```

This produces: style pattern, colour palette (96 options), font pairing (57 options), effects, and anti-patterns. The `--persist` flag writes `design-system/MASTER.md` — the Executor reads this during build.

Then add stack-specific guidelines using the stack confirmed in S09 (or inferred from context):

```bash
python3 ~/.claude/skills/ui-ux-pro-max/scripts/search.py "<product keywords>" --stack <nextjs|react|vue|shadcn> --domain ux
```

Use the output as the foundation for all three directions below. Do not invent palettes or font pairings from scratch.

**Step 2b — `impeccable teach`:** Run to set up `PRODUCT.md` and `DESIGN.md` context files from the product brief and `ui-ux-pro-max` output. Without these files, impeccable produces generic output that ignores the product.

```
/impeccable teach
```

Populate `PRODUCT.md` with: product name, users (from S02), brand tone, anti-references (competitor designs to avoid), strategic principles (from S01). Populate `DESIGN.md` with the palette and typography from `ui-ux-pro-max` output.

**Step 2c — `impeccable shape`:** Plan the UX/UI before drafting any directions. This defines the structure, hierarchy, and key decisions before visual work begins.

```
/impeccable shape
```

**Step 2d — `design-taste-frontend`:** Set DESIGN_VARIANCE, MOTION_INTENSITY, and VISUAL_DENSITY dials against the `ui-ux-pro-max` output. *(If not installed, apply manual anti-slop fallback rules.)*

Each direction must incorporate S06 and S07 constraints. Each must include:

```
Direction <A/B/C>: <Name>
Personality: <3 character words>
Visual reference: <2 real products/sites this resembles>
Primary colour: #<hex> — <contrast ratio vs background: X.X:1 — meets S07 requirement: yes/no>
Accent colour: #<hex>
Background: #<hex>
Heading font: <exact font name> — <character sets supported>
Body font: <exact font name>
UI density: <compact / balanced / spacious>
Animation level: <1-5> — must not exceed S06 animation ceiling <N> on public pages
RTL compatible: <yes/no — per S07 RTL decision>
Why this fits: <2 sentences connecting to S01 problem and S02 user types>
S06/S07 compliance: <confirm animation ceiling met, contrast ratios met>
```

Ask: "Which direction fits best — or is there a combination? You can adjust any specific value."

### 3. Lock in direction and confirm personality

Once the user picks a direction (or hybrid):
- Lock in all values: hex codes, fonts, animation level
- Verify contrast ratios for all locked text/background combinations against S07 requirements
- Invoke the matching Taste Skill variant based on chosen direction
- Invoke `emil-design-eng` — apply component-level polish: spring physics, hover state craft, transition timing, and interaction causality. *(If not installed, apply fallback rules manually.)*
- Run `ecc:make-interfaces-feel-better` — apply micro-interaction improvements

### 4. Impeccable + sketching

- Run `/impeccable teach` *(Skip if not installed.)*
- Run `/impeccable shape` *(Skip if not installed — define screen list and hierarchy in text.)*
- Run `/impeccable critique` *(Skip if not installed.)*
- Invoke `gsd-sketch` — wireframe each screen. URL slugs in wireframes must match S06 URL structure. *(If not installed, describe as structured text.)*
- Invoke `ecc:click-path-audit` — audit flows for friction. *(Skip if ECC not installed.)*

### 5. Google Stitch — full-screen mockup generation

First invoke `stitch-design-taste`. *(If not installed, embed design constraints directly in the Stitch brief.)*

Stitch brief must include:
- WCAG level from S07 (e.g. "All designs must meet WCAG AA — colour contrast 4.5:1 minimum for normal text")
- Animation ceiling from S06 (e.g. "Animation level max [N] on public pages")
- RTL requirement from S07 (if applicable)

Emit a FOUNDER_QUESTION pause for the external Stitch handoff — this is the one step in S08 that genuinely requires the user to leave Claude and return with output:

```
FOUNDER_QUESTION: Open stitch.withgoogle.com (or v0.dev if unavailable). Use Gemini 2.5 Pro. Paste this brief and return with the generated screens:

---
Product: <product name and one-sentence description from S01>
Design personality: <locked personality from step 3>
Colour palette: primary <hex>, accent <hex>, background <hex>
Typography: <heading font>, <body font>
Animation level: <1-N — max public page level per S06 SEO constraints>
Accessibility: WCAG <level> — <contrast ratio> minimum for all normal text
Generate these 5 screens:
1. Homepage / hero — URL: <S05 URL structure homepage slug>. Communicates <hero intent from S01> with CTA '<primary CTA>'
2. Main dashboard for <primary user role from S02> — shows <core data/features from S03>
3. <Key feature screen from S03 — name it with S05 URL slug>
4. Admin panel — <admin primary action from S02>
5. Mobile view of <core loop step from S03>
---

Select the screens you like best. Export as HTML/Tailwind CSS. Paste or import the output here.
CONTEXT: Stitch is an external tool — mockup generation requires the founder to leave Claude and return with output. Cannot be automated.
DEFAULT_IF_SKIPPED: Skip full-screen mockups. Continue with component specs from 21st.dev MCP and structured text wireframes only.
```

The Injector will pause the pipeline at this FOUNDER_QUESTION, collect the Stitch output when the founder returns, inject it as context, and resume S08 from step 6.

### 6. 21st.dev MCP — component refinement

*(Skip if not installed.)*

After Stitch screens are approved, refine components. Every component must include focus state in its spec:

> **Hero reference:** Browse [motionsites.ai](https://motionsites.ai/) for production-quality hero sections — many free, some paid. Filter by palette and animation level to match locked direction. Present 2-3 options to the founder before building the hero component.
- `mcp__21st-dev-magic__21st_magic_component_inspiration` — explore variations
- `mcp__21st-dev-magic__21st_magic_component_builder` — generate hero, CTA, nav
- `mcp__21st-dev-magic__21st_magic_component_refiner` — iterate until components match direction

Run `ecc:ui-demo` to validate. *(Skip if ECC not installed.)*

**If S09 stack is Vue 3:** also invoke `ecc:ui-to-vue` (batch-converts design screenshots into Vue 3 Composition API components with Vant, Element Plus, or Ant Design Vue). Pass the Stitch-exported screens as input. This produces the first-pass component code the Executor will refine. *(Skip if stack is not Vue.)*

### 7. Animation spec, accessibility verification, and compile

Install framer-motion before running motion skills: `npm i framer-motion`

Run `ecc:motion-foundations` → `ecc:motion-patterns` to establish animation tokens and patterns.

If the product has **complex animation requirements** (drag-and-drop, gesture-driven UI, SVG path animations, imperative sequences, sortable lists): run `ecc:motion-advanced` after `motion-patterns`. Signals that trigger this: S03 features include drag-to-reorder, swipe gestures, canvas/SVG interactions, or animated loaders. *(Requires motion-foundations to have run first. Skip if animation scope is simple.)*

Run `ecc:motion-ui` to produce the final named animation requirements list. Every entry must include a `prefers-reduced-motion` fallback — required per S07. *(Skip full motion chain if ECC not installed — name each animation manually.)*

Run `ecc:accessibility` — verify all colour choices meet S07 contrast ratios, all interactive components have focus states, all animations have reduced-motion fallbacks, RTL layout uses logical CSS properties if required. *(Skip if ECC not installed — verify manually against S07 specs.)*

**`impeccable` final pass — run in sequence:**
```
/impeccable critique   — UX design review with heuristic scoring
/impeccable audit      — technical quality checks (a11y, perf, responsive)
/impeccable polish     — final quality pass before writing the doc
```
Apply findings before writing the section doc. *(Skip if impeccable not installed.)*

### Verification gate (run before writing the doc)

Invoke `superpowers:verification-before-completion`. Check each item — do not write until all pass:

- [ ] S06 forward flags consumed — SSR pages, animation ceiling, URL structure, content hierarchy, structured data all incorporated
- [ ] S07 forward flags consumed — WCAG level, contrast ratios, focus states, animation fallbacks, RTL, i18n routing all incorporated
- [ ] All screens from the inventory use URL slugs matching S06 URL structure
- [ ] Design direction locked: hex codes, fonts, animation level confirmed by user
- [ ] Colour contrast verified for all text/background combinations against S07 ratios
- [ ] Every animation has a prefers-reduced-motion fallback documented
- [ ] Every interactive component in component inventory has focus state in spec
- [ ] Stitch brief used is recorded verbatim
- [ ] All key user flows documented step by step
- [ ] Third-party embeds or SSR constraints flagged for S10
- [ ] No open issues without a decision or owner

If any item fails: surface the gap to the user and resolve before writing.

Write `docs/architect/08-ux-interface.md` with all of the above.

### Spec output (write after verification gate passes)

Write to `docs/architect/spec/08-ux-interface.md`:

```
# Spec: S08 — UX, Interface Design & Branding

## Key Decisions
<Design direction (hex palette, fonts, animation level 1-5 — max public page level per S06); full screen inventory with URL slugs matching S06 structure and auth-gated/public status; key user flows; CSS design system tokens including focus-ring and reduced-motion; SSR confirmation; RTL approach; i18n routing confirmed>

## S06 Constraints Applied
<SSR pages confirmed; animation ceiling honoured; URL structure followed in Screen Inventory; content hierarchy incorporated; structured data requirements passed to S10>

## S07 Constraints Applied
<WCAG level implemented; contrast ratios verified; focus states in every component; reduced-motion fallback in every animation; RTL approach if required; i18n routing confirmed>

## Constraints for Downstream Sections
<S09 (Technical Architecture — stack, auth strategy, and integrations): final public screen list (SSR scope), animation level confirmed, i18n routing pattern, any third-party embeds, CSS design system tokens for frontend framework selection.>

## Dependencies on Upstream Sections
<S01 (Problem & Vision — product scope and commercial viability): product category and brand personality. S02 (User Roles & Personas — permission model and role definitions): role-specific screen requirements. S03 (Feature Map & User Stories — MVP features and acceptance criteria): features that map to screens. — flag any brand claims that may carry legal exposure in the Advisory Notes. S05 (SEO & GTM Strategy — SEO, GTM, and sales motion): SSR pages, animation ceiling, URL structure, content hierarchy, structured data. S06 (Accessibility & i18n Principles — WCAG compliance and i18n architecture): WCAG level, contrast ratios, focus states, animation fallbacks, RTL, i18n routing.>
```
