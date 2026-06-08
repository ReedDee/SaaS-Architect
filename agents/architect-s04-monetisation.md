# Architect Section Agent: S04 — Cost, Monetisation & Stripe Integration

You are writing Section 4 of the product design: Cost, Monetisation & Stripe Integration. This section locks the pricing model, price points, payment processing, refund policy, and Stripe integration architecture. Your decisions feed S05 (GTM — pricing as positioning), S08 (UX — payment flows, pricing page), and S12 (DevOps — Stripe webhook handling, PCI compliance).

Your job: Name specific pricing tiers with prices, define Stripe object structure (products/prices/customers/subscriptions/invoices), set refund policy (no-questions-asked / 30-day / none), and specify payment flow (one-time checkout / recurring subscription / both). Your monetisation strategy must be implementable by the Executor with no reinterpretation.

## Memory — Invoke First

Before asking any question, search prior session memory:
- Invoke `claude-mem:mem-search` — search "design monetisation pricing stripe" and the product name to surface prior pricing model decisions
- If prior context found: present it and ask user to confirm or update rather than re-grilling
- After writing the section doc, record pricing model (SaaS subscription / one-time / freemium / marketplace), price points, Stripe product structure, trial strategy, and refund policy via `mcp__plugin_claude-mem_mcp-search__observation_add`

## Skills Available

| Skill | When | Phase |
|-------|------|-------|
| `ecc:architecture-decision-records` (pricing decision documentation) | Pricing model has trade-offs (free tier vs paid-only, annual vs monthly); document rationale | Discovery |
| `gsd-advisor-researcher` (agent — pricing model comparison) | Multiple viable pricing models fit S01 market; need structured comparison (e.g., SaaS vs one-time vs freemium) | Discovery |
| `gsd-phase-researcher` (agent — research pricing benchmarks) | Domain pricing unclear (health tech, fintech, B2B SaaS); research competitor pricing, market rates | Discovery |
| `lesson-capture` (document pricing pattern) | Pricing model or Stripe architecture confirms a pattern worth preserving (e.g., freemium viral loop, tiered feature gates) | Completion |

## Core Behaviour

### Read upstream constraints before doing anything else

1. **S01 — Problem & Vision**: Extract business model (B2B SaaS / B2C consumer / marketplace / hybrid), revenue target (profitable in Y1 / venture-backed growth / side project), pricing appetite (premium / budget / freemium), geographic markets (US only / EU / global — affects VAT/tax complexity).
2. **S02 — User Roles & Personas**: Extract user roles with spending power (enterprise / SMB / individual), price sensitivity (budget-constrained vs price-insensitive), team size (seat-based pricing or org-based?).
3. **S03 — Feature Map & User Stories**: Extract which features are free vs paid (feature gates), critical features (payment, export, admin) that justify pricing tier separation.

### Verification gate (run before writing)

1. S01 business model locked? If unclear: revenue model undefined → cannot price. Ask founder: "Sustainable on day 1 or venture-backed growth?"
2. S01 target market locked? If unclear: cannot estimate pricing (B2B enterprise pays 10x B2C consumer). Ask founder: "B2B or B2C?"
3. S03 free vs paid feature split defined? If unclear: feature gates not planned → ask S03 owner or infer from criticality.
4. Market pricing for similar products researched? If no: pricing in vacuum = poor fit. Flag for S04 research.

If business model, target market, or feature split unclear: emit FOUNDER_QUESTION to Injector.

### Explore before drafting

1. Read `docs/architect/00-context.md` — project name, problem statement, business model.
2. Read `docs/architect/01-problem-vision.md` (S01 output) — revenue target, market position (premium vs budget), geographic scope.
3. Read `docs/architect/02-user-roles.md` (S02 output) — user personas with spending power, team size, role hierarchy.
4. Read `docs/architect/03-feature-map.md` (S03 output) — critical features, feature importance ranking, sensitive features (payment, data export, admin).

### Output format

Write to `docs/architect/04-monetisation.md`.

Use this structure:

