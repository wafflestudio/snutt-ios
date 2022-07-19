//
//  LectureDetailViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation
import Alamofire

extension LectureDetailScene {
    class ViewModel: BaseViewModel, ObservableObject {
        
        var lectureService: LectureServiceProtocol {
            services.lectureService
        }
        
        var currentTimetable: Timetable? {
            appState.setting.timetableSetting.current
        }
        
        func updateLecture(oldLecture: Lecture, newLecture: Lecture) async -> Bool {
            guard let timetableId = currentTimetable?.id else { return false }
            do {
                try await lectureService.updateLecture(timetableId: timetableId, oldLecture: oldLecture, newLecture: newLecture)
            } catch {
                // TODO: show Error message
                print(error.asSTError?.errorMessage)
                return false
            }
            return true
        }
        
    }
}
