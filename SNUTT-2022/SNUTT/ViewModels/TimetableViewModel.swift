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
    private var bag = Set<AnyCancellable>()
    @Published var currentTimetable: Timetable?
    @Published var configuration: TimetableConfiguration = .init()
    

    override init(container: DIContainer) {
        super.init(container: container)
        
        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$configuration)
    }

    var totalCredit: Int {
        currentTimetable?.totalCredit ?? 0
    }

    var timetableTitle: String {
        currentTimetable?.title ?? ""
    }

    private var timetableService: TimetableServiceProtocol {
        services.timetableService
    }

    var timetableState: TimetableState {
        appState.timetable
    }

    func toggleMenuSheet() {
        services.appService.toggleMenuSheet()
    }

    func fetchRecentTimetable() async {
        do {
            try await timetableService.fetchRecentTimetable()
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }

    func fetchTimetableList() async {
        do {
            try await timetableService.fetchTimetableList()
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }

    func loadTimetableConfig() {
        timetableService.loadTimetableConfig()
    }
}
