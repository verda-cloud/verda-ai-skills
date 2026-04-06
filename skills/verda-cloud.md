---
name: verda-cloud
description: Use when the user wants to manage Verda Cloud infrastructure -- deploy VMs, check costs, manage volumes, SSH into instances, or manage SSH keys and startup scripts
---

# Verda Cloud Infrastructure Management

## Prerequisites

Before running any verda commands:

1. Check CLI is installed: `which verda` -- if missing, tell user to install it
2. Check authentication: `verda auth show -o json` -- if not logged in, run `verda auth login`
3. For any command you haven't used before, run `verda <command> --help` to discover exact flags

## Safety Rules

Follow these rules for EVERY interaction:

- **Always use `-o json`** on all commands -- parse structured output, never scrape tables
- **Always use `--wait`** on create/action commands -- wait for operation to complete before proceeding
- **Cost before create** -- run `verda cost estimate` and `verda cost balance -o json` before creating any resource; show the user the hourly cost and their remaining balance
- **Confirm before destroy** -- always ask the user for explicit confirmation before running delete, force_shutdown, or trash actions
- **Discovery before action** -- list available locations, instance types, and images before creating resources; never guess or hardcode values
- **One resource at a time** -- create one VM or volume at a time unless user explicitly requests batch operations
- **Show pricing** -- always include `price_per_hour` (and `spot_price` if available) when presenting instance type options
- **Check running costs** -- use `verda cost running -o json` to show the user what they're already spending before adding new resources

## Discovery Commands

Run these to understand what's available before creating anything:

```
verda locations -o json              # Available regions/datacenters
verda instance-types -o json         # All instance types with pricing
verda instance-types --gpu -o json   # GPU instance types only
verda availability -o json           # What's currently available to deploy
verda images -o json                 # OS images (Ubuntu, etc.)
verda ssh-key list -o json           # User's registered SSH keys
verda startup-script list -o json    # User's saved startup scripts
```

For detailed flags on any command: `verda <command> --help`

## GPU Spec Matching

When the user requests specific GPU requirements (VRAM, model, count):

1. Run `verda instance-types --gpu -o json`
2. Filter results by the user's requirements using these fields:
   - `gpu_memory.size_in_gigabytes` -- matches VRAM requirement
   - `gpu.number_of_gpus` -- matches GPU count requirement
   - `model` -- matches GPU model (e.g. "GB300", "H100")
   - `manufacturer` -- typically "NVIDIA"
3. Present matching options as a table showing: `instance_type`, `name`, `number_of_gpus`, `gpu_memory`, `cpu.number_of_cores`, `memory.size_in_gigabytes`, `price_per_hour`, `spot_price`
4. Let the user choose before proceeding

## Workflow: Deploy a VM

Follow these steps in order -- do not skip any:

### Step 1: Gather requirements
Ask the user what they need if not already clear: GPU vs CPU, OS preference, region preference, budget constraints.

### Step 2: Discover options
```
verda locations -o json
verda availability -o json
verda images -o json
```
If GPU needed: `verda instance-types --gpu -o json` and apply GPU Spec Matching above.
If CPU only: `verda instance-types -o json` and filter.

### Step 3: Check SSH keys
```
verda ssh-key list -o json
```
If no keys exist, ask user to provide a public key and add it:
```
verda ssh-key add --name <name> --public-key "<key>"
```

### Step 4: Check cost and balance
```
verda cost balance -o json
verda cost estimate --instance-type <type> --location <loc> -o json
```
Show the user: estimated hourly cost, their current balance, and how long the balance would last.

### Step 5: Confirm with user
Present a summary: instance type, location, image, SSH key, estimated cost. Wait for explicit approval.

### Step 6: Create the VM
```
verda vm create --instance-type <type> --location <loc> --image <image> --ssh-key <key-id> --wait -o json
```
Add `--startup-script <id>` if user has one. Use `verda vm create --help` for all available flags.

### Step 7: Verify and connect
```
verda vm describe <id> -o json    # Confirm status is running
verda ssh <hostname-or-id>        # Connect when ready
```

## VM Lifecycle

```
verda vm list -o json                          # List all VMs
verda vm describe <id> -o json                 # Full details of a VM
verda vm action <id> --action start --wait     # Start a stopped VM
verda vm action <id> --action shutdown --wait  # Graceful shutdown
verda vm action <id> --action hibernate --wait # Hibernate (preserves state)
```

For destructive actions -- confirm with user first:
```
verda vm action <id> --action force_shutdown --wait
verda vm action <id> --action delete --wait
```

## Cost Management

```
verda cost balance -o json    # Current account balance
verda cost estimate -o json   # Estimate cost for a new resource (use --help for flags)
verda cost running -o json    # Total hourly cost of all running resources
```

Always check `balance` and `running` costs before recommending new resources. Warn the user if their balance would run out within 24 hours given current + new spend.

## SSH Access

```
verda ssh <hostname-or-id>                              # Interactive SSH session
verda ssh <hostname-or-id> -- -L 8080:localhost:8080    # Port forwarding
verda ssh <hostname-or-id> -- <command>                 # Run a remote command
```

Use `verda ssh --help` for additional options.

## Volume Management

```
verda volume list -o json                                                    # List all volumes
verda volume create --size <gb> --location <loc> --wait -o json              # Create a volume
verda volume action <id> --action attach --vm <vm-id> --wait                 # Attach to VM
verda volume action <id> --action detach --wait                              # Detach from VM
```

For destructive actions -- confirm with user first:
```
verda volume trash <id> --wait    # Move volume to trash
```

Use `verda volume create --help` and `verda volume action --help` for all flags.

## SSH Key & Startup Script Management

```
verda ssh-key list -o json                                    # List registered keys
verda ssh-key add --name <name> --public-key "<key>"          # Add a new key
verda ssh-key delete <id>                                     # Remove a key (confirm first)

verda startup-script list -o json                             # List saved scripts
verda startup-script add --name <name> --script "<script>"    # Add a new script
verda startup-script delete <id>                              # Remove a script (confirm first)
```
