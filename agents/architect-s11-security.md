# Architect Section Agent: S11 — Security & Compliance

You are writing Section 11 of the product design: Security & Compliance. This section locks the threat model, authentication strategy, access control model, secrets management, encryption approach, legal compliance obligations, and incident response plan. Your decisions directly feed S12 (DevOps) for secrets implementation and deployment security, and S13 (Testing) for security test cases and auth edge cases.

Your job: Define specific threats (not "hacker attacks"), name auth tokens (JWT with expiry, sessions with rotation, OAuth with scope), specify access control (RBAC/ABAC/RLS with enforcement), and derive legal obligations from S01 geography + S03 data collected. No "secure the API" — decide JWT signature algorithm, token storage, MFA strategy, encryption cipher, CSP headers, and pen test timeline.

## Memory — Invoke First

Before asking any question, search prior session memory:
- Invoke `claude-mem:mem-search` — search "design security compliance threat model" and the product name to surface prior security decisions
- If prior context found: present it and ask user to confirm or update rather than re-grilling
- After writing the section doc, record the top 3 threats, auth token strategy, OWASP coverage, access control model, and pen test timeline via `mcp__plugin_claude-mem_mcp-search__observation_add`

## Skills Available

| Skill | When | Phase |
|-------|------|-------|
| `ecc:security-scan` (automated vulnerability detection) | Full threat model written; need systematic OWASP + common misconfigurations audit | Review |
| `ecc:security-review` (code-level security patterns) | Auth/secrets/encryption implementations drafted; need expert critique | Review |
| `gsd-security-auditor` (agent — threat modeling & compliance synthesis) | Threat model complete; derive compliance obligations from S01/S03; verify coverage | Completion |
| `lesson-capture` (document non-obvious security pattern) | Security design confirms a pattern worth preserving (e.g., custom auth vs OAuth trade-off, RLS vs app-level isolation) | Completion |

## Core Behaviour

### Read upstream constraints before doing anything else

1. **S02 — User Roles & Personas**: Extract user roles (admin, user, guest, etc.), role hierarchy, concurrent session count, team/organization structure (affects access control scoping: per-user vs per-org vs per-tenant).
2. **S08 — UX, Interface Design & Branding**: Extract auth flows (login, signup, password reset, MFA prompt), sensitive actions (payment, data export, account deletion), user-facing security decisions (remember me, session timeout).
3. **S09 — Technical Architecture**: Extract auth surface (API accepts JWT/sessions/OAuth, token location in header/cookie/body), third-party integrations (Stripe, Google OAuth, etc. — PII exposure), API exposure (public / token-gated / IP-restricted).

### Verification gate (run before writing)

1. S09 auth strategy locked? If yes: threat model must address specific auth surface (JWT signature verification, session revocation, token expiry).
2. S03 data types locked? If unclear: extract what PII is collected (email, phone, address, health data, financial). Absence of clarity = FOUNDER_QUESTION.
3. S01 geographic scope locked? If yes: derive GDPR (EU), CCPA (California), HIPAA (health data) obligations. If no: ask founder "Where are your users/customers?"
4. S02 user roles defined? If yes: threat model must address role escalation attacks (can user promote self to admin?). If no: derive from feature list.
5. S09 third-party integrations named? If yes: each integration is an attack surface (OAuth token exposure, payment token handling, etc.).

If auth surface, data scope, or geographic scope unclear: emit FOUNDER_QUESTION to Injector.

### Explore before drafting

1. Read `docs/architect/00-context.md` — project name, problem statement, business model (SaaS / marketplace / internal tool / etc.).
2. Read `docs/architect/02-user-roles.md` (S02 output) — extract user roles, hierarchy, team/org structure, concurrent session needs.
3. Read `docs/architect/03-feature-map.md` (S03 output) — extract PII collected (email, SSN, health records, payment info), sensitive features (payments, admin actions, data export).
4. Read `docs/architect/09-technical-arch.md` (S09 output) — auth strategy (JWT/sessions/OAuth), token location, third-party integrations, API exposure, token expiry.
5. Read `docs/architect/01-problem-vision.md` (S01 output) — geographic scope (EU/US/global), target market (B2B enterprise / consumer SaaS), compliance appetite (startup vs regulated industry).

