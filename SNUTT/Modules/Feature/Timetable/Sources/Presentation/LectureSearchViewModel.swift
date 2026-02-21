//
//  LectureSearchViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import FoundationUtility
import Observation
import SharedUIComponents
import SwiftUI
import SwiftUtility
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
    @ObservationIgnored
    @Dependency(\.notificationCenter) var notificationCenter

    let timetableViewModel: TimetableViewModel

    init(timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
        subscribeToNotifications()
    }

    private func subscribeToNotifications() {
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToBookmarkMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.searchDisplayMode = .bookmark
        }
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
    var searchDisplayMode: SearchDisplayMode = .search

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
    var selectedPredicates: [SearchPredicate] = []
    var isTimeSelectionSheetOpen = false

    var displayPredicates: [SearchPredicate] {
        var displayPredicates = selectedPredicates.filter { $0.category != .time }
        if isTimeIncludeSelected {
            displayPredicates.append(.timeInclude(.init(day: 0, startMinute: 0, endMinute: 0)))
        }
        if isTimeExcludeSelected {
            displayPredicates.append(.timeExclude(.init(day: 0, startMinute: 0, endMinute: 0)))
        }
        return displayPredicates
    }

    var isTimeIncludeSelected: Bool {
        selectedPredicates.contains { if case .timeInclude = $0 { return true } else { return false } }
    }

    var isTimeExcludeSelected: Bool {
        selectedPredicates.contains { if case .timeExclude = $0 { return true } else { return false } }
    }

    var selectedTimeIncludeRanges: [SearchTimeRange] {
        selectedPredicates.compactMap {
            if case .timeInclude(let range) = $0 { return range } else { return nil }
        }
    }

    var isSearchingDifferentQuarter: Bool {
        if let currentTimetable = timetableViewModel.currentTimetable,
            let searchingQuarter, searchingQuarter != currentTimetable.quarter
        {
            true
        } else {
            false
        }
    }

    var supportedCategories: [SearchFilterCategory] {
        SearchFilterCategory.allCases
            .filter { $0 != .instructor }
            .filter { $0 == .time || availablePredicates.keys.contains($0) }
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
        if predicate.category == .time {
            selectedPredicates.removeAll(where: { $0.category == .time })
        } else {
            selectedPredicates.removeAll(where: { $0 == predicate })
        }
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

        // If time exclude filter is selected, update it with current timetable state
        if isTimeExcludeSelected {
            setTimeExcludeRangesFromCurrentTimetable()
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

    func setTimeIncludeRanges(_ ranges: [SearchTimeRange]) {
        // Remove all time predicates first
        selectedPredicates.removeAll { $0.category == .time }
        // Add timeInclude for each range
        selectedPredicates.append(contentsOf: ranges.map { .timeInclude($0) })
    }

    func setTimeExcludeRangesFromCurrentTimetable() {
        // Remove all time predicates first
        selectedPredicates.removeAll { $0.category == .time }

        guard let currentTimetable = timetableViewModel.currentTimetable else { return }

        let ranges: [SearchPredicate] = currentTimetable.occupiedTimeRanges.map { .timeExclude($0) }

        // If timetable is empty, add a dummy timeExclude predicate to indicate filter is active
        // The backend will handle empty timetable case appropriately
        if ranges.isEmpty {
            selectedPredicates.append(.timeExclude(.init(day: 0, startMinute: 0, endMinute: 0)))
        } else {
            selectedPredicates.append(contentsOf: ranges)
        }
    }

    func clearTimeFilter() {
        selectedPredicates.removeAll { $0.category == .time }
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
                try await lectureRepository.removeBookmark(lectureID: lecture.referenceID)
                bookmarkedLectures.removeAll { $0.id == lecture.id }
            } else {
                analyticsLogger.logEvent(
                    AnalyticsAction.addToBookmark(
                        .init(lectureID: lecture.referenceID, referrer: lectureActionReferrer)
                    )
                )
                try await lectureRepository.addBookmark(lectureID: lecture.referenceID)
                if !bookmarkedLectures.contains(where: { $0.id == lecture.id }) {
                    bookmarkedLectures.append(lecture)
                }
            }
        case .vacancy:
            if isToggled(lecture: lecture, type: type) {
                try await vacancyRepository.deleteVacancyLecture(lectureID: lecture.referenceID)
                vacancyLectureIds.remove(lecture.id)
            } else {
                analyticsLogger.logEvent(
                    AnalyticsAction.addToVacancy(.init(lectureID: lecture.referenceID, referrer: lectureActionReferrer))
                )
                try await vacancyRepository.addVacancyLecture(lectureID: lecture.referenceID)
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

public enum SearchDisplayMode: Equatable {
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
            TimetableStrings.searchPredicateTimeDirectSelection
        case .timeExclude:
            TimetableStrings.searchPredicateTimeEmptySlots
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

extension SearchTimeRange {
    func formatted() -> String {
        // Convert day Int (0-6) to Weekday enum
        guard let weekday = Weekday(rawValue: day) else { return "" }

        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())

        // Create dates for time formatting only
        guard let startDate = calendar.date(byAdding: .minute, value: startMinute, to: baseDate),
            let endDate = calendar.date(byAdding: .minute, value: endMinute, to: baseDate)
        else {
            return ""
        }

        // Format times as HH:mm (24-hour format)
        let timeFormat: Date.FormatStyle = .dateTime.hour(.defaultDigits(amPM: .omitted)).minute()
        let startTime = startDate.formatted(timeFormat)
        let endTime = endDate.formatted(timeFormat)

        return "\(weekday.shortSymbol) \(startTime)-\(endTime)"
    }
}
