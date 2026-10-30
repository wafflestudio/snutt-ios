import Dependencies
import Foundation
import Testing
import TimetableInterface

@testable import Evaluations

// MARK: - Domain

@Suite struct EvaluationDomainTests {
    @Test func draftRequiresEveryFieldBeforeSubmission() {
        var draft = EvaluationDraft()
        #expect(draft.submission == nil)

        draft.semesterLectureID = 10
        draft.rating = 4.5
        draft.scores = [.gradeSatisfaction: 3, .teachingSkill: 4, .gains: 5]
        draft.content = String(repeating: "가", count: EvaluationDraft.minimumContentLength)
        #expect(draft.submission == nil)

        draft.scores[.lifeBalance] = 2.5
        let submission = try? #require(draft.submission)
        #expect(submission?.semesterLectureID == 10)
        #expect(submission?.scores.lifeBalance == 2.5)
    }

    @Test func draftCountsContentWithoutSurroundingWhitespace() {
        var draft = EvaluationDraft()
        draft.content = "   " + String(repeating: "a", count: EvaluationDraft.minimumContentLength - 1) + "\n\n"
        #expect(!draft.meetsMinimumContentLength)
        draft.content += "b"
        #expect(draft.meetsMinimumContentLength)
    }

    @Test func likeToggleAdjustsCount() {
        let like = EvaluationLike(count: 3, isLiked: false)
        #expect(like.toggled() == EvaluationLike(count: 4, isLiked: true))
        #expect(like.toggled().toggled() == like)
        #expect(EvaluationLike(count: 0, isLiked: true).toggled().count == 0)
    }

    @Test func pagedContentAppendsWithoutDuplicates() {
        let first = LectureEvaluation.stub(id: 1)
        let second = LectureEvaluation.stub(id: 2)
        let content = PagedContent(CursorPage(items: [first], nextCursor: "a"))
            .appending(CursorPage(items: [first, second], nextCursor: nil))

        #expect(content.items.map(\.id) == [1, 2])
        #expect(!content.canLoadMore)
    }

    @Test func searchQueryNeedsTextOrTags() {
        #expect(!LectureSearchQuery(text: "  ", tags: []).isSearchable)
        #expect(LectureSearchQuery(text: "인공지능", tags: []).isSearchable)
        #expect(LectureSearchQuery(text: "", tags: [SearchTag(id: 6, name: "1학년")]).isSearchable)
    }
}

// MARK: - Use Case

@Suite struct EvaluationHomeUseCaseTests {
    @Test func loadHomeUsesRecommendedFeedAndGroupsTakenLectures() async throws {
        let repository = StubEvaluationRepository(
            takenLectures: [
                .stub(id: 1, quarter: Quarter(year: 2025, semester: .first)),
                .stub(id: 2, quarter: Quarter(year: 2025, semester: .second)),
                .stub(id: 3, quarter: Quarter(year: 2025, semester: .first)),
            ],
            averageRatings: [1: 4.5],
            myEvaluations: [2: [.stub(id: 20, lectureID: 2)]]
        )

        let home = try await EvaluationHomeUseCase(repository: repository).loadHome()

        #expect(home.selectedSort.kind == .recommended)
        #expect(home.availableSorts.map(\.kind) == [.recommended, .latest])
        #expect(home.mainFeed == repository.feeds[.recommended])
        #expect(
            home.takenLectureGroups.map(\.quarter) == [
                Quarter(year: 2025, semester: .second), Quarter(year: 2025, semester: .first),
            ]
        )
        #expect(home.takenLectureGroups[1].lectures.map(\.id) == [1, 3])
        #expect(home.takenLectureGroups[1].lectures[0].averageRating == 4.5)
        #expect(home.takenLectureGroups[0].lectures[0].myEvaluations.map(\.id) == [20])
    }

    @Test func loadHomeFailsWithoutRequiredSorts() async {
        let repository = StubEvaluationRepository(sorts: [EvaluationSort(id: 1, kind: .latest)])

        await #expect(throws: EvaluationError.missingRequiredSort) {
            try await EvaluationHomeUseCase(repository: repository).loadHome()
        }
    }
}

