# Evaluation Home Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor Evaluations home and see-all loading/error/pagination UI so the home screen has section-level skeleton loading, alert-driven explicit failures, invisible infinite pagination, and loading/loaded previews.

**Architecture:** Keep `EvaluationHomeScene` as the navigation and state-routing owner. Extract only meaningful UI sections, let view models throw explicit load/sort errors upward, and keep pagination as private view-model bookkeeping with no renderable footer state. Preview fixtures live near Evaluations UI and do not depend on repositories or network calls.

**Tech Stack:** Swift 6.1, SwiftUI, Observation `@Observable`, swift-dependencies, Swift Testing only if implementation exposes a risky behavior that needs coverage, Tuist module build.

---

## File Map

- Modify `Modules/Feature/Evaluations/Sources/Presentation/EvaluationHomeViewModel.swift`
  - Remove display-string failure state.
  - Split initial load/refresh semantics so refresh keeps loaded content on failure.
  - Make load and sort methods throw errors to the scene.
- Modify `Modules/Feature/Evaluations/Sources/Presentation/EvaluationSeeAllViewModel.swift`
  - Make `loadState == .loaded([LectureEvaluation])` the single visible-list source of truth.
  - Remove `evaluations`, `PaginationState`, and `retryLoadMore()`.
  - Keep pagination as private `cursor`, `canLoadMore`, `isLoadingMore`, and request generation state.
- Modify `Modules/Feature/Evaluations/Sources/BusinessLogic/Domain/EvaluationError.swift`
  - Conform to `LocalizedError`.
- Create `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationHomeSectionLink.swift`
  - Shared section link row used by home sections.
- Create `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationMainFeedSection.swift`
  - Main feed section with loaded/loading modes and section-level redaction.
- Create `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationTakenLectureSection.swift`
  - Taken lecture section with loaded/loading modes and section-level redaction.
- Create `Modules/Feature/Evaluations/Sources/UI/Preview/EvaluationPreviewFixtures.swift`
  - File-private or internal preview fixtures for home loading/loaded previews and section previews.
- Modify `Modules/Feature/Evaluations/Sources/UI/EvaluationHomeScene.swift`
  - Replace `ProgressView` and `ContentUnavailableView` with skeleton scroll content plus alert-wrapped loading.
  - Use extracted sections.
  - Add loading and loaded previews.
- Modify `Modules/Feature/Evaluations/Sources/UI/EvaluationSeeAllScene.swift`
  - Remove failed screen and pagination footer.
  - Wrap explicit loads/sorts with `errorAlertHandler`.
  - Use loaded payload from `loadState`.
  - Add silent bottom-near pagination trigger.
- Modify `Modules/Feature/Evaluations/Tests/EvaluationsTests.swift`
  - Only update existing tests that fail due to removed `.failed(String)` or removed visible pagination state. Do not add new test cases unless a behavior cannot be verified by build/manual preview.
- Run `tuist generate --no-open` if any new Swift files are added.
- Run `tuist build Evaluations`.
- Run `just format` if formatting changes are needed.

---

### Task 1: Convert Evaluations Errors And Load State To Alert-Friendly Types

**Files:**
- Modify: `Modules/Feature/Evaluations/Sources/BusinessLogic/Domain/EvaluationError.swift`
- Modify: `Modules/Feature/Evaluations/Sources/Presentation/EvaluationHomeViewModel.swift`

- [ ] **Step 1: Make `EvaluationError` localized**

Replace `EvaluationError` with:

```swift
/// Errors surfaced by the native evaluation flow.
enum EvaluationError: LocalizedError, Equatable, Sendable {
    case missingRequiredSort(String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredSort:
            "강의평을 불러오지 못했습니다."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingRequiredSort(let displayName):
            "\(displayName) 정렬 정보를 불러오지 못했습니다."
        }
    }
}
```

- [ ] **Step 2: Remove renderable failed state**

In `EvaluationHomeViewModel.swift`, replace `LoadState` and remove `PaginationState` from this file:

```swift
enum LoadState<Value: Equatable & Sendable>: Equatable, Sendable {
    case loading
    case loaded(Value)
}
```

Delete:

```swift
enum PaginationState: Equatable, Sendable {
    case loading
    case failed(String)
}

func evaluationLoadMessage(for error: any Error) -> String {
    if let error = error as? EvaluationError, case .missingRequiredSort = error {
        return "필수 정렬 정보를 불러오지 못했습니다."
    }
    return "강의평을 불러오지 못했습니다."
}
```

- [ ] **Step 3: Make home load throw and keep skeleton on failure**

Replace `load()` with:

```swift
func load() async throws {
    homeState = .loading
    let data = try await useCase.loadHome()
    homeState = .loaded(data)
}
```

This preserves skeleton after failure because the thrown error leaves `homeState` at `.loading`.

- [ ] **Step 4: Add refresh that preserves loaded content**

Add this method below `load()`:

```swift
func refresh() async throws {
    let data = try await useCase.loadHome()
    homeState = .loaded(data)
}
```

Use this for pull-to-refresh so an existing loaded screen is not replaced by skeleton while refreshing.

- [ ] **Step 5: Make sort selection throw and revert on failure**

Replace `selectSort(_:)` with:

```swift
func selectSort(_ sort: EvaluationSort) async throws {
    guard case .loaded(let previousState) = homeState, previousState.selectedSort != sort else { return }

    let requestedSort = sort
    homeState = .loaded(
        .init(
            selectedSort: sort,
            availableSorts: previousState.availableSorts,
            mainFeed: previousState.mainFeed,
            takenLectureFeed: previousState.takenLectureFeed
        )
    )

    do {
        let page = try await useCase.loadEvaluations(sort: sort, cursor: nil)
        guard case .loaded(let currentState) = homeState,
            currentState.selectedSort == requestedSort
        else { return }
        homeState = .loaded(
            .init(
                selectedSort: requestedSort,
                availableSorts: currentState.availableSorts,
                mainFeed: EvaluationFeedContent(
                    evaluations: page.evaluations,
                    cursor: page.cursor,
                    canLoadMore: !page.isLast
                ),
                takenLectureFeed: currentState.takenLectureFeed
            )
        )
    } catch {
        guard case .loaded(let currentState) = homeState,
            currentState.selectedSort == requestedSort
        else { return }
        homeState = .loaded(previousState)
        throw error
    }
}
```

- [ ] **Step 6: Run focused compile feedback**

Run:

```bash
tuist build Evaluations
```

Expected: compile errors in scenes and tests that still reference `.failed`, non-throwing `load()`, non-throwing `selectSort(_:)`, or `PaginationState`. Leave them for later tasks.

---

### Task 2: Refactor See-All View Model For Single Source Of Truth And Silent Pagination

**Files:**
- Modify: `Modules/Feature/Evaluations/Sources/Presentation/EvaluationSeeAllViewModel.swift`

- [ ] **Step 1: Replace stored properties**

Replace these properties:

```swift
var loadState: LoadState<[LectureEvaluation]> = .loading
var selectedSort: EvaluationSort
let availableSorts: [EvaluationSort]
var evaluations: [LectureEvaluation] = []
var paginationState: PaginationState?

@ObservationIgnored
private let useCase: EvaluationHomeUseCase
private var cursor: String?
private var canLoadMore = true
```

with:

```swift
var loadState: LoadState<[LectureEvaluation]> = .loading
var selectedSort: EvaluationSort
let availableSorts: [EvaluationSort]

@ObservationIgnored
private let useCase: EvaluationHomeUseCase
private var cursor: String?
private var canLoadMore = true
private var isLoadingMore = false
private var firstPageRequestID = 0
```

- [ ] **Step 2: Add visible evaluations and request helpers**

Add:

```swift
var loadedEvaluations: [LectureEvaluation] {
    guard case .loaded(let evaluations) = loadState else {
        return []
    }
    return evaluations
}

private func nextFirstPageRequestID() -> Int {
    firstPageRequestID += 1
    return firstPageRequestID
}
```

- [ ] **Step 3: Make explicit first-page load throw**

Replace `load()` with:

```swift
func load() async throws {
    let requestedSort = selectedSort
    let requestID = nextFirstPageRequestID()
    loadState = .loading
    cursor = nil
    canLoadMore = true
    isLoadingMore = false

    let page = try await useCase.loadEvaluations(sort: requestedSort, cursor: nil)
    guard selectedSort == requestedSort,
        firstPageRequestID == requestID
    else { return }
    cursor = page.cursor
    canLoadMore = !page.isLast
    loadState = .loaded(page.evaluations)
}
```

- [ ] **Step 4: Add refresh preserving semantics**

Add:

```swift
func refresh() async throws {
    let requestedSort = selectedSort
    let requestID = nextFirstPageRequestID()
    let page = try await useCase.loadEvaluations(sort: requestedSort, cursor: nil)
    guard selectedSort == requestedSort,
        firstPageRequestID == requestID
    else { return }
    cursor = page.cursor
    canLoadMore = !page.isLast
    isLoadingMore = false
    loadState = .loaded(page.evaluations)
}
```

- [ ] **Step 5: Make sort selection throw and revert**

Replace `selectSort(_:)` with:

