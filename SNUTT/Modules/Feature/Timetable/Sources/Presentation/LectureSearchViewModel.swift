//
//  LectureSearchViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Combine
import Dependencies
import Observation
import TimetableInterface
import VacancyInterface

@Observable
@MainActor
class LectureSearchViewModel {
    @ObservationIgnored
    @Dependency(\.lectureSearchRepository) private var searchRepository
    @ObservationIgnored
    @Dependency(\.vacancyRepository) private var vacancyRepository
    @ObservationIgnored
    @Dependency(\.lectureRepository) private var lectureRepository
    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    private let timetableViewModel: TimetableViewModel
    private let router: LectureSearchRouter

    init(timetableViewModel: TimetableViewModel, router: LectureSearchRouter = .init()) {
        self.timetableViewModel = timetableViewModel
        self.router = router
    }

    var searchQuery = ""
    var searchingQuarter: Quarter? {
        didSet {
            if oldValue != searchingQuarter {
                Task {
                    try? await fetchVacancyLectures()
                    try? await fetchBookmarkedLectures()
                }
            }
        }
    }
    var searchDisplayMode: SearchDisplayMode {
        get { router.searchDisplayMode }
        set { router.searchDisplayMode = newValue }
    }

    var isSearchFilterOpen = false
    var targetForLectureDetail: Lecture?
    var targetForLectureReview: Lecture?
    var scrollPositions = [SearchDisplayMode: Lecture.ID]()
    var scrollPosition: Lecture.ID? {
        get { scrollPositions[.search] }
        set { scrollPositions[.search] = newValue }
    }

    private let dataSource = LectureSearchResultDataSource()
    var selectedLecture: Lecture?
    private var vacancyLectureIds: Set<Lecture.ID> = []
    private(set) var bookmarkedLectures: [Lecture] = []
    private var bookmarkedLectureIds: Set<Lecture.ID> {
        Set(bookmarkedLectures.map(\.id))
    }

    private(set) var availablePredicates: [SearchFilterCategory: [SearchPredicate]] = [:]
    var selectedCategory: SearchFilterCategory = .sortCriteria
    private(set) var selectedPredicates: [SearchPredicate] = []

    var supportedCategories: [SearchFilterCategory] {
        SearchFilterCategory.allCases
            .filter { $0 != .instructor }
            .filter { availablePredicates.keys.contains($0) }
    }

    func fetchAvailablePredicates(quarter: Quarter) async throws {
        let predicates = try await searchRepository.fetchSearchPredicates(quarter: quarter)
        availablePredicates = Dictionary(grouping: predicates, by: { $0.category })
    }

    func togglePredicate(predicate: SearchPredicate) {
        if selectedPredicates.contains(predicate) {
            selectedPredicates.removeAll { $0 == predicate }
            return
        }
        if predicate.category == .sortCriteria {
            selectedPredicates.removeAll(where: { $0.category == .sortCriteria })
        }
        selectedPredicates.append(predicate)
    }

    func deselectPredicate(predicate: SearchPredicate) {
        selectedPredicates.removeAll(where: { $0 == predicate })
    }

    func fetchInitialSearchResult() async throws {
        guard let searchingQuarter else { return }
        if let currentTimetable = timetableViewModel.currentTimetable {
            analyticsLogger.logEvent(
                AnalyticsAction.searchLecture(
                    .init(query: searchQuery, quarter: currentTimetable.quarter.localizedDescription)
                )
            )
        }
        try await dataSource.fetchInitialSearchResult(
            query: searchQuery,
            quarter: searchingQuarter,
            predicates: selectedPredicates
        )
    }

    func resetSearchResult() {
        dataSource.reset()
        selectedLecture = nil
    }

    func fetchVacancyLectures() async throws {
        let lectures = try await vacancyRepository.fetchVacancyLectures()
        vacancyLectureIds = Set(lectures.compactMap(\._id))
    }

    func fetchBookmarkedLectures() async throws {
        guard let searchingQuarter else { return }
        bookmarkedLectures = try await lectureRepository.fetchBookmarks(quarter: searchingQuarter)
    }
}

extension LectureSearchViewModel: ExpandableLectureListViewModel {
    func isToggled(lecture: Lecture, type: ActionButtonType) -> Bool {
        switch type {
        case .detail:
            false
        case .review:
            false
        case .bookmark:
            bookmarkedLectureIds.contains(lecture.id)
        case .vacancy:
            vacancyLectureIds.contains(lecture.id)
        case .add:
            timetableViewModel.isLectureInCurrentTimetable(lecture: lecture)
        }
    }

    var searchState: LectureSearchResultDataSource.SearchState {
        dataSource.searchState
    }

    var lectures: [Lecture] {
        guard case .searched(let lectures) = dataSource.searchState else {
            return []
        }
        return lectures
    }

    func selectLecture(_ lecture: Lecture) {
        selectedLecture = lecture
    }

    func isSelected(lecture: Lecture) -> Bool {
        selectedLecture?.id == lecture.id
    }

