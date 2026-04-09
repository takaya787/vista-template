## Scripts Architecture

Scripts are organized by scenario under `scripts/<scenario_name>/`. Each scenario is a self-contained directory with its own `__init__.py`.

```
scripts/
└── weekly_report/   # e.g. weekly report
└── slack_notify/    # e.g. another scenario
```

- Internal imports: `from scripts.<scenario_name>.<module> import ...`
- Entry points: `PYTHONPATH="$(pwd)" python scripts/<scenario_name>/main.py`

## LaunchAgents

> All LaunchAgent registration, removal, and ledger management must be handled by the **`launch-agent-registrar`** agent (`.claude/agents/launch-agent-registrar.md`). Do not perform these operations manually.

### Naming Convention

Use reverse-domain format: `com.vista.<kebab-case-description>`

- Example: `com.vista.weekly-report`, `com.vista.slack-notify`
- Plist files: `~/Library/LaunchAgents/com.vista.<name>.plist`

### Quick Reference

```bash
# Verify after registration (exit status: - = not running, 0 = success, non-zero = error)
launchctl list | grep com.vista.<name>

# Trigger immediately for testing
launchctl kickstart -k gui/$(id -u)/com.vista.<name>

# Inspect logs
cat /tmp/com.vista.<name>.log
cat /tmp/com.vista.<name>-error.log
```

## Task Master Usage Policy

- A PRD is called a **scenario**
- Each scenario maps to **one Task Master task** with multiple subtasks
- Scenario naming: kebab-case matching the script folder (e.g. `weekly-report`, `slack-notify`)
- Task title format: `[scenario-name] <summary>` (e.g. `[weekly-report] Sprint progress report automation`)
- Subtask titles describe a single implementation step within the scenario