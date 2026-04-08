# Scenario: Check Running Costs

## User prompt
"Show me my running costs"

## Expected command sequence
1. `verda auth show` — check auth
2. `verda cost running` — get running costs
3. `verda cost balance` — show balance for context

## Must verify
- [ ] Agent classified as "explore" (not "deploy")
- [ ] Agent did NOT run instance-types or availability
- [ ] Agent showed cost breakdown to user
- [ ] Agent used -o json flag
