# Evaluation Main Native Migration Design

## Context

The Evaluations module currently renders the lecture evaluation experience through `EvaluationsWebScene`. This project starts the native migration with the main tab screen only. Existing web-based Evaluations entry points stay intact, while new native code uses `Evaluation` naming for new domain, state, use case, repository, and UI types.

The main tab will replace the web view with a native evaluation home screen. Search, filter, evaluation detail, lecture detail, write evaluation, all evaluations, and my evaluations destinations are connected as navigation placeholders in this phase.

## Scope

In scope:

- Native main screen for the Evaluations tab.
- Real API integration for the main recommended/latest evaluation feed.
- Real API integration for the taken lectures section.
- A recommended/latest toggle that shows only the selected feed.
- Navigation skeletons to search, filter, evaluation detail, lecture detail, write evaluation, all evaluations, and my evaluations.
- Previewable SwiftUI components for every meaningful screen section and cell.
- New native naming based on `Evaluation`, not `Review`.

Out of scope:

- Native search results.
- Native filter implementation.
- Native detail and write flows beyond placeholder destinations.
- Removing or renaming the legacy web view code.
- Applying search filters to the home feed.
- Rendering average score details for taken lectures unless the required API is added in a later phase.

## API Notes

The generated Evaluations API client declares `https://snutt-ev-api-dev.wafflestudio.com`, but the working dev route is under the main API host with the `/ev-service` prefix:

- `GET /ev-service/v1/tags/main`
- `GET /ev-service/v1/tags/main/{id}/evaluations`
- `GET /ev-service/v1/users/me/lectures/latest`

The native repository should derive its base URL from `API_SERVER_URL` and append `/ev-service`, instead of hardcoding a dev host. Some generated operation bodies are `HTTPBody`, so the repository is responsible for decoding those responses into local DTOs before mapping to domain models.

The main tag response currently includes `최신`, `교양`, `추천`, `명강`, `꿀강`, and `고진감래`. The home screen uses only `최신` and `추천`.

## Architecture

Add a native implementation inside the existing Evaluations module.

- `BusinessLogic/Domain`: native evaluation models and typed IDs.
- `BusinessLogic/Application`: `EvaluationRepository` and `EvaluationHomeUseCase`.
- `Infra`: `EvaluationAPIRepository`, generated client wiring, HTTP body decoding, DTO-to-domain mapping.
- `Presentation`: `EvaluationViewModel`, load state, navigation destinations.
- `UI`: `EvaluationScene` and small previewable components.

`EvaluationHomeUseCase` owns home-screen orchestration:

- `loadHome()` loads main tags, resolves latest/recommended sort IDs, loads the default recommended feed, and loads taken lectures.
- `loadEvaluations(sort:cursor:)` loads the selected main evaluation feed and pagination.
- `loadTakenLectures()` refreshes the taken lectures section.

`EvaluationRepository` owns individual API calls and mapping. `EvaluationViewModel` owns UI state and navigation only.

## UIProvider Migration

Keep the legacy method and add a native method.

```swift
@MainActor
public protocol EvaluationsUIProvidable: Sendable {
    func makeEvaluationsScene(for evLectureID: Int) -> AnyView
    func makeEvaluationScene(for evLectureID: EvLectureID) -> AnyView
}
```

`makeEvaluationsScene(for:)` continues to return `EvaluationsWebScene`. `makeEvaluationScene(for:)` returns the native evaluation flow, initially opening a placeholder lecture/evaluation detail destination as needed. The app Evaluations tab uses the native `EvaluationScene()` directly.

`EvLectureID` must live in `EvaluationsInterface` so other feature modules can call the native provider without depending on the Evaluations implementation module.

## Domain Models

New native models use `Evaluation` naming. Legacy web types keep `Evaluations` naming.

