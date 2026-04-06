# verda-ai-skills

## What is this

A skill file that teaches AI coding agents (Claude Code, Cursor, Codex, Gemini) how to use the `verda` CLI to manage Verda Cloud infrastructure -- deploy GPU/CPU VMs, manage volumes, check costs, and SSH into instances. Install the skill and your agent gains structured knowledge of Verda Cloud workflows without you having to explain them each time.

## Install

Run the install script:

```
./install.sh
```

Or manually copy the skill file:

```
cp skills/verda-cloud.md ~/.claude/skills/
```

## What it does

- Safety-first workflows -- confirms destructive actions before executing
- GPU spec matching -- finds instances by VRAM, GPU model, or workload requirements
- Cost awareness -- surfaces pricing and running costs before provisioning
- VM lifecycle -- create, start, stop, restart, and destroy instances
- Volume management -- create, attach, detach, and trash persistent storage
- SSH access -- connect to instances with port forwarding for notebooks and services

## Example prompts

Try these with your AI agent after installing the skill:

- "Deploy a GPU VM with at least 80GB VRAM"
- "Show me my running costs"
- "List available GPU instances and their specs"
- "SSH into my VM and set up port forwarding for Jupyter"

## Requirements

- `verda` CLI installed and authenticated:

  ```
  verda auth login
  ```

## Supported agents

Claude Code, Cursor, Codex, Gemini -- any agent that reads markdown skill files.
