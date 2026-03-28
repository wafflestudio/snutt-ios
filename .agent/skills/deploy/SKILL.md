---
name: deploy
description: "Create and push SNUTT iOS deployment tags for TestFlight (dev/prod) and App Store. Use when a user asks to deploy to TestFlight, App Store, tag a release, or push deployment tags for SNUTT iOS."
---

# Deploy SNUTT iOS

## Tag Format

```
testflight/dev/v{version}-{slug}  - Deploy Dev app to TestFlight (with beta badge)
testflight/v{version}-{slug}      - Deploy Prod app to TestFlight
appstore/v{version}-{slug}        - Deploy Prod app to App Store (requires GitHub Release)
```

## Slug Generation

Always derive the slug automatically from the HEAD commit message. Abbreviate it to a short, lowercase, hyphen-separated string (e.g., `fix-login`, `cleanup-legacy`). Do not ask the user for a slug. If the tag already exists, append a numeric suffix (e.g., `-2`, `-3`).

## TestFlight Deployment

- Ask the user for:
  - Deployment version (e.g., `4.0.0`).
  - Environment: `dev` or `prod` (support both if requested).
- Generate slug from HEAD commit message.
- Build the tag:
  - `dev` => `testflight/dev/v{version}-{slug}`
  - `prod` => `testflight/v{version}-{slug}`
- Verify the tag does not already exist: `git tag -l <tag>`.
- Create the tag on current HEAD: `git tag <tag>`.
- Push the tag: `git push origin <tag>`.
- Report the created tag(s) and the push result.

## App Store Deployment

App Store deployments require a **GitHub Release** with release notes (used as App Store changelog).

### Step 1: Gather info

- Ask the user for:
  - Deployment version (e.g., `4.0.0`).
  - Release notes in Korean (for App Store changelog). Can be a rough draft.

### Step 2: Polish release notes

- Review the user's notes. If they are a rough draft or not suitable for end users, rewrite them into polished App Store release notes.
- Reference previous releases for tone and format:
  ```bash
  gh api repos/wafflestudio/snutt-ios/releases --jq '[.[] | select(.tag_name | startswith("appstore/"))] | .[:3] | .[] | "=== \(.tag_name) ===\n\(.body)\n"'
  ```
- **Patch version convention**: If the version is a patch release (e.g., `X.Y.Z` where `Z > 0`), automatically append the most recent major/minor release notes below a separator. Find the latest `appstore/vX.Y.0*` release and append its body. Format:
  ```
  {새 릴리즈 노트}

  ---

  [X.Y.0]
  {이전 릴리즈 노트 body}
  ```
  If no matching major/minor release is found, just use the new notes alone.
- Present the final release notes to the user for confirmation before proceeding.

### Step 3: Tag, push, and release

- Generate slug from HEAD commit message.
- Build the tag: `appstore/v{version}-{slug}`.
- Verify the tag does not already exist.
- Create and push the tag first:
  ```bash
  git tag {tag} && git push origin {tag}
  ```
- Check if a GitHub Release already exists for this version:
  ```bash
  gh release list --json tagName -q '.[].tagName' | grep "^appstore/v{version}"
  ```
  - **If a release exists**: Update the existing release to point to the new tag and update notes if needed:
    ```bash
    gh release edit {old-tag} --tag {new-tag} --notes "{release_notes}"
    ```
  - **If no release exists**: Create a new GitHub Release:
    ```bash
    gh release create {tag} --title "{tag}" --notes "{release_notes}"
    ```

The deployment workflow will:
- Validate that a GitHub Release exists for the tag.
- Extract release notes from the GitHub Release.
- Submit to App Store with compliance information (IDFA: false, Encryption: false).
- **Release strategy** (automatic, based on version):
  - **Patch release** (`X.Y.Z` where `Z > 0`): Immediate release upon approval (no phased rollout).
  - **Major/Minor release** (`X.Y.0`): Phased release upon approval (gradual 7-day rollout).

## Notes

- The slug is just for tag uniqueness — derive it automatically, never ask the user.
- For re-deploys of the same version, reuse the existing GitHub Release by updating its tag.
