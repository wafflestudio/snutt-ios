import Dependencies
import Foundation
import SwiftUtility
import Testing
import TimetableInterface

@testable import Evaluations

@Suite struct EvaluationHomeUseCaseTests {
    @Test func loadHomeUsesRecommendedFeedAndTakenLectures() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let evaluation = LectureEvaluation.preview()
        let takenLecture = TakenLectureSummary.preview()
        let repository = FakeEvaluationRepository(
            sorts: [latestSort, recommendedSort],
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [evaluation],
                    cursor: "next",
                    isLast: false
                )
            ],
            takenLectures: [takenLecture]
        )
        let useCase = EvaluationHomeUseCase(repository: repository)

        let home = try await useCase.loadHome()

        #expect(home.selectedSort == recommendedSort)
        #expect(home.availableSorts == [recommendedSort, latestSort])
        #expect(home.mainFeed.evaluations == [evaluation])
        #expect(home.mainFeed.cursor == "next")
        #expect(home.mainFeed.canLoadMore)
        #expect(home.takenLectureFeed?.takenQuarter == Quarter(year: 2025, semester: .first))
        #expect(home.takenLectureFeed?.lectures == [takenLecture])
    }

    @Test func loadHomeUsesLatestTakenLectureQuarterAsFeedQuarter() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let oldTakenLecture = TakenLectureSummary.preview(
            lectureID: 10,
            takenQuarter: Quarter(year: 2024, semester: .summer)
        )
        let latestTakenLecture = TakenLectureSummary.preview(
            lectureID: 20,
            takenQuarter: Quarter(year: 2025, semester: .first)
        )
        let repository = FakeEvaluationRepository(
            sorts: [latestSort, recommendedSort],
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [],
                    cursor: nil,
                    isLast: true
                )
            ],
            takenLectures: [oldTakenLecture, latestTakenLecture]
        )
        let useCase = EvaluationHomeUseCase(repository: repository)

        let home = try await useCase.loadHome()

        #expect(home.takenLectureFeed?.takenQuarter == Quarter(year: 2025, semester: .first))
        #expect(home.takenLectureFeed?.lectures == [oldTakenLecture, latestTakenLecture])
    }

    @Test func loadHomeDoesNotCreateTakenLectureFeedWithoutTakenLectures() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let repository = FakeEvaluationRepository(
            sorts: [latestSort, recommendedSort],
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [],
                    cursor: nil,
                    isLast: true
                )
            ],
            takenLectures: []
        )
        let useCase = EvaluationHomeUseCase(repository: repository)

        let home = try await useCase.loadHome()

        #expect(home.takenLectureFeed == nil)
    }

    @Test func loadHomeFailsWithoutRecommendedSort() async throws {
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let repository = FakeEvaluationRepository(sorts: [latestSort])
        let useCase = EvaluationHomeUseCase(repository: repository)

        await #expect(throws: EvaluationError.missingRequiredSort("추천")) {
            try await useCase.loadHome()
        }
    }
}

@MainActor
@Suite struct EvaluationHomeViewModelTests {
    private func makeViewModel(repository: any EvaluationRepository) -> EvaluationHomeViewModel {
        withDependencies {
            $0.evaluationRepository = repository
        } operation: {
            EvaluationHomeViewModel()
        }
    }

