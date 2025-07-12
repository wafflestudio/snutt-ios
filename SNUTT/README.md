# SNUTT iOS

## Requirements

- **Xcode**: 16.0+
- **iOS**: 17.0+

## Prerequisites

```bash
# Install prerequisites (if not already installed)
curl https://mise.run | sh
brew install just mint pre-commit swift-format
```

## Quick Start

```bash
# Install dependencies (mise will auto-select versions from .mise.toml)
mise install
tuist install

# Setup development environment
just dev
# or
just prod
```

## Commands

```bash
# Development
just dev                   # Generate dev OpenAPI + project
just prod                  # Generate prod OpenAPI + project
just clean-build           # Clean build
just clean-generate        # Clean generate

# Code Quality
just format                # Format Swift code using swift-format
just check                 # Run all checks (dependencies, imports, formatting)

# OpenAPI
just openapi-dev           # Generate dev OpenAPI
just openapi-prod          # Generate prod OpenAPI

# Tuist commands
tuist install              # Install dependencies
tuist generate             # Generate project
tuist clean                # Clean cache
tuist test                 # Run tests
```
