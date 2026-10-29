# CLAUDE.md

SNUTT iOS — SNU course timetable app. Swift 6.1, SwiftUI, iOS 17+. Project generated with **Tuist**, tasks run with **just**. The Tuist version is pinned in `.mise.toml` (`mise exec -- tuist ...`).

## Commands

```bash
tuist generate --no-open   # Regenerate project (`just generate` also syncs certs and opens Xcode)
tuist build "SNUTT Dev"    # Build the app (dev API)
tuist build Timetable      # Build one module — much faster when only one module changed
tuist test Timetable       # Test one module
tuist test ModuleTests     # Test all modules
just check                 # tuist inspect implicit-imports + swift-format
just openapi-dev           # Download OpenAPI spec and generate code
```

- **Rerun `tuist generate --no-open`** after adding, deleting, or moving files, or changing `Project.swift`, Tuist config, or resources with generated accessors (Localizable.strings, assets).
- **Always pass a scheme to `tuist build`.** Without one it builds every scheme.
- **Run `tuist build` in the foreground, synchronously.** Never in the background.
- OpenAPI output (`**/Generated/`) is gitignored. On a fresh checkout, if the build fails on missing generated types, run `just openapi-dev` first. Output locations: `APIClientInterface/Sources/Generated` (types), `APIClient/Sources/Generated` (client), `Evaluations/Sources/Infra/Generated` (evaluation server).
- A pre-commit hook runs swift-format (120 columns, 4-space indent, `.swift-format`).

### Schemes

- App: `SNUTT Dev`, `SNUTT Prod`, `SNUTT Widget` (includes the widget extension)
- Modules: every previewable Feature module and every UI Shared/Utility module gets a scheme with the module's name. `*Interface` modules and `previewable: false` modules (Analytics, Configs, APIClient) have none.

## Module Structure

Three categories under `Modules/`. Modules and their dependencies are declared in `Project.swift`.

- `Feature/` — feature modules and their `*Interface` contract modules
- `Shared/` — SNUTT-specific UI and app utilities (design system, `SharedAppMetadata`)
- `Utility/` — general-purpose helpers with no app context

### Dependency Rules

- A Feature may depend on other Features' **Interfaces only**. Importing another Feature directly is forbidden.
- An Interface must never depend on a Feature implementation.
- To show another Feature's UI, use the **UIProvider pattern** (below).
- Only the app module (`SNUTT/Sources/Composition/LiveDependencies.swift`) wires implementations together.

### Layers inside a Feature

```
Sources/
├─ UI/            # SwiftUI views; depend only on ViewModels
├─ Presentation/  # @Observable @MainActor ViewModels; inject repositories/use cases via @Dependency
├─ BusinessLogic/ # Use cases (only when needed)
├─ Infra/         # Repository implementations (API, UserDefaults, Keychain, SDKs)
└─ Composition/   # This Feature's DependencyKey registrations (LiveDependencies.swift)
```

Views never touch repositories or use cases. ViewModels may inject repositories directly (most do today). Add a use case only when there is real logic to hold, such as combining several repositories. Domain models and repository protocols live in `*Interface` modules. Infra maps DTOs to domain models.

## Dependency Injection (swift-dependencies)

**Where does the key go?** Does another Feature need to import this protocol?

- **Yes** → define it in the `*Interface` module as a `TestDependencyKey` with only a `testValue` (usually a `@Spyable`-generated Spy). Add `liveValue`/`previewValue` via `@retroactive DependencyKey` in the implementing Feature's `Composition/` or in the app's `LiveDependencies.swift`.
  - Example: `TimetableInterface/Sources/Repository/TimetableLocalRepository.swift` → `Timetable/Sources/Composition/LiveDependencies.swift`
- **No** → define a plain `DependencyKey` (internal) directly in the Feature's `Composition/LiveDependencies.swift`.
  - Example: `LectureSearchRepositoryKey` in `Timetable/Sources/Composition/LiveDependencies.swift`

Repository protocols and implementations are all `Sendable`.

### UIProvider Pattern

Use it when Feature A needs to show a screen from Feature B:

1. In B's Interface, define `@MainActor protocol XxxUIProvidable: Sendable` (methods return `AnyView`) and a `TestDependencyKey` whose `testValue` is an empty implementation.
2. Keep the `DependencyValues` accessor `fileprivate`, and expose a `public` accessor on `EnvironmentValues`. Wrap that accessor in `withDependencies { $0.context = .live }` so previews read the live value too.
3. Implement the protocol in B, and wire it as `liveValue` in the app's `LiveDependencies.swift`.
4. Use it in A via `@Environment(\.xxxUIProvider)`.

Reference: `TimetableInterface/Sources/UI/TimetableUIProvidable.swift`, `Timetable/Sources/UI/TimetableUIProvider.swift`

Use `@Entry` for simple environment values.

## Testing

- Use **Swift Testing** (`@Test`, `#expect`) only. No XCTest in new tests.
- Tests live in each module's `Tests/`. Use `@Spyable`-generated Spies as mocks.

## Misc

- The app's Info.plist is defined in `Tuist/ProjectDescriptionHelpers/InfoPlist.swift`.
- API hosts: Dev → `snutt-api-dev.wafflestudio.com`, Prod → `snutt-api.wafflestudio.com`
- The widget extension lives in `SNUTTWidget/` and mostly uses Timetable functionality.
