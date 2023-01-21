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
    @Published private var _selectedTab: TabType = .review
    @Published var searchResult: [Lecture]? = nil
    @Published var selectedTagList: [SearchTag] = []
    @Published var isLoading: Bool = false
    @Published var isLectureOverlapped: Bool = false
    @Published var isEmailVerifyAlertPresented = false

    var errorTitle: String = ""
    var errorMessage: String = ""

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

    var selectedTab: TabType {
        get { _selectedTab }
        set { services.globalUIService.setSelectedTab(newValue) }
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
        appState.system.$selectedTab.assign(to: &$_selectedTab)
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
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func initializeSearchState() {
        services.searchService.initializeSearchState()
    }

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchMoreSearchResult() async {
        do {
            try await services.searchService.fetchMoreSearchResult()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func deselectTag(_ tag: SearchTag) {
        services.searchService.deselectTag(tag)
    }
    
    func bookmarkLecture(lecture: Lecture) async {
        do {
            try await services.lectureService.bookmarkLecture(lecture: lecture)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
    
    func undoBookmarkLecture(selected: Lecture) async {
        guard let lecture = getBookmarkedLecture(selected) else { return }
        do {
            try await services.lectureService.undoBookmarkLecture(lecture: lecture)
            services.searchService.setSelectedLecture(nil)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
    
    func getBookmarkedLecture(_ lecture: Lecture) -> Lecture? {
        timetableState.bookmark?.lectures.first(where: { $0.isEquivalent(with: lecture) })
    }

    func addLecture(lecture: Lecture) async {
        do {
            try await services.lectureService.addLecture(lecture: lecture)
        } catch {
            if let error = error.asSTError {
                if error.code == .LECTURE_TIME_OVERLAP {
                    DispatchQueue.main.async {
                        self.isLectureOverlapped = true
                        self.errorTitle = error.title
                        self.errorMessage = error.content
                    }
                } else {
                    services.globalUIService.presentErrorAlert(error: error)
                }
            }
        }
    }

    func deleteLecture(selected: Lecture) async {
        guard let lecture = getExistingLecture(selected) else { return }
        do {
            try await services.lectureService.deleteLecture(lecture: lecture)
            services.searchService.setSelectedLecture(nil)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func getExistingLecture(_ lecture: Lecture) -> Lecture? {
        timetableState.current?.lectures.first(where: { $0.isEquivalent(with: lecture) })
    }
    
    func fetchReviewId(of lecture: Lecture) async -> String? {
        do {
            return try await services.lectureService.fetchReviewId(courseNumber: lecture.courseNumber, instructor: lecture.instructor)
        } catch let error as STError where error.code == .EMAIL_NOT_VERIFIED {
            await MainActor.run {
                errorTitle = error.title
                errorMessage = error.content
                isEmailVerifyAlertPresented = true
            }
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
        return nil
    }

    func overwriteLecture(lecture: Lecture) async {
        do {
            try await services.lectureService.addLecture(lecture: lecture, isForced: true)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func preloadReviewWebView(reviewId: String) {
        services.globalUIService.sendDetailWebViewReloadSignal(url: WebViewType.reviewDetail(id: reviewId).url)
    }

    private var searchState: SearchState {
        appState.search
    }

    private var timetableState: TimetableState {
        appState.timetable
    }
}
