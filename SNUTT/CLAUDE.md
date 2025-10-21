# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This project uses **Tuist** for project generation and **Just** for task automation.

### Essential Setup Commands
```bash
# Install prerequisites (if not already installed)
curl https://mise.run | sh
brew install just mint pre-commit swift-format

# Install dependencies (mise will auto-select versions from .mise.toml)
mise install
tuist install

# Setup development environment
just dev                   # Generate dev OpenAPI + project
just prod                  # Generate prod OpenAPI + project
```

### Common Development Tasks
```bash
# Project Generation & Building
tuist generate             # Generate Xcode project
tuist clean                # Clean Tuist cache
tuist install              # Install dependencies
tuist test                 # Run all tests
tuist build               # Build the project

# Clean Operations
just clean-build           # Full clean build (clears DerivedData, installs deps, builds)
just clean-generate        # Clean generate (clears DerivedData, installs deps, generates)
just clean-derived-data    # Clear Xcode DerivedData only

# Code Quality
just format                # Format Swift code using swift-format
just check                 # Run all checks (dependencies, imports, formatting)

# OpenAPI Generation
just openapi-dev           # Generate dev environment OpenAPI
just openapi-prod          # Generate prod environment OpenAPI

# Testing
tuist test                 # Run all module tests
# Test individual modules using Xcode schemes (e.g., "ModuleTests" scheme)
```

### Build Configurations
- **Dev**: Development configuration with debug symbols
- **Prod**: Production/release configuration
- The project uses scheme-based configuration switching

## Architecture Overview

SNUTT follows a **strict modular architecture** with Clean Architecture principles:

### Module Categories
1. **Feature Modules** (`Modules/Feature/`): Self-contained features with implementations
2. **Feature Interface Modules** (`Modules/Feature/*Interface/`): Public contracts for features
3. **Shared Modules** (`Modules/Shared/`): Reusable UI components and app-wide utilities
4. **Utility Modules** (`Modules/Utility/`): Low-level utilities and helpers

### Critical Dependency Rules
- **Feature → FeatureInterface**: Features can ONLY depend on interfaces of other features
- **FeatureInterface → Feature**: **STRICTLY FORBIDDEN** - Interfaces cannot depend on implementations
- **Feature/FeatureInterface → Utility/Shared**: Can depend on utilities and shared modules
- No circular dependencies between modules at the same level

### Clean Architecture Layers (within each feature)
```
UI Layer (SwiftUI Views)
    ↓
Presentation Layer (ViewModels with @Observable)
    ↓
Business Logic Layer (Use Cases, Domain Models, Repository Protocols)
    ↓
Infrastructure Layer (Repository Implementations)
```

**Layer Rules:**
- UI can ONLY depend on ViewModels (Presentation layer)
- UI CANNOT directly access repositories or use cases
- ViewModels use dependency injection to access business logic
- Business logic depends on repository interfaces, not implementations

### Dependency Injection Pattern

The project uses **swift-dependencies** with the following pattern:

**Interface Definition** (in FeatureInterface modules):
```swift
@Spyable
public protocol SomeRepository: Sendable {
    func someMethod() async throws -> ReturnType
}

public enum SomeRepositoryKey: TestDependencyKey {
    public static let testValue: any SomeRepository = SomeRepositorySpy()
}

extension DependencyValues {
    public var someRepository: any SomeRepository {
        get { self[SomeRepositoryKey.self] }
        set { self[SomeRepositoryKey.self] = newValue }
    }
}
```

**Live Implementation** (in Feature module's `LiveDependencies.swift`):
```swift
extension SomeRepositoryKey: DependencyKey {
    public static let liveValue: any SomeRepository = SomeAPIRepository()
}
```

**Usage in ViewModels:**
```swift
@Observable
@MainActor
public class FeatureViewModel {
    @Dependency(\.someRepository) private var someRepository
    // Implementation
}
```

### Key Features
- **Timetable**: Core timetable functionality and UI components
- **Auth**: Authentication with Kakao, Facebook, Google integrations
- **Vacancy**: Classroom vacancy checking
- **Themes**: UI theming system
- **Notifications**: Push notification handling
- **Settings**: App configuration and user preferences
- **Reviews**: App store review integration
- **Popup**: App-wide popup system

## Technology Stack

- **Language**: Swift 6.1+ with modern Swift Concurrency (`async/await`)
- **UI Framework**: SwiftUI with Observation framework (`@Observable`, `@Bindable`)
- **Minimum iOS Version**: 17.0+
- **Xcode Version**: 16.0+
- **Project Management**: Tuist for modular project generation
- **Code Formatting**: swift-format with 120 character line length, 4-space indentation
- **API Integration**: OpenAPI-generated client with separate dev/prod configurations
- **Dependency Injection**: swift-dependencies package
- **Maps**: Kakao Maps SDK
- **Testing**: Built-in unit testing with Spyable for mock generation

## Code Style & Conventions

- **Formatting**: Automatic formatting via swift-format (configured in `.swift-format`)
- **Pre-commit Hooks**: swift-format runs automatically on commit
- **Sendable**: All repository protocols and implementations must be `Sendable`
- **MainActor**: ViewModels should be annotated with `@MainActor`
- **Async/Await**: Use Swift Concurrency for all asynchronous operations
- **Observation**: Use `@Observable` macro for ViewModels instead of ObservableObject

## File Structure Template

Each feature should follow this structure:
```
Modules/Feature/FeatureName/
├─ Sources/
│   ├─ UI/              # SwiftUI Views
│   ├─ Presentation/    # ViewModels
│   ├─ BusinessLogic/   # Use Cases, Domain Models
│   ├─ Infra/          # Repository Implementations
│   └─ Composition/     # Dependency Registration (LiveDependencies.swift)
└─ Tests/
    └─ UnitTests/       # Tests for all layers
```

## OpenAPI Integration

- API specs are automatically downloaded and generated
- Separate configurations for dev and prod environments
- Generated clients are located in `Modules/Feature/APIClientInterface/`
- Use `just openapi-dev` or `just openapi-prod` to regenerate API clients

## Widget Extension

The project includes a widget extension (`SNUTTWidget`) with its own target and dependencies, primarily using timetable functionality.