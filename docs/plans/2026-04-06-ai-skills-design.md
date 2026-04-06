# Verda AI Skills -- Design & Implementation Plan

## Overview

A single, unified skill file that teaches AI agents (Claude Code, Cursor, Codex, Gemini) how to use the `verda` CLI to manage cloud infrastructure. The skill is a markdown file that agents read to understand available commands, workflows, and safety rules.

## Target User

Developers and researchers using AI coding agents who have `verda` CLI installed and authenticated.

## Key Design Decisions

1. **Single unified skill** (`verda-cloud.md`) -- not multiple files. The Verda CLI has ~15-20 commands, and real workflows (e.g., deploy a VM) cut across discovery, cost, creation, and SSH. Splitting creates friction where the agent must figure out which skill to load first.

2. **Workflow-oriented, not reference-oriented** -- the skill tells the agent *what order to run commands* and *what safety checks to perform*. It does NOT include full flag references or response schemas -- the agent can run `verda <cmd> --help` and read the JSON output itself.

3. **Target size: 150-200 lines** -- enough for workflows + safety rules, small enough to not explode context. If it grows beyond that, split with evidence, not speculation.

4. **Rely on CLI output for GPU spec matching** (not a hardcoded GPU reference table). GPU offerings change as Verda adds new hardware, so a static table in the skill goes stale. `verda instance-types --gpu -o json` already returns all needed fields (`gpu_memory.size_in_gigabytes`, `gpu.number_of_gpus`, `model`, `manufacturer`, `price_per_hour`, `spot_price`). The skill teaches the agent to filter CLI output against user requirements (VRAM size, GPU count, model name) rather than looking up specs from an embedded table.

## Repo Structure

```
verda-ai-skills/
  skills/
    verda-cloud.md            # Single unified skill
  tests/
    mock-verda.sh             # Mock CLI that validates args, returns canned JSON
    scenarios/
      deploy-gpu-vm.sh        # Dry-run test: deploy GPU VM workflow
      list-and-describe.sh    # Dry-run test: list + describe
      delete-vm.sh            # Dry-run test: destructive action safety
      check-costs.sh          # Dry-run test: cost workflow
    expected/
      deploy-gpu-vm.json      # Expected command sequence + args
      list-and-describe.json
      delete-vm.json
      check-costs.json
  install.sh                  # Install skill to ~/.claude/skills/
  README.md
  docs/plans/
    2026-04-06-ai-skills-design.md  # This file
```

## Skill Design Principles

1. **Always use `-o json`** -- agents parse structured output, not tables
2. **Safety first** -- always check cost/balance before creating resources, always confirm destructive actions with user
3. **Discovery before action** -- list locations/types/images before creating
4. **Idempotent guidance** -- check current state before acting
5. **Delegate details to `--help`** -- don't duplicate flag references in the skill

## Skill Content: `verda-cloud.md`

### Metadata

```yaml
---
name: verda-cloud
description: Use when the user wants to manage Verda Cloud infrastructure -- deploy VMs, check costs, manage volumes, SSH into instances, or manage SSH keys and startup scripts
---
```

### Section Structure (Target: 150-200 lines)

#### 1. Prerequisites (~10 lines)
- Check `verda` is installed: `which verda`
- Check auth: `verda auth show -o json`
- If not authenticated: tell user to run `verda auth login`

#### 2. Safety Rules (~15 lines)
- NEVER create a VM without showing cost estimate to user first
- NEVER perform destructive actions (delete, shutdown) without explicit user confirmation
- ALWAYS use `--wait` flag so agent knows when operations complete
- ALWAYS check `verda cost balance -o json` before creating resources
- ALWAYS use `-o json` for all commands to get parseable output
- When a command needs more detail on flags, run `verda <command> --help`

#### 3. Discovery Commands (~20 lines)
Quick reference of commands for exploring available resources:
```
verda locations -o json                              # datacenters
verda instance-types [--gpu|--cpu] [--spot] -o json  # specs + pricing
verda availability [--location X] [--type Y] -o json # stock check
verda images [--type X] [--category Y] -o json       # OS images
verda ssh-key list -o json                           # SSH keys
verda startup-script list -o json                    # startup scripts
```

#### 4. Workflow: Deploy a VM (~30 lines)
Step-by-step with decision points:
```
1. verda auth show -o json                              # verify auth
2. verda cost balance -o json                           # check balance
3. verda locations -o json                              # pick location
4. verda instance-types --gpu -o json                   # pick instance type
5. verda availability --type <type> -o json             # verify available
6. verda images --type <type> -o json                   # pick OS image
7. verda cost estimate --type <type> --os-volume <size> -o json  # estimate cost
8. [CONFIRM WITH USER: show estimated cost, ask to proceed]
9. verda vm create --instance-type <type> --location <loc> \
     --image <image> --ssh-key <key-id> --wait -o json
10. verda vm describe <id> -o json                      # verify running
```
Add `--startup-script <id>` if user has one. Use `verda vm create --help` for all available flags.

