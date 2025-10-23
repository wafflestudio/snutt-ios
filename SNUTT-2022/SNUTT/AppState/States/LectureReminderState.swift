//
//  LectureReminderState.swift
//  SNUTT
//
//  Created by 최유림 on 10/3/25.
//

import Combine

@MainActor
extension AppState {
    class LectureReminderState {
        @Published var reminderList: [LectureReminder] = []
    }
}
