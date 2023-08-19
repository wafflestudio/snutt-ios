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
    @Published var isVacancyBannerVisible = false

    override init(container: DIContainer) {
        super.init(container: container)

        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$configuration)
        appState.timetable.$metadataList.assign(to: &$metadataList)
        appState.vacancy.$isBannerVisible.assign(to: &$isVacancyBannerVisible)
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

    func goToVacancyPage() {
        services.vacancyService.goToVacancyPage()
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
