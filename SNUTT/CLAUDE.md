# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SNUTT is an iOS app for Seoul National University's timetable management system built with Swift using a modular architecture. The project uses Tuist for project management and generation.

- **Language**: Swift 6.0
- **Deployment Target**: iOS 17.0+
- **Architecture Pattern**: Modular architecture with feature modules and interfaces

## Development Commands

### Environment Setup

```bash
# Install prerequisites
curl https://mise.run | sh
brew install just

# Install dependencies
mise install
tuist install

# Setup development environment
just dev      # Generate dev OpenAPI + project
just prod     # Generate prod OpenAPI + project
```

### Project Generation

```bash
# Clean and regenerate
just clean-build           # Clean build
just clean-generate        # Clean generate

# OpenAPI
just openapi-dev           # Generate dev OpenAPI
just openapi-prod          # Generate prod OpenAPI

# Tuist commands
tuist install              # Install dependencies
tuist generate             # Generate project
tuist clean                # Clean cache
tuist test                 # Run tests
tuist build                # Build the project (use this to verify code changes)
```

## Project Architecture

### Module Structure

The codebase follows a modular architecture pattern with three main module categories:

1. **Feature Modules**: Self-contained features with their own UI, business logic, and data access layers
   - Examples: Timetable, Auth, Settings, Vacancy, Notifications

2. **Feature Interface Modules**: Interfaces/contracts that define the public API of feature modules
   - Examples: TimetableInterface, AuthInterface, APIClientInterface

3. **Utility and Shared Modules**: Reusable components and utilities
   - **Shared**: Common UI components and app metadata
   - **Utility**: Foundation extensions, SwiftUI utilities, etc.

### Module Dependencies

Features can only depend on interfaces of other features, not their implementations. This enforces loose coupling between modules. The dependency rules are:

- **Feature → FeatureInterface**: A feature can only depend on interfaces of other features
- **Feature → Utility/Shared**: Features can depend on utilities and shared components
- **FeatureInterface → Utility**: Interfaces can depend on utilities
- **Utility → Utility**: Utilities can depend on other utilities

### Key Modules

- **Timetable**: Core timetable functionality
- **APIClient**: OpenAPI-generated API client for backend communication
- **Auth**: Authentication and user management
- **Themes**: Theme management for the app
- **Settings**: App settings and preferences
- **Vacancy**: Feature related to course vacancies

### External Dependencies

The project uses several third-party dependencies:
- Dependencies (Point-Free's dependency injection)
- OpenAPI Runtime and URLSession
- SwiftUI Introspect
- Firebase Core and Messaging
- KakaoMapsSDK

## Dependency Injection Pattern

### Interface Module Pattern

Interface modules should follow this pattern to maintain clean separation between interface definitions and implementations:

1. **Interface Module (e.g., VacancyInterface)**:
   ```swift
   @Spyable
   public protocol SomeRepository: Sendable {
       func someMethod() async throws -> ReturnType
   }
   
   public enum SomeRepositoryKey: TestDependencyKey {
       public static let testValue: any SomeRepository = {
           let spy = SomeRepositorySpy()
           spy.someMethodReturnValue = defaultValue
           return spy
       }()
   }
   
   extension DependencyValues {
       public var someRepository: any SomeRepository {
           get { self[SomeRepositoryKey.self] }
           set { self[SomeRepositoryKey.self] = newValue }
       }
   }
   ```

2. **Live Implementation (in LiveDependencies.swift)**:
   ```swift
   extension SomeRepositoryKey: @retroactive DependencyKey {
       public static let liveValue: any SomeRepository = SomeAPIRepository()
   }
   ```

### Key Principles

- **Interface modules** only define protocols and test dependencies using `TestDependencyKey`
- **Live implementations** are injected via `@retroactive DependencyKey` in `LiveDependencies.swift`
- This pattern ensures interface modules don't depend on concrete implementations
- Follows the same pattern as other modules (TimetableRepository, AuthRepository, etc.)

## Build Configurations

The project has two main configurations:
- **Dev**: Development environment
- **Prod**: Production environment

Each configuration uses its own xcconfig file located in the XCConfigs directory.

## Widget Extension

The project includes a widget extension for iOS home screen widgets that displays timetable information.