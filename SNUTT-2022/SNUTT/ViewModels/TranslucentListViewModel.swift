//
//   TranslucentListViewModel.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/25.
//

import Combine
import SwiftUI

class TransculentListViewModel: BaseViewModel, ObservableObject {
    @Published private var _currentTimetable: Timetable?
    @Published private var _timetableConfig: TimetableConfiguration = .init()
    @Published private var _selectedLecture: Lecture?
    @Published private var _selectedTab: TabType = .review

    @Published var isLoading: Bool = false
    @Published var isLectureOverlapped: Bool = false
    @Published var isEmailVerifyAlertPresented = false
    @Published var bookmarkedLectures: [Lecture] = []
    @Published var isFirstBookmark: Bool = false
    @Published var isFirstBookmarkAlertPresented: Bool = false

    var errorTitle: String = ""
    var errorMessage: String = ""

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
        appState.search.$isLoading.assign(to: &$isLoading)
        appState.timetable.$bookmark.compactMap {
            $0?.lectures
        }.assign(to: &$bookmarkedLectures)
        appState.timetable.$isFirstBookmark.assign(to: &$isFirstBookmark)
    }

    func fetchMoreSearchResult() async {
        do {
            try await services.searchService.fetchMoreSearchResult()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func getBookmark() async {
        do {
            try await services.searchService.getBookmark()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func bookmarkLecture(lecture: Lecture) async {
        DispatchQueue.main.async {
            self.isFirstBookmarkAlertPresented = self.isFirstBookmark
        }
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
