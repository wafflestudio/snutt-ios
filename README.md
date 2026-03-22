<br />
<div align="center">
  <a href="https://github.com/wafflestudio/snutt-ios">
    <img src="https://user-images.githubusercontent.com/33917774/199519767-60590904-b15a-4464-ab21-e3a424649d5c.svg" alt="Logo" width="70" height="70">
  </a>

  <h3 align="center">SNUTT iOS</h3>

  <p align="center">
    The best timetable application for SNU students, developed and maintained by SNU students.
    <br />
    <br />
    <a href="https://github.com/wafflestudio/snutt-ios/actions/workflows/snutt-ci.yml">
      <img src="https://github.com/wafflestudio/snutt-ios/actions/workflows/snutt-ci.yml/badge.svg"/>
    </a>
    <a href="https://github.com/wafflestudio/snutt-ios/actions/workflows/snutt-deploy.yml">
      <img src="https://github.com/wafflestudio/snutt-ios/actions/workflows/snutt-deploy.yml/badge.svg"/>
    </a>
    <img src="https://img.shields.io/badge/Swift-6.1-F05138?logo=swift&logoColor=white"/>
    <img src="https://img.shields.io/badge/Platforms-iOS_17+-F05138?logo=swift&logoColor=white"/>
    <a href="https://apps.apple.com/kr/app/snutt-%EC%84%9C%EC%9A%B8%EB%8C%80%ED%95%99%EA%B5%90-%EC%8B%9C%EA%B0%84%ED%91%9C-%EC%95%B1/id1215668309">
      <img src="https://img.shields.io/itunes/v/1215668309?logo=app-store&logoColor=white&color=0D96F6&label=App%20Store"/>
    </a>
    <img src="https://img.shields.io/github/license/wafflestudio/snutt-ios"/>
  </p>
</div>

## Requirements

- **Xcode**: 16.0+
- **iOS**: 17.0+

## Prerequisites

### 1. Install Development Tools

```bash
# Install mise (for managing tool versions)
curl https://mise.run | sh

# Install Just (command runner)
brew install just

# Install other tools
brew install mint pre-commit swift-format
```

### 2. Install Tools Managed by mise

```bash
# Install tools declared in .mise.toml
# (currently tuist and ruby)
mise install

# Verify installation
mise exec -- ruby -v
mise exec -- tuist version
```

### 3. Install Ruby Dependencies for Fastlane

```bash
# Install project Ruby gems from Gemfile.lock
mise exec -- bundle install
```

## Getting Started

Follow these steps to set up your development environment:

```bash
# 1. Install tools managed by mise
mise install

# 2. Install Swift package dependencies
mise exec -- tuist install

# 3. Generate API client code (first time only)
just openapi-dev

# 4. Generate Xcode project and open it
just generate
```

That's it! Xcode should open automatically with the generated project.

## Development Commands

View all available commands:

```bash
just --list
```

### Essential Commands

- **`just generate`** - Generate Xcode project with proper certificates and open it
- **`just openapi-dev`** - Generate API client for dev server
- **`just openapi-prod`** - Generate API client for prod server
- **`just certs`** - Sync development certificates (readonly)
- **`just format`** - Format Swift code (auto-runs on commit)
- **`just check`** - Run code quality checks

### Tuist Commands

```bash
mise exec -- tuist install             # Install dependencies
mise exec -- tuist generate            # Generate Xcode project
mise exec -- tuist clean               # Clean Tuist cache
mise exec -- tuist build "SNUTT Dev"  # Build dev configuration
```

## Common Workflows

### First Time Setup

```bash
just openapi-dev  # Generate API client
just generate     # Generate project and open Xcode
```

### After Changing API Spec

```bash
just openapi-dev   # For dev server
# or
just openapi-prod  # For prod server
```

### After Adding/Deleting Files

```bash
just generate  # Regenerate Xcode project with Tuist
```

### Before Committing

```bash
just format  # Format code (or let pre-commit hook do it)
```

## Device Registration

To test on a physical device, you need a write access to App Store Connect and Match Repository.

### Steps

1. Run the device registration command:
   ```bash
   just register-device
   ```

3. Enter your device name and UDID when prompted

4. Regenerate the project to apply new provisioning profiles:
   ```bash
   just generate
   ```

## Deployment

SNUTT uses **tag-based automatic deployment** via GitHub Actions.

### Tag Format

```
testflight/dev/v{version}  - Deploy Dev app to TestFlight (with beta badge)
testflight/v{version}      - Deploy Prod app to TestFlight
appstore/v{version}        - Deploy Prod app to App Store (requires GitHub Release)
```

### Deployment Methods

#### 1. TestFlight Deployment (Dev & Prod)

Simply create and push a tag:

```bash
# Deploy Dev app to TestFlight (includes beta badge on app icon)
git tag testflight/dev/v4.0.0
git push origin testflight/dev/v4.0.0

# Deploy Prod app to TestFlight
git tag testflight/v4.0.0
git push origin testflight/v4.0.0
```

#### 2. App Store Deployment (Prod only)

**IMPORTANT**: App Store deployments require a GitHub Release with release notes.

**Steps:**

1. **Create a GitHub Release first** at https://github.com/wafflestudio/snutt-ios/releases/new
   - Choose the tag name (e.g., `appstore/v4.0.0`)
   - Write release notes in Korean (these will be submitted to App Store)
   - Publish the release

2. **Push the tag** (if not created automatically by release):
   ```bash
   git tag appstore/v4.0.0
   git push origin appstore/v4.0.0
   ```

The deployment workflow will:
- Validate that a GitHub Release exists for the tag
- Extract release notes from the GitHub Release
- Submit to App Store with the release notes
- Include compliance information (IDFA: false, Encryption: false)

**If the GitHub Release doesn't exist**, the deployment will fail with instructions.

#### 3. Re-deploying the Same Version

You can add any slug after the version number to re-deploy:

```bash
# Re-deploy same version with different build number
git tag testflight/v4.0.0-fix-login
git tag appstore/v4.0.0-resubmit
git push origin testflight/v4.0.0-fix-login

# For App Store re-deployment, create a new GitHub Release with the new tag
```

The version number will be extracted as the same (e.g., `4.0.0`), but the build number will auto-increment from App Store Connect.

## Architecture

SNUTT follows a **strict modular architecture** with Clean Architecture principles.

For detailed information about the project structure, architecture patterns, and development guidelines, see [CLAUDE.md](CLAUDE.md).
