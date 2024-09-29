//
//  GlobalUIService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import Foundation
import SwiftUI

@MainActor
protocol GlobalUIServiceProtocol: Sendable {
    func setColorScheme(_ colorScheme: ColorScheme?)
    func loadColorSchemeDuringBootstrap()

    func setSelectedTab(_ tab: TabType)
    func setIsErrorAlertPresented(_ value: Bool)
    func setIsMenuOpen(_ value: Bool)

    func openEllipsis(for timetable: TimetableMetadata)
    func closeEllipsis()

    func openThemeSheet()
    func closeThemeSheet()

    func openRenameSheet()
    func closeRenameSheet()

    func openCreateSheet(withPicker: Bool)
    func closeCreateSheet()

    func setRenameTitle(_ value: String)
    func setCreateTitle(_ value: String)
    func setCreateQuarter(_ value: Quarter?)

    func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?)

    func presentErrorAlert(error: STError?)
    func presentErrorAlert(error: ErrorCode)
    func presentErrorAlert(error: Error)

    func preloadWebViews()
    func sendMainWebViewReloadSignal()
    func sendDetailWebViewReloadSignal(url: URL)

    func setRoutingState<V>(_ key: WritableKeyPath<ViewRoutingState, V>, value: V)
    func hasNewBadge(settingName: String) -> Bool
    
    func showNoticeViewIfNeeded() async throws
}

struct GlobalUIService: GlobalUIServiceProtocol, UserAuthHandler, ConfigsProvidable {
    var appState: AppState
    var localRepositories: AppEnvironment.LocalRepositories
    var webRepositories: AppEnvironment.WebRepositories

    var configRepository: ConfigRepositoryProtocol? {
        webRepositories.configRepository
    }

    func setColorScheme(_ colorScheme: ColorScheme?) {
        appState.system.preferredColorScheme = colorScheme
        localRepositories.userDefaultsRepository.set(String.self, key: .preferredColorScheme, value: colorScheme?.description)
    }

    func loadColorSchemeDuringBootstrap() {
        let colorSchemeDescription = localRepositories.userDefaultsRepository.get(String.self, key: .preferredColorScheme)
        let colorScheme = ColorScheme.from(description: colorSchemeDescription)
        appState.system.preferredColorScheme = colorScheme
    }

    func setSelectedTab(_ tab: TabType) {
        appState.system.selectedTab = tab
    }

    func setIsErrorAlertPresented(_ value: Bool) {
        appState.system.isErrorAlertPresented = value
    }

    func setIsMenuOpen(_ value: Bool) {
        appState.menu.isOpen = value
    }

    func openEllipsis(for timetable: TimetableMetadata) {
        appState.menu.isEllipsisSheetOpen = true
        appState.menu.ellipsisTarget = timetable
    }

    func closeEllipsis() {
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.ellipsisTarget = nil
    }

    func openThemeSheet() {
        appState.menu.isOpen = false
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.isThemeSheetOpen = true
        if let currentTimetable = appState.timetable.current {
            appState.timetable.current?.selectedTheme = appState.theme.themeList.first(where: { $0.id == currentTimetable.themeId || $0.theme == currentTimetable.theme })
        }
    }

    func closeThemeSheet() {
        appState.menu.isThemeSheetOpen = false
        appState.timetable.current?.selectedTheme = nil
    }

    func openRenameSheet() {
        appState.menu.renameTitle = appState.menu.ellipsisTarget?.title ?? ""
        appState.menu.isEllipsisSheetOpen = false
        appState.menu.isRenameSheetOpen = true
    }

    func closeRenameSheet() {
        appState.menu.isRenameSheetOpen = false
    }

    func openCreateSheet(withPicker: Bool) {
        appState.menu.createTitle = ""
        appState.menu.createQuarter = withPicker ? appState.timetable.courseBookList?.first : nil
        appState.menu.isCreateSheetOpen = true
    }

    func closeCreateSheet() {
        appState.menu.isCreateSheetOpen = false
    }