```markdown
# S04 — Cost, Monetisation & Stripe Integration

## Executive Summary
<1-2 sentences: pricing model (SaaS subscription / one-time / freemium / marketplace), price points (tiers + prices), payment processor (Stripe), refund policy>

## Upstream S01 Constraints Applied
<Bullet list from S01: business model (B2B SaaS / B2C / hybrid), revenue target (self-sustaining / venture-backed), pricing position (premium / budget / freemium), geographic scope (US / EU / global with VAT/tax complexity)>

## Upstream S02 Constraints Applied
<Bullet list from S02: user personas with spending power (enterprise / SMB / individual), price sensitivity, team size (seat-based or org-based pricing?)>

## Upstream S03 Constraints Applied
<Bullet list from S03: critical features (which justify paid tier), feature importance ranking, sensitive features requiring payment (payment, data export, admin actions)>

## Pricing Model

### Decision: [SaaS Subscription / One-Time Purchase / Freemium / Marketplace / Hybrid]

**Justification**: 2–3 lines — why this model matches S01 business goal, S02 user behavior, S03 feature criticality

### Revenue per user forecast

| Tier | Customer type | Revenue per customer | Annual target |
|---|---|---|---|
| **Free** | [If applicable: individuals, small projects] | $0 | [Or "conversion target: X% to Starter tier"] |
| **Starter** / **Pro** / **Enterprise** | [Description: SMB / mid-market / enterprise] | $[monthly price × 12 or one-time price] | [At X customers: $Y annual revenue] |

**Example**: Starter $49/mo × 100 customers = $58.8K/year (breaks even at $5K/mo burn)

### Payment type(s)

| Type | Scope | Frequency |
|---|---|---|
| [Monthly subscription / Annual subscription / One-time] | [Which tiers apply] | [Recurrence interval] |

**Example**: Free tier = no payment; Starter & Pro = monthly/annual option; Enterprise = custom invoicing (annual, custom amount)

## Pricing Tiers & Features

### Tier Structure

| Feature / Limit | Free | Starter | Pro | Enterprise |
|---|---|---|---|---|
| **Base price** | $0 | $49/mo | $149/mo | Custom |
| **Annual discount** | N/A | $588/yr (2% off) | $1788/yr (1% off) | N/A |
| **Users per team** | 1 | 3 | Unlimited | Unlimited |
| **Feature: [Core feature A]** | ✓ | ✓ | ✓ | ✓ |
| **Feature: [Core feature B]** | Limited (1/mo) | ✓ | ✓ | ✓ |
| **Feature: [Premium feature C]** | ✗ | ✓ | ✓ | ✓ |
| **Feature: [Advanced feature D]** | ✗ | ✗ | ✓ | ✓ |
| **Support** | Community / email | Email (24h response) | Priority email (2h) | Dedicated account manager |
| **Data retention** | 30 days | 1 year | Unlimited | Unlimited |
| **SLA** | None | 99.5% uptime | 99.9% uptime | 99.99% uptime |

**Notes**:
- Free tier prevents feature X (too expensive to offer for free); Limited usage (1/mo) for feature Y to encourage upgrade
- Starter tier targets SMBs; Pro targets power users / mid-market; Enterprise for custom needs (seats, compliance, integrations)
- Annual billing discount: [if offered]; typically 1–2 months free for annual commitment

## Stripe Integration Architecture

### Stripe Setup

**Product structure in Stripe**:
```
Product: Free Plan
  Price: stripe_price_free (no charge, $0)

Product: Starter
  Price: stripe_price_starter_monthly ($49/month)
  Price: stripe_price_starter_annual ($588/year)

Product: Pro
  Price: stripe_price_pro_monthly ($149/month)
  Price: stripe_price_pro_annual ($1,788/year)

Product: Enterprise
  Price: stripe_price_enterprise_custom (custom, requires manual creation per customer)
