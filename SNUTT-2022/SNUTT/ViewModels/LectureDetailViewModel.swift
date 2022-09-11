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
        
        func openLectureTimeSheet(lecture: Binding<Lecture>, timePlace: TimePlace) {
            services.globalUIService.setIsLectureTimeSheetOpen(true, modifying: timePlace) { modifiedTimePlace in
                guard let firstIndex = lecture.timePlaces.firstIndex(where: { $0.id == timePlace.id}) else { return }
                lecture.wrappedValue.timePlaces[firstIndex] = modifiedTimePlace
            }
        }
    }
}
