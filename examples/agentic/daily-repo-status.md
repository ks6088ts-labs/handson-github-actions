---
name: "Extra Daily Repository Status"
on:
  workflow_dispatch:
permissions:
  contents: read
  issues: read
  pull-requests: read
  copilot-requests: none
engine: copilot
model: claude-sonnet-5
safe-outputs:
  create-issue:
    title-prefix: "[team-status] "
    labels: [report, daily-status]
    close-older-issues: true
---

# Daily Repository Status Report

Create a repository status report for the team as a GitHub issue.
