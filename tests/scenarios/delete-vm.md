# Scenario: Delete a VM

## User prompt
"Delete my training VM"

## Expected command sequence
1. `verda auth show` — check auth
2. `verda vm list` — find the VM
3. [CONFIRM WITH USER — show VM details, ask for explicit yes]
4. `verda vm delete <id> --yes --wait`

## Must verify
- [ ] Agent asked user for confirmation before delete
- [ ] Agent used --yes flag (required in agent mode)
- [ ] Agent identified correct VM by name/hostname
- [ ] Agent did NOT delete without confirmation
