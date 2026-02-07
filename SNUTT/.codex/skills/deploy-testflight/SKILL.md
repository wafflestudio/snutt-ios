---
name: deploy-testflight
description: "Create and push SNUTT iOS TestFlight deployment tags by asking for version, environment (dev/prod), and a one-word change slug, following README.md tag rules. Use when a user asks to deploy to TestFlight, tag a TestFlight release, or push TestFlight tags for SNUTT iOS."
---

# Deploy TestFlight tags (SNUTT iOS)

## Workflow

- Read `README.md` in the repo and follow the Deployment > Tag Format rules.
- Ask the user for:
  - Deployment version (e.g., `4.0.0`).
  - Environment: `dev` or `prod`.
  - One-word change slug (short, lowercase, letters/numbers/hyphens). This is required.
- Build the tag:
  - `dev` => `testflight/dev/v{version}-{slug}`
  - `prod` => `testflight/v{version}-{slug}`
- Verify the tag does not already exist: `git tag -l <tag>`.
  - If it exists, stop and ask for a different version or slug. Do not delete tags unless explicitly asked.
- Create the tag on current HEAD: `git tag <tag>`.
- Push the tag: `git push origin <tag>`.
- Report the created tag and the push result.

## Notes

- Do not create `appstore/` tags in this workflow.
- If the user wants to re-deploy the same version, insist on a new slug.
