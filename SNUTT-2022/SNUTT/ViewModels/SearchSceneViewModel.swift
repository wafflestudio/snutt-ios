//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine
import SwiftUI

class SearchSceneViewModel: BaseViewModel, ObservableObject {
    @Published private var _currentTimetable: Timetable?
    @Published private var _timetableConfig: TimetableConfiguration = .init()
    @Published private var _selectedLecture: Lecture?
    @Published private var _searchText: String = ""
    @Published private var _isFilterOpen: Bool = false
    @Published var searchResult: [Lecture]? = nil
    @Published var selectedTagList: [SearchTag] = []
    @Published var isLoading: Bool = false
    @Published var isErrorAlertPresented = false
    @Published var isLectureOverlapped: Bool = false
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""

    var searchText: String {
        get { _searchText }
        set { services.searchService.setSearchText(newValue) }
    }

    var isFilterOpen: Bool {
        get { _isFilterOpen }
        set { services.searchService.setIsFilterOpen(newValue) }
    }

    var selectedLecture: Lecture? {
        get { _selectedLecture }
        set { services.searchService.setSelectedLecture(newValue) }
    }

    var currentTimetableWithSelection: Timetable? {
        _currentTimetable?.withSelectedLecture(_selectedLecture)
    }

    var timetableConfigWithAutoFit: TimetableConfiguration {
        _timetableConfig.withAutoFitEnabled()
    }

    override init(container: DIContainer) {
        super.init(container: container)

        appState.timetable.$current.assign(to: &$_currentTimetable)
        appState.timetable.$configuration.assign(to: &$_timetableConfig)
        appState.search.$selectedLecture.assign(to: &$_selectedLecture)
        appState.search.$searchText.assign(to: &$_searchText)
        appState.search.$isFilterOpen.assign(to: &$_isFilterOpen)
        appState.search.$searchResult.assign(to: &$searchResult)
        appState.search.$isLoading.assign(to: &$isLoading)
        appState.search.$selectedTagList.assign(to: &$selectedTagList)
    }

    func fetchTags() async {
        if appState.search.searchTagList != nil {
            return
        }
        guard let currentTimetable = timetableState.current else { return }
        do {
            try await services.searchService.fetchTags(quarter: currentTimetable.quarter)
        } catch {
            showError(error)
        }
    }

    func initializeSearchState() {
        services.searchService.initializeSearchState()
    }

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            showError(error)
        }
    }

    func fetchMoreSearchResult() async {
        do {
            try await services.searchService.fetchMoreSearchResult()
        } catch {
            showError(error)
        }
    }

    func deselectTag(_ tag: SearchTag) {
        services.searchService.deselectTag(tag)
    }

    func addLecture(lecture: Lecture) async {
        do {
            try await services.lectureService.addLecture(lecture: lecture)
        } catch {
            showError(error)
        }
    }

    func fetchReviewId(of lecture: Lecture, bind: Binding<String>) async {
        do {
            try await services.lectureService.fetchReviewId(courseNumber: lecture.courseNumber, instructor: lecture.instructor, bind: bind)
        } catch {
            showError(error)
        }
    }

    func overwriteLecture(lecture: Lecture) async {
        do {
            try await services.lectureService.overwriteLecture(lecture: lecture)
        } catch {
            showError(error)
        }
    }

    private func showError(_ error: Error) {
        if let error = error.asSTError {
            DispatchQueue.main.async {
                self.isErrorAlertPresented = true
                if error.code == .LECTURE_TIME_OVERLAP {
                    self.isLectureOverlapped = true
                }
                self.errorTitle = error.title
                self.errorMessage = error.content
            }
        }
    }

    private var searchState: SearchState {
        appState.search
    }

    private var timetableState: TimetableState {
        appState.timetable
    }
}
