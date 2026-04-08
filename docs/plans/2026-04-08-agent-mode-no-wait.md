# Feature Spec: Default `--wait false` in Agent Mode

## Goal

In `--agent` mode, `vm create` should return immediately after the API accepts the request, printing the instance info (ID, status, hostname). The agent can then poll with `vm describe` if needed. This avoids 2-5 minute hangs that block the conversation.

## Current Behavior

- `--wait` defaults to `true` for all modes
- `vm create` blocks up to 5 minutes (default `--wait-timeout`) polling for `running` status
- In agent mode, this means the agent hangs with no output until the VM is ready or timeout

## Proposed Behavior

- **Agent mode (`--agent`)**: `--wait` defaults to `false`
- **Interactive mode**: `--wait` defaults to `true` (unchanged)
- User can still override: `verda --agent vm create ... --wait` to force blocking

## Implementation

In `internal/verda-cli/cmd/vm/create.go`, after flags are parsed:

```go
// In agent mode, default --wait to false — return immediately with instance info.
// Agents poll with 'vm describe' when they need status.
if factory.IsAgentMode() && !cmd.Flags().Changed("wait") {
    opts.Wait.Enabled = false
}
```

The rest of the create flow stays the same — when `--wait` is false, it creates the instance and prints the API response (which includes `id`, `status`, `hostname`).

## Output

Agent mode without `--wait`:
```json
{
  "id": "inst-abc123",
  "hostname": "my-gpu",
  "status": "ordered",
  "instance_type": "1A100.22V",
  "location": "FIN-01"
}
```

Agent then polls if needed:
```bash
verda --agent vm describe inst-abc123 -o json
```

## Skill Update

After this CLI change, update `verda-cloud.md` step 9:

```markdown
### 9. Create
verda --agent vm create ... -o json
# Returns immediately with status "ordered" or "provisioning"

### 10. Check status (if needed)
verda --agent vm describe <id> -o json
# If user wants to connect, poll until status is "running" (check every 15s, max 2m)
```

Remove `--wait --wait-timeout 2m` from the create command in the skill.

## Testing

- `verda --agent vm create ...` returns immediately with JSON (status: ordered)
- `verda --agent vm create ... --wait` still blocks until running
- `verda vm create ...` (interactive, no --agent) still blocks by default
- Verify `cmd.Flags().Changed("wait")` correctly detects explicit `--wait`
