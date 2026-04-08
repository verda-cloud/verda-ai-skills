# verda-ai-skills

Teach AI coding agents how to manage Verda Cloud infrastructure through the `verda` CLI. Install the skills and your agent gains structured knowledge of deployment workflows, cost management, and troubleshooting — without you explaining them each time.

## Install

### Quick install (auto-detects your agent)

```bash
git clone https://github.com/verda-cloud/verda-ai-skills.git
cd verda-ai-skills
./install.sh
```

### Manual install by agent

**Claude Code:**
```bash
cp skills/*.md ~/.claude/skills/
```

**Cursor:**
```bash
mkdir -p .cursor/rules
cp skills/*.md .cursor/rules/
```

**Codex:**
```bash
# Append skill content to your project's AGENTS.md
cat skills/verda-cloud.md >> AGENTS.md
cat skills/verda-commands.md >> AGENTS.md
```

**Gemini CLI:**
```bash
# Copy to project root
cp skills/verda-cloud.md GEMINI.md
```

## Requirements

- `verda` CLI installed: `brew install verda-cloud/tap/verda-cli`
- Authenticated: `verda auth login`

## What's included

| File | Purpose | Size |
|------|---------|------|
| `verda-cloud.md` | Decision engine — teaches agents HOW to reason about tasks | ~150 lines |
| `verda-commands.md` | Command reference — teaches agents WHAT to run and where values come from | ~130 lines |

### Skills teach agents to:

- **Classify requests** — distinguish explore vs deploy vs manage vs troubleshoot
- **Follow the dependency chain** — billing → compute → instance type → location → image → keys → cost → confirm
- **Handle errors** — parse structured `--agent` mode errors and recover automatically
- **Be efficient** — parallel fetches, cache within conversation, skip unnecessary steps
- **Stay safe** — cost checks before creation, confirmation before destruction

## Example prompts

- "Deploy a GPU VM with at least 80GB VRAM for training"
- "What's the cheapest GPU I can get right now?"
- "Show me my running costs and suggest ways to save"
- "SSH into my training box and set up Jupyter port forwarding"
- "Shut down all my VMs that aren't running anything"

## Supported agents

Claude Code, Cursor, Codex, Gemini CLI — any agent that reads markdown skill files.
