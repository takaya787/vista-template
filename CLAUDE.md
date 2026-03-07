# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development

- Contribute to `main` branch
- Versioning via GitHub Releases

## Convention / Config Rule

- **Convention** (`rules/convention/`): Immutable standards. Must NOT contain project-specific information or concrete service names (e.g., no GitHub org names, Notion URLs, repo names)
- **Config** (`rules/config/`): Project-specific settings. All concrete details (service URLs, org names, credentials references) must go here
- Convention always takes precedence over Config on conflict
