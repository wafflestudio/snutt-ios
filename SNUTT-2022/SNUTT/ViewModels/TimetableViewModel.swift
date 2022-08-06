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

    override init(container: DIContainer) {
        super.init(container: container)
    }
    
    var totalCredit: Int {
        timetableState.current?.totalCredit ?? 0
    }
    
    var timetableTitle: String {
        timetableState.current?.title ?? ""
    }

    private var timetableService: TimetableServiceProtocol {
        services.timetableService
    }

    private var currentTimetable: Timetable? {
        appState.timetable.current
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
}
