## Scripts Architecture

Scripts are organized by scenario under `scripts/<scenario_name>/`. Each scenario is a self-contained directory with its own `__init__.py`.

```
scripts/
└── weekly_report/   # e.g. weekly report
└── slack_notify/    # e.g. another scenario
```

- Internal imports: `from scripts.<scenario_name>.<module> import ...`
- Entry points: `PYTHONPATH="$(pwd)" python scripts/<scenario_name>/main.py`

## LaunchAgents Naming Convention

Use reverse-domain format: `com.vista.<kebab-case-description>`

- Example: `com.vista.weekly-report`, `com.vista.slack-notify`
- Plist files: `~/Library/LaunchAgents/com.vista.<name>.plist`

## LaunchAgents Setup & Testing

### PATH Configuration (mandatory)

LaunchAgent processes do not inherit the login shell's `PATH`. All shell scripts invoked by a plist **must** export the following PATH at the top:

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
```

This covers: `claude` (`~/.local/bin`), `gh`, `brew`-installed tools (`/opt/homebrew/bin`).

### Post-setup Test (mandatory)

After registering or modifying a LaunchAgent, always verify it runs correctly:

```bash
# Trigger immediately (kills any running instance first)
launchctl kickstart -k gui/$(id -u)/com.vista.<name>

# Check exit status (- = not running, 0 = success, non-zero = error)
launchctl list | grep com.vista.<name>

# Inspect logs
cat /tmp/<name>.log
cat /tmp/<name>-error.log
```

## Task Master Usage Policy

- A PRD is called a **scenario**
- Each scenario maps to **one Task Master task** with multiple subtasks
- Scenario naming: kebab-case matching the script folder (e.g. `weekly-report`, `slack-notify`)
- Task title format: `[scenario-name] <summary>` (e.g. `[weekly-report] Sprint progress report automation`)
- Subtask titles describe a single implementation step within the scenario