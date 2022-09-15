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

        func updateLecture(oldLecture: Lecture, newLecture: Lecture) async -> Lecture? {
            do {
                try await lectureService.updateLecture(oldLecture: oldLecture, newLecture: newLecture)
                guard let lecture = appState.timetable.current?.lectures.first(where: { $0.id == newLecture.id }) else { return nil }
                return lecture
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return nil
            }
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

        func getLecture(lecture: Lecture, without timePlace: TimePlace) -> Lecture {
            var lecture = lecture
            guard let index = lecture.timePlaces.firstIndex(where: { $0.id == timePlace.id }) else { return lecture }
            lecture.timePlaces.remove(at: index)
            return lecture
        }

        func getLectureWithNewTimePlace(lecture: Lecture) -> Lecture {
            var lecture = lecture
            lecture.timePlaces.append(.init(id: "",
                                            day: .mon,
                                            start: 1,
                                            len: 1,
                                            place: "",
                                            isCustom: lecture.isCustom,
                                            isTemporary: true))
            return lecture
        }
    }
}
