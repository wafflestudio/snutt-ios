//
//  TimetableViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import Foundation

class TimetableViewModel: BaseViewModel, ObservableObject {
    @Published var currentTimetable: Timetable?
    @Published var configuration: TimetableConfiguration = .init()
    @Published private var metadataList: [TimetableMetadata]?
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    @Published var isErrorAlertPresented = false
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""

    override init(container: DIContainer) {
        super.init(container: container)

        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$configuration)
        appState.notification.$notifications.assign(to: &$notifications)
        appState.notification.$unreadCount.assign(to: &$unreadCount)
        appState.timetable.$metadataList.assign(to: &$metadataList)
    }

    var totalCredit: Int {
        currentTimetable?.totalCredit ?? 0
    }

    var timetableTitle: String {
        currentTimetable?.title ?? ""
    }

    var isNewCourseBookAvailable: Bool {
        services.courseBookService.isNewCourseBookAvailable()
    }

    func setIsMenuOpen(_ value: Bool) {
        services.globalUIService.setIsMenuOpen(value)
    }

    func fetchRecentTimetable() async {
        do {
            try await timetableService.fetchRecentTimetable()
        } catch {
            showError(error)
        }
    }

    func fetchTimetableList() async {
        do {
            try await timetableService.fetchTimetableList()
        } catch {
            showError(error)
        }
    }

    func fetchCourseBookList() async {
        do {
            try await services.courseBookService.fetchCourseBookList()
        } catch {
            showError(error)
        }
    }

    func fetchInitialNotifications(updateLastRead: Bool) async {
        do {
            try await services.notificationService.fetchInitialNotifications(updateLastRead: updateLastRead)
        } catch {
            showError(error)
        }
    }

    func fetchMoreNotifications() async {
        do {
            try await services.notificationService.fetchMoreNotifications()
        } catch {
            showError(error)
        }
    }

    func fetchNotificationsCount() async {
        do {
            try await services.notificationService.fetchUnreadNotificationCount()
        } catch {
            showError(error)
        }
    }

    func fetchUser() async {
        do {
            try await services.userService.fetchUser()
        } catch {
            showError(error)
        }
    }

    func loadTimetableConfig() {
        timetableService.loadTimetableConfig()
    }

    private func showError(_ error: Error) {
        if let error = error.asSTError {
            DispatchQueue.main.async {
                self.isErrorAlertPresented = true
                self.errorTitle = error.title
                self.errorMessage = error.content
            }
        }
    }

    private var timetableService: TimetableServiceProtocol {
        services.timetableService
    }

    private var timetableState: TimetableState {
        appState.timetable
    }
}
