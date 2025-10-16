//
//  TimetableViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import Foundation

class TimetableViewModel: BaseViewModel, ObservableObject {
    @Published private(set) var currentTimetable: Timetable?
    @Published private(set) var configuration: TimetableConfiguration = .init()
    @Published private var metadataList: [TimetableMetadata]?
    @Published private(set) var isVacancyBannerVisible = false

    @Published private(set) var unreadCount: Int = 0

    @Published private var _routingState: TimetableScene.RoutingState = .init()
    var routingState: TimetableScene.RoutingState {
        get { _routingState }
        set {
            services.globalUIService.setRoutingState(\.timetableScene, value: newValue)
        }
    }

    override init(container: DIContainer) {
        super.init(container: container)

        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$configuration)
        appState.timetable.$metadataList.assign(to: &$metadataList)
        appState.vacancy.$isBannerVisible.assign(to: &$isVacancyBannerVisible)

        appState.notification.$unreadCount.assign(to: &$unreadCount)
        appState.routing.$timetableScene.assign(to: &$_routingState)
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
    
    func goToBookmarkPage() {
        services.vacancyService.goToBookmarkPage()
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
