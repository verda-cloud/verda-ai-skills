# Scenario: Deploy a GPU VM

## User prompt
"Deploy a GPU VM with at least 80GB VRAM for training"

## Expected command sequence (in order)
1. `verda auth show` — check auth
2. `verda instance-types --gpu` — find GPU types (parallel OK)
3. `verda ssh-key list` — check keys (parallel OK)
4. `verda cost balance` — check balance (parallel OK)
5. `verda availability --type <matched-type>` — check stock
6. `verda images --type <matched-type>` — get OS options
7. `verda cost estimate --type <matched-type>` — estimate cost
8. [CONFIRM WITH USER]
9. `verda vm create --kind gpu --instance-type <type> --os <image> ...`
10. `verda vm describe <id>` — verify running

## Must verify
- [ ] Agent checked auth before any resource commands
- [ ] Agent filtered by VRAM >= 80GB
- [ ] Agent showed cost estimate before creating
- [ ] Agent asked for confirmation before creating
- [ ] Agent used --agent flag
- [ ] Agent used -o json flag
- [ ] Agent used --wait on create
