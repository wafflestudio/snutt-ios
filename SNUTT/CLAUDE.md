# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This project uses **Tuist** for project generation and **Just** for task automation.

### Essential Commands
```bash
# Project Generation
just generate             # Generate Xcode project with proper certificates and open it
tuist generate --no-open  # Generate without opening Xcode (useful when making file changes)

# ⚠️ IMPORTANT: You must regenerate the project after:
# - Creating new files
# - Deleting files
# - Renaming or moving files
# - Adding new modules
# - Modifying Project.swift or Tuist configuration files
# Tip: Use --no-open when you plan to continue editing files before opening Xcode

# Building
# ⚠️ WARNING: DO NOT use `tuist build` without specifying a scheme!
# It will build ALL schemes (app + all modules) and take a very long time.
# ALWAYS specify a scheme name:

tuist build "SNUTT Dev"    # Build development configuration (RECOMMENDED)
tuist build "SNUTT Prod"   # Build production configuration
tuist build "SNUTT Widget" # Build app + widget extension

# Module-Specific Builds (Preview Schemes)
# Use these for faster builds when working on a single module:
tuist build "Timetable Preview"          # Build only Timetable module
tuist build "Auth Preview"               # Build only Auth module
tuist build "Vacancy Preview"            # Build only Vacancy module
tuist build "Themes Preview"             # Build only Themes module
# ... and more Preview schemes for other modules

# Testing
tuist build "ModuleTests"  # Build all module tests

# Code Quality
just format                # Format Swift code using swift-format
just check                 # Run all checks (formatting, imports, etc.)

# API Code Generation
just openapi-dev           # Generate API client for dev server
just openapi-prod          # Generate API client for prod server
```

### Available Schemes

This project automatically generates the following schemes:

#### Main App Schemes
- **SNUTT Dev**: Development build with dev API endpoint (`snutt-api-dev.wafflestudio.com`)
- **SNUTT Prod**: Production build with prod API endpoint (`snutt-api.wafflestudio.com`)
- **SNUTT Widget**: Build app with widget extension for testing widgets

#### Module Preview Schemes

Each feature and shared UI module has its own Preview scheme for faster, isolated builds:

**Feature Module Previews:**
- `Timetable Preview`, `Auth Preview`, `Notifications Preview`
- `Vacancy Preview`, `Themes Preview`, `Settings Preview`
- `Reviews Preview`, `Friends Preview`, `Popup Preview`

**Shared UI Module Previews:**
- `TimetableUIComponents Preview`
- `SharedUIComponents Preview`, `SharedUIWebKit Preview`, `SharedUIMapKit Preview`

**Test Scheme:**
- `ModuleTests`: Runs all module tests across the project

#### When to Use Preview Schemes

Preview schemes are ideal for **localized development** when working on a single module:

```bash
# Example: Working on Timetable feature only
tuist build "Timetable Preview"  # Much faster than full app build

# Example: Making changes to shared UI components
tuist build "SharedUIComponents Preview"
```

**Benefits:**
- **Faster build times**: Only builds the target module and its dependencies
- **Quick validation**: Immediately verify if your changes compile without full app rebuild
- **Focused development**: Isolate work to specific modules