    @Test func loadSetsLoadedHomeState() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let evaluation = LectureEvaluation.preview()
        let takenLecture = TakenLectureSummary.preview()
        let repository = FakeEvaluationRepository(
            sorts: [latestSort, recommendedSort],
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [evaluation],
                    cursor: "next",
                    isLast: false
                )
            ],
            takenLectures: [takenLecture]
        )
        let viewModel = makeViewModel(repository: repository)

        try await viewModel.load()

        #expect(
            viewModel.homeState
                == .loaded(
                    .init(
                        selectedSort: recommendedSort,
                        availableSorts: [recommendedSort, latestSort],
                        mainFeed: EvaluationFeedContent(
                            evaluations: [evaluation],
                            cursor: "next",
                            canLoadMore: true
                        ),
                        takenLectureFeed: TakenLectureFeedContent(
                            takenQuarter: Quarter(year: 2025, semester: .first),
                            lectures: [takenLecture]
                        )
                    )
                )
        )
    }

    @Test func selectSortLoadsSelectedFeed() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let recommendedEvaluation = LectureEvaluation.preview(id: 1)
        let latestEvaluation = LectureEvaluation.preview(id: 2)
        let repository = FakeEvaluationRepository(
            sorts: [recommendedSort, latestSort],
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [recommendedEvaluation],
                    cursor: nil,
                    isLast: true
                ),
                EvaluationRequest(sort: latestSort, cursor: nil): EvaluationPage(
                    evaluations: [latestEvaluation],
                    cursor: nil,
                    isLast: true
                ),
            ]
        )
        let viewModel = makeViewModel(repository: repository)
        try await viewModel.load()

        try await viewModel.selectSort(latestSort)

        guard case .loaded(let home) = viewModel.homeState else {
            Issue.record("Expected loaded home state")
            return
        }
        #expect(home.selectedSort == latestSort)
        #expect(home.mainFeed.evaluations == [latestEvaluation])
        #expect(await repository.evaluationRequests.last == EvaluationRequest(sort: latestSort, cursor: nil))
    }

    @Test func selectSortIgnoresStaleResult() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let recommendedEvaluation = LectureEvaluation.preview(id: 1)
        let latestEvaluation = LectureEvaluation.preview(id: 2)
        let repository = FakeEvaluationRepository(
            sorts: [recommendedSort, latestSort],
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [recommendedEvaluation],
                    cursor: nil,
                    isLast: true
                ),
                EvaluationRequest(sort: latestSort, cursor: nil): EvaluationPage(
                    evaluations: [latestEvaluation],
                    cursor: nil,
                    isLast: true
                ),
            ],
            delayedRequests: [
                EvaluationRequest(sort: latestSort, cursor: nil)
            ]
        )
        let viewModel = makeViewModel(repository: repository)
        try await viewModel.load()

        let latestTask = Task { try await viewModel.selectSort(latestSort) }
        try await Task.sleep(for: .milliseconds(20))
        try await viewModel.selectSort(recommendedSort)
        try await latestTask.value

        guard case .loaded(let home) = viewModel.homeState else {
            Issue.record("Expected loaded home state")
            return
        }
        #expect(home.selectedSort == recommendedSort)
        #expect(home.mainFeed.evaluations == [recommendedEvaluation])
    }

    @Test func navigationMethodsAppendDestinations() {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let viewModel = makeViewModel(repository: FakeEvaluationRepository())

        viewModel.openSearch()
        viewModel.openFilter()
        viewModel.openEvaluationDetail(EvaluationID(1))
        viewModel.openLectureDetail(EvaluationLectureID(2))
        viewModel.openWriteEvaluation(EvaluationLectureID(3))
        viewModel.openMyEvaluations()
        viewModel.openAllEvaluations(sort: recommendedSort.kind)

        #expect(
            viewModel.path == [
                .search,
                .filter,
                .evaluationDetail(EvaluationID(1)),
                .lectureDetail(EvaluationLectureID(2)),
                .writeEvaluation(EvaluationLectureID(3)),
                .myEvaluations,
                .allEvaluations(sort: .recommended),
            ]
        )
    }
}

@MainActor
@Suite struct EvaluationSeeAllViewModelTests {
    private func makeViewModel(
        repository: any EvaluationRepository,
        initialSortKind: EvaluationSort.Kind = .recommended,
        availableSorts: [EvaluationSort]
    ) -> EvaluationSeeAllViewModel {
        withDependencies {
            $0.evaluationRepository = repository
        } operation: {
            EvaluationSeeAllViewModel(
                initialSortKind: initialSortKind,
                availableSorts: availableSorts
            )
        }
    }