    func setRenameTitle(_ value: String) {
        appState.menu.renameTitle = value
    }

    func setCreateTitle(_ value: String) {
        appState.menu.createTitle = value
    }

    func setCreateQuarter(_ value: Quarter?) {
        appState.menu.createQuarter = value
    }

    func hasNewBadge(settingName: String) -> Bool {
        return appState.system.configs?.settingsBadge?.new.contains { $0 == settingName } ?? false
    }

    // MARK: Preload Review WebViews

    func preloadWebViews() {
        guard let accessToken = appState.user.accessToken else { return }
        appState.review.preloadedMain.preload(url: WebViewType.review.url, accessToken: accessToken)
        appState.review.preloadedDetail.preload(url: WebViewType.review.url, accessToken: accessToken)
    }

    func sendMainWebViewReloadSignal() {
        appState.review.preloadedMain.eventSignal?.send(.reload(url: WebViewType.review.url))
    }

    func sendDetailWebViewReloadSignal(url: URL) {
        appState.review.preloadedDetail.eventSignal?.send(.reload(url: url))
    }

    // MARK: Lecture Time Sheet

    func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?) {
        appState.menu.timePlaceToModify = timePlace
        appState.menu.lectureTimeSheetAction = action
        appState.menu.isLectureTimeSheetOpen = value
    }
    
    // MARK: Show Notice View
    func showNoticeViewIfNeeded() async throws {
        let configs = try await configRepository?.fetchConfigs()
        appState.system.noticeViewInfo = configs?.notices
    }

    // MARK: Error Handling

    func presentErrorAlert(error: Error) {
        presentErrorAlert(error: error.asSTError)
    }

    func presentErrorAlert(error: ErrorCode) {
        presentErrorAlert(error: .init(error))
    }

    func presentErrorAlert(error: STError?) {
        guard let error = error else {
            appState.system.isErrorAlertPresented = false
            return
        }

        if error.code == .WRONG_USER_TOKEN || error.code == .NO_USER_TOKEN {
            clearUserInfo()
        }

        appState.system.error = error
        appState.system.isErrorAlertPresented = true
    }
}

// MARK: Deep Link Routing

extension GlobalUIService {
    func setRoutingState<V>(_ key: WritableKeyPath<ViewRoutingState, V>, value: V) {
        appState.routing[keyPath: key] = value
    }
}

class FakeGlobalUIService: GlobalUIServiceProtocol {
    func setColorScheme(_ colorScheme: ColorScheme?) {}
    func loadColorSchemeDuringBootstrap() {}

    func setSelectedTab(_ tab: TabType) {}
    func setIsErrorAlertPresented(_ value: Bool) {}
    func setIsMenuOpen(_ value: Bool) {}

    func openEllipsis(for timetable: TimetableMetadata) {}
    func closeEllipsis() {}

    func openThemeSheet() {}
    func closeThemeSheet() {}

    func openRenameSheet() {}
    func closeRenameSheet() {}

    func openCreateSheet(withPicker: Bool) {}
    func closeCreateSheet() {}

    func setRenameTitle(_ value: String) {}
    func setCreateTitle(_ value: String) {}
    func setCreateQuarter(_ value: Quarter?) {}

    func setIsLectureTimeSheetOpen(_ value: Bool, modifying timePlace: TimePlace?, action: ((TimePlace) -> Void)?) {}

    func presentErrorAlert(error: STError?) {}
    func presentErrorAlert(error: ErrorCode) {}
    func presentErrorAlert(error: Error) {}

    func preloadWebViews() {}
    func sendMainWebViewReloadSignal() {}
    func sendDetailWebViewReloadSignal(url: URL) {}

    func setRoutingState<V>(_ key: WritableKeyPath<ViewRoutingState, V>, value: V) {}
    func hasNewBadge(settingName: String) -> Bool { return true }
    
    func showNoticeViewIfNeeded() async throws {}
}
