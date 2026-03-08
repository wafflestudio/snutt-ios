---
name: gh-inspect-deploy-run
description: "Inspect SNUTT iOS GitHub Actions deployment runs with gh and review the relevant logs. Use when a user asks to inspect a dev/prod TestFlight or App Store Connect deploy run, including failed runs."
---

# Inspect SNUTT Deploy Run

## Workflow

- Prefer `gh` and GitHub Actions data. Do not start with guesswork.
- If the user specifies environment or version, first find the matching deployment run.
  - `prod` tags/branches look like `testflight/v{version}-...`
  - `dev` tags/branches look like `testflight/dev/v{version}-...`
- Otherwise, inspect the latest run from workflow `Deploy to App Store Connect`.
- Find the run:

```bash
gh run list --limit 20 --json databaseId,workflowName,headBranch,status,conclusion,url
```

- Inspect the run and identify the relevant job/step:

```bash
gh run view RUN_ID --json name,displayTitle,status,conclusion,url,jobs
```

- Inspect the relevant job logs:

```bash
gh run view RUN_ID --job JOB_ID
gh api repos/wafflestudio/snutt-ios/actions/jobs/JOB_ID/logs | tail -n 250
gh api repos/wafflestudio/snutt-ios/actions/jobs/JOB_ID/logs | rg -n "::error|error:|ARCHIVE FAILED|BUILD FAILED|fastlane finished with errors|No such module|has no member|Provisioning profile|CodeSign"
```

- If the raw log is too large, narrow it with:

```bash
gh api repos/wafflestudio/snutt-ios/actions/jobs/JOB_ID/logs | sed -n 'START,ENDp'
gh api repos/wafflestudio/snutt-ios/actions/jobs/JOB_ID/logs | rg -n "CompileSwift|SwiftCompile|::error|ARCHIVE FAILED|BUILD FAILED|Process completed with exit code"
```
