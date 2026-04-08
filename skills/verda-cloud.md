---
name: verda-cloud
description: Use when the user mentions Verda Cloud, GPU/CPU VMs, cloud instances, deploying servers, ML training infrastructure, cloud costs/billing, SSH into remote machines, or verda CLI commands.
---

# Verda Cloud

## Prerequisites

1. Check CLI: `which verda` — if missing, install:
   `brew install verda-cloud/tap/verda-cli` or `curl -sSL https://raw.githubusercontent.com/verda-cloud/verda-cli/main/scripts/install.sh | sh`
2. Check auth: `verda auth show -o json` — if error, tell user: `verda auth login` (interactive browser flow, user must run it themselves)
3. Always use `--agent` flag for non-interactive mode — returns structured JSON errors on stderr
4. Always use `-o json` on all commands — parse structured output, never scrape tables

## Safety Rules

- **Cost before create** — always run cost estimate + balance check before creating any resource
- **Confirm before destroy** — ask user for explicit confirmation before delete, force_shutdown, or trash
- **Discovery before action** — check what's available before creating; never guess or hardcode values
- **Show pricing** — always include price_per_hour when presenting instance options
- **One at a time** — create one VM or volume at a time unless user explicitly requests batch

## Classify the Request

Before acting, determine what the user needs:

| Type | Signal | Approach |
|------|--------|----------|
| **Explore** | "what's available", "show me", "how much" | Run discovery/cost commands, present results, stop |
| **Deploy** | "create", "deploy", "spin up", "launch" | Full deploy workflow with safety checks |
| **Manage** | "start", "stop", "delete", "SSH" | Identify target VM first, then act |
| **Troubleshoot** | "not working", "can't connect", "error" | Gather state (describe, status), then diagnose |

Don't create resources when user is just exploring. Don't run full discovery when user knows exactly what they want.

## Deploy Decision Framework

When creating a VM, walk this dependency chain. Skip steps the user already answered.

### 1. Billing → spot or on-demand?
- User says "cheap", "testing", "interruptible" → suggest **spot**
- User says "production", "stable", "long-running" → **on-demand**
- If on-demand and user wants discount → check long-term contracts

### 2. Compute → GPU or CPU?
- ML/AI/training/inference/CUDA/rendering → **GPU**
- Web server, API, database, dev box → **CPU**

### 3. Instance type → match requirements
- Fetch: `verda --agent instance-types [--gpu|--cpu] -o json`
- Match by user requirements: VRAM (`gpu_memory.size_in_gigabytes`), GPU count (`gpu.number_of_gpus`), GPU model, RAM, price
- Present top 3 options sorted by price. Show: name, GPUs, VRAM, RAM, price/hr

### 4. Location → where is it in stock?
- Fetch: `verda --agent availability --type <selected> [--spot] -o json`
- **Location depends on instance-type availability, NOT the other way around**
- Pick cheapest available location, or respect user preference

### 5. Image → which OS?
- Fetch: `verda --agent images --type <instance-type> -o json`
- GPU default: Ubuntu + CUDA. CPU default: plain Ubuntu
- Let user choose if multiple options

### 6. SSH keys → does user have any?
- Fetch: `verda --agent ssh-key list -o json`
- If none: ask user for public key path or content, add with `verda --agent ssh-key add`
- Attach all keys unless user specifies

### 7. Cost → can they afford it?
- Fetch in parallel: `verda --agent cost balance -o json` + `verda --agent cost estimate --type <type> --os-volume 50 -o json`
- Calculate runway: balance / total_hourly = hours
- Warn if < 24h runway. Show: hourly cost, balance, runway

### 8. Confirm → show summary, get approval
Present: instance type, location, image, SSH keys, estimated hourly cost.
Wait for explicit "yes" before creating.

### 9. Create
`verda --agent vm create --kind <kind> --instance-type <type> --location <loc> --os <image> --hostname <name> --ssh-key <id> [--is-spot] [--os-volume-size 50] --wait -o json`

### 10. Verify
`verda --agent vm describe <id> -o json` — confirm status is running, get IP address.
Offer: `verda ssh <hostname>` to connect.

## Spot VM Extras

When deploying spot instances, also handle:
- Volume discontinue policy: recommend `keep_detached` for important data
- Add `--os-volume-on-spot-discontinue keep_detached` to create command
- Warn user: spot VMs can be interrupted at any time

## Volume Decisions

- **OS volume**: always created with VM, default 50 GiB
- **Storage volume**: optional. NVMe = fast + expensive, HDD = slow + cheap
- **Existing volumes**: can attach detached volumes (must match VM location)
  Check: `verda --agent volume list --status detached -o json`

## Efficiency Rules

- **Parallel fetches**: locations, instance-types, ssh-key list, cost balance are independent — run them together
- **Cache in conversation**: instance-types and locations don't change mid-session — reuse previous output
- **Skip when specific**: if user says "deploy 1V100.6V in FIN-01", skip instance-type listing — just check availability + cost
- **Use --help once**: run `verda <cmd> --help` for flag details not covered here, remember the output

## Error Recovery

Handle `--agent` mode structured errors (JSON on stderr):

| Error Code | Meaning | Action |
|------------|---------|--------|
| `AUTH_ERROR` | Not logged in or token expired | Tell user: `verda auth login` |
| `INSUFFICIENT_BALANCE` | Can't afford resource | Show balance, suggest spot or smaller instance |
| `NOT_FOUND` | Resource doesn't exist | Re-fetch resource list, verify ID |
| `MISSING_REQUIRED_FLAGS` | Command needs more flags | Read `details.missing`, provide values, retry |
| `CONFIRMATION_REQUIRED` | Destructive action needs --yes | Confirm with user, retry with `--yes` |
| `VALIDATION_ERROR` | Bad input value | Read `details.field` + `details.reason`, fix and retry |
| `INTERACTIVE_PROMPT_BLOCKED` | Command tried to prompt | Read `details.choices`, pick value, pass as flag |

## Asking Good Questions

When user request is vague ("I need a GPU"):
1. **Workload**: training, inference, fine-tuning? → determines GPU size
2. **Model size**: parameter count → VRAM requirement (7B ≈ 16GB, 13B ≈ 24GB, 70B ≈ 80GB+)
3. **Budget**: hourly budget constraint?

Pick the most critical unknown and ask ONE question. Don't interrogate.