// MARK: - View Models

@MainActor
@Suite struct EvaluationHomeViewModelTests {
    @Test func selectSortReplacesFeed() async throws {
        let repository = StubEvaluationRepository()
        let viewModel = withDependencies {
            $0.evaluationRepository = repository
        } operation: {
            EvaluationHomeViewModel()
        }
        try await viewModel.load()
        let latestSort = try #require(viewModel.homeState.value?.availableSorts.last)

        try await viewModel.selectSort(latestSort)

        #expect(viewModel.homeState.value?.selectedSort == latestSort)
        #expect(viewModel.homeState.value?.mainFeed == repository.feeds[.latest])
    }

    @Test func selectSortRollsBackOnFailure() async throws {
        let repository = StubEvaluationRepository()
        let viewModel = withDependencies {
            $0.evaluationRepository = repository
        } operation: {
            EvaluationHomeViewModel()
        }
        try await viewModel.load()
        let previousContent = try #require(viewModel.homeState.value)
        repository.failingSortKinds.setValue([.latest])

        await #expect(throws: StubError.self) {
            try await viewModel.selectSort(previousContent.availableSorts[1])
        }
        #expect(viewModel.homeState.value == previousContent)
    }

    @Test func toggleLikeUpdatesOptimisticallyAndRollsBackOnFailure() async throws {
        let repository = StubEvaluationRepository()
        let viewModel = withDependencies {
            $0.evaluationRepository = repository
        } operation: {
            EvaluationHomeViewModel()
        }
        try await viewModel.load()
        let evaluation = try #require(viewModel.homeState.value?.mainFeed.first?.evaluation)

        try await viewModel.toggleLike(evaluation)
        #expect(viewModel.homeState.value?.mainFeed.first?.evaluation.like == evaluation.like.toggled())
        #expect(repository.likeRequests.value == [LikeRequest(id: evaluation.id, isLiked: true)])

        repository.failsLike.setValue(true)
        let likedEvaluation = try #require(viewModel.homeState.value?.mainFeed.first?.evaluation)
        await #expect(throws: StubError.self) {
            try await viewModel.toggleLike(likedEvaluation)
        }
        #expect(viewModel.homeState.value?.mainFeed.first?.evaluation.like == likedEvaluation.like)
    }

    @Test func createdEvaluationOpensHighlightedLectureDetail() async throws {
        let viewModel = withDependencies {
            $0.evaluationRepository = StubEvaluationRepository()
        } operation: {
            EvaluationHomeViewModel()
        }
        try await viewModel.load()

        try await viewModel.didCreateEvaluation(99, for: 7)

        #expect(viewModel.path == [.lectureDetail(7, highlighting: 99)])
    }
}

@MainActor
@Suite struct EvaluationSearchViewModelTests {
    @Test func searchLoadsResultsAndResetsWhenQueryIsCleared() async throws {
        let viewModel = makeViewModel(store: StubFilterStore())
        viewModel.queryText = "인공지능"

        try await viewModel.search()
        guard case .loaded(let results) = viewModel.resultState else {
            Issue.record("Expected loaded results")
            return
        }
        #expect(results.query.text == "인공지능")
        #expect(results.nextPage == 1)

        viewModel.queryText = ""
        #expect(viewModel.resultState == .idle)
    }

    @Test func applyingFiltersPersistsAndSearches() async throws {
        let store = StubFilterStore()
        let viewModel = makeViewModel(store: store)
        let tag = SearchTag(id: 25, name: "3학점")

        try await viewModel.applyFilterTags([tag])

        #expect(viewModel.isPresented)
        #expect(store.tags.value == [tag])
        guard case .loaded(let results) = viewModel.resultState else {
            Issue.record("Expected loaded results")
            return
        }
        #expect(results.query.tags == [tag])
    }

    @Test func restoresPersistedFilters() {
        let tag = SearchTag(id: 6, name: "1학년")
        let viewModel = makeViewModel(store: StubFilterStore(tags: [tag]))
        #expect(viewModel.filterTags == [tag])
    }

