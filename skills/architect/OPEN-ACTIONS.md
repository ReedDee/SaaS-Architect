# Architect — Open Actions

Shown on every `/architect` load. Update as items close. Last updated: 2026-06-18.

## Pending (resume here)

| # | Action | Why | Status |
|---|--------|-----|--------|
| 1 | Sandbox-test the completion-verification gate on a live pipeline | Built Injector Step 5a.5 gate but never run against a real hollow section | not started |
| 2 | Scaffold architect as a real plugin (`.claude-plugin/plugin.json` + marketplace + move agents/skills under plugin root) | Prerequisite for ALL distribution work; vendored skills currently sit loose in `~/.claude/` | not started |
| 3 | Vendor the 3 native agents' dirs + 6 skills + security-reviewer into the plugin root once scaffolded | Make plugin self-contained | blocked on #2 |
| 4 | Bundle `.mcp.json` (exa + context7) into the plugin scaffold | Auto-start research/docs MCPs for distributed users; replaces ~5 research refs cleanly | blocked on #2 |
| 5 | Build loud-degrade guard for ~14 P1 external refs | They fail silently if ECC/GSD absent; log skip to `00-issues.md` | not started |

## Known gaps (not blocking, track)

| Gap | Detail |
|-----|--------|
| Silent degradation | ~93 `ecc:`/`gsd-` refs (45 ECC skills, 6 ECC agents, 14 GSD skills, 28 GSD agents) fire only if plugin installed; no warning when skipped. Most are P2 optional — only ~14 P1 worth the loud-degrade guard. |
| No plugin-dependency mechanism | Confirmed via official docs: plugin.json/marketplace.json cannot declare deps on other plugins. ECC/GSD must be vendored, MCP-bundled, or documented as manual prereqs. |
| Context-load claim | Memory obs #1907: measured ~30% savings, not the 70% the design claims. Re-measure or correct the claim. |

## Done this session (2026-06-18)

- Completion-verification gate wired into Injector Step 5a.5 + `required_outputs` added to all 14 registry sections; Tracker refuses bare "complete".
- 6 P0 skills vendored to `~/.claude/skills/architect-*` with MIT attribution + `architect-THIRD-PARTY-NOTICES.md`.
- security-reviewer agent vendored (self-contained); removed from ghost watchlist.
- 3 native agents written (architect-plan-checker, -verifier, -debugger) replacing gsd-sdk-coupled GSD agents.
- All P0 refs rewired ecc:/gsd- → architect- across executor, planner, change-mgmt, principles, s13; introspection wired into Executor BLOCKED path.
- 5 research/docs refs rewired to exa/context7 as primary (s01, s05, planner, executor); ECC research skills marked optional.
- Licensing confirmed MIT for ECC/GSD/superpowers.
