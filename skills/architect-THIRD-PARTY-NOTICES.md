# Third-Party Notices — Architect Pipeline

The architect pipeline bundles ("vendors") the following skills as P0 (critical-path)
dependencies so the pipeline runs safely without requiring the ECC or GSD plugins to
be installed. Each is redistributed under the MIT License. Original authorship and
copyright are retained below as required by the MIT License.

The vendored copies live in `~/.claude/skills/architect-<name>/` and are referenced
in the architect agents under the `architect-` namespace. The upstream originals
remain the canonical source; update vendored copies when upstream changes materially.

---

## Vendored skills

| Vendored name | Upstream | Original author / holder | License |
|---|---|---|---|
| architect-agent-introspection-debugging | ecc:agent-introspection-debugging | Affaan Mustafa (ECC), 2026 | MIT |
| architect-verification-loop | ecc:verification-loop | Affaan Mustafa (ECC), 2026 | MIT |
| architect-santa-method | ecc:santa-method | Ronald Skelton (RapportScore.ai); distributed via ECC | MIT |
| architect-safety-guard | ecc:safety-guard | Affaan Mustafa (ECC), 2026 | MIT |
| architect-gateguard | ecc:gateguard | community contributor; distributed via ECC | MIT |
| architect-tdd-workflow | ecc:tdd-workflow | Affaan Mustafa (ECC), 2026 | MIT |

## Vendored agents (verbatim copy, self-contained)

| Vendored name | Upstream | Original author / holder | License |
|---|---|---|---|
| architect-security-reviewer | ecc:security-reviewer (agent) | Affaan Mustafa (ECC), 2026 | MIT |

## Native agents (architect-original, GSD-inspired)

These are NOT copies. They were written from scratch for the architect pipeline,
targeting architect's own `docs/architect/` layout, with no `gsd-sdk` runtime
dependency. The GSD agents below were design inspiration only; no GSD code was copied.
No attribution is legally required, but the lineage is noted for honesty.

| Native agent | Inspired by (not copied) | Upstream author | Note |
|---|---|---|---|
| architect-plan-checker | gsd-plan-checker | TÂCHES / gsd-build | goal-backward plan check, architect-native |
| architect-verifier | gsd-verifier | TÂCHES / gsd-build | goal-backward build verification, architect-native |
| architect-debugger | gsd-debugger | TÂCHES / gsd-build | scientific-method debug, architect-native |

---

## MIT License (applies to all bundled ECC skills above)

```
MIT License

Copyright (c) 2026 Affaan Mustafa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

GSD skills/agents (get-shit-done-cc) are MIT-licensed by TÂCHES / gsd-build.
superpowers components, where referenced, are MIT-licensed © 2025 Jesse Vincent.
