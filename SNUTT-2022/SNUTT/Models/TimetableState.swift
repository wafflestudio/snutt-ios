//
//  TimetableState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import SwiftUI
import WidgetKit

class TimetableState: ObservableObject {
    @Published var current: Timetable?
    @Published var metadataList: [TimetableMetadata]?
    @Published var configuration: TimetableConfiguration = .init()

    private var bag = Set<AnyCancellable>()

    init() {
        $current
            .compactMap { $0 }
            .sink { timetable in
                let dto = TimetableDto(from: timetable)
                let data = dto.asJSONData()
                if let userDefaults = UserDefaults(suiteName: "group.com.wafflestudio.snutt-2022") {
                    userDefaults.set(data, forKey: "currentTimetable")
                    WidgetCenter.shared.reloadTimelines(ofKind: "TimetableWidget")
                }
            }
            .store(in: &bag)
    }
}
