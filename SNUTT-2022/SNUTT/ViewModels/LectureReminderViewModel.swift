//
//  LectureReminderViewModel.swift
//  SNUTT
//
//  Created by 최유림 on 8/30/25.
//

import Foundation

class LectureReminderViewModel: BaseViewModel, ObservableObject {
    
    override init(container: DIContainer) {
        super.init(container: container)
    }
    
    var reminderList: [LectureReminder] {
        appState.reminder.reminderList
    }
    
    func changeLectureReminderState(lectureId: String, to option: ReminderOption) async throws {
        do {
            try await services.lectureService.changeLectureReminderState(lectureId: lectureId, to: option)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