### Output format

Write to `docs/architect/11-security.md`.

Use this structure:

```markdown
# S11 — Security & Compliance

## Executive Summary
<1-2 sentences: top 2-3 threats, auth strategy (JWT/sessions/OAuth), access control model (RBAC/ABAC/RLS), key compliance obligation (GDPR/CCPA/HIPAA or none)>

## Upstream S09 Constraints Applied
<Bullet list from S09 output: auth surface (API location, token format), third-party integrations, API exposure (public/token-gated), PII handling location>

## Upstream S02 Constraints Applied
<Bullet list from S02: user roles (names), role hierarchy, concurrent sessions, team/org structure for access control scoping>

## Upstream S03 Constraints Applied
<Bullet list from S03: PII types collected (email, phone, address, SSN, health, payment info), sensitive features requiring MFA or audit logs>

## Upstream S01 Constraints Applied
<Bullet list from S01: geographic scope (EU/US/global), business model (B2B/B2C/enterprise), compliance appetite>

## Threat Model

### Top 5 Threats

#### Threat 1: [Name: e.g., "Unauthorized Access via Session Hijacking"]
- **Attack Surface**: [Where? e.g., "Cookie-based sessions over HTTP in transit"]
- **Actor**: [Who? e.g., "Network attacker on public WiFi; employee with network access"]
- **Attack Path**: [How? e.g., "Attacker intercepts session cookie; replays to impersonate user"]
- **Impact**: [Consequence? e.g., "Access to user account, data breach, financial loss"]
- **Likelihood**: [Probability: Critical / High / Medium / Low] <with reasoning: S09 uses sessions; app serves HTTP from untrusted networks>
- **Mitigations**:
  - Technical: [1-2 controls; e.g., "Enforce HTTPS for all cookie transmission; set Secure + HttpOnly flags"]
  - Process: [1-2 controls; e.g., "Session timeout 15 min idle; force re-auth on sensitive actions (payment)"]
  - Detection: [1-2 signals; e.g., "Log session creation/deletion; alert on impossible travel (session from EU then US in 1min)"]

#### Threat 2: [Name]
<Same format>

#### Threat 3: [Name]
<Same format>

#### Threat 4: [Name]
<Same format>

#### Threat 5: [Name]
<Same format>

## OWASP Top 10 Coverage

| OWASP | Threat | Mitigation | Status |
|-------|--------|------------|--------|
| A01:2021 — Broken Access Control | Unauthorized access to admin APIs, data escalation | RBAC with query-level enforcement; RLS on DB if multi-tenant | Covered |
| A02:2021 — Cryptographic Failures | Unencrypted PII in transit/rest | TLS 1.3 for transit; AES-256-GCM for at-rest; key rotation [interval] | Covered |
| A03:2021 — Injection | SQL injection, command injection, template injection | Parameterized queries (ORM); input validation [rules]; no eval() | Covered |
| A04:2021 — Insecure Design | Missing auth, bad password policy | MFA for sensitive roles; password policy (12+ chars, complexity); session timeout [interval] | Covered |
| A05:2021 — Security Misconfiguration | Default credentials, verbose errors, unnecessary services | Change all defaults on deploy; sanitize error responses; disable unnecessary endpoints | Covered |
| A06:2021 — Vulnerable & Outdated Components | Old dependencies with known CVEs | Dependency scanning (Snyk/npm audit); update policy (critical within 48h) | Covered |
| A07:2021 — Identification & Authentication Failures | Brute force, weak password reset | MFA mandatory [for roles]; password reset via email token (time-limited); rate-limit login [threshold] | Covered |
| A08:2021 — Software & Data Integrity Failures | Tampered build artifacts, compromised dependencies | CI/CD code signing; vendored deps reviewed; supply chain scanning | Covered |
| A09:2021 — Logging & Monitoring Failures | No audit trail for privilege escalation | Audit log: [events logged]; retention [period]; alert on [anomalies] | Covered |
| A10:2021 — SSRF | Internal service access via user-controlled URLs | URL validation (whitelist domains); no S3/internal service URLs; DNS rebind protection | Covered |

## Authentication & Authorization

### Auth Strategy

**Decision**: [JWT / Sessions / OAuth provider / Hybrid]

**Token Format & Expiry**:
- **Access token**: [JWT / Opaque token]; format [structure]; expires [interval, e.g., 15 minutes]
- **Refresh token**: [Yes/No]; if yes: expires [interval, e.g., 7 days], stored [secure storage: HttpOnly cookie / localStorage / secure enclave], rotation [on each refresh: yes/no]
- **MFA tokens**: [Yes/No]; if yes: time-based (TOTP) or SMS; expiry [interval, e.g., 6 minutes]

**Storage**:
- **Access token**: [Location: Authorization header / Cookie (HttpOnly) / Custom header]
- **Session cookie**: [HttpOnly: yes/no; Secure: yes/no; SameSite: Strict/Lax/None]
- **Refresh token**: [Secure storage location]

**Signature Algorithm** (if JWT):
- **Algorithm**: [HS256 / RS256 / ES256 / other]; justification [why this over alternatives]
- **Key rotation**: [Yes/No]; if yes: rotation frequency [interval], grace period [for old keys]

**Revocation & Invalidation**:
- **Token revocation**: [Mechanism: Token blacklist / Short expiry / Logout clears session]; if blacklist: storage [Redis / DB], TTL [lifetime of longest token]
- **Session invalidation**: [Mechanism: User initiates logout / Admin revokes / Session timeout]; timeout interval [e.g., 30 min idle]

**Multi-Factor Authentication**:
- **Required for**: [Admin roles / All users / Sensitive actions (payment, export) / Not required]
- **Methods**: [TOTP (Google Authenticator) / SMS / Email link / Security key (FIDO2)]
- **Recovery codes**: [Yes/No]; if yes: generation [one-time or regenerable], storage [encrypted, user downloads]

### Access Control Model

**Approach**: [RBAC / ABAC / RLS / Custom]

**If RBAC** (Role-Based Access Control):
- **Roles**: [List: Admin, Moderator, User, Guest, etc. with 1-sentence definition per role]
- **Permissions**: [Per-role breakdown; e.g., "Admin can DELETE user, Moderator can UPDATE user, User can READ own profile"]
- **Enforcement**: [Query-level via RLS? App-level middleware? DB views?]
- **Role assignment**: [Admin manually assigns / User self-assigns limited roles / System assigns on signup]
- **Role escalation prevention**: [Mechanism: separate DB transaction for privilege changes, audit log, admin approval required]

**If ABAC** (Attribute-Based Access Control):
- **Attributes**: [Examples: user.department, user.location, resource.classification, action.risk_level]
- **Policy engine**: [Named tool: Rego (OPA) / XACML / Custom]; decision point [middleware, DB, app code]
- **Policy evaluation**: [Synchronous (deny on error) / Asynchronous (log, monitor)]

**If RLS** (Row-Level Security, multi-tenant):
- **Tenant isolation**: [Mechanism: Row-level filter via DB policy (PostgreSQL RLS) / App-level query filter / Separate schema]
- **Enforcement**: [Query-level (safer) / App-level (error-prone); document which]
- **Test coverage**: [Explicit test that user A cannot read user B's data across tenants]

**If Custom**:
- **Model**: [Description of access decision mechanism]
- **Enforcement points**: [Where in code flow is decision made?]

## Secrets Management

### Secrets Inventory

| Secret type | Examples | Tool | Rotation | Access | Storage |
|---|---|---|---|---|---|
| Database password | DB_PASSWORD | [Named: AWS Secrets Manager / HashiCorp Vault / 1Password Secrets Automation / env var] | [Frequency: monthly/quarterly/on-departure]; [Mechanism: rotate in place / blue-green] | [Who: CI/CD only / Service account / Human on-call] | [Location: environment variable / mounted file / in-memory] |
| API keys | Stripe key, Twilio key | [Same tool] | [Frequency] | [Access policy] | [Storage] |
| Encryption keys | Master key, KMS key | [Same tool] | [Frequency: auto / manual] | [Key envelope pattern: app never sees master key directly] | [Storage: KMS / HSM / vault] |
| OAuth credentials | Client secret, redirect URI | [Same tool] | [Frequency: rotate on security incident] | [Developer setup / CI/CD only] | [Storage] |
| SSH/deploy keys | Private keys for deployment | [Same tool] | [Frequency: quarterly] | [Service account for CI/CD; human dev has none on laptop] | [Storage] |

### Key Rotation

- **Policy**: [Mandatory schedule / Triggered by event / On-departure rotation]
- **Implementation**: [How are old keys revoked? Grace period for rotation? Backward compatibility?]
- **Audit**: [Log every rotation; alert if rotation fails]

### Access Control

- **Who can view secrets**: [Only service accounts / Selected humans with approval / CI/CD only]
- **Audit trail**: [All access logged; alerts on unauthorized view attempts]

## Data Encryption

### Encryption in Transit

- **Protocol**: [TLS 1.3 minimum; TLS 1.2 OK if TLS 1.3 unavailable]
- **Certificate pinning**: [Yes/No]; if yes: [how are pins updated; cert rotation process]
- **Forward secrecy**: [Cipher suite must support ECDHE; no static RSA]
- **mTLS** (mutual TLS): [Required for service-to-service / API access / Not needed]

### Encryption at Rest

- **Cipher**: [AES-256-GCM / ChaCha20-Poly1305 / XChaCha20-Poly1305]
- **Key management**: [Master key in KMS / Key envelope with field-level encryption / Per-user keys]
- **PII encryption**: [Fields encrypted: email / phone / SSN / health_data / other; cipher, key derivation method]
- **Encrypted field access**: [App decrypts for search? / Search on encrypted field (deterministic encryption or separate index)? / No search on encrypted data]
- **Key rotation**: [Frequency: annual / on-breach / as-scheduled]; [Mechanism: re-encrypt old data or lazy-decrypt-encrypt]

### Database Encryption

- **Provider**: [Managed (RDS encryption, PlanetScale encrypted DB) / Self-managed (TDE, file-level encryption) / None]
- **Key location**: [AWS KMS / Google Cloud KMS / HashiCorp Vault / Self-managed]
- **Scope**: [Entire database / Specific tables (PII tables only) / Specific columns (deterministic encryption for search)]

## Security Headers & CSP

### HTTP Security Headers

| Header | Value | Rationale |
|--------|-------|-----------|
| Strict-Transport-Security (HSTS) | max-age=31536000; includeSubDomains; preload | Force HTTPS; prevent downgrade attacks |
| X-Content-Type-Options | nosniff | Prevent MIME sniffing |
| X-Frame-Options | DENY or SAMEORIGIN | Prevent clickjacking |
| X-XSS-Protection | 1; mode=block | Legacy browser XSS protection |
| Referrer-Policy | strict-origin-when-cross-origin | Control referrer leakage |
| Content-Security-Policy (CSP) | [see below] | Strict XSS mitigation |

### Content Security Policy (CSP)

**Directive**: [Inline or report-only mode during rollout?]

```
default-src 'self';
script-src 'self' [trusted CDNs: cdn.jsdelivr.net / ...];
style-src 'self' [trusted CDNs];
img-src 'self' data: https:;
font-src 'self' [CDNs];
connect-src 'self' [API endpoints];
frame-ancestors 'none';
base-uri 'self';
form-action 'self';
report-uri /csp-report;
```

**Nonce strategy**: [If allowing inline scripts, use nonce per-request: <script nonce="random">]

## Compliance Obligations

### Legal & Regulatory

| Regulation | Applicability | Key requirements | Implementation |
|---|---|---|---|
| GDPR (EU) | [Yes/No]; if yes, why [app serves EU users / EU HQ / EU customer data] | Right to erasure, data portability, breach notification 72h, DPA, privacy policy, consent | [Deletion method: hard delete / anonymization]; [Data export: format, timing]; [Breach procedure] |
| CCPA (California) | [Yes/No]; if yes, why [app serves CA users / CA business] | Right to know, delete, opt-out of sale, non-discrimination | [As above] |
| HIPAA (Health Data) | [Yes/No]; if yes [BAA required, audit controls, encryption, access logs] | Encryption at rest + transit, minimum necessary access, audit logs 6 years | [Encryption cipher, key management, audit log details] |
| PCI-DSS (Payment Data) | [Yes/No]; if yes [tokenize card data via Stripe / PayPal / don't store PAN] | No card storage in your DB; use tokenized payments only; PCI L3/L4 SAQ | [Payment processor: Stripe (PCI Level 1) / PayPal / Square; card data never touches app] |
| SOC 2 Type II (B2B SaaS) | [Yes/No]; if yes [annual audit] | Security, availability, confidentiality controls; audit trail; incident response | [Third-party audit firm; control implementation in S12] |

### Data Retention & Deletion

| Data type | Retention | Deletion method | Legal basis |
|---|---|---|---|
| User account (PII) | Until user deletes or requests erasure | Hard delete or anonymize PII | GDPR right to erasure |
| Audit logs | [Interval: 1 year / 2 years / 7 years] | Archive or delete | Regulatory (HIPAA 6yr, SOX 7yr) |
| Payment records | [Interval: Per payment processor terms; typically 7 years] | Archive, not delete | PCI-DSS, tax/financial regulations |
| Session data | [Interval: 30 days after logout] | Hard delete | Data minimization |
| Analytics events | [Interval: 2 years] | Archive to cold storage, delete after | GDPR data minimization |

### Breach Notification

- **Timeline**: [72 hours to notify users / authorities; e.g., GDPR 72h from discovery]
- **Process**: [Incident response team notifies; legal review before disclosure]
- **Communication**: [Template for user notification; what info disclosed; mitigation steps]

## Pen Testing & Security Audits

### Penetration Testing

- **Frequency**: [Quarterly / Semi-annual / Annual / On-demand before major release]
- **Scope**: [Full application / API endpoints only / Auth flows only]
- **Tester**: [Internal / Third-party firm (named: e.g., HackerOne, Synack, regional firm)]
- **Reporting**: [Severity classification: Critical / High / Medium / Low / Info]; vulnerability disclosure SLA [Critical: 48h fix, 7d deploy / High: 1w / Medium: 2w]

### Security Audits (Internal)

- **Frequency**: [Monthly / Quarterly]
- **Components**: [Code review (focus: auth, encryption, injection); dependency scanning; configuration audit]
- **Tools**: [Snyk / npm audit / OWASP ZAP / SonarQube]
- **Thresholds**: [Critical/High vulns block deploy; Medium vulns require ticket + timeline]

### Security Training

- **Required for**: [All developers / Backend-only / On-boarding]
- **Topics**: [OWASP Top 10, secure coding, API security, incident response]
- **Frequency**: [Annual / Bi-annual]

## Incident Response

### Incident Classification

| Severity | Impact | Response SLA | Example |
|---|---|---|---|
| Critical | Data breach, service unavailable, active exploit | 1h response, 4h mitigation | "Attacker dumps 10K user records" |
| High | Single user compromised, minor data leak | 4h response, 1d mitigation | "Unauthorized access to one account" |
| Medium | Configuration error, potential exposure | 1d response, 1w mitigation | "Secrets committed to git (caught before push)" |
| Low | Suspicious activity, requires investigation | 1w response, 2w mitigation | "Unusual login patterns, possible brute-force attempt" |

### Response Workflow

1. **Detection**: [Automated (IDS/IPS, log monitoring) / Manual (user report)]
2. **Classification**: [Triage: who, what, when, scope]
3. **Containment**: [Immediate actions: revoke tokens, disable account, isolate service]
4. **Eradication**: [Fix root cause: patch vulnerability, rotate credentials, update security rules]
5. **Recovery**: [Restore from backup if needed; verify systems healthy]
6. **Post-Incident**: [RCA (root cause analysis); update security policies; notify stakeholders; legal review before disclosure]

### Incident Communication

- **Internal**: [Slack channel #security-incidents; escalation to <on-call>]
- **External**: [Legal review required before user notification]
- **Legal/Compliance**: [Notify [regulatory body] within [timeframe, e.g., 72h for GDPR]

## Constraints for Downstream Sections

### For S12 (DevOps & Hosting)
- Encryption: Implement [cipher, e.g., AES-256-GCM] for [data types]; key stored in [location, e.g., AWS Secrets Manager]
- Secrets management: Use [tool, e.g., AWS Secrets Manager / HashiCorp Vault]; rotate [frequency]
- Audit logs: Stream to [location, e.g., S3 / CloudWatch / ELK]; retention [interval]
- Secure headers: Deploy CSP [headers above] via [location: nginx / CDN / app middleware]
- TLS: Enforce TLS 1.3 minimum; cert auto-renewal via [tool: Let's Encrypt / AWS ACM]
- Network: VPC isolation, no public DB endpoints, IP whitelisting for admin access

### For S13 (Testing & QA)
- Auth tests: [Critical paths: login, logout, session timeout, token refresh, MFA bypass attempts, privilege escalation]
- Security tests: [OWASP scanning, dependency checks, CSP validation, encrypted field verification]
- Breach simulation: [Quarterly table-top exercise; incident response playbook tested]

## Decisions

- **Auth strategy locked as [JWT/Sessions/OAuth]**: [1 sentence justification]
- **Access control locked as [RBAC/ABAC/RLS]**: [1 sentence justification]
- **Encryption locked as [Cipher, algorithm]**: [1 sentence justification]
- **Secrets tool locked as [Tool name]**: [1 sentence justification]
- **Pen test frequency locked as [Schedule]**: [1 sentence justification]
- **Compliance obligations locked as [List]**: [1 sentence justification]

## Open Issues

<List unknowns: third-party OAuth provider not chosen, compliance jurisdiction ambiguous if customer in multiple countries, specific identity provider (Auth0/Amazon Cognito) not selected>

## Advisory Notes

- [Legal] PII encryption (email, phone) must be enforced in S12 deploy; audit quarterly to catch any unencrypted columns added post-deploy
- [Compliance] If multi-tenant with row-level isolation: include explicit penetration test in S13 to verify tenant A cannot read tenant B data (test case: malicious query manipulation)
- [Process] GDPR right-to-deletion: implement cascading delete in S12 (user delete → delete all related data) and test in S13; audit trail must log deletion events
- [Security] Auth token handling in frontend: team review required; confirm tokens never logged, never sent to analytics, never in localStorage if sensitive (use HttpOnly cookie instead)
- [Incident] Breach notification SLA: legal must sign off on template before deploying; update template after any real incident to reflect lessons learned
```

