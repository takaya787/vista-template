---
paths: "**/*"
---

# Python Environment Convention

Prevent local environment pollution and ensure reproducible, safe Python execution.

## Rules

### 1. venv Under tmp/ Is Mandatory

When executing Python, always create a venv under a `tmp/` prefixed path and run inside it.

```bash
# Correct
python -m venv tmp/venv
source tmp/venv/bin/activate
pip install <package>
python script.py

# Prohibited
python script.py              # Direct execution without venv
python -m venv .venv          # venv outside tmp/
python -m venv myenv          # venv outside tmp/
```

### 2. No Local Installation via brew or pip

The following installation methods are prohibited:

- `brew install` for any Python-related package
- `pip install` in the global environment (outside a venv)
- `pip install --user` (user-level installation)
- `sudo pip install` (system-level installation)
- Any other operation that modifies the system Python environment

```bash
# Prohibited
brew install python
brew install pipenv
pip install requests
pip install --user requests
sudo pip install requests

# Correct
source tmp/venv/bin/activate && pip install requests
```

### 3. tmp/ Directory Handling

- `tmp/` must be excluded from version control (add to `.gitignore`)
- venv environments are disposable — recreate as needed
- Track dependencies in `requirements.txt` or `pyproject.toml` for reproducibility
