//
//  LectureDetailViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Combine
import SwiftUI

extension LectureDetailScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var isErrorAlertPresented: Bool = false
        @Published var isLectureOverlapped: Bool = false
        @Published var isEmailVerifyAlertPresented = false
        @Published private var bookmarkedLectures: [Lecture] = []
        @Published var vacancyNotificationLectures: [Lecture] = []
        var errorTitle: String = ""
        var errorMessage: String = ""
        var supportForMapViewEnabled: Bool = true

        override init(container: DIContainer) {
            super.init(container: container)
            appState.system.$selectedTab.assign(to: &$_selectedTab)
            appState.timetable.$bookmark.compactMap { $0?.lectures }.assign(to: &$bookmarkedLectures)
            appState.vacancy.$lectures.assign(to: &$vacancyNotificationLectures)
            supportForMapViewEnabled = !(appState.system.configs?.disableMapFeature ?? false)
        }

        var lectureService: LectureServiceProtocol {
            services.lectureService
        }

        var currentTimetable: Timetable? {
            appState.timetable.current
        }

        @Published private var _selectedTab: TabType = .review
        var selectedTab: TabType {
            get { _selectedTab }
            set { services.globalUIService.setSelectedTab(newValue) }
        }

        func addCustomLecture(lecture: Lecture, isForced: Bool = false) async -> Bool {
            do {
                try await lectureService.addCustomLecture(lecture: lecture, isForced: isForced)
                return true
            } catch let error as STError where error.code == .LECTURE_TIME_OVERLAP {
                isLectureOverlapped = true
                errorTitle = error.title
                errorMessage = error.content
            } catch let error as STError where error.code == .NO_LECTURE_TITLE || error.code == .INVALID_LECTURE_TIME {
                isErrorAlertPresented = true
                errorTitle = error.title
                errorMessage = error.content
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
            return false
        }

        func updateLecture(oldLecture: Lecture?, newLecture: Lecture, isForced: Bool = false) async -> Bool {
            guard let oldLecture = oldLecture else {
                return false
            }

            do {
                try await lectureService.updateLecture(
                    oldLecture: oldLecture,
                    newLecture: newLecture,
                    isForced: isForced
                )
                return true
            } catch let error as STError where error.code == .LECTURE_TIME_OVERLAP {
                isLectureOverlapped = true
                errorTitle = error.title
                errorMessage = error.content
            } catch let error as STError where error.code == .NO_LECTURE_TITLE || error.code == .INVALID_LECTURE_TIME {
                isErrorAlertPresented = true
                errorTitle = error.title
                errorMessage = error.content
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
            return false
        }

        func deleteLecture(lecture: Lecture) async {
            do {
                try await lectureService.deleteLecture(lecture: lecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func openLectureTimeSheet(lecture: Binding<Lecture>, timePlace: TimePlace) {
            services.globalUIService.setIsLectureTimeSheetOpen(true, modifying: timePlace) { modifiedTimePlace in
                guard let firstIndex = lecture.timePlaces.firstIndex(where: { $0.id == timePlace.id }) else { return }
                lecture.wrappedValue.timePlaces[firstIndex] = modifiedTimePlace
            }
        }

        func resetLecture(lecture: Lecture) async -> Lecture? {
            do {
                try await lectureService.resetLecture(lecture: lecture)
                guard let current = appState.timetable.current else { return nil }
                return current.lectures.first(where: { $0.id == lecture.id })
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
            return nil
        }

        func getEvLectureInfo(of lecture: Lecture) async -> EvLecture? {
            if lecture.isCustom { return nil }
            do {
                return try await services.lectureService.getEvLecture(of: lecture)
            } catch {
                return nil
            }
        }

        func fetchSyllabusURL(of lecture: Lecture) async -> String {
            guard let currentQuarter = currentTimetable?.quarter else {
                return ""
            }

            do {
                return try await services.courseBookService.fetchSyllabusURL(quarter: currentQuarter, lecture: lecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return ""
            }
        }

        func getBuildingList(of lecture: Lecture) async -> [Building] {
            do {
                return try await lectureService.getBuildingList(of: lecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return []
            }
        }

        func getLecture(lecture: Lecture, without timePlace: TimePlace) -> Lecture {
            var lecture = lecture
            guard let index = lecture.timePlaces.firstIndex(where: { $0.id == timePlace.id }) else { return lecture }
            lecture.timePlaces.remove(at: index)
            return lecture
        }

        func getLectureWithNewTimePlace(lecture: Lecture) -> Lecture {
            var lecture = lecture
            lecture.timePlaces.append(.init(id: UUID().description,
                                            day: .mon,
                                            startTime: .init(hour: 9, minute: 0),
                                            endTime: .init(hour: 10, minute: 0),
                                            place: "",
                                            isCustom: lecture.isCustom,
                                            isTemporary: true))
            return lecture
        }

        func findLectureInCurrentTimetable(_ lecture: Lecture) -> Lecture? {
            guard let lecture = appState.timetable.current?.lectures
                .first(where: { $0.isEquivalent(with: lecture) })
            else {
                return nil
            }
            return lecture
        }

        func reloadDetailWebView(detailId: Int?) {
            guard let detailId = detailId else { return }
            services.globalUIService.sendDetailWebViewReloadSignal(url: WebViewType.reviewDetail(id: detailId).url)
        }

        func bookmarkLecture(lecture: Lecture) async {
            FirebaseAnalyticsLogger().logEvent(.addToBookmark(.init(
                lectureID: lecture.referenceId,
                referrer: .lectureDetail
            )))
            do {
                try await services.lectureService.bookmarkLecture(lecture: lecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func undoBookmarkLecture(lecture: Lecture) async {
            if !isBookmarked(lecture: lecture) { return }
            do {
                try await services.lectureService.undoBookmarkLecture(lecture: lecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func isBookmarked(lecture: Lecture) -> Bool {
            appState.timetable.bookmark?.lectures
                .contains(where: { $0.isEquivalent(with: lecture) }) ?? false
        }

        func addVacancyLecture(lecture: Lecture) async {
            FirebaseAnalyticsLogger().logEvent(.addToVacancy(.init(
                lectureID: lecture.referenceId,
                referrer: .lectureDetail
            )))
            do {
                try await services.vacancyService.addLecture(lecture: lecture)
            } catch let error as STError where error.code == .INVALID_SEMESTER_FOR_VACANCY_NOTIFICATION {
                isErrorAlertPresented = true
                errorTitle = error.title
                errorMessage = error.content
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func deleteVacancyLecture(lecture: Lecture) async {
            do {
                try await services.vacancyService.deleteLectures(lectures: [lecture])
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func isVacancyNotificationEnabled(lecture: Lecture) -> Bool {
            return vacancyNotificationLectures.contains(where: { $0.isEquivalent(with: lecture) })
        }

        var theme: Theme {
            if let currentTimetable = appState.timetable.current {
                return appState.theme.themeList
                    .first(where: { $0.id == currentTimetable.themeId || $0.theme == currentTimetable.theme }) ??
                    Theme(rawValue: 0)
            } else { return Theme(rawValue: 0) }
        }

        func setIsMapViewExpanded(_ expand: Bool) {
            lectureService.setIsMapViewExpanded(expand)
        }

        func shouldOpenLectureMapView() -> Bool {
            lectureService.shouldExpandLectureMapView()
        }
    }
}