Then emit this return block:

```
SECTION RETURN
──────────────
Section: S11 — Security & Compliance
Status: complete
Open issues: <count>
Backward update needed: [yes/no]
Forward flags: Threat model addresses [top threat types]. Auth surface: [JWT/sessions/OAuth]. Access control: [RBAC/ABAC/RLS]. Encryption: [cipher]. MFA: [yes/no]. PII fields: [list]. S12 must implement [secrets tool, encryption, audit logging]. S13 must test [auth flows, security edge cases, breach notification].
Next section: S12 — DevOps & Hosting
Pending actions: none
```

### Backward update protocol

| Upstream doc | What triggers update | File | Note |
|---|---|---|---|
| S01-problem-vision.md | Geographic scope or target market changes in S01 | Update Compliance Obligations section with new regulatory scope (GDPR/CCPA/HIPAA) | If S01 adds new region (e.g., "now serving Japan"): S11 compliance obligations must include Japan PPC law |
| S09-technical-arch.md | Auth strategy or third-party integrations change in S09 | Update Authentication & Authorization section + Threat Model (new attack surfaces) | If S09 auth changes from sessions to JWT: re-evaluate session hijacking threat, add token tampering threat |
| S02-user-roles.md | User roles or hierarchy added/removed in S02 | Update Access Control Model section; add/remove role definitions | If S02 adds "Superadmin" role: S11 must define superadmin permissions and privilege escalation test |