```swift
func selectSort(_ sort: EvaluationSort) async throws {
    guard case .loaded(let previousEvaluations) = loadState,
        selectedSort != sort
    else { return }

    let previousSort = selectedSort
    let previousCursor = cursor
    let previousCanLoadMore = canLoadMore
    let previousFirstPageRequestID = firstPageRequestID

    selectedSort = sort
    let requestID = nextFirstPageRequestID()
    loadState = .loading
    cursor = nil
    canLoadMore = true
    isLoadingMore = false

    do {
        let page = try await useCase.loadEvaluations(sort: sort, cursor: nil)
        guard selectedSort == sort,
            firstPageRequestID == requestID
        else { return }
        cursor = page.cursor
        canLoadMore = !page.isLast
        loadState = .loaded(page.evaluations)
    } catch {
        guard selectedSort == sort,
            firstPageRequestID == requestID
        else { return }
        selectedSort = previousSort
        loadState = .loaded(previousEvaluations)
        cursor = previousCursor
        canLoadMore = previousCanLoadMore
        isLoadingMore = false
        firstPageRequestID = previousFirstPageRequestID
        throw error
    }
}
```

- [ ] **Step 6: Replace pagination method**

Replace `loadMoreIfNeeded(current:)` and delete `retryLoadMore()`:

```swift
func loadMoreIfNeeded(current evaluation: LectureEvaluation) async {
    let currentEvaluations = loadedEvaluations
    guard canLoadMore,
        !isLoadingMore,
        currentEvaluations.suffix(5).contains(where: { $0.id == evaluation.id })
    else { return }

    let requestedSort = selectedSort
    let requestedCursor = cursor
    let requestID = firstPageRequestID

    isLoadingMore = true
    defer {
        isLoadingMore = false
    }

    do {
        let page = try await useCase.loadEvaluations(
            sort: requestedSort,
            cursor: requestedCursor
        )
        guard selectedSort == requestedSort,
            cursor == requestedCursor,
            firstPageRequestID == requestID
        else { return }

        let mergedEvaluations = (loadedEvaluations + page.evaluations).removingDuplicateIDs()
        cursor = page.cursor
        canLoadMore = !page.isLast
        loadState = .loaded(mergedEvaluations)
    } catch {
        // Pagination failures stay visually silent; a later bottom-near trigger retries.
    }
}
```

- [ ] **Step 7: Add local duplicate filtering**

At the bottom of `EvaluationSeeAllViewModel.swift`, add:

```swift
extension Array where Element == LectureEvaluation {
    fileprivate func removingDuplicateIDs() -> [LectureEvaluation] {
        var seenIDs = Set<EvaluationID>()
        return filter { seenIDs.insert($0.id).inserted }
    }
}
```

- [ ] **Step 8: Run focused compile feedback**

Run:

```bash
tuist build Evaluations
```

Expected: scene and test compile errors remain until later tasks update UI and existing expectations.

---

### Task 3: Extract Home Section Components

**Files:**
- Create: `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationHomeSectionLink.swift`
- Create: `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationMainFeedSection.swift`
- Create: `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationTakenLectureSection.swift`

- [ ] **Step 1: Create section link component**

Create `EvaluationHomeSectionLink.swift`:

```swift
//
//  EvaluationHomeSectionLink.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct EvaluationHomeSectionLink: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 20)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.animatable())
    }
}
```

- [ ] **Step 2: Create main feed section**

Create `EvaluationMainFeedSection.swift`:

```swift
//
//  EvaluationMainFeedSection.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EvaluationMainFeedSection: View {
    enum Mode: Equatable {
        case loading
        case loaded(
            feed: EvaluationFeedContent,
            selectedSort: EvaluationSort,
            availableSorts: [EvaluationSort]
        )

        var isLoading: Bool {
            if case .loading = self { true } else { false }
        }
    }

    let mode: Mode
    let onSelectSort: (EvaluationSort) -> Void
    let onSelectEvaluation: (EvaluationID) -> Void
    let onOpenSeeAll: () -> Void

    private var feed: EvaluationFeedContent {
        switch mode {
        case .loading:
            .placeholder
        case .loaded(let feed, _, _):
            feed
        }
    }

    private var selectedSort: EvaluationSort {
        switch mode {
        case .loading:
            .placeholderRecommended
        case .loaded(_, let selectedSort, _):
            selectedSort
        }
    }

    private var availableSorts: [EvaluationSort] {
        switch mode {
        case .loading:
            [.placeholderRecommended, .placeholderLatest]
        case .loaded(_, _, let availableSorts):
            availableSorts
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EvaluationSortToggle(
                sorts: availableSorts,
                selectedSort: selectedSort,
                onSelect: onSelectSort
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            evaluationList
                .animation(.defaultSpring, value: feed.previewEvaluationIDs)

            EvaluationHomeSectionLink(title: "강의평 전체보기", action: onOpenSeeAll)
                .padding(.top, 8)
        }
        .redacted(reason: mode.isLoading ? .placeholder : [])
    }

    @ViewBuilder
    private var evaluationList: some View {
        if !mode.isLoading, feed.evaluations.isEmpty {
            emptyRow("아직 등록된 강의평이 없습니다.")
                .padding(.horizontal, 20)
        } else {
            ForEach(feed.previewEvaluations) { evaluation in
                LectureEvaluationCell(
                    evaluation: evaluation,
                    onTap: {
                        onSelectEvaluation(evaluation.id)
                    }
                )
                .padding(.horizontal, 20)

                Divider()
                    .padding(.leading, 20)
            }
        }
    }

    private func emptyRow(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 18)
    }
}

extension EvaluationFeedContent {
    fileprivate var previewEvaluations: [LectureEvaluation] {
        Array(evaluations.prefix(5))
    }

    fileprivate var previewEvaluationIDs: [EvaluationID] {
        previewEvaluations.map(\.id)
    }
}
```