    @Test func loadUsesInitialSort() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let evaluation = LectureEvaluation.preview(id: 1)
        let repository = FakeEvaluationRepository(
            evaluationPages: [
                EvaluationRequest(sort: latestSort, cursor: nil): EvaluationPage(
                    evaluations: [evaluation],
                    cursor: "next",
                    isLast: false
                )
            ]
        )
        let viewModel = makeViewModel(
            repository: repository,
            initialSortKind: .latest,
            availableSorts: [recommendedSort, latestSort]
        )

        try await viewModel.load()

        #expect(viewModel.selectedSort == latestSort)
        #expect(viewModel.loadedEvaluations == [evaluation])
        #expect(await repository.evaluationRequests == [EvaluationRequest(sort: latestSort, cursor: nil)])
    }

    @Test func selectSortReloadsFirstPage() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let recommendedEvaluation = LectureEvaluation.preview(id: 1)
        let latestEvaluation = LectureEvaluation.preview(id: 2)
        let repository = FakeEvaluationRepository(
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [recommendedEvaluation],
                    cursor: "recommended-next",
                    isLast: false
                ),
                EvaluationRequest(sort: latestSort, cursor: nil): EvaluationPage(
                    evaluations: [latestEvaluation],
                    cursor: nil,
                    isLast: true
                ),
            ]
        )
        let viewModel = makeViewModel(
            repository: repository,
            availableSorts: [recommendedSort, latestSort]
        )
        try await viewModel.load()

        try await viewModel.selectSort(latestSort)

        #expect(viewModel.selectedSort == latestSort)
        #expect(viewModel.loadedEvaluations == [latestEvaluation])
        #expect(
            await repository.evaluationRequests == [
                EvaluationRequest(sort: recommendedSort, cursor: nil),
                EvaluationRequest(sort: latestSort, cursor: nil),
            ]
        )
    }

    @Test func refreshIgnoresStaleFirstPageResult() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let latestSort = EvaluationSort(id: 2, kind: .latest)
        let recommendedEvaluation = LectureEvaluation.preview(id: 1)
        let latestEvaluation = LectureEvaluation.preview(id: 2)
        let repository = FakeEvaluationRepository(
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [recommendedEvaluation],
                    cursor: nil,
                    isLast: true
                ),
                EvaluationRequest(sort: latestSort, cursor: nil): EvaluationPage(
                    evaluations: [latestEvaluation],
                    cursor: nil,
                    isLast: true
                ),
            ],
            delayedRequests: [
                EvaluationRequest(sort: latestSort, cursor: nil)
            ]
        )
        let viewModel = makeViewModel(
            repository: repository,
            initialSortKind: .latest,
            availableSorts: [recommendedSort, latestSort]
        )

        try await viewModel.load()

        let latestTask = Task { try await viewModel.refresh() }
        try await Task.sleep(for: .milliseconds(20))
        try await viewModel.selectSort(recommendedSort)
        try await latestTask.value

        #expect(viewModel.selectedSort == recommendedSort)
        #expect(viewModel.loadedEvaluations == [recommendedEvaluation])
    }

    @Test func loadMoreAppendsNextPage() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let firstEvaluation = LectureEvaluation.preview(id: 1)
        let nextEvaluation = LectureEvaluation.preview(id: 2)
        let repository = FakeEvaluationRepository(
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [firstEvaluation],
                    cursor: "next",
                    isLast: false
                ),
                EvaluationRequest(sort: recommendedSort, cursor: "next"): EvaluationPage(
                    evaluations: [nextEvaluation],
                    cursor: nil,
                    isLast: true
                ),
            ]
        )
        let viewModel = makeViewModel(
            repository: repository,
            availableSorts: [recommendedSort]
        )
        try await viewModel.load()

        await viewModel.loadMoreIfNeeded(current: firstEvaluation)

        #expect(viewModel.loadedEvaluations == [firstEvaluation, nextEvaluation])
        #expect(
            await repository.evaluationRequests == [
                EvaluationRequest(sort: recommendedSort, cursor: nil),
                EvaluationRequest(sort: recommendedSort, cursor: "next"),
            ]
        )
    }

    @Test func loadMoreIgnoresDuplicateWhileLoading() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let firstEvaluation = LectureEvaluation.preview(id: 1)
        let nextEvaluation = LectureEvaluation.preview(id: 2)
        let repository = FakeEvaluationRepository(
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [firstEvaluation],
                    cursor: "next",
                    isLast: false
                ),
                EvaluationRequest(sort: recommendedSort, cursor: "next"): EvaluationPage(
                    evaluations: [nextEvaluation],
                    cursor: nil,
                    isLast: true
                ),
            ],
            delayedRequests: [
                EvaluationRequest(sort: recommendedSort, cursor: "next")
            ]
        )
        let viewModel = makeViewModel(
            repository: repository,
            availableSorts: [recommendedSort]
        )
        try await viewModel.load()

        let loadMoreTask = Task {
            await viewModel.loadMoreIfNeeded(current: firstEvaluation)
        }
        try await Task.sleep(for: .milliseconds(20))
        await viewModel.loadMoreIfNeeded(current: firstEvaluation)
        await loadMoreTask.value

        #expect(viewModel.loadedEvaluations == [firstEvaluation, nextEvaluation])
        #expect(
            await repository.evaluationRequests == [
                EvaluationRequest(sort: recommendedSort, cursor: nil),
                EvaluationRequest(sort: recommendedSort, cursor: "next"),
            ]
        )
    }

    @Test func loadMoreFailureKeepsExistingEvaluations() async throws {
        let recommendedSort = EvaluationSort(id: 1, kind: .recommended)
        let firstEvaluation = LectureEvaluation.preview(id: 1)
        let repository = FakeEvaluationRepository(
            evaluationPages: [
                EvaluationRequest(sort: recommendedSort, cursor: nil): EvaluationPage(
                    evaluations: [firstEvaluation],
                    cursor: "next",
                    isLast: false
                )
            ]
        )
        let viewModel = makeViewModel(
            repository: repository,
            availableSorts: [recommendedSort]
        )
        try await viewModel.load()

        await viewModel.loadMoreIfNeeded(current: firstEvaluation)

        #expect(viewModel.loadedEvaluations == [firstEvaluation])
    }
}