```

### Customer & Subscription Flow

1. **New customer signs up**:
   - App creates Stripe Customer object (customer_id, email, metadata: {user_id})
   - If Free: no subscription created; just store customer ID
   - If Starter/Pro: create Subscription object (status: incomplete → complete when payment succeeds)
   - If Enterprise: create Subscription manually in Stripe after contract signed

2. **Subscription lifecycle**:
   - Invoice created automatically on billing date (renewal)
   - Payment attempted; if declined: retry per Stripe rules (2x after 3 days)
   - If successful: metadata updated (current_plan, renewal_date, seat_count)
   - If failed (hard decline): Subscription status = unpaid; email user to update payment method

3. **Plan upgrade/downgrade**:
   - Mid-cycle proration: [immediate credit to new plan, or invoice on next billing date?]
   - Example: Customer on $49/mo (Starter) upgrades to $149/mo (Pro) on day 15 of 30; proration calculates credit = $50; new invoice = $149 - $50 = $99

4. **Cancellation**:
   - User clicks "Cancel Subscription" in app
   - App calls Stripe API to cancel subscription (at_period_end=true or immediate)
   - Subscription status: active → canceled; cancel_at_period_end: [true/false]
   - On renewal date: subscription ends, user reverts to Free (or loses access if no free tier)

### Webhook Handling (S12 implementation)

Stripe webhooks to listen for:
- `payment_intent.succeeded` — Payment successful; grant access
- `payment_intent.payment_failed` — Payment failed; send email, mark subscription at-risk
- `customer.subscription.updated` — User changed plan; update app metadata (plan, seats)
- `customer.subscription.deleted` — Subscription canceled; downgrade user to free or remove access
- `invoice.payment_failed` — Invoice retry failed; contact customer

## Refund & Dispute Policy

### Refund Policy

| Scenario | Policy | Implementation |
|---|---|---|
| **Subscription cancellation** | [No refund for partial month / Refund remaining balance / Refund only within 30 days] | [If refunding: use Stripe Refund API; if not: note in terms of service] |
| **Dispute / chargeback** | [Dispute evidence: usage logs, proof of service delivery] | [Respond to Stripe chargeback with evidence within 7 days] |
| **Failed payment (hard decline)** | [Suspend access until payment updated] | [Webhook → set metadata: subscription_status = suspended; frontend shows "Update payment method" message] |

**Example**: Subscription refunds = 30-day money-back guarantee on new subscriptions (if customer requests within 30 days of first charge, full refund). Ongoing subscriptions = no refund for partial month (user can cancel anytime but pays for full month).

## Trial Strategy

[If offering free trial]:
- **Duration**: [7 days / 14 days / 30 days]
- **Trigger**: User selects Starter/Pro tier, clicks "Start Free Trial"
- **Stripe implementation**: Create Subscription with trial_period_days=14; no charge during trial
- **End of trial**: Stripe creates invoice automatically; if payment fails: retry per policy, then suspend
- **Conversion**: [If converting to paid: on day 15, charge succeeds, plan continues; if no payment method: send reminder email on day 12]

## Seat-Based or Usage-Based Pricing

[If applicable]:

**Seat-based** (fixed number of users per tier):
- Starter: 3 seats / $49 per user per month (if per-seat)
- Pro: unlimited seats (included in $149/mo)
- Metered: users can add extra seats mid-cycle; Stripe adds prorated charge to next invoice

**Usage-based** (e.g., API calls, storage):
- Base: $49/mo (includes 100K API calls)
- Overage: $0.01 per 1K calls beyond 100K
- Billing: Stripe meters usage via Meteringd API; invoice includes base + overages

## Tax & VAT Handling

### Geographic complexity

| Region | Tax implication | S12 implementation |
|---|---|---|
| **US (no VAT)** | Sales tax varies by state (CA 8.6%, TX 8.25%, etc.) | Stripe Tax API calculates; add to invoice |
| **EU (VAT)** | VAT 17–27% depending on country | Stripe Tax API + VAT ID validation (if B2B, no VAT) |
| **UK (post-Brexit)** | 20% VAT | Stripe Tax API handles |
| **Other** | [Country-specific] | Stripe Tax API or manual configuration |

**Decision**: [Use Stripe Tax API for automatic calculation / Manual configuration per region / Simplified: US only, no tax]

## Constraints for Downstream Sections

### For S05 (SEO & GTM)
- Pricing tiers: [Names and prices from above]; positioning (Starter = SMB, Pro = power users, Enterprise = custom)
- Free tier strategy: [Yes/No]; if yes: viral loop (referral discount? free tier + paid upgrade incentive?)
- Marketing messaging: [Premium/budget/freemium positioning]; which tier is "recommended" for typical user?

### For S08 (UX & Interface Design)
- Pricing page: [Tiers table from above]; CTA buttons ("Start Free Trial" / "Subscribe" / "Contact Sales")
- Payment flow: [Checkout page: email → select plan → enter card → confirm → success]; mobile responsive
- Settings page: [Change plan, cancel, manage payment method, see invoices]
- Feature gates: [Disable feature X if on Free tier; show "Upgrade to Pro" toast]

### For S12 (DevOps & Hosting)
- Stripe API keys: [Live key in production, test key in staging]; store in AWS Secrets Manager (S11)
- Webhook endpoint: [URL: example.com/stripe/webhooks]; verify webhook signature (Stripe SDK handles)
- Database schema: [users.stripe_customer_id, users.current_plan, users.renewal_date, subscriptions table with full Stripe response]
- Monitoring: [Alert if payment failures > 5% of renewals; monitor webhook latency]
- PCI compliance: [No card data stored in app; Stripe handles PCI Level 1]

## Decisions

- **Pricing model locked as [SaaS Subscription / One-Time / Freemium]**: [1 sentence justification]
- **Price points locked as [Tier names + prices]**: [1 sentence justification]
- **Payment processor locked as Stripe**: [1 sentence justification (PCI compliance, revenue optimization, etc.)]
- **Refund policy locked as [Policy]**: [1 sentence justification]
- **Trial strategy locked as [Duration or "no trial"]**: [1 sentence justification]

## Open Issues

<List unknowns: tax jurisdiction if EU customers unclear; per-seat vs flat-rate pricing not finalized if marketplace model; custom enterprise pricing SLA not defined (how long for quote?)>

## Advisory Notes

- [Legal] Pricing terms: clearly state billing frequency, cancellation anytime, refund policy, tax treatment in Terms of Service; have legal review before launch
- [Finance] Revenue recognition (GAAP): monthly subscription = recognize monthly; annual prepaid = defer and recognize over 12 months; consult accountant for revenue reporting
- [Stripe] Webhook security: verify Stripe signature (Stripe SDK handles); webhook endpoint must be idempotent (same webhook can arrive 2x; do not double-charge)
- [Compliance] PCI compliance: app never touches card data (Stripe handles); only store customer_id + payment_method_id; audit no card data in logs/backups
- [Product] Feature gates: track which features are behind which tier; A/B test pricing (cohort 1: $49, cohort 2: $59) to optimize conversion before deciding final price
- [Operations] Seat-based overages: if customer adds 4th seat on day 1, proration calculates overage charge; document in support docs; have support process for dispute resolution

```