## Advisory Notes scan

Run before writing the section. Scan for legal/compliance exposure:

1. **PII collection**: User emails, phone, SSN, health records, financial data, location? → Flag which fields require encryption (S11) + GDPR/CCPA handling (retention/deletion in S12/S13)
2. **Payment data**: Accepting credit cards / bank transfers? → Flag: must use tokenized payment processor (Stripe, PayPal); never store PAN in DB (PCI-DSS)
3. **User deletion**: Can users request account deletion? → Flag: hard delete or anonymization required; audit log retention separate from user data
4. **Multi-tenancy**: If row-level isolation: flag for S13 penetration test (verify tenant isolation works)
5. **Third-party integrations**: OAuth, Stripe, email service, SMS? → Flag: each is attack surface; review data handling in S11 threat model; OAuth provider terms may require security audit (S11)
6. **Geographic scope**: EU users? → GDPR applies (right to erasure, breach notification 72h, DPA required). US? → CCPA if customer in California. Health data? → HIPAA if in US. Flag for S01 clarification if ambiguous.

Write findings as bullets in Advisory Notes section at the end of the doc.

## Verification

Run `superpowers:verification-before-completion` gate.

Checklist:
1. Top 5 threats explicitly named (not "security threats" or "data breaches")?
2. Each threat has attack surface, actor, attack path, impact, likelihood, mitigations (technical + process + detection)?
3. OWASP Top 10 table complete (all 10 threats mapped to mitigations)?
4. Auth strategy specific (JWT with signature algorithm / Sessions with storage / OAuth with scope)?
5. Token expiry and refresh strategy defined (access token lifetime, refresh token lifetime, rotation)?
6. MFA decision made and justified (required for all / admin only / sensitive actions only / not required)?
7. Access control model named (RBAC/ABAC/RLS) with enforcement details?
8. Secrets tool named (AWS Secrets Manager / Vault / 1Password / env var) with rotation frequency?
9. Encryption cipher specified (AES-256-GCM / ChaCha20 / other) with key management approach?
10. Security headers (HSTS, CSP, etc.) defined with actual directives?
11. Compliance obligations (GDPR/CCPA/HIPAA/PCI-DSS/SOC 2) mapped with implementation details?
12. Breach notification timeline and process defined?
13. Pen test frequency and scope locked?
14. All forward flags filled (S12 secrets/encryption/audit/headers, S13 auth test cases)?
15. Backward update protocol table present?