    private func makeViewModel(store: StubFilterStore) -> EvaluationSearchViewModel {
        withDependencies {
            $0.evaluationRepository = StubEvaluationRepository()
            $0.evaluationSearchFilterStore = store
        } operation: {
            EvaluationSearchViewModel()
        }
    }
}

@MainActor
@Suite struct EvaluationWriteViewModelTests {
    @Test func loadSelectsMostRecentWritableSemester() async throws {
        let viewModel = withDependencies {
            $0.evaluationRepository = StubEvaluationRepository()
        } operation: {
            EvaluationWriteViewModel(lectureID: 1)
        }

        try await viewModel.load()

        #expect(viewModel.draft.semesterLectureID == 2)
        #expect(!viewModel.canSubmit)
    }
}

@MainActor
@Suite struct MyEvaluationsViewModelTests {
    @Test func groupsConsecutiveEvaluationsBySemester() async throws {
        let viewModel = withDependencies {
            $0.evaluationRepository = StubEvaluationRepository(
                myEvaluationFeed: [
                    .stub(id: 1, quarter: Quarter(year: 2025, semester: .second)),
                    .stub(id: 2, quarter: Quarter(year: 2025, semester: .second)),
                    .stub(id: 3, quarter: Quarter(year: 2025, semester: .first)),
                ]
            )
        } operation: {
            MyEvaluationsViewModel()
        }

        try await viewModel.load()

        let sections = try #require(viewModel.sections)
        #expect(sections.map(\.items.count) == [2, 1])
        #expect(
            sections.map(\.quarter) == [
                Quarter(year: 2025, semester: .second), Quarter(year: 2025, semester: .first),
            ]
        )
    }
}

// MARK: - API Mapping

@Suite struct EvaluationAPIMappingTests {
    @Test func decodesSnakeCaseEvaluationFeed() throws {
        let json = """
            {
              "content": [{
                "id": 33931, "user_id": "185189", "content": "좋은 수업",
                "grade_satisfaction": 3.0, "teaching_skill": 4.0, "gains": 5.0, "life_balance": 2.5,
                "rating": 4.0, "like_count": 2, "is_hidden": false, "is_reported": false, "is_liked": true,
                "from_snuev": false, "year": 2026, "semester": 1,
                "lecture": {"id": 49268, "title": "창의적통합설계2 ", "instructor": "Chenglin Fan"},
                "is_modifiable": false, "is_reportable": true
              }],
              "cursor": "next", "last": false, "size": 20
            }
            """
        let response = try JSONDecoder().decode(
            Components.Schemas.CursorPaginationResponseEvaluationWithLectureResponse.self,
            from: Data(json.utf8)
        )

        let page = try response.evaluationPage()
        let item = try #require(page.items.first)

        #expect(page.nextCursor == "next")
        #expect(item.lecture.title == "창의적통합설계2")
        #expect(item.evaluation.quarter == Quarter(year: 2026, semester: .first))
        #expect(item.evaluation.scores?.lifeBalance == 2.5)
        #expect(item.evaluation.like == EvaluationLike(count: 2, isLiked: true))
        #expect(item.evaluation.permissions == .report)
    }

    @Test func lastPageHasNoNextCursor() throws {
        let json = #"{"content": [], "cursor": "ignored", "last": true, "size": 20}"#
        let response = try JSONDecoder().decode(
            Components.Schemas.CursorPaginationResponseEvaluationWithLectureResponse.self,
            from: Data(json.utf8)
        )
        #expect(try response.evaluationPage().nextCursor == nil)
    }

    @Test func legacyEvaluationsWithoutScoresMapToNilScores() throws {
        let json = """
            {
              "id": 1, "user_id": "u", "content": "c", "rating": 3.5, "like_count": 0,
              "is_hidden": false, "is_reported": false, "is_liked": false, "from_snuev": true,
              "year": 2019, "semester": 3, "lecture_id": 7, "is_modifiable": true, "is_reportable": false
            }
            """
        let evaluation = try JSONDecoder().decode(
            Components.Schemas.EvaluationWithSemesterResponse.self,
            from: Data(json.utf8)
        ).lectureEvaluation()

        #expect(evaluation.scores == nil)
        #expect(evaluation.quarter == Quarter(year: 2019, semester: .second))
        #expect(evaluation.permissions == .modify)
    }

