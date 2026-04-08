#!/usr/bin/env bash
# Layer 1: Validate that commands and flags referenced in skills are real.
# Runs verda <cmd> --help and checks that referenced flags exist.
set -euo pipefail

PASS=0
FAIL=0
ERRORS=()

check_command() {
  local cmd="$1"
  if verda $cmd --help &>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    ERRORS+=("FAIL: 'verda $cmd --help' not found")
  fi
}

check_flag() {
  local cmd="$1"
  local flag="$2"
  if verda $cmd --help 2>&1 | grep -- "$flag" > /dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    ERRORS+=("FAIL: 'verda $cmd' missing flag '$flag'")
  fi
}

echo "Layer 1: Command Knowledge Validation"
echo "======================================"

# --- Commands exist ---
check_command "auth login"
check_command "auth show"
check_command "auth use"
check_command "locations"
check_command "instance-types"
check_command "availability"
check_command "images"
check_command "vm create"
check_command "vm list"
check_command "vm describe"
check_command "vm start"
check_command "vm shutdown"
check_command "vm hibernate"
check_command "vm delete"
check_command "vm availability"
check_command "cost balance"
check_command "cost estimate"
check_command "cost running"
check_command "ssh-key list"
check_command "ssh-key add"
check_command "ssh-key delete"
check_command "startup-script list"
check_command "startup-script add"
check_command "startup-script delete"
check_command "volume list"
check_command "volume describe"
check_command "volume create"
check_command "volume action"
check_command "volume trash"

# --- Key flags exist ---
check_flag "instance-types" "--gpu"
check_flag "instance-types" "--cpu"
check_flag "instance-types" "--spot"
check_flag "vm create" "--kind"
check_flag "vm create" "--instance-type"
check_flag "vm create" "--os"
check_flag "vm create" "--hostname"
check_flag "vm create" "--location"
check_flag "vm create" "--ssh-key"
check_flag "vm create" "--is-spot"
check_flag "vm create" "--os-volume-size"
check_flag "vm create" "--storage-size"
check_flag "vm create" "--storage-type"
check_flag "vm create" "--startup-script"
check_flag "vm create" "--contract"
check_flag "vm create" "--wait"
check_flag "vm create" "--os-volume-on-spot-discontinue"
check_flag "vm list" "--status"
check_flag "availability" "--type"
check_flag "availability" "--location"
check_flag "availability" "--spot"
check_flag "images" "--type"
check_flag "cost estimate" "--type"
check_flag "cost estimate" "--os-volume"
check_flag "cost estimate" "--spot"
check_flag "volume create" "--name"
check_flag "volume create" "--size"
check_flag "volume create" "--type"
check_flag "volume create" "--location"
check_flag "volume list" "--status"
check_flag "ssh-key add" "--name"
check_flag "ssh-key add" "--public-key"

# --- Report ---
echo ""
for err in "${ERRORS[@]+"${ERRORS[@]}"}"; do
  echo "  $err"
done
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