- [ ] **Step 3: Create taken lecture section**

Create `EvaluationTakenLectureSection.swift`:

```swift
//
//  EvaluationTakenLectureSection.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct EvaluationTakenLectureSection: View {
    enum Mode: Equatable {
        case loading
        case loaded(TakenLectureFeedContent)

        var isLoading: Bool {
            if case .loading = self { true } else { false }
        }
    }

    let mode: Mode
    let onOpenMyEvaluations: () -> Void
    let onSelectLecture: (EvaluationLectureID) -> Void
    let onWriteEvaluation: (EvaluationLectureID) -> Void

    private var feed: TakenLectureFeedContent {
        switch mode {
        case .loading:
            .placeholder
        case .loaded(let feed):
            feed
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ForEach(feed.lectures) { lecture in
                TakenLectureCell(
                    lecture: lecture,
                    onTap: {
                        onSelectLecture(lecture.id)
                    },
                    onWrite: {
                        onWriteEvaluation(lecture.id)
                    }
                )
                .padding(.horizontal, 20)

                Divider()
                    .padding(.leading, 20)
            }
        }
        .redacted(reason: mode.isLoading ? .placeholder : [])
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(feed.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 8)

            Button {
                onOpenMyEvaluations()
            } label: {
                HStack(spacing: 4) {
                    Text("나의 강의평")
                        .font(.system(size: 14, weight: .medium))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.secondary)
                .contentShape(Rectangle())
            }
            .buttonStyle(.animatable())
        }
        .padding(.horizontal, 20)
        .frame(height: 54)
        .background(Color.accentColor.opacity(0.07))
    }
}

extension TakenLectureFeedContent {
    fileprivate var title: String {
        "\(takenQuarter.year % 100)년 \(takenQuarter.semester.rawValue)학기 수강한 강의"
    }
}
```

- [ ] **Step 4: Run project generation**

Run:

```bash
tuist generate --no-open
```

Expected: project generation succeeds and new component files are included.

---

### Task 4: Add Preview Fixtures And Section Previews

**Files:**
- Create: `Modules/Feature/Evaluations/Sources/UI/Preview/EvaluationPreviewFixtures.swift`
- Modify: `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationMainFeedSection.swift`
- Modify: `Modules/Feature/Evaluations/Sources/UI/Components/EvaluationTakenLectureSection.swift`

- [ ] **Step 1: Create preview fixtures**

Create `EvaluationPreviewFixtures.swift`:

```swift
//
//  EvaluationPreviewFixtures.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import TimetableInterface

enum EvaluationPreviewFixtures {
    static let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
    static let latestSort = EvaluationSort(id: 2, kind: .latest)
    static let sorts = [recommendedSort, latestSort]

    static let homeContent = EvaluationHomeContent(
        selectedSort: recommendedSort,
        availableSorts: sorts,
        mainFeed: EvaluationFeedContent(
            evaluations: evaluations,
            cursor: "preview-next",
            canLoadMore: true
        ),
        takenLectureFeed: takenLectureFeed
    )

    static let evaluations: [LectureEvaluation] = [
        lectureEvaluation(
            id: 1,
            lectureID: 101,
            title: "컴퓨터의 개념 및 실습",
            instructor: "김교수",
            rating: 4.5,
            content: "실습이 많아서 시간이 들지만 수업 내용을 이해하는 데 도움이 됩니다.",
            likeCount: 12,
            isLiked: true
        ),
        lectureEvaluation(
            id: 2,
            lectureID: 102,
            title: "자료구조",
            instructor: "이교수",
            rating: 4.0,
            content: "과제 난이도는 있는 편이지만 설명이 명확하고 시험 범위가 예측 가능합니다.",
            likeCount: 7,
            isLiked: false
        ),
        lectureEvaluation(
            id: 3,
            lectureID: 103,
            title: "인공지능의 이해",
            instructor: "박교수",
            rating: 4.8,
            content: "프로젝트 중심으로 진행되어 팀 활동과 발표가 많습니다.",
            likeCount: 24,
            isLiked: true
        ),
    ]

    static let takenLectureFeed = TakenLectureFeedContent(
        takenQuarter: Quarter(year: 2025, semester: .first),
        lectures: [
            takenLecture(
                lectureID: 201,
                title: "컴퓨터 네트워크",
                instructor: "최교수"
            ),
            takenLecture(
                lectureID: 202,
                title: "운영체제",
                instructor: "정교수"
            ),
        ]
    )

    static var placeholderFeed: EvaluationFeedContent {
        EvaluationFeedContent(
            evaluations: [
                lectureEvaluation(
                    id: -1,
                    lectureID: -101,
                    title: "컴퓨터의 개념 및 실습",
                    instructor: "김교수",
                    rating: 4.5,
                    content: "과제가 실습 위주라 시간이 조금 걸리지만 수업 내용을 이해하는 데 도움이 됩니다.",
                    likeCount: 12,
                    isLiked: true
                ),
                lectureEvaluation(
                    id: -2,
                    lectureID: -102,
                    title: "자료구조와 알고리즘",
                    instructor: "이교수",
                    rating: 4.0,
                    content: "수업 자료가 잘 정리되어 있고 예제가 충분해 따라가기 좋습니다.",
                    likeCount: 8,
                    isLiked: false
                ),
                lectureEvaluation(
                    id: -3,
                    lectureID: -103,
                    title: "인공지능의 이해",
                    instructor: "박교수",
                    rating: 4.8,
                    content: "프로젝트 중심으로 진행되어 실제 적용 경험을 쌓을 수 있습니다.",
                    likeCount: 20,
                    isLiked: true
                ),
            ],
            cursor: nil,
            canLoadMore: false
        )
    }

    static var placeholderTakenLectureFeed: TakenLectureFeedContent {
        TakenLectureFeedContent(
            takenQuarter: Quarter(year: 2025, semester: .first),
            lectures: [
                takenLecture(
                    lectureID: -201,
                    title: "컴퓨터 네트워크",
                    instructor: "최교수"
                ),
                takenLecture(
                    lectureID: -202,
                    title: "운영체제",
                    instructor: "정교수"
                ),
            ]
        )
    }

    private static func lectureEvaluation(
        id: EvaluationID,
        lectureID: EvaluationLectureID,
        title: String,
        instructor: String,
        rating: Double,
        content: String,
        likeCount: Int,
        isLiked: Bool
    ) -> LectureEvaluation {
        LectureEvaluation(
            id: id,
            lecture: EvaluationLectureBrief(
                id: lectureID,
                title: title,
                instructor: instructor
            ),
            rating: rating,
            content: content,
            year: 2025,
            semester: 1,
            likeCount: likeCount,
            isLiked: isLiked,
            isReportable: true
        )
    }

    private static func takenLecture(
        lectureID: EvaluationLectureID,
        title: String,
        instructor: String
    ) -> TakenLectureSummary {
        TakenLectureSummary(
            lecture: EvaluationLectureBrief(
                id: lectureID,
                title: title,
                instructor: instructor
            ),
            department: "컴퓨터공학부",
            courseNumber: "M1522.000100",
            credit: 3,
            academicYear: "3",
            classification: "전공선택",
            takenQuarter: Quarter(year: 2025, semester: .first)
        )
    }
}

extension EvaluationSort {
    static var placeholderRecommended: Self {
        EvaluationPreviewFixtures.recommendedSort
    }

    static var placeholderLatest: Self {
        EvaluationPreviewFixtures.latestSort
    }
}

extension EvaluationFeedContent {
    static var placeholder: Self {
        EvaluationPreviewFixtures.placeholderFeed
    }
}

extension TakenLectureFeedContent {
    static var placeholder: Self {
        EvaluationPreviewFixtures.placeholderTakenLectureFeed
    }
}
```

- [ ] **Step 2: Add main feed previews**

At the bottom of `EvaluationMainFeedSection.swift`, add:

```swift
#Preview("Main Feed Loading") {
    EvaluationMainFeedSection(
        mode: .loading,
        onSelectSort: { _ in },
        onSelectEvaluation: { _ in },
        onOpenSeeAll: {}
    )
    .background(Color(uiColor: .systemBackground))
}

#Preview("Main Feed Loaded") {
    EvaluationMainFeedSection(
        mode: .loaded(
            feed: EvaluationPreviewFixtures.homeContent.mainFeed,
            selectedSort: EvaluationPreviewFixtures.homeContent.selectedSort,
            availableSorts: EvaluationPreviewFixtures.homeContent.availableSorts
        ),
        onSelectSort: { _ in },
        onSelectEvaluation: { _ in },
        onOpenSeeAll: {}
    )
    .background(Color(uiColor: .systemBackground))
}
```

- [ ] **Step 3: Add taken lecture previews**

At the bottom of `EvaluationTakenLectureSection.swift`, add:

```swift
#Preview("Taken Lecture Loading") {
    EvaluationTakenLectureSection(
        mode: .loading,
        onOpenMyEvaluations: {},
        onSelectLecture: { _ in },
        onWriteEvaluation: { _ in }
    )
    .background(Color(uiColor: .systemBackground))
}

#Preview("Taken Lecture Loaded") {
    EvaluationTakenLectureSection(
        mode: .loaded(EvaluationPreviewFixtures.takenLectureFeed),
        onOpenMyEvaluations: {},
        onSelectLecture: { _ in },
        onWriteEvaluation: { _ in }
    )
    .background(Color(uiColor: .systemBackground))
}
```

- [ ] **Step 4: Generate project after new files**

Run:

```bash
tuist generate --no-open
```

Expected: generation succeeds.

---

### Task 5: Refactor Evaluation Home Scene

**Files:**
- Modify: `Modules/Feature/Evaluations/Sources/UI/EvaluationHomeScene.swift`

- [ ] **Step 1: Add alert environment**

Add below the `@State` property:

```swift
@Environment(\.errorAlertHandler) private var errorAlertHandler
```

- [ ] **Step 2: Wrap initial load in alert handler**

Replace:

```swift
.onLoad {
    await viewModel.load()
}
```

with:

```swift
.onLoad {
    await errorAlertHandler.withAlert {
        try await viewModel.load()
    }
}
```

- [ ] **Step 3: Replace content state switch**

Replace `content` with:

```swift
@ViewBuilder
private var content: some View {
    switch viewModel.homeState {
    case .loading:
        scrollContent(homeContent: nil)

    case .loaded(let state):
        scrollContent(homeContent: state)
    }
}
```

- [ ] **Step 4: Replace loaded content with shared scroll content**

Delete `loadedContent(_:)`, `mainEvaluationList(_:)`, `takenLectureSection(_:)`, `sectionLink(_:action:)`, and `emptyRow(_:)`.

Add:

```swift
private func scrollContent(homeContent: EvaluationHomeContent?) -> some View {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            EvaluationSearchEntryView(
                onSearch: viewModel.openSearch,
                onFilter: viewModel.openFilter
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 22)

            mainFeedSection(homeContent: homeContent)

            takenLectureSection(homeContent: homeContent)
        }
        .animation(.defaultSpring, value: homeContent?.selectedSort)
    }
    .withResponsiveTouch()
    .background(Color(uiColor: .systemBackground))
    .refreshable {
        await errorAlertHandler.withAlert {
            if homeContent == nil {
                try await viewModel.load()
            } else {
                try await viewModel.refresh()
            }
        }
    }
}
```

- [ ] **Step 5: Add section builder helpers**

Add below `scrollContent(homeContent:)`:

```swift
private func mainFeedSection(homeContent: EvaluationHomeContent?) -> some View {
    EvaluationMainFeedSection(
        mode: mainFeedMode(homeContent: homeContent),
        onSelectSort: { sort in
            errorAlertHandler.withAlert {
                try await viewModel.selectSort(sort)
            }
        },
        onSelectEvaluation: viewModel.openEvaluationDetail,
        onOpenSeeAll: {
            let sort = homeContent?.selectedSort.kind ?? .recommended
            viewModel.openAllEvaluations(sort: sort)
        }
    )
}

@ViewBuilder
private func takenLectureSection(homeContent: EvaluationHomeContent?) -> some View {
    switch takenLectureMode(homeContent: homeContent) {
    case nil:
        EmptyView()
    case let mode?:
        EvaluationTakenLectureSection(
            mode: mode,
            onOpenMyEvaluations: viewModel.openMyEvaluations,
            onSelectLecture: viewModel.openLectureDetail,
            onWriteEvaluation: viewModel.openWriteEvaluation
        )
        .padding(.top, 18)
    }
}

private func mainFeedMode(homeContent: EvaluationHomeContent?) -> EvaluationMainFeedSection.Mode {
    guard let homeContent else {
        return .loading
    }
    return .loaded(
        feed: homeContent.mainFeed,
        selectedSort: homeContent.selectedSort,
        availableSorts: homeContent.availableSorts
    )
}

private func takenLectureMode(homeContent: EvaluationHomeContent?) -> EvaluationTakenLectureSection.Mode? {
    guard let homeContent else {
        return .loading
    }
    guard let feed = homeContent.takenLectureFeed else {
        return nil
    }
    return .loaded(feed)
}
```

- [ ] **Step 6: Remove moved extensions**

Remove these extensions from `EvaluationHomeScene.swift` because they now live with components:

```swift
extension EvaluationFeedContent {
    fileprivate var previewEvaluations: [LectureEvaluation] {
        Array(evaluations.prefix(5))
    }

    fileprivate var previewEvaluationIDs: [EvaluationID] {
        previewEvaluations.map(\.id)
    }
}

extension TakenLectureFeedContent {
    fileprivate var title: String {
        "\(takenQuarter.year % 100)년 \(takenQuarter.semester.rawValue)학기 수강한 강의"
    }
}
```

- [ ] **Step 7: Add home previews**

Replace the existing preview with:

```swift
#Preview("Loading") {
    NavigationStack {
        EvaluationHomeScene.PreviewContent(homeContent: nil)
            .navigationTitle("강의평")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Loaded") {
    NavigationStack {
        EvaluationHomeScene.PreviewContent(homeContent: EvaluationPreviewFixtures.homeContent)
            .navigationTitle("강의평")
            .navigationBarTitleDisplayMode(.inline)
    }
}
```

Add a private preview helper inside `EvaluationHomeScene`:

```swift
#if DEBUG
extension EvaluationHomeScene {
    struct PreviewContent: View {
        let homeContent: EvaluationHomeContent?

        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    EvaluationSearchEntryView(
                        onSearch: {},
                        onFilter: {}
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 22)

                    EvaluationMainFeedSection(
                        mode: mainFeedMode,
                        onSelectSort: { _ in },
                        onSelectEvaluation: { _ in },
                        onOpenSeeAll: {}
                    )

                    if let takenLectureMode {
                        EvaluationTakenLectureSection(
                            mode: takenLectureMode,
                            onOpenMyEvaluations: {},
                            onSelectLecture: { _ in },
                            onWriteEvaluation: { _ in }
                        )
                        .padding(.top, 18)
                    }
                }
            }
            .withResponsiveTouch()
            .background(Color(uiColor: .systemBackground))
        }

        private var mainFeedMode: EvaluationMainFeedSection.Mode {
            guard let homeContent else {
                return .loading
            }
            return .loaded(
                feed: homeContent.mainFeed,
                selectedSort: homeContent.selectedSort,
                availableSorts: homeContent.availableSorts
            )
        }

        private var takenLectureMode: EvaluationTakenLectureSection.Mode? {
            guard let homeContent else {
                return .loading
            }
            guard let feed = homeContent.takenLectureFeed else {
                return nil
            }
            return .loaded(feed)
        }
    }
}
#endif
```

- [ ] **Step 8: Run compile feedback**

Run:

```bash
tuist build Evaluations
```

Expected: remaining errors are primarily in `EvaluationSeeAllScene.swift` and tests.

---

### Task 6: Refactor Evaluation See-All Scene

**Files:**
- Modify: `Modules/Feature/Evaluations/Sources/UI/EvaluationSeeAllScene.swift`

- [ ] **Step 1: Add alert environment**

Add below `@State private var viewModel`:

```swift
@Environment(\.errorAlertHandler) private var errorAlertHandler
```

- [ ] **Step 2: Wrap initial load**

Replace:

```swift
.onLoad {
    await viewModel.load()
}
```

with:

```swift
.onLoad {
    await errorAlertHandler.withAlert {
        try await viewModel.load()
    }
}
```

- [ ] **Step 3: Replace content switch**

Replace `content` with:

```swift
@ViewBuilder
private var content: some View {
    switch viewModel.loadState {
    case .loading:
        loadingContent

    case .loaded(let evaluations):
        loadedContent(evaluations)
    }
}
```

- [ ] **Step 4: Add refreshable loading surface**

Add:

```swift
private var loadingContent: some View {
    ScrollView {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.top, 120)
    }
    .refreshable {
        await errorAlertHandler.withAlert {
            try await viewModel.load()
        }
    }
}
```

- [ ] **Step 5: Make loaded content accept payload**

Replace `private var loadedContent: some View` with:

```swift
private func loadedContent(_ evaluations: [LectureEvaluation]) -> some View {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            EvaluationSortToggle(
                sorts: viewModel.availableSorts,
                selectedSort: viewModel.selectedSort,
                onSelect: { sort in
                    errorAlertHandler.withAlert {
                        try await viewModel.selectSort(sort)
                    }
                }
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            if evaluations.isEmpty {
                emptyRow("아직 등록된 강의평이 없습니다.")
                    .padding(.horizontal, 20)
            } else {
                ForEach(evaluations) { evaluation in
                    LectureEvaluationCell(
                        evaluation: evaluation,
                        onTap: {
                            onSelectEvaluation(evaluation.id)
                        }
                    )
                    .padding(.horizontal, 20)
                    .onAppear {
                        Task {
                            await viewModel.loadMoreIfNeeded(current: evaluation)
                        }
                    }

                    Divider()
                        .padding(.leading, 20)
                }
            }
        }
    }
    .withResponsiveTouch()
    .refreshable {
        await errorAlertHandler.withAlert {
            try await viewModel.refresh()
        }
    }
    .animation(.defaultSpring, value: viewModel.selectedSort)
    .animation(.defaultSpring, value: evaluations.map(\.id))
}
```