    @Test func decodesLectureSummaryWithEvaluationCount() throws {
        let json = """
            {
              "id": 49268, "title": "창의적통합설계2", "instructor": "Chenglin Fan", "department": "컴퓨터공학부",
              "course_number": "M1522.000300", "credit": 3, "academic_year": "4학년", "classification": "전선",
              "evaluation": {
                "avg_grade_satisfaction": 3.0, "avg_teaching_skill": 3.5, "avg_gains": 4.0,
                "avg_life_balance": 2.0, "avg_rating": 4.0, "evaluation_count": 12
              }
            }
            """
        let summary = try JSONDecoder().decode(
            Components.Schemas.LectureEvaluationSummaryResponse.self,
            from: Data(json.utf8)
        ).lectureEvaluationSummary

        #expect(summary.evaluationCount == 12)
        #expect(summary.averageRating == 4.0)
        #expect(summary.averageScores?.teachingSkill == 3.5)
        #expect(summary.info.metadataText == "컴퓨터공학부 · 전선 · \(EvaluationsStrings.lectureCredit(3))")
    }

    @Test func mainTagsMapToSupportedSortsInServerOrder() {
        let group = Components.Schemas.TagGroupDto(
            id: 1,
            name: "main",
            ordering: -1,
            tags: [
                .init(id: 2, name: "추천", ordering: 3),
                .init(id: 1, name: "최신", ordering: 1),
                .init(id: 3, name: "명강", ordering: 4),
            ]
        )
        #expect(
            group.evaluationSorts == [
                EvaluationSort(id: 1, kind: .latest), EvaluationSort(id: 2, kind: .recommended),
            ]
        )
    }
}

// MARK: - Test Doubles

private struct StubError: Error {}

private struct LikeRequest: Equatable {
    let id: EvaluationID
    let isLiked: Bool
}

private final class StubEvaluationRepository: EvaluationRepository, @unchecked Sendable {
    let sorts: [EvaluationSort]
    let feeds: [EvaluationSort.Kind: [EvaluationWithLecture]]
    let takenLectures: [TakenLecture]
    let averageRatings: [EvaluationLectureID: Double]
    let myEvaluations: [EvaluationLectureID: [LectureEvaluation]]
    let myEvaluationFeed: [EvaluationWithLecture]

    let failingSortKinds = LockIsolated<Set<EvaluationSort.Kind>>([])
    let failsLike = LockIsolated(false)
    let likeRequests = LockIsolated<[LikeRequest]>([])

    init(
        sorts: [EvaluationSort] = [EvaluationSort(id: 2, kind: .recommended), EvaluationSort(id: 1, kind: .latest)],
        takenLectures: [TakenLecture] = [],
        averageRatings: [EvaluationLectureID: Double] = [:],
        myEvaluations: [EvaluationLectureID: [LectureEvaluation]] = [:],
        myEvaluationFeed: [EvaluationWithLecture] = []
    ) {
        self.sorts = sorts
        self.feeds = [
            .recommended: [.stub(id: 1), .stub(id: 2)],
            .latest: [.stub(id: 3)],
        ]
        self.takenLectures = takenLectures
        self.averageRatings = averageRatings
        self.myEvaluations = myEvaluations
        self.myEvaluationFeed = myEvaluationFeed
    }

    func fetchMainSorts() async throws -> [EvaluationSort] { sorts }

    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> CursorPage<EvaluationWithLecture> {
        if failingSortKinds.value.contains(sort.kind) { throw StubError() }
        return CursorPage(items: feeds[sort.kind] ?? [], nextCursor: nil)
    }

    func fetchTakenLectures() async throws -> [TakenLecture] { takenLectures }

