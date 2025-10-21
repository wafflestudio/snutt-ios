//
//  LectureReminderViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 8/30/25.
//

import Foundation

class LectureReminderViewModel: BaseViewModel, ObservableObject {
    
    @Published var reminderList: [LectureReminder] = []
    
    override init(container: DIContainer) {
        super.init(container: container)
        appState.reminder.$reminderList.assign(to: &$reminderList)
    }
    
    func fetchLectureReminderList() async {
        do {
            try await services.lectureService.fetchLectureReminderList()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
    
    func changeLectureReminderState(lectureId: String, to option: ReminderOption) async throws {
        do {
            try await services.lectureService.changeLectureReminderState(lectureId: lectureId, to: option)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
