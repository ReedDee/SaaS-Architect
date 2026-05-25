#!/usr/bin/env bash
set -e

REPO="https://raw.githubusercontent.com/ReedDee/SaaS-Architect/main/agents"
DEST="$HOME/.claude/agents"

echo "Installing SaaS Architect agents to $DEST..."

mkdir -p "$DEST"

agents=(
  "architect-principles.md"
  "architect-injector.md"
  "architect-planner.md"
  "architect-executor.md"
  "architect-brief-writer.md"
  "architect-change-mgmt.md"
  "architect-tracker.md"
  "architect-s01-problem-vision.md"
  "architect-s02-user-roles.md"
  "architect-s03-feature-map.md"
  "architect-s04-monetisation.md"
  "architect-s05-seo-gtm.md"
  "architect-s06-accessibility-i18n.md"
  "architect-s07-analytics.md"
  "architect-s08-ux-interface.md"
  "architect-s09-technical-arch.md"
  "architect-s10-data-arch.md"
  "architect-s11-security.md"
  "architect-s12-devops-hosting.md"
  "architect-s13-testing-qa.md"
  "lessons.md"
)

for agent in "${agents[@]}"; do
  curl -fsSL "$REPO/$agent" -o "$DEST/$agent"
  echo "  ✓ $agent"
done

echo ""
echo "Done. Open Claude Code in any project directory and run /architect"
