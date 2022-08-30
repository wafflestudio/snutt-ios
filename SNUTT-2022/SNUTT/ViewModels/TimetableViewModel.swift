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
    @Published private var metadataList: [TimetableMetadata]?

    override init(container: DIContainer) {
        super.init(container: container)

        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$configuration)
        appState.timetable.$metadataList.assign(to: &$metadataList)
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
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchTimetableList() async {
        do {
            try await timetableService.fetchTimetableList()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchCourseBookList() async {
        do {
            try await services.courseBookService.fetchCourseBookList()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func loadTimetableConfig() {
        timetableService.loadTimetableConfig()
    }
}
