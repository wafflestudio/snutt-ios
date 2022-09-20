//
//  LectureDetailViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation

extension LectureDetailScene {
    class ViewModel: BaseViewModel, ObservableObject {
        var lectureService: LectureServiceProtocol {
            services.lectureService
        }

        var reviewService: ReviewServiceProtocol {
            services.reviewService
        }

        var currentTimetable: Timetable? {
            appState.timetable.current
        }

        func updateLecture(oldLecture: Lecture, newLecture: Lecture) async -> Bool {
            do {
                try await lectureService.updateLecture(oldLecture: oldLecture, newLecture: newLecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
            }
            return true
        }

        func deleteLecture(lecture: Lecture) async {
            do {
                try await lectureService.deleteLecture(lecture: lecture)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func fetchReviewId(of lecture: Lecture) async {
            do {
                try await lectureService.fetchReviewId(courseNumber: lecture.courseNumber, instructor: lecture.instructor)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func resetReviewId() {
            services.reviewService.resetReviewId()
        }
    }
}
