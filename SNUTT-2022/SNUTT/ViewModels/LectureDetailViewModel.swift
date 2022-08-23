//
//  LectureDetailViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Alamofire
import Foundation

extension LectureDetailScene {
    class ViewModel: BaseViewModel, ObservableObject {
        var lectureService: LectureServiceProtocol {
            services.lectureService
        }

        var currentTimetable: Timetable? {
            appState.timetable.current
        }

        func updateLecture(oldLecture: Lecture, newLecture: Lecture) async -> Bool {
            do {
                try await lectureService.updateLecture(oldLecture: oldLecture, newLecture: newLecture)
            } catch {
                services.globalUiService.presentErrorAlert(error: error)
                return false
            }
            return true
        }

        func deleteLecture(lecture: Lecture) async {
            do {
                try await lectureService.deleteLecture(lecture: lecture)
            } catch {
                services.globalUiService.presentErrorAlert(error: error)
            }
        }
    }
}
