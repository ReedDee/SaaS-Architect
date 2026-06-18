---
name: architect-init
description: Initialize architect scaffold (Step -2) - creates docs/architect/ structure for any project
---

# Architect Init — Step -2

Generic scaffold initialization for new or add-to-existing projects.

## Input Parameters

- `project_name`: Project name (string)
- `cwd`: Project root directory (absolute path, passed at runtime)
- `mode`: Full | Lite | Custom (string)
- `sections`: Array of section numbers to run: [1,2,3,4,7,8,9]
- `product_brief`: 2-3 sentence product description (string)

## Execution (Generic for Any User)

### 1. Create folder structure (relative to cwd)

```
docs/architect/
  ├─ 00-context.md
  ├─ 00-state.md
  ├─ 00-issues.md
  ├─ 00-next-section-brief.md
  └─ spec/
```

Create `docs/` if missing.

### 2. Write docs/architect/00-context.md

Replace placeholders:
- `<project_name>` → from input
- `<cwd>` → from input (absolute path)
- `<today>` → current date YYYY-MM-DD
- `<mode>` → from input
- `<skipped_sections>` → calculate from sections array
- `<product_brief>` → from input

### 3. Write docs/architect/00-state.md

Replace placeholders:
- `<project_name>` → from input
- `<cwd>` → from input
- `<today>` → current date
- `<sections_pending>` → calculate from sections array (e.g., [S01, S02, S03, S04, S07, S08, S09])
- `<next_section>` → first pending section number

### 4. Write docs/architect/00-issues.md

Template only (empty, ready for population).

### 5. Write docs/architect/00-next-section-brief.md

Template only (empty, ready for Brief Writer).

### 6. Skills check (optional warning)

Scan `~/.claude/plugins/cache/ecc/*/skills/` for:
- architect
- frontend-patterns (if 6 in sections)
- backend-patterns (if 7 in sections)
- database-migrations (if 8 in sections)
- security-scan (if 10 in sections)
- tdd-workflow (if 13 in sections)

If missing: log warning to 00-issues.md but do not block.

### 7. Return status

Output exactly:
```
Scaffold initialized: docs/architect/
Mode: <mode>
Sections: <list>
Ready for S01.
```

## No Hardcoded Paths

- Uses `cwd` parameter only
- No Ray-specific or user-specific paths
- Relative paths only (docs/architect/, etc.)
- Reusable across projects and users

## Silent Execution

No intermediate tool output. Only final status message.
