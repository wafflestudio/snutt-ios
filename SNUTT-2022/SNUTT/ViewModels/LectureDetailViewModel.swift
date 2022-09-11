//
//  LectureDetailViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire
import Foundation
import SwiftUI

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

        // TODO: 새로운 Lecture 리턴해서 뷰를 업데이트해주어야 함 (resetLecture 참고)
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
        
        func openLectureTimeSheet(lecture: Binding<Lecture>, timePlace: TimePlace) {
            services.globalUIService.setIsLectureTimeSheetOpen(true, modifying: timePlace) { modifiedTimePlace in
                guard let firstIndex = lecture.timePlaces.firstIndex(where: { $0.id == timePlace.id}) else { return }
                lecture.wrappedValue.timePlaces[firstIndex] = modifiedTimePlace

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

        func fetchReviewId(of lecture: Lecture) async {
            do {
                let id = try await lectureService.fetchReviewId(courseNumber: lecture.courseNumber, instructor: lecture.instructor)
                reviewService.setDetailId(id)
                services.globalUIService.setSelectedTab(.review)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}