    func fetchLectureSummary(lectureID: EvaluationLectureID) async throws -> LectureEvaluationSummary {
        LectureEvaluationSummary(
            info: .stub(id: lectureID),
            averageRating: averageRatings[lectureID],
            averageScores: nil,
            evaluationCount: 0
        )
    }

    func fetchLectureEvaluations(
        lectureID: EvaluationLectureID,
        cursor: String?
    ) async throws -> CursorPage<LectureEvaluation> {
        CursorPage(items: [], nextCursor: nil)
    }

    func fetchMyLectureEvaluations(lectureID: EvaluationLectureID) async throws -> [LectureEvaluation] {
        myEvaluations[lectureID] ?? []
    }

    func fetchMyEvaluations(cursor: String?) async throws -> CursorPage<EvaluationWithLecture> {
        CursorPage(items: myEvaluationFeed, nextCursor: nil)
    }

    func fetchSearchTagGroups() async throws -> [SearchTagGroup] { [] }

    func searchLectures(query: LectureSearchQuery, page: Int) async throws -> LectureSearchPage {
        LectureSearchPage(results: [], page: page, isLast: false)
    }

    func fetchWriteTarget(lectureID: EvaluationLectureID) async throws -> EvaluationWriteTarget {
        EvaluationWriteTarget(
            lecture: EvaluationLectureBrief(id: lectureID, title: "강의", instructor: nil),
            semesterLectures: [
                SemesterLecture(id: 3, quarter: Quarter(year: 2026, semester: .first), hasMyEvaluation: true),
                SemesterLecture(id: 2, quarter: Quarter(year: 2025, semester: .second), hasMyEvaluation: false),
            ]
        )
    }

    func createEvaluation(_ submission: EvaluationSubmission) async throws -> EvaluationID { 1 }
    func deleteEvaluation(id: EvaluationID) async throws {}

    func setLiked(_ isLiked: Bool, evaluationID: EvaluationID) async throws {
        if failsLike.value { throw StubError() }
        likeRequests.withValue { $0.append(LikeRequest(id: evaluationID, isLiked: isLiked)) }
    }

    func reportEvaluation(id: EvaluationID, reason: String) async throws {}
}

private struct StubFilterStore: EvaluationSearchFilterStore {
    let tags: LockIsolated<[SearchTag]>

    init(tags: [SearchTag] = []) {
        self.tags = LockIsolated(tags)
    }

    func loadTags() -> [SearchTag] { tags.value }
    func saveTags(_ tags: [SearchTag]) { self.tags.setValue(tags) }
}

extension LectureEvaluation {
    fileprivate static func stub(
        id: EvaluationID,
        lectureID: EvaluationLectureID = 1,
        quarter: Quarter = Quarter(year: 2025, semester: .second)
    ) -> LectureEvaluation {
        LectureEvaluation(
            id: id,
            lectureID: lectureID,
            rating: 4,
            scores: nil,
            content: "내용",
            quarter: quarter,
            like: EvaluationLike(count: 0, isLiked: false),
            permissions: .report
        )
    }
}

extension EvaluationWithLecture {
    fileprivate static func stub(
        id: EvaluationID,
        quarter: Quarter = Quarter(year: 2025, semester: .second)
    ) -> EvaluationWithLecture {
        EvaluationWithLecture(
            evaluation: .stub(id: id, lectureID: EvaluationLectureID(id.rawValue), quarter: quarter),
            lecture: EvaluationLectureBrief(id: EvaluationLectureID(id.rawValue), title: "강의 \(id)", instructor: nil)
        )
    }
}

extension EvaluationLectureInfo {
    fileprivate static func stub(id: EvaluationLectureID) -> EvaluationLectureInfo {
        EvaluationLectureInfo(
            brief: EvaluationLectureBrief(id: id, title: "강의 \(id)", instructor: nil),
            department: nil,
            academicYear: nil,
            classification: nil,
            credit: nil
        )
    }
}

extension TakenLecture {
    fileprivate static func stub(id: EvaluationLectureID, quarter: Quarter) -> TakenLecture {
        TakenLecture(info: .stub(id: id), takenQuarter: quarter, averageRating: nil, myEvaluations: [])
    }
}