@Suite struct EvaluationAPIModelsTests {
    @Test func mainTagMapsToSupportedSortsOnly() throws {
        let tagGroup = Components.Schemas.TagGroupDto(
            id: 10,
            name: "메인",
            ordering: 0,
            tags: [
                Components.Schemas.TagDto(id: 1, name: "추천", ordering: 0),
                Components.Schemas.TagDto(id: 2, name: "교양", ordering: 1),
                Components.Schemas.TagDto(id: 3, name: "최신", ordering: 2),
                Components.Schemas.TagDto(id: 4, name: "명강", ordering: 3),
            ]
        )
        let sorts = tagGroup.evaluationSorts

        #expect(
            sorts == [
                EvaluationSort(id: 1, kind: .recommended),
                EvaluationSort(id: 3, kind: .latest),
            ]
        )
    }

    @Test func mainTagUsesDeterministicOrderWhenOrderingTies() throws {
        let tagGroup = Components.Schemas.TagGroupDto(
            id: 10,
            name: "메인",
            ordering: 0,
            tags: [
                Components.Schemas.TagDto(id: 3, name: "최신", ordering: 1),
                Components.Schemas.TagDto(id: 1, name: "추천", ordering: 1),
            ]
        )

        #expect(
            tagGroup.evaluationSorts == [
                EvaluationSort(id: 1, kind: .recommended),
                EvaluationSort(id: 3, kind: .latest),
            ]
        )
    }

    @Test func evaluationPageMapsToDomainPage() throws {
        let response = Components.Schemas.CursorPaginationResponseEvaluationWithLectureResponse(
            content: [
                Components.Schemas.EvaluationWithLectureResponse(
                    content: "Good structure and practical examples",
                    fromSnuev: false,
                    id: 5001,
                    isHidden: false,
                    isLiked: true,
                    isModifiable: false,
                    isReportable: true,
                    isReported: false,
                    lecture: Components.Schemas.SimpleLectureDto(
                        id: 1001,
                        instructor: "Kim",
                        title: "Algorithms"
                    ),
                    likeCount: 7,
                    rating: 4.5,
                    semester: 2,
                    userId: "user-1",
                    year: 2025
                )
            ],
            cursor: "cursor-2",
            last: false,
            size: 1,
            totalCount: 10
        )
        let page = response.evaluationPage

        #expect(page.cursor == "cursor-2")
        #expect(page.isLast == false)
        #expect(page.evaluations.count == 1)
        #expect(page.evaluations[0].id == 5001)
        #expect(page.evaluations[0].lecture.id == 1001)
        #expect(page.evaluations[0].lecture.title == "Algorithms")
        #expect(page.evaluations[0].lecture.instructor == "Kim")
        #expect(page.evaluations[0].rating == 4.5)
        #expect(page.evaluations[0].content == "Good structure and practical examples")
        #expect(page.evaluations[0].year == 2025)
        #expect(page.evaluations[0].semester == 2)
        #expect(page.evaluations[0].likeCount == 7)
        #expect(page.evaluations[0].isLiked)
        #expect(page.evaluations[0].isReportable)
    }

    @Test func takenLecturesMapToDomainSummaries() throws {
        let response = Components.Schemas.ListResponseLectureTakenByUserResponse(
            content: [
                Components.Schemas.LectureTakenByUserResponse(
                    academicYear: "3",
                    category: "일반",
                    classification: .교양,
                    courseNumber: "M1522.000100",
                    credit: 3,
                    department: "Computer Science",
                    id: 1001,
                    instructor: "Kim",
                    takenSemester: 1,
                    takenYear: 2025,
                    title: "Algorithms"
                )
            ],
            totalCount: 1
        )
        let lectures = try response.takenLectureSummaries()

        #expect(lectures.count == 1)
        #expect(lectures[0].lecture.id == 1001)
        #expect(lectures[0].lecture.title == "Algorithms")
        #expect(lectures[0].lecture.instructor == "Kim")
        #expect(lectures[0].department == "Computer Science")
        #expect(lectures[0].courseNumber == "M1522.000100")
        #expect(lectures[0].credit == 3)
        #expect(lectures[0].academicYear == "3")
        #expect(lectures[0].classification == "교양")
        #expect(lectures[0].takenQuarter == Quarter(year: 2025, semester: .first))
    }

    @Test func takenLecturesThrowWhenTitleIsMissing() throws {
        let response = Components.Schemas.ListResponseLectureTakenByUserResponse(
            content: [
                Components.Schemas.LectureTakenByUserResponse(
                    academicYear: "3",
                    category: "일반",
                    classification: .교양,
                    courseNumber: "M1522.000100",
                    credit: 3,
                    department: "Computer Science",
                    id: 1001,
                    instructor: "Kim",
                    takenSemester: 1,
                    takenYear: 2025
                )
            ],
            totalCount: 1
        )

        #expect(throws: OptionalError.self) {
            try response.takenLectureSummaries()
        }
    }
}

