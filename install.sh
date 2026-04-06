#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skills/verda-cloud.md" "$SKILL_DIR/"
echo "Verda Cloud skill installed to $SKILL_DIR/verda-cloud.md"