#### 5. VM Lifecycle (~15 lines)
```
verda vm list [-o json] [--status running]            # list all VMs
verda vm describe <id> -o json                        # detailed info
verda vm action --id <id>                             # interactive action selection
```
Actions: start, shutdown, force_shutdown, hibernate, delete
- For delete: ALWAYS confirm with user first

#### 6. Cost Management (~10 lines)
```
verda cost balance -o json                            # account balance
verda cost estimate --type <type> [--os-volume N] [--storage N] [--spot] -o json
verda cost running -o json                            # running instance costs
```

#### 7. SSH Access (~10 lines)
```
verda ssh <hostname-or-id>                            # SSH into VM
verda ssh <host> --user ubuntu --key ~/.ssh/id_ed25519
verda ssh <host> -- -L 8080:localhost:8080            # port forwarding
```

#### 8. Volume Management (~10 lines)
```
verda volume list -o json
verda volume create                                   # use --help for flags
verda volume action --id <id>                         # attach, detach, trash
verda volume trash list -o json
```

#### 9. SSH Key & Startup Script Management (~10 lines)
```
verda ssh-key list -o json
verda ssh-key add                                     # use --help for flags
verda ssh-key delete
verda startup-script list -o json
verda startup-script add                              # use --help for flags
verda startup-script delete
```

**Estimated total: ~140-160 lines**

## Installation

### install.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skills/verda-cloud.md" "$SKILL_DIR/"
echo "Verda Cloud skill installed to $SKILL_DIR/verda-cloud.md"
```

### Future: CLI integration

```bash
verda skills install    # copies skill from embedded or fetched source
verda skills update     # updates to latest version
```

## Quality Validation

### Level 1: Dry-Run Tests (Implement Now)

Mock the `verda` CLI with a shell script that:
- Validates the command and flags are correct
- Returns canned JSON responses
- Logs the command sequence

Test scenarios:
1. **deploy-gpu-vm** -- agent should: check auth → check balance → discover → estimate cost → confirm → create → verify
2. **list-and-describe** -- agent should: list VMs → pick one → describe it
3. **delete-vm** -- agent should: confirm with user before deleting
4. **check-costs** -- agent should: balance + running costs + estimate

Each scenario has an expected command sequence. The test asserts:
- Commands were called in the right order
- Required flags were present (e.g., `-o json`)
- Safety checks happened (e.g., cost estimate before create)
- User confirmation was requested before destructive actions

### Level 2: Real Integration Tests (Future)

Run against Verda API with a test account. Create VM, verify, delete. Expensive but definitive.

### Level 3: Human Eval (Future)

Have developers/researchers try the skill with real tasks and rate the experience.

## Implementation Steps

### Step 1: Initialize Repo

```bash
cd verda-ai-skills
git init
```

Create:
- `README.md` -- project overview, installation instructions, what skills are
- `.gitignore`
- `LICENSE`

### Step 2: Write the Skill

Create `skills/verda-cloud.md` following the section structure above. Key principles:
- Workflow-oriented, not reference-oriented
- Safety rules are prominent and clear
- Commands show the `-o json` pattern
- Agent is told to use `--help` for full flag details
- Target 150-200 lines

### Step 3: Write install.sh

The install script from the Installation section above.

### Step 4: Build Mock CLI for Testing

Create `tests/mock-verda.sh`:
- A bash script that mimics `verda` CLI behavior
- Accepts the same subcommands and flags
- Validates required flags are present
- Returns canned JSON from fixture files
- Logs every invocation to a command log file

Create `tests/fixtures/`:
- `auth-show.json` -- canned auth response
- `cost-balance.json` -- canned balance response
- `locations.json` -- canned locations response
- `instance-types-gpu.json` -- canned GPU instance types
- `availability.json` -- canned availability matrix
- `images.json` -- canned image list
- `cost-estimate.json` -- canned cost estimate
- `vm-create.json` -- canned create response
- `vm-list.json` -- canned VM list
- `vm-describe.json` -- canned VM details
- `ssh-key-list.json` -- canned SSH keys

### Step 5: Write Test Scenarios

Create test scripts in `tests/scenarios/` that:
1. Set `PATH` to prefer `mock-verda.sh` as `verda`
2. Define the scenario (what the user asked)
3. Define expected command sequence
4. Run the agent with the skill loaded
5. Compare command log against expected sequence

For the initial implementation, these can be **manual test scripts** that a developer runs with Claude Code to verify behavior. Full automation (running an agent programmatically) is a future enhancement.

Simpler initial approach for Step 5:
- Each scenario is a markdown file describing the test case
- Expected command sequence is documented
- Developer runs the scenario manually with Claude Code + mock CLI
- Verifies the command log matches expectations

### Step 6: Document in README

- What this repo is
- How to install
- How to use (with examples)
- How to test
- How to contribute new scenarios

## Open Questions

1. Should skills be embedded in the `verda` CLI binary and extracted via `verda skills install`?
2. Should we publish skills to a registry (npm, homebrew tap) for easier distribution?
3. How do we version-sync skills with CLI changes? (e.g., new flags, new commands)
4. Should the mock CLI return realistic data from actual Verda API snapshots?
