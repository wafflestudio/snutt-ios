//
//  LectureSearchViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import SwiftUI
import TimetableInterface

@MainActor
class LectureSearchViewModel: ObservableObject {
    @Dependency(\.lectureSearchRepository) private var searchRepository
    @Published var searchQuery = ""

    private let pageLimit = 20
    private var currentPage = 0
    private var isLoading = false
    private var canFetchMore = true
    private var searchResults = CurrentValueSubject<[any Lecture], Never>([])
    @Published private(set) var selectedLecture: (any Lecture)?

    private func fetchSearchResult(at page: Int) async throws -> [any Lecture] {
        let offset = pageLimit * page
        let response = try await searchRepository.fetchSearchResult(query: searchQuery, quarter: .init(year: 2024, semester: .second), filters: [], offset: offset, limit: pageLimit)
        if response.count < pageLimit {
            canFetchMore = false
        }
        currentPage = page
        return response
    }

    func fetchInitialSearchResult() async {
        guard !isLoading else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let lectures = try await fetchSearchResult(at: 0)
            searchResults.value = lectures
            objectWillChange.send()
        } catch {
            // TODO: handle error
//            assertionFailure()
        }
    }

    private func fetchMoreSearchResult() async {
        guard !isLoading, canFetchMore else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let lectures = try await fetchSearchResult(at: currentPage + 1)
            searchResults.value.append(contentsOf: lectures)
        } catch {
//            assertionFailure()
        }
    }
}

extension LectureSearchViewModel: ExpandableLectureListViewModel {
    var lectures: [any Lecture] {
        searchResults.value
    }

    var lecturesPublisher: AnyPublisher<[any Lecture], Never> {
        searchResults.eraseToAnyPublisher()
    }

    func selectLecture(_ lecture: any Lecture) {
        selectedLecture = lecture
    }

    func isSelected(lecture: any Lecture) -> Bool {
        selectedLecture?.id == lecture.id
    }

    func isBookmarked(lecture _: any Lecture) -> Bool {
        false
    }

    func isInCurrentTimetable(lecture _: any Lecture) -> Bool {
        false
    }

    func isVacancyNotificationEnabled(lecture _: any Lecture) -> Bool {
        false
    }

    func fetchMoreLectures() async {
        await fetchMoreSearchResult()
    }
}
