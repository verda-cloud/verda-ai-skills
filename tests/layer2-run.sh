#!/usr/bin/env bash
# Layer 2: Workflow integration test runner.
# Sets up mock CLI in PATH, clears log, prints instructions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCENARIO="${1:-}"

if [ -z "$SCENARIO" ]; then
  echo "Usage: ./tests/layer2-run.sh <scenario-name>"
  echo ""
  echo "Available scenarios:"
  ls "$SCRIPT_DIR/scenarios/" | sed 's/.md$//'
  exit 1
fi

SCENARIO_FILE="$SCRIPT_DIR/scenarios/${SCENARIO}.md"
if [ ! -f "$SCENARIO_FILE" ]; then
  echo "Scenario not found: $SCENARIO_FILE"
  exit 1
fi

# Setup
export VERDA_MOCK_LOG="/tmp/verda-mock.log"
export VERDA_FIXTURES_DIR="$SCRIPT_DIR/fixtures"
export PATH="$SCRIPT_DIR/bin:$PATH"

# Create bin/verda symlink to mock
mkdir -p "$SCRIPT_DIR/bin"
ln -sf "$SCRIPT_DIR/mock-verda.sh" "$SCRIPT_DIR/bin/verda"
chmod +x "$SCRIPT_DIR/mock-verda.sh" "$SCRIPT_DIR/bin/verda"

# Clear previous log
> "$VERDA_MOCK_LOG"

echo "Layer 2: Workflow Integration Test"
echo "==================================="
echo ""
echo "Scenario: $SCENARIO"
echo "Mock log: $VERDA_MOCK_LOG"
echo ""
echo "--- Scenario Description ---"
cat "$SCENARIO_FILE"
echo ""
echo "--- Instructions ---"
echo "1. Open a NEW Claude Code / Cursor session"
echo "2. Make sure skills are installed: ./install.sh"
echo "3. Paste the 'User prompt' from above"
echo "4. After the agent finishes, run:"
echo "   cat $VERDA_MOCK_LOG"
echo "5. Compare command log against 'Expected command sequence'"
echo ""
echo "Mock CLI is ready at: $SCRIPT_DIR/bin/verda"
echo "Add to PATH: export PATH=\"$SCRIPT_DIR/bin:\$PATH\""
