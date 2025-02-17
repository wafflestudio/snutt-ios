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

@Observable
@MainActor
class LectureSearchViewModel {
    @ObservationIgnored
    @Dependency(\.lectureSearchRepository) private var searchRepository

    private let timetableViewModel: TimetableViewModel

    init(timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
    }

    var searchQuery = ""
    var searchingQuarter: Quarter?
    var searchDisplayMode: SearchDisplayMode = .search
    var isSearchFilterOpen = false
    var targetForLectureDetailSheet: (any Lecture)?

    private let dataSource = LectureSearchResultDataSource()
    var selectedLecture: (any Lecture)?

    private(set) var availablePredicates: [SearchFilterCategory: [SearchPredicate]] = [:]
    var selectedCategory: SearchFilterCategory = .sortCriteria
    private(set) var selectedPredicates: [SearchPredicate] = []

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
}

extension LectureSearchViewModel: ExpandableLectureListViewModel {
    func isToggled(lecture: any Lecture, type: ActionButtonType) -> Bool {
        switch type {
        case .detail:
            false
        case .review:
            false
        case .bookmark:
            false
        case .vacancy:
            false
        case .add:
            timetableViewModel.isLectureInCurrentTimetable(lecture: lecture)
        }
    }

    var lectures: [any Lecture] {
        dataSource.searchResults
    }

    func selectLecture(_ lecture: any Lecture) {
        selectedLecture = lecture
    }

    func isSelected(lecture: any Lecture) -> Bool {
        selectedLecture?.id == lecture.id
    }

    func toggleAction(lecture: any Lecture, type: ActionButtonType) async throws {
        switch type {
        case .detail:
            targetForLectureDetailSheet = lecture
        case .review:
            break
        case .bookmark:
            break
        case .vacancy:
            break
        case .add:
            do {
                if !isToggled(lecture: lecture, type: type) {
                    try await timetableViewModel.addLecture(lecture: lecture)
                } else {
                    try await timetableViewModel.removeLecture(lecture: lecture)
                }
                selectedLecture = nil
            } catch let error as APIClientError {
                if let knownError = error.underlyingError as? LocalizedErrorCode,
                   knownError == .duplicateLecture
                {
                    // TODO: force add
                }
            }
        }
    }

    func fetchMoreLectures() async throws {
        try await dataSource.fetchMoreSearchResult()
    }
}

enum SearchDisplayMode {
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

enum SearchFilterCategory: String, Sendable, CaseIterable {
    case sortCriteria
    case classification
    case department
    case academicYear
    case credit
    case instructor
    case category
    case time
    case etc

    static var supportedCases: [SearchFilterCategory] {
        var allCases = allCases
        allCases.removeAll(where: { $0 == .instructor })
        return allCases
    }

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
             let .instructor(value),
             let .classification(value):
            value
        case let .credit(value):
            "\(value)학점"
        case .timeInclude:
            ""
        case .timeExclude:
            ""
        case let .etc(value):
            ""
        }
    }
}