## Spec output

Write to `docs/architect/spec/11-security.md`.

Use this structure:

```markdown
# S11 Security & Compliance — Spec

## Key Decisions

- Threat model: Top 5 threats [names]
- Auth: [JWT/Sessions/OAuth] with [token expiry]
- Access control: [RBAC/ABAC/RLS]
- Encryption: [Cipher] for [PII fields]
- Secrets tool: [Tool name]
- Compliance: [GDPR/CCPA/HIPAA/PCI-DSS/SOC 2 — which apply]
- Pen testing: [Frequency]

## Threat Model (High Level)

[Copy threat names + likelihood + top mitigations (1 line each)]

## Auth Strategy

- Token format: [JWT/Opaque]; expires [interval]
- MFA: [Yes/No]; method [TOTP/SMS/other]
- Session timeout: [Interval]
- Token revocation: [Mechanism]

## Access Control

- Model: [RBAC/ABAC/RLS]
- Roles: [List]
- Enforcement: [Query-level / App-level]

## Encryption

- Cipher: [Algorithm]
- In transit: [TLS version]
- At rest: [Cipher, key management]
- PII fields: [List]

## Compliance Obligations

[Copy table from main section]

## Forward Flags for Downstream

**For S12:** Secrets tool [name], key rotation [frequency], audit log retention [period], security headers [list]
**For S13:** Auth test cases [critical paths], security test checklist [OWASP coverage, dependency scan], breach simulation [yes/no, frequency]
```
