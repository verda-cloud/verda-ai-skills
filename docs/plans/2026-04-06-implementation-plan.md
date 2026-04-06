# Verda AI Skills Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ship a single unified skill file that teaches AI agents how to use the `verda` CLI, plus install script and README.

**Architecture:** Single markdown skill file (`skills/verda-cloud.md`) with workflow-oriented guidance, safety rules, and GPU spec matching. Install script copies to `~/.claude/skills/`. No test infrastructure yet.

**Tech Stack:** Markdown, Bash

---

### Task 1: Initialize Git Repo

**Files:**
- Create: `.gitignore`

**Step 1: Initialize repo and create .gitignore**

```bash
cd /Users/lei/dev/src/github/verda-cloud/verda-ai-skills
git init
```

Create `.gitignore`:
```
.DS_Store
*.swp
*.swo
*~
```

**Step 2: Initial commit**

```bash
git add .gitignore docs/
git commit -m "chore: init repo with design doc"
```

---

### Task 2: Write the Skill File

**Files:**
- Create: `skills/verda-cloud.md`

**Step 1: Create `skills/verda-cloud.md`**

The skill should follow the design doc structure (~150-160 lines):

1. **Metadata** — name, description, trigger conditions
2. **Prerequisites** (~10 lines) — check `verda` installed, check auth
3. **Safety Rules** (~15 lines) — cost before create, confirm before delete, always `-o json`, always `--wait`
4. **Discovery Commands** (~20 lines) — locations, instance-types, availability, images, ssh-keys, startup-scripts
5. **GPU Spec Matching** (~8 lines) — when user has GPU requirements (VRAM, model, count), use `verda instance-types --gpu -o json` and filter by `gpu_memory.size_in_gigabytes`, `gpu.number_of_gpus`, `model`. Show user matching options with pricing.
6. **Workflow: Deploy a VM** (~30 lines) — step-by-step with decision points
7. **VM Lifecycle** (~15 lines) — list, describe, actions
8. **Cost Management** (~10 lines) — balance, estimate, running
9. **SSH Access** (~10 lines) — ssh, port forwarding
10. **Volume Management** (~10 lines) — list, create, actions
11. **SSH Key & Startup Script Management** (~10 lines)

Key details from real CLI output to incorporate:
- `verda instance-types --gpu -o json` returns: `gpu_memory.size_in_gigabytes`, `gpu.number_of_gpus`, `model`, `price_per_hour`, `spot_price`, `manufacturer`
- Global flags: `-o json`, `--debug`, `--timeout`
- VM actions: start, shutdown, force_shutdown, hibernate, delete

**Step 2: Commit**

```bash
git add skills/verda-cloud.md
git commit -m "feat: add verda-cloud skill"
```

---

### Task 3: Write install.sh

**Files:**
- Create: `install.sh`

**Step 1: Create `install.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/skills/verda-cloud.md" "$SKILL_DIR/"
echo "Verda Cloud skill installed to $SKILL_DIR/verda-cloud.md"
```

Make executable: `chmod +x install.sh`

**Step 2: Commit**

```bash
git add install.sh
git commit -m "feat: add install script"
```

---

### Task 4: Write README.md

**Files:**
- Create: `README.md`

**Step 1: Create `README.md`**

Sections:
- **What is this** — one-paragraph explanation
- **Install** — `./install.sh` or manual copy
- **What it does** — brief list of capabilities
- **Example prompts** — 3-4 example prompts users can try:
  - "Deploy a GPU VM with at least 80GB VRAM"
  - "Show me my running costs"
  - "List available GPU instances and their specs"
  - "SSH into my VM and set up port forwarding for Jupyter"
- **Requirements** — `verda` CLI installed and authenticated
- **Supported agents** — Claude Code, Cursor, Codex, Gemini (any agent that reads markdown skills)

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README"
```

---

### Task 5: Update Design Doc

**Files:**
- Modify: `docs/plans/2026-04-06-ai-skills-design.md`

**Step 1: Add GPU spec matching section to design doc**

Add the GPU filtering decision (Option B) we agreed on to the design doc under the Discovery Commands section.

**Step 2: Commit**

```bash
git add docs/
git commit -m "docs: add GPU spec matching decision to design"
```