@Suite struct EvaluationFakeRepositoryTests {
    @Test func fakeRepositoryProvidesHomeAndPaginatedEvaluationData() async throws {
        let repository = EvaluationFakeRepository()
        let sorts = try await repository.fetchMainSorts()
        let recommendedSort = try #require(sorts.first { $0.kind == .recommended })
        let latestSort = try #require(sorts.first { $0.kind == .latest })

        let recommendedFirstPage = try await repository.fetchEvaluations(sort: recommendedSort, cursor: nil)
        let recommendedNextPage = try await repository.fetchEvaluations(
            sort: recommendedSort,
            cursor: try #require(recommendedFirstPage.cursor)
        )
        let latestFirstPage = try await repository.fetchEvaluations(sort: latestSort, cursor: nil)
        let takenLectures = try await repository.fetchTakenLectures()

        #expect(sorts.map(\.kind) == [.recommended, .latest])
        #expect(recommendedFirstPage.evaluations.count >= 5)
        #expect(recommendedFirstPage.isLast == false)
        #expect(recommendedNextPage.evaluations.isEmpty == false)
        #expect(recommendedNextPage.isLast == false)
        #expect(latestFirstPage.evaluations.first != recommendedFirstPage.evaluations.first)
        #expect(takenLectures.isEmpty == false)
    }
}