**Note:** Some modules don't have Preview schemes:
- `Analytics` (marked as `previewable: false`)
- `Configs` (marked as `previewable: false`)
- `APIClient` (marked as `previewable: false`)
- All `*Interface` modules (FeatureInterface modules don't have preview schemes)

### Build Configurations
- **Dev**: Development configuration, API: `snutt-api-dev.wafflestudio.com`
- **Prod**: Production configuration, API: `snutt-api.wafflestudio.com`

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
- **Feature → Feature**: **FORBIDDEN** - Use UIProvider pattern instead (see "Core Architecture Patterns" below)
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

## Core Architecture Patterns

### 1. UIProvider Pattern - Cross-Feature UI Composition

Since features cannot directly depend on each other, SNUTT uses a **UIProvider pattern** to share UI components between features.

**Problem:** Feature A needs to show UI from Feature B, but importing Feature B violates the architecture.

**Solution:** Feature B defines a `UIProvidable` protocol in its interface module. Feature A uses this protocol via dependency injection. The app wires them together.

**Example: TimetableUIProvidable**

Interface definition in `TimetableInterface/Sources/UI/TimetableUIProvidable.swift`:
```swift
@MainActor
public protocol TimetableUIProvidable: Sendable {
    func lectureDetailRow(type: DetailLabelType, lecture: Lecture) -> AnyView
    func timetableView(
        timetable: Timetable?,
        configuration: TimetableConfiguration,
        preferredTheme: Theme?,
        availableThemes: [Theme]
    ) -> AnyView
}

public enum TimetableUIProviderKey: TestDependencyKey {
    public static let testValue: any TimetableUIProvidable = EmptyTimetableUIProvider()
}

extension DependencyValues {
    public var timetableUIProvider: any TimetableUIProvidable {
        withDependencies {
            $0.context = .live
        } operation: {
            Dependency(\.timetableUIProvider).wrappedValue
        }
    }
}
```

Implementation in `Timetable/Sources/UI/TimetableUIProvider.swift`:
```swift
public struct TimetableUIProvider: TimetableUIProvidable {
    public nonisolated init() {}

    public func lectureDetailRow(type: DetailLabelType, lecture: Lecture) -> AnyView {
        AnyView(LectureDetailRow(type: type, lecture: lecture))
    }

    public func timetableView(...) -> AnyView {
        AnyView(TimetableZStack(...))
    }
}
```

Injection at app level in `SNUTT/Sources/Composition/LiveDependencies.swift`:
```swift
extension TimetableUIProviderKey: @retroactive DependencyKey {
    public static let liveValue: any TimetableUIProvidable = TimetableUIProvider()
}
```

Usage in another feature:
```swift
@Environment(\.timetableUIProvider) private var timetableUIProvider

var body: some View {
    timetableUIProvider.lectureDetailRow(type: .lecturer, lecture: lecture)
}
```

**Key Benefits:**
- Features remain independent (no direct imports)
- Dependency graph stays clean
- UI can be mocked in previews with test values
- App controls wiring, not individual features

---

### 2. EnvironmentValue with withDependencies - Preview Support

SNUTT bridges `DependencyValues` (swift-dependencies) with `EnvironmentValues` (SwiftUI) using `withDependencies`:

```swift
extension EnvironmentValues {
    public var timetableUIProvider: any TimetableUIProvidable {
        withDependencies {
            $0.context = .live  // Switch to live context for previews
        } operation: {
            Dependency(\.timetableUIProvider).wrappedValue
        }
    }
}
```

**Why this pattern?**
- In app runtime: Dependencies uses `.live` context by default (production implementations)
- In previews: The `withDependencies { $0.context = .live }` explicitly switches to live context so preview values work seamlessly
- Ensures previews display actual UI, not test stubs
- Allows DependencyKey configuration to work in SwiftUI preview environment

**@Entry Pattern - Simpler Alternative**

For simpler environment values that don't need DependencyKey complexity:
```swift
extension EnvironmentValues {
    @Entry public var timetableViewModel: any TimetableViewModelProtocol = DefaultTimetableViewModel()
}
```

The `@Entry` macro automatically provides a default value for previews without manual getter/setter.

---

### 3. Three-Level Dependency Injection Strategy

SNUTT uses a sophisticated three-level DI system to maintain architecture integrity:

**Level 1: Interface Module - Define Contract with TestDependencyKey**

In `TimetableInterface/Sources/Repository/TimetableLocalRepository.swift`:
```swift
@Spyable
public protocol TimetableLocalRepository: Sendable {
    func loadSelectedTimetable() throws -> Timetable
    func storeSelectedTimetable(_ timetable: Timetable) throws
}

public enum TimetableLocalRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableLocalRepository = {
        let spy = TimetableLocalRepositorySpy()  // Auto-generated by @Spyable
        spy.loadSelectedTimetableReturnValue = PreviewHelpers.preview(id: "1")
        return spy
    }()
}

extension DependencyValues {
    public var timetableLocalRepository: any TimetableLocalRepository {
        get { self[TimetableLocalRepositoryKey.self] }
        set { self[TimetableLocalRepositoryKey.self] = newValue }
    }
}
```

**Key Points:**
- Interface modules use `TestDependencyKey` (not `DependencyKey`)
- Only define `testValue` with pre-configured spy
- Interfaces don't know implementation details
- `@Spyable` automatically generates spy classes for testing

**Level 2: Feature Module - Provide Implementation with DependencyKey**

In `Timetable/Sources/Composition/LiveDependencies.swift`:
```swift
extension TimetableLocalRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any TimetableLocalRepository =
        TimetableUserDefaultsRepository()

    public static let previewValue: any TimetableLocalRepository = {
        let spy = TimetableLocalRepositorySpy()
        spy.loadSelectedTimetableReturnValue = PreviewHelpers.preview(id: "1")
        return spy
    }()
}
```

**Key Points:**
- Feature modules add `DependencyKey` conformance via `@retroactive`
- Define `liveValue` (production) and `previewValue` (Xcode previews)
- Feature-specific dependencies wired here (API repos, local storage, SDKs)
- Not exposed publicly - only used by app's LiveDependencies

**Level 3: App Module - Wire Everything at Root**

In `SNUTT/Sources/Composition/LiveDependencies.swift`:
```swift
// Imports all feature implementations
import Timetable
import Auth
import Vacancy
// ... more features

// Wire all dependencies at app level
extension TimetableUIProviderKey: @retroactive DependencyKey {
    public static let liveValue: any TimetableUIProvidable = TimetableUIProvider()
}

extension AuthRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any AuthRepository = AuthAPIRepository()
}

extension VacancyRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any VacancyRepository = VacancyAPIRepository()
}
```

**Key Points:**
- Central place where all production implementations are wired
- Only the app module imports feature implementations
- Uses `@retroactive` to add conformances to interface types
- Features remain independent from each other
- Dependency graph is acyclic and clearly defined

---

### 4. Clean Architecture Layers - Detailed Responsibilities

**UI Layer** (`Sources/UI/`)
- SwiftUI Views and Scenes
- Pure UI presentation
- Responds to user interactions
- Accesses state only via ViewModels
- No business logic, no repository access

**Presentation Layer** (`Sources/Presentation/`)
- ViewModels marked with `@Observable` and `@MainActor`
- Orchestrates business logic operations
- Manages presentation state (loading, error, data)
- Performs side effects (navigation, analytics)
- Injects dependencies via `@Dependency`
- Never directly access repositories (go through use cases)

**Business Logic Layer** (`Sources/BusinessLogic/`)
- **Use Cases**: Orchestrate repository calls, implement domain logic
- **Domain Models**: Value types representing core concepts (defined in interface)
- **Repository Protocols**: Contracts for data access (defined in interface)
- Business logic has **zero knowledge** of HTTP, storage, SDKs, or UI

**Infrastructure Layer** (`Sources/Infra/`)
- **API Repositories**: HTTP communication via OpenAPI client, DTO-to-domain transformation
- **Local Storage Repositories**: UserDefaults, Keychain, CoreData access
- **SDK Wrappers**: Third-party SDKs (Auth services, ImageRenderer)
- Implementation details hidden from business logic
- Transforms external data formats to domain models

**Example: API Repository**
```swift
public struct LectureAPIRepository: LectureRepository {
    @Dependency(\.apiClient) private var apiClient  // External dependency

    public func fetchBuildingList(places: [LectureBuilding]) async throws -> [Building] {
        let response = try await apiClient.searchBuildings(query: .init(places: joinedPlaces))
        return response.content.compactMap { Building(dto: $0) }  // DTO → Domain
    }
}
```

---

### 5. TestDependencyKey vs DependencyKey - When to Use Each

The choice depends on **whether the dependency is shared across features**:

**TestDependencyKey - For Cross-Feature Dependencies**

Use in Interface modules when a protocol is **used by multiple features**:
```swift
// TimetableInterface/Sources/Repository/TimetableLocalRepository.swift
// Used by: Timetable feature, Settings feature, potentially others

@Spyable
public protocol TimetableLocalRepository: Sendable {
    func loadSelectedTimetable() throws -> Timetable
}

public enum TimetableLocalRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableLocalRepository = {
        let spy = TimetableLocalRepositorySpy()
        spy.loadSelectedTimetableReturnValue = PreviewHelpers.preview(id: "1")
        return spy
    }()
    // NOTE: No liveValue - interface module can't import implementations
}

extension DependencyValues {
    public var timetableLocalRepository: any TimetableLocalRepository {
        get { self[TimetableLocalRepositoryKey.self] }
        set { self[TimetableLocalRepositoryKey.self] = newValue }
    }
}
```

**Why TestDependencyKey for cross-feature?**
- Other features import only the interface module (no feature implementation)
- Interface module can't define liveValue (would create circular dependency)
- Each feature provides its own implementation via `@retroactive DependencyKey` in Composition
- Only provides `testValue` - concrete implementations defined elsewhere

**DependencyKey - For Feature-Internal Dependencies**

Use directly in Feature Composition when a protocol is **used only within that feature**:
```swift
// Timetable/Sources/Composition/LiveDependencies.swift
// Used by: Only Timetable feature (not shared)

struct LectureSearchRepositoryKey: DependencyKey {  // Direct DependencyKey
    static let liveValue: any LectureSearchRepository = LectureSearchAPIRepository()

    static let previewValue: any LectureSearchRepository = {
        let spy = LectureSearchRepositorySpy()
        spy.fetchSearchResultQueryQuarterPredicatesOffsetLimitReturnValue = []
        return spy
    }()
}

extension DependencyValues {
    var lectureSearchRepository: any LectureSearchRepository {
        get { self[LectureSearchRepositoryKey.self] }
        set { self[LectureSearchRepositoryKey.self] = newValue }
    }
}
```

**Why DependencyKey directly for internal?**
- Only this feature uses it (no circular dependency risk)
- Can safely define liveValue immediately (implementation is in same feature)
- Simpler and more direct - no need for @retroactive conformance
- Keeps internal dependencies private to the feature

**Real-World Example:**

```
TimetableLocalRepository:
  ✓ Shared by multiple features (Timetable, Settings, etc.)
  → Defined as TestDependencyKey in TimetableInterface (testValue only)
  → App's Composition adds @retroactive DependencyKey with liveValue
  → All features: import TimetableInterface, use testValue in previews,
                  use app-injected liveValue at runtime

LectureSearchRepository:
  ✓ Used only by Timetable feature
  → DependencyKey defined in Timetable/Composition/LiveDependencies.swift
  → No interface module needed if truly feature-internal
```

**Decision Tree:**
```
Does another feature need to import this protocol?
├─ YES  → TestDependencyKey in *Interface module
│         (liveValue added by feature in Composition)
└─ NO   → DependencyKey directly in feature's Composition
          (liveValue defined immediately)
```

---

### 6. Shared vs Utility Modules - Clear Distinction

| Aspect | Shared Modules | Utility Modules |
|--------|---|---|
| **Purpose** | SNUTT-specific UI & app utilities | General-purpose Swift helpers |
| **Reusability** | Only within SNUTT | Any Swift project |
| **App Context** | Contains design system decisions | Zero app context |
| **Examples** | `Popup` (12pt corner radius, SNUTT styling), `CommonTabView`, `Logo` | `Color+Hex` (generic extension), `@OnLoad` modifier |
| **Location** | `Modules/Shared/SharedUIComponents/`, `SharedAppMetadata/` | `Modules/Utility/SwiftUIUtility/`, `FoundationUtility/` |
| **Dependencies** | App-specific (assets, themes, configs) | Only Foundation/SwiftUI |
| **Used By** | Features, App | All modules |

**Shared Example:**
```swift
// SharedUIComponents/Popup/Popup.swift - SNUTT-specific
private enum Layout {
    static var cornerRadius: CGFloat { 12 }      // Design decision
    static var horizontalMargin: CGFloat { 40 }   // Design decision
    static var backgroundOpacity: CGFloat { 0.5 }
}
```

**Utility Example:**
```swift
// SwiftUIUtility/Color+Hex.swift - Generic, any app can use
extension Color {
    public init(hex: String, alpha: Double = 1) {
        // Pure hex parsing logic - no app context
    }
}
```

---

### Key Features by Module

- **Timetable**: Course timetable display, lecture search & edit, image export
- **Auth**: User authentication (local, Kakao, Google, Facebook, Apple), account management
- **Notifications**: Real-time notification display, FCM integration
- **Vacancy**: Course vacancy tracking, vacancy alerts
- **Themes**: Timetable color theme management & selection
- **Settings**: Account settings, app preferences, feature toggles
- **Reviews**: Lecture evaluation display (read-only)
- **Friends**: Friend list, timetable sharing
- **Popup**: App-wide popup/announcement system
- **Analytics**: Firebase analytics integration
- **Configs**: Server-side configuration & feature flags

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
- **Testing**: Swift Testing framework with Spyable for mock generation

## Testing Strategy

SNUTT uses **Swift Testing** framework (Apple's modern testing framework) instead of XCTest.

### Swift Testing Basics

**Import Statement:**
```swift
import Testing
```

**Test Function:**
```swift
@Test func testExample() {
    #expect(1 + 1 == 2)
}
```

- Use `@Test` macro instead of `func testXxx()` or XCTestCase subclasses
- Use `#expect(condition)` instead of `XCTAssert*` methods

**Test Suite (optional):**
```swift
@Suite struct TimetableTests {
    @Test func loadsTimetable() {
        #expect(true)
    }

    @Test func savesTimetable() {
        #expect(true)
    }
}
```

### Test File Organization

Test files are located in each module's `Tests/` directory:
```
Modules/Feature/FeatureName/Tests/FeatureNameTests.swift
```

### Important: NO XCTest

- **Do NOT use XCTest** in new test files
- **Do NOT use XCTAssert*** methods
- Always use Swift Testing framework with `@Test` and `#expect`

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
