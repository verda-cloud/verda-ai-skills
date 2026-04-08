#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS=("verda-cloud.md" "verda-commands.md")
installed=0

echo "Verda AI Skills Installer"
echo "========================="
echo ""

# --- Dependency check ---
if ! command -v verda &>/dev/null; then
  echo "ERROR: verda CLI not found."
  echo ""
  echo "Install it first:"
  echo "  brew install verda-cloud/tap/verda-cli"
  echo "  # or"
  echo "  curl -sSL https://raw.githubusercontent.com/verda-cloud/verda-cli/main/scripts/install.sh | sh"
  exit 1
fi
echo "verda CLI: $(verda version 2>/dev/null || echo 'found')"

# --- Auth check (warn, don't block) ---
if verda auth show -o json &>/dev/null; then
  echo "verda auth: OK"
else
  echo "verda auth: not configured (run 'verda auth login' before using skills)"
fi
echo ""

# --- Install for detected agents ---

install_skills() {
  local dest="$1"
  local agent="$2"
  mkdir -p "$dest"
  for skill in "${SKILLS[@]}"; do
    cp "$SCRIPT_DIR/skills/$skill" "$dest/"
  done
  echo "  $agent: installed to $dest/"
  installed=$((installed + 1))
}

# Claude Code
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
install_skills "$CLAUDE_DIR" "Claude Code"

# Cursor (project-level — install to current working directory if .cursor/ exists or user wants it)
if [ -d ".cursor" ] || [ -f ".cursorrules" ]; then
  CURSOR_DIR=".cursor/rules"
  install_skills "$CURSOR_DIR" "Cursor (project)"
fi

# Codex (if AGENTS.md exists in current directory, append instructions)
if [ -f "AGENTS.md" ]; then
  echo "  Codex: detected AGENTS.md — see README for manual integration"
fi

echo ""
echo "Installed to $installed agent(s)."
echo ""
echo "Try these prompts with your AI agent:"
echo '  "Deploy a GPU VM with at least 80GB VRAM"'
echo '  "Show me my running costs"'
echo '  "What GPU instances are available right now?"'