```swift
public typealias EvaluationID = Tagged<EvaluationIDTag, Int64>
public enum EvaluationIDTag {}

public typealias EvLectureID = Tagged<EvLectureIDTag, Int64>
public enum EvLectureIDTag {}

struct EvLectureBrief: Equatable, Identifiable {
    var id: EvLectureID
    var title: String
    var instructor: String?
}

struct LectureEvaluation: Equatable, Identifiable {
    var id: EvaluationID
    var lecture: EvLectureBrief
    var rating: Double
    var content: String
    var year: Int
    var semester: Int
    var likeCount: Int
    var isLiked: Bool
    var isReportable: Bool
}

struct TakenLectureSummary: Equatable, Identifiable {
    var lecture: EvLectureBrief
    var id: EvLectureID { lecture.id }

    var department: String?
    var courseNumber: String?
    var credit: Int?
    var academicYear: String?
    var classification: String?
    var takenYear: Int
    var takenSemester: Int
}
```

`EvLectureID` is a separate EV-service lecture ID, not `TimetableInterface.LectureID` and not `TimetableLectureID`.

## State Model

Use enum load state rather than scattered boolean flags.

```swift
enum LoadState<Value: Equatable>: Equatable {
    case loading
    case loaded(Value)
    case failed(EvaluationError)
}

struct EvaluationHomeViewState: Equatable {
    var selectedSort: EvaluationSort
    var availableSorts: [EvaluationSort]
    var mainEvaluations: MainEvaluationsState
    var takenLectureSection: TakenLectureSectionState
}

struct MainEvaluationsState: Equatable {
    var evaluations: [LectureEvaluation]
    var cursor: String?
    var canLoadMore: Bool
    var paginationState: PaginationState
}

enum PaginationState: Equatable {
    case idle
    case loading
    case failed(EvaluationError)
}
```

The screen starts in `.loading`. Initial load failure uses `.failed`. Sort changes and pagination update the loaded `EvaluationHomeViewState` without dropping the whole screen state.

## UI Design

Use system navigation for navigation bars and titles:

- `NavigationStack`
- `.navigationTitle("강의평")`
- system toolbar/navigation modifiers where applicable

Do not custom-build navigation bar chrome or tab bar behavior. The app will rely on system/liquid-glass components for those areas.

The content uses the flat design guide:

- Minimal search entry view at the top.
- No home filter chips. Filters belong to the search flow only.
- Recommended/latest text toggle, showing only the selected feed.
- Main evaluations list.
- "강의평 전체보기" row.
- Fixed taken lectures section title: `25년 2학기 수강한 강의`.
- "나의 강의평" action.
- Taken lecture list with write evaluation action.

The search entry component should stay intentionally small so it can later be replaced with an OS search component.

## UI Components

Previewable components:

- `EvaluationScene`
- `EvaluationSearchEntryView`
- `EvaluationSortToggle`
- `MainEvaluationsSection`
- `LectureEvaluationCell`
- `TakenLectureSection`
- `TakenLectureCell`
- `EvaluationPlaceholderScene`
- Empty/loading/error section views as needed

Navigation destinations:

```swift
enum EvaluationDestination: Hashable {
    case search
    case filter
    case evaluationDetail(EvaluationID)
    case lectureDetail(EvLectureID)
    case writeEvaluation(EvLectureID)
    case myEvaluations
    case allEvaluations(sort: EvaluationSort.Kind)
}
```

## Error Handling

Initial home load failure renders an in-screen retry state. Section-level failures after a loaded state, such as pagination or sort reload failure, are represented in the relevant state value and surfaced with the existing app error alert pattern where appropriate.

Empty states are section-level:

- No main evaluations for selected sort.
- No taken lectures.

## Tests

Use Swift Testing, not XCTest.

Add focused tests for:

- Mapping main tags to latest/recommended `EvaluationSort` values.
- `EvaluationHomeUseCase.loadHome()` loading recommended feed and taken lectures.
- Sort toggling replacing the displayed feed with the selected sort.
- Pagination appending items, updating cursor, and respecting `canLoadMore`.
- Missing latest/recommended tag producing a clear error.
- Repository decoding sample `HTTPBody` JSON into domain models.

## Implementation Notes

After adding new source files, regenerate the Tuist project with `tuist generate --no-open`.

Prefer module build validation with:

```bash
tuist build Evaluations
```

If shared interface files change, also build affected callers or the dev app scheme as needed.