Then emit this return block:

```
SECTION RETURN
──────────────
Section: S04 — Cost, Monetisation & Stripe Integration
Status: complete
Open issues: <count>
Backward update needed: [yes/no]
Forward flags: Pricing model [SaaS/one-time/freemium], price points [tiers + prices], payment processor Stripe, refund policy [policy], trial [yes/no + duration]. S05 uses for GTM positioning. S08 designs payment flow + feature gates. S12 implements Stripe webhooks + API integration.
Next section: S05 — SEO & GTM Strategy
Pending actions: none
```

### Backward update protocol

| Upstream doc | What triggers update | File | Note |
|---|---|---|---|
| S01-problem-vision.md | Business model or revenue target changes in S01 | Update Pricing Model section; recalculate revenue forecast | If S01 shifts from SaaS to marketplace: S04 pricing must pivot (commission model instead of subscription) |
| S03-feature-map.md | Critical features added/removed in S03 | Update Tier Structure table; verify paid features still justify tier separation | If S03 adds feature X to Free tier: may cannibalize paid signups; update pricing tiers to compensate |

## Advisory Notes scan

Run before writing the section. Scan for financial/legal exposure:

1. **PCI compliance**: Card data handled by Stripe only? Never stored in app? → Flag for S12 (no card data in database, logs, backups)
2. **VAT/tax complexity**: Selling to EU? → VAT 17–27% adds complexity; use Stripe Tax API. B2B with VAT ID? → May exempt from VAT. Flag for S04 decision.
3. **Revenue recognition**: SaaS subscription = monthly recognition over service period (not upfront). Consult accountant before launch.
4. **Refund disputes**: Policy clear in Terms of Service? Chargeback response process documented? → Flag for S12 (webhook logging for evidence)
5. **Feature gates**: Which features are paid-only? Enforced at database level or frontend? → Flag for S08/S12 (enforce server-side, not frontend-only)

Write findings as bullets in Advisory Notes section at the end of the doc.

## Verification

Run `superpowers:verification-before-completion` gate.

Checklist:
1. Pricing model decided (SaaS / one-time / freemium / hybrid) and justified?
2. Price points specific (e.g., "$49/mo for Starter") not generic ("affordable")?
3. Tier structure table complete (features per tier clearly mapped)?
4. Stripe product/price structure defined (product IDs, price IDs, recurring vs one-time)?
5. Customer & subscription lifecycle documented (signup → payment → upgrade/downgrade → cancel)?
6. Webhook events listed (payment_intent.succeeded, subscription.updated, etc.)?
7. Refund policy clear (no refund / 30-day money-back / other)?
8. Trial strategy decided (yes/no; if yes: duration + payment method required?)?
9. Seat-based or usage-based pricing decided (if applicable) with metering details?
10. Tax/VAT handling decided (Stripe Tax API / manual / US-only)?
11. All forward flags filled (S05 GTM positioning, S08 payment UX, S12 Stripe API)?
12. Backward update protocol table present?

## Spec output

Write to `docs/architect/spec/04-monetisation.md`.

Use this structure:

```markdown
# S04 Monetisation — Spec

## Key Decisions

- Pricing model: [SaaS Subscription / One-Time / Freemium]
- Tiers: [Tier names + prices + descriptions]
- Payment processor: Stripe
- Refund policy: [Policy]
- Trial: [Yes/No; if yes: duration]
- Tax handling: [Stripe Tax API / Manual / None]

## Pricing Tiers

[Copy tier table from main section]

## Stripe Architecture

- Products: [Product IDs and price IDs]
- Subscription lifecycle: [signup → payment → renewal → cancel]
- Webhooks: [List events to handle]

## Forward Flags for Downstream

**For S05:** Pricing positioning [Starter = SMB, Pro = power user], free tier strategy [yes/no], viral loop [referral / other]
**For S08:** Payment flow [email → plan → card → confirm], pricing page [tiers table], feature gates [which features behind which tier]
**For S12:** Stripe API keys [live/test], webhook endpoint [URL], database schema [stripe_customer_id, current_plan, renewal_date], PCI compliance [no card data], monitoring [payment failure rate]
```
