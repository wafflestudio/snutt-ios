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
    <a href="https://github.com/wafflestudio/snutt-ios/actions/workflows/snutt-ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/wafflestudio/snutt-ios/snutt-ci.yml?label=CI&logo=github"/></a>
    <a href="https://github.com/wafflestudio/snutt-ios/actions/workflows/snutt-deploy.yml"><img src="https://img.shields.io/github/actions/workflow/status/wafflestudio/snutt-ios/snutt-deploy.yml?label=Deploy&logo=github"/></a>
    <a href="LICENSE"><img src="https://img.shields.io/github/license/wafflestudio/snutt-ios"/></a>
    <br />
    <a href="https://apps.apple.com/kr/app/snutt-%EC%84%9C%EC%9A%B8%EB%8C%80%ED%95%99%EA%B5%90-%EC%8B%9C%EA%B0%84%ED%91%9C-%EC%95%B1/id1215668309"><img src="https://img.shields.io/itunes/v/1215668309?logo=app-store&logoColor=white&color=0D96F6&label=App%20Store"/></a>
    <a href="SNUTT/Project.swift"><img src="https://img.shields.io/badge/Swift-6.1-F05138?logo=swift&logoColor=white"/></a>
    <a href="SNUTT/Project.swift"><img src="https://img.shields.io/badge/Platforms-iOS_17+-F05138?logo=swift&logoColor=white"/></a>
  </p>
</div>

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

All available commands are documented in the Justfile:

```bash
just --list
```

## Device Registration

To test on a physical device, you need write access to App Store Connect and Match Repository.

1. Run `just register-device`
2. Enter your device name and UDID when prompted
3. Run `just generate` to apply new provisioning profiles

## Architecture

SNUTT follows a **strict modular architecture** with Clean Architecture principles.

For detailed information about the project structure, architecture patterns, and development guidelines, see [CLAUDE.md](CLAUDE.md).