- [ ] **Step 6: Delete pagination footer**

Delete the entire `paginationFooter` property and remove references to it.

- [ ] **Step 7: Update preview**

Replace the existing preview with:

```swift
#Preview("See All") {
    EvaluationSeeAllScene(
        initialSortKind: .recommended,
        availableSorts: EvaluationPreviewFixtures.sorts,
        onSelectEvaluation: { _ in }
    )
}
```

- [ ] **Step 8: Run compile feedback**

Run:

```bash
tuist build Evaluations
```

Expected: remaining errors are existing tests that refer to removed `.failed`, `paginationState`, `evaluations`, or non-throwing methods.

---

### Task 7: Update Existing Tests For New API Shape

**Files:**
- Modify: `Modules/Feature/Evaluations/Tests/EvaluationsTests.swift`

- [ ] **Step 1: Update home load call sites**

Replace:

```swift
await viewModel.load()
```

with:

```swift
try await viewModel.load()
```

inside async throwing tests. In non-throwing test functions, either make the test `async throws` or keep only navigation-only tests unchanged.

- [ ] **Step 2: Update home sort call sites**

Replace:

```swift
await viewModel.selectSort(latestSort)
```

with:

```swift
try await viewModel.selectSort(latestSort)
```

For `Task` bodies that call `selectSort`, use:

```swift
let latestTask = Task {
    try await viewModel.selectSort(latestSort)
}
```

and await:

```swift
try await latestTask.value
```

- [ ] **Step 3: Update see-all load and sort call sites**

Replace:

```swift
await viewModel.load()
await viewModel.selectSort(latestSort)
```

with:

```swift
try await viewModel.load()
try await viewModel.selectSort(latestSort)
```

- [ ] **Step 4: Replace direct `evaluations` assertions**

Replace:

```swift
#expect(viewModel.evaluations == [evaluation])
```

with:

```swift
#expect(viewModel.loadedEvaluations == [evaluation])
```

Apply the same replacement to all `viewModel.evaluations` assertions.

- [ ] **Step 5: Remove visible pagination failure expectation**

Delete or rewrite the test named `loadMoreFailureKeepsExistingEvaluations` because pagination failure is now visually silent and not represented by `paginationState`.

If keeping the test as an API-shape regression check, replace its final assertion:

```swift
#expect(viewModel.paginationState == .failed("강의평을 불러오지 못했습니다."))
```

with:

```swift
#expect(viewModel.loadedEvaluations == [firstEvaluation])
```

Do not add a new test for invisible failure unless implementation exposes a public state that needs verification.

- [ ] **Step 6: Run tests or module build**

Run:

```bash
tuist build Evaluations
```

Expected: build succeeds or surfaces only formatting/style issues.

---

### Task 8: Final Verification And Formatting

**Files:**
- Verify all files touched in prior tasks.

- [ ] **Step 1: Generate project if new files were added**

Run:

```bash
tuist generate --no-open
```

Expected: generation succeeds.

- [ ] **Step 2: Build Evaluations**

Run:

```bash
tuist build Evaluations
```

Expected: build succeeds.

- [ ] **Step 3: Format if needed**

Run:

```bash
just format
```

Expected: formatting completes. If it changes files, inspect the diff before finalizing.

- [ ] **Step 4: Inspect previews manually**

Open Xcode previews for:

- `EvaluationHomeScene` preview named `Loading`
- `EvaluationHomeScene` preview named `Loaded`
- `EvaluationMainFeedSection` previews named `Main Feed Loading` and `Main Feed Loaded`
- `EvaluationTakenLectureSection` previews named `Taken Lecture Loading` and `Taken Lecture Loaded`

Expected:

- Loading previews show redacted skeleton rows in the final layout shape.
- Loaded previews show real Korean fixture content.
- See-all list has no pagination footer UI.

- [ ] **Step 5: Review git diff**

Run:

```bash
git diff -- Modules/Feature/Evaluations docs/superpowers/specs docs/superpowers/plans
```

Expected: changes are limited to Evaluations refactor files, this implementation plan, and the already-approved design document.

---

## Self-Review

- Spec coverage: The plan covers home skeleton structure, section extraction, redacted loading, alert-driven explicit failures, pull-to-refresh retry, see-all single source of truth, invisible pagination following lecture search, `EvaluationError: LocalizedError`, no new tests by default, module build verification, and loading/loaded previews.
- Placeholder scan: The plan contains no placeholder markers or unspecified “handle later” tasks.
- Type consistency: `LoadState` has only `.loading` and `.loaded(Value)` after Task 1. `EvaluationSeeAllViewModel.loadedEvaluations` is the only public helper for visible list reads. Pagination render state is removed.
