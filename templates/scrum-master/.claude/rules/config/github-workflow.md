---
paths: "**/*"
---

# GitHub Workflow Rules

## Access

| Key              | Value                                                    |
| ---------------- | -------------------------------------------------------- |
| **Org**          | `{{ORG_NAME}}`                                           |
| **Project**      | {{PROJECT_NAME}} (`projectV2(number: {{PROJECT_NUMBER}})`) |
| **Issue Repo**   | `{{ORG_NAME}}/{{ISSUE_REPO}}` — source of truth for task management |
| **Output Repos** | {{OUTPUT_REPOS}}                                         |

## Data Sources

### Issues
- Primary source of truth for task tracking
- Always read full issue body + comments before summarizing
- Use `gh issue view <n> -R {{ORG_NAME}}/{{ISSUE_REPO}}` for details

### Project Board
- Use GraphQL API via `gh api graphql` for project item queries
- Track status transitions: Todo → In Progress → In Review → Done
- Respect sprint assignments and priorities

## When Reading Issues
1. Fetch the issue with full body and comments
2. Check linked PRs and their status
3. Check project board status for the issue
4. Summarize: title, status, assignee, blockers, next action

## When Reporting Status
- Group by: sprint / status / assignee as appropriate
- Highlight blockers and overdue items
- Suggest priority adjustments when workload is unbalanced

## When Creating/Updating Issues
- Write clear acceptance criteria
- Add appropriate labels
- Link related issues and PRs
- Always confirm with the user before creating or modifying issues