private actor FakeEvaluationRepository: EvaluationRepository {
    var evaluationRequests: [EvaluationRequest] = []

    private let sorts: [EvaluationSort]
    private let evaluationPages: [EvaluationRequest: EvaluationPage]
    private let takenLectures: [TakenLectureSummary]
    private let delayedRequests: Set<EvaluationRequest>

    init(
        sorts: [EvaluationSort] = [],
        evaluationPages: [EvaluationRequest: EvaluationPage] = [:],
        takenLectures: [TakenLectureSummary] = [],
        delayedRequests: Set<EvaluationRequest> = []
    ) {
        self.sorts = sorts
        self.evaluationPages = evaluationPages
        self.takenLectures = takenLectures
        self.delayedRequests = delayedRequests
    }

    func fetchMainSorts() async throws -> [EvaluationSort] {
        sorts
    }

    func fetchEvaluations(sort: EvaluationSort, cursor: String?) async throws -> EvaluationPage {
        let request = EvaluationRequest(sort: sort, cursor: cursor)
        evaluationRequests.append(request)
        if delayedRequests.contains(request) {
            try await Task.sleep(for: .milliseconds(50))
        }
        guard let page = evaluationPages[request] else {
            throw FakeEvaluationRepositoryError.unexpectedEvaluationRequest
        }
        return page
    }

    func fetchTakenLectures() async throws -> [TakenLectureSummary] {
        takenLectures
    }
}

private struct EvaluationRequest: Equatable, Hashable, Sendable {
    let sort: EvaluationSort
    let cursor: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(sort.id)
        hasher.combine(sort.kind)
        hasher.combine(cursor)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.sort == rhs.sort && lhs.cursor == rhs.cursor
    }
}

private enum FakeEvaluationRepositoryError: Error {
    case unexpectedEvaluationRequest
}

extension LectureEvaluation {
    fileprivate static func preview(
        id: EvaluationID = 1,
        lectureID: EvaluationLectureID = 10
    ) -> Self {
        Self(
            id: id,
            lecture: EvaluationLectureBrief(id: lectureID, title: "Algorithms", instructor: "Kim"),
            rating: 4.5,
            content: "Useful lecture",
            year: 2025,
            semester: 1,
            likeCount: 3,
            isLiked: false,
            isReportable: true
        )
    }
}

extension TakenLectureSummary {
    fileprivate static func preview(
        lectureID: EvaluationLectureID = 10,
        takenQuarter: Quarter = Quarter(year: 2025, semester: .first)
    ) -> Self {
        Self(
            lecture: EvaluationLectureBrief(id: lectureID, title: "Algorithms", instructor: "Kim"),
            department: "Computer Science",
            courseNumber: "M1522.000100",
            credit: 3,
            academicYear: "3",
            classification: "Major",
            takenQuarter: takenQuarter
        )
    }
}
