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
        
        func updateLecture(oldLecture: Lecture, newLecture: Lecture) async {
            guard let timetableId = currentTimetable?.id else { return }
            do {
                try await lectureService.updateLecture(timetableId: timetableId, oldLecture: oldLecture, newLecture: newLecture)
            } catch {
//                print("sheet", error.asAFError?.errorDescription)
            }
        }
        
    }
}
