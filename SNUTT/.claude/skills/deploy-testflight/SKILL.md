---
name: deploy-testflight
description: "Create and push SNUTT iOS TestFlight deployment tags for dev/prod using a version and a short slug; if the slug is omitted, derive one from the most recent commits. Use when a user asks to deploy to TestFlight, tag a TestFlight release, or push TestFlight tags for SNUTT iOS."
---

# Deploy TestFlight tags (SNUTT iOS)

## Workflow

- Ask the user for:
  - Deployment version (e.g., `4.0.0`).
  - Environment: `dev` or `prod` (support both if requested).
  - Change slug (short, lowercase, letters/numbers/hyphens). Optional.
- If the slug is not provided, look at the most recent 5 commit subjects and make a short, reasonable slug that reflects those changes.
  - Keep it lowercase and simple; if nothing stands out, use `update`.
- Build the tag:
  - `dev` => `testflight/dev/v{version}-{slug}`
  - `prod` => `testflight/v{version}-{slug}`
- Verify the tag does not already exist: `git tag -l <tag>`.
  - If it exists, choose a different slug (derive a new one if needed) or ask for a new version. Do not delete tags unless explicitly asked.
- Create the tag on current HEAD: `git tag <tag>`.
- Push the tag: `git push origin <tag>`.
- Report the created tag(s) and the push result.

## Notes

- Do not create `appstore/` tags in this workflow.
- If the user wants to re-deploy the same version, insist on a new slug.
