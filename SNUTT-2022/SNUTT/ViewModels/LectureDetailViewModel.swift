//
//  LectureDetailViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Combine
import Foundation
import SwiftUI

extension LectureDetailScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var isErrorAlertPresented = false
        @Published var isLectureOverlapped: Bool = false
        @Published var errorTitle: String = ""
        @Published var errorMessage: String = ""

        override init(container: DIContainer) {
            super.init(container: container)
        }

        var lectureService: LectureServiceProtocol {
            services.lectureService
        }

        var currentTimetable: Timetable? {
            appState.timetable.current
        }

        func addCustomLecture(lecture: Lecture) async -> Bool {
            do {
                try await lectureService.addCustomLecture(lecture: lecture)
                return true
            } catch {
                showError(error)
                return false
            }
        }

        func overwriteLecture(lecture: Lecture) async -> Bool {
            do {
                try await lectureService.overwriteLecture(lecture: lecture)
                return true
            } catch {
                showError(error)
                return false
            }
        }

        func overwriteCustomLecture(lecture: Lecture) async -> Bool {
            do {
                try await lectureService.overwriteCustomLecture(lecture: lecture)
                return true
            } catch {
                showError(error)
                return false
            }
        }

        func updateLecture(oldLecture: Lecture, newLecture: Lecture) async -> Bool {
            do {
                try await lectureService.updateLecture(oldLecture: oldLecture, newLecture: newLecture)
                return true
            } catch {
                showError(error)
                return false
            }
        }

        func forceUpdateLecture(oldLecture: Lecture?, newLecture: Lecture) async -> Bool {
            guard let oldLecture = oldLecture else {
                return false
            }

            do {
                try await lectureService.forceUpdateLecture(oldLecture: oldLecture, newLecture: newLecture)
                return true
            } catch {
                showError(error)
                return false
            }
        }

        func deleteLecture(lecture: Lecture) async {
            do {
                try await lectureService.deleteLecture(lecture: lecture)
            } catch {
                showError(error)
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
                showError(error)
            }
            return nil
        }

        func fetchReviewId(of lecture: Lecture, bind: Binding<String>) async {
            do {
                try await lectureService.fetchReviewId(courseNumber: lecture.courseNumber, instructor: lecture.instructor, bind: bind)
            } catch {
                showError(error)
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
                                            start: 1,
                                            len: 1,
                                            place: "",
                                            isCustom: lecture.isCustom,
                                            isTemporary: true))
            return lecture
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
    }
}
