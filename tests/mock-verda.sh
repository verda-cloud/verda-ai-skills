#!/usr/bin/env bash
# Mock verda CLI — logs commands and returns fixture JSON.
# Set VERDA_MOCK_LOG to control log file path.
# Set VERDA_FIXTURES_DIR to control fixture directory.

LOG="${VERDA_MOCK_LOG:-/tmp/verda-mock.log}"
FIXTURES="${VERDA_FIXTURES_DIR:-$(dirname "$0")/fixtures}"

# Log the full command
echo "verda $*" >> "$LOG"

# Strip --agent, -o json, --wait flags for matching
args="$*"
args=$(echo "$args" | sed 's/--agent//g; s/-o json//g; s/--wait//g' | xargs)

# Match command to fixture
case "$args" in
  "auth show")         cat "$FIXTURES/auth-show.json" ;;
  "locations")         cat "$FIXTURES/locations.json" ;;
  instance-types*)     cat "$FIXTURES/instance-types.json" ;;
  availability*)       cat "$FIXTURES/availability.json" ;;
  images*)             cat "$FIXTURES/images.json" ;;
  "cost balance")      cat "$FIXTURES/cost-balance.json" ;;
  cost\ estimate*)     cat "$FIXTURES/cost-estimate.json" ;;
  "cost running")      cat "$FIXTURES/cost-running.json" ;;
  "ssh-key list")      cat "$FIXTURES/ssh-key-list.json" ;;
  vm\ create*)         cat "$FIXTURES/vm-create.json" ;;
  "vm list")           cat "$FIXTURES/vm-list.json" ;;
  vm\ describe*)       cat "$FIXTURES/vm-describe.json" ;;
  "volume list")       cat "$FIXTURES/volume-list.json" ;;
  ssh*)                echo '{"status": "connected"}' ;;
  version)             echo "mock-verda v0.0.0-test" ;;
  *)
    echo "{\"error\": {\"code\": \"UNKNOWN_COMMAND\", \"message\": \"mock does not handle: $args\"}}" >&2
    exit 1
    ;;
esac
