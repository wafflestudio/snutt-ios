//
//  TimetableViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import SwiftUI
import UIKit

class TimetableViewModel: BaseViewModel, ObservableObject {
    @Published var showAlert: Bool = false
    @Published var totalCredit: Int = 0
    @Published var timetableTitle: String = ""

    override init(container: DIContainer) {
        super.init(container: container)

        timetableState.$current
            .map { $0?.totalCredit ?? 0 }
            .assign(to: &$totalCredit)

        timetableState.$current
            .map { $0?.title ?? "" }
            .assign(to: &$timetableTitle)
    }

    var currentTimetable: Timetable? {
        timetableState.current
    }

    var currentConfiguration: TimetableConfiguration {
        timetableState.configuration
    }

    func toggleMenuSheet() {
        appState.setting.menuSheetSetting.isOpen.toggle()
    }

    func fetchRecentTimetable() async {
        do {
            try await timetableService.fetchRecentTimetable()
        } catch {
            // TODO: handle error
            DispatchQueue.main.async {
                self.showAlert = true
            }
        }
    }

    func fetchTimetableList() async {
        do {
            try await timetableService.fetchTimetableList()
        } catch {
            // TODO: handle error
        }
    }

    func loadTimetableConfig() {
        timetableService.loadTimetableConfig()
    }

    private var timetableService: TimetableServiceProtocol {
        services.timetableService
    }

    private var timetableState: TimetableState {
        appState.timetable
    }
}
