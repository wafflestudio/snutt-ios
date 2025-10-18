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
        appState.timetable.$current.compactMap { $0?.lectures }.assign(to: &$_lectures)
    }
    
    @Published var _lectures: [Lecture] = []
    
    var lectures: [Lecture] {
        _lectures.filter { $0.timePlaces.isEmpty }
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
    
    private var theme: Theme {
        if let currentTimetable = appState.timetable.current {
            return appState.theme.themeList.first(where: { $0.id == currentTimetable.themeId || $0.theme == currentTimetable.theme }) ?? Theme(rawValue: 0)
        } else { return Theme(rawValue: 0) }
    }
    
    var placeholderLecture: Lecture {
        var lecture: Lecture = .init(from: .init(_id: UUID().uuidString, lecture_id: nil, classification: nil, department: nil, academic_year: nil, course_title: "새로운 강의", credit: 0, class_time: nil, class_time_json: [], class_time_mask: [], instructor: "", remark: nil, category: nil, categoryPre2025: nil, course_number: nil, lecture_number: nil, created_at: nil, updated_at: nil, color: theme.isCustom ? LectureColorDto(fg: theme.colors[0].fg.toHex(), bg: theme.colors[0].bg.toHex()) : nil, colorIndex: theme.isCustom ? 0 : 1, wasFull: false, snuttEvLecture: nil, quota: nil, registrationCount: nil, freshmanQuota: nil))
        if !theme.isCustom { lecture = lecture.withTheme(theme: theme.theme?.rawValue) }
        lecture.timePlaces.append(.init(id: UUID().uuidString,
                                        day: .mon,
                                        startTime: .init(hour: 9, minute: 0),
                                        endTime: .init(hour: 10, minute: 0),
                                        place: "",
                                        isCustom: true,
                                        isTemporary: true))
        return lecture
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