    func toggleAction(lecture: Lecture, type: ActionButtonType, overrideOnConflict: Bool) async throws {
        switch type {
        case .detail:
            targetForLectureDetail = lecture
            analyticsLogger.logScreen(
                AnalyticsScreen.lectureDetail(
                    .init(lectureID: lecture.referenceID, referrer: detailReferrer)
                )
            )
        case .review:
            targetForLectureReview = lecture
            analyticsLogger.logScreen(
                AnalyticsScreen.reviewDetail(
                    .init(lectureID: lecture.referenceID, referrer: detailReferrer)
                )
            )
        case .bookmark:
            if isToggled(lecture: lecture, type: type) {
                try await lectureRepository.removeBookmark(lectureID: lecture.id)
                bookmarkedLectures.removeAll { $0.id == lecture.id }
            } else {
                analyticsLogger.logEvent(
                    AnalyticsAction.addToBookmark(
                        .init(lectureID: lecture.referenceID, referrer: lectureActionReferrer)
                    )
                )
                try await lectureRepository.addBookmark(lectureID: lecture.id)
                if !bookmarkedLectures.contains(where: { $0.id == lecture.id }) {
                    bookmarkedLectures.append(lecture)
                }
            }
        case .vacancy:
            if isToggled(lecture: lecture, type: type) {
                try await vacancyRepository.deleteVacancyLecture(lectureID: lecture.id)
                vacancyLectureIds.remove(lecture.id)
            } else {
                analyticsLogger.logEvent(
                    AnalyticsAction.addToVacancy(.init(lectureID: lecture.referenceID, referrer: lectureActionReferrer))
                )
                try await vacancyRepository.addVacancyLecture(lectureID: lecture.id)
                vacancyLectureIds.insert(lecture.id)
            }
        case .add:
            if !isToggled(lecture: lecture, type: type) {
                analyticsLogger.logEvent(
                    AnalyticsAction.addToTimetable(
                        .init(
                            lectureID: lecture.referenceID,
                            timetableID: timetableViewModel.currentTimetable?.id,
                            referrer: lectureActionReferrer
                        )
                    )
                )
                try await timetableViewModel.addLecture(lecture: lecture, overrideOnConflict: overrideOnConflict)
            } else {
                try await timetableViewModel.removeLecture(lecture: lecture)
            }
            selectedLecture = nil
        }
    }

    private var detailReferrer: DetailScreenReferrer {
        switch searchDisplayMode {
        case .bookmark: .bookmark
        case .search: .search(query: searchQuery)
        }
    }

    var lectureActionReferrer: LectureActionReferrer {
        switch searchDisplayMode {
        case .search:
            return .search(query: searchQuery)
        case .bookmark:
            return .bookmark
        }
    }

    func fetchMoreLectures() async throws {
        try await dataSource.fetchMoreSearchResult()
    }
}

public enum SearchDisplayMode {
    case search
    case bookmark

    mutating func toggle() {
        switch self {
        case .search:
            self = .bookmark
        case .bookmark:
            self = .search
        }
    }
}

@Observable
@MainActor
public final class LectureSearchRouter {
    public var searchDisplayMode: SearchDisplayMode = .search
    public nonisolated init() {}
}

enum SearchFilterCategory: String, Sendable, CaseIterable {
    case sortCriteria
    case classification
    case department
    case academicYear
    case credit
    case instructor
    case category
    case categoryPre2025
    case time
    case etc

    var localizedDescription: String {
        switch self {
        case .sortCriteria:
            TimetableStrings.searchFilterSortCriteria
        case .classification:
            TimetableStrings.searchFilterClassification
        case .department:
            TimetableStrings.searchFilterDepartment
        case .academicYear:
            TimetableStrings.searchFilterAcademicYear
        case .credit:
            TimetableStrings.searchFilterCredit
        case .instructor:
            TimetableStrings.searchFilterInstructor
        case .category:
            TimetableStrings.searchFilterCategory
        case .categoryPre2025:
            TimetableStrings.searchFilterCategoryPre2025
        case .time:
            TimetableStrings.searchFilterTime
        case .etc:
            TimetableStrings.searchFilterEtc
        }
    }
}

extension SearchPredicate {
    var category: SearchFilterCategory {
        switch self {
        case .sortCriteria:
            .sortCriteria
        case .classification:
            .classification
        case .department:
            .department
        case .academicYear:
            .academicYear
        case .credit:
            .credit
        case .instructor:
            .instructor
        case .category:
            .category
        case .categoryPre2025:
            .categoryPre2025
        case .timeExclude, .timeInclude:
            .time
        case .etc:
            .etc
        }
    }

    var localizedDescription: String {
        switch self {
        case let .sortCriteria(value),
            let .department(value),
            let .academicYear(value),
            let .category(value),
            let .categoryPre2025(value),
            let .instructor(value),
            let .classification(value):
            value
        case let .credit(value):
            "\(value)\(TimetableStrings.searchPredicateCreditSuffix)"
        case .timeInclude:
            ""
        case .timeExclude:
            ""
        case let .etc(value):
            switch value {
            case .english:
                TimetableStrings.searchPredicateEtcEnglish
            case .army:
                TimetableStrings.searchPredicateEtcArmy
            }
        }
    }
}
