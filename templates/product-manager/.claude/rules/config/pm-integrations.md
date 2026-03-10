---
paths: "**/*"
---

# PM Integrations Config

Project-specific tool settings. For connection methods and conventions, see common `rules/convention/integrations.md`.

## Issue Tracker

| Key | Value |
|-----|-------|
| Tool | <!-- github / linear / jira / none --> |
| Project / Board URL | `{{ISSUE_TRACKER_URL}}` |
| Access method | <!-- gh CLI / browser / API --> |

## Roadmap Tool

| Key | Value |
|-----|-------|
| Tool | <!-- notion / productboard / linear / sheets / none --> |
| URL | `{{ROADMAP_URL}}` |

## Analytics

| Key | Value |
|-----|-------|
| Primary tool | <!-- ga4 / mixpanel / amplitude / none --> |
| Dashboard URL | `{{ANALYTICS_DASHBOARD_URL}}` |

## User Research

| Key | Value |
|-----|-------|
| Research repository | <!-- notion / dovetail / local / none --> |
| URL | `{{RESEARCH_REPO_URL}}` |
| Raw interview storage | `inbox/` |
