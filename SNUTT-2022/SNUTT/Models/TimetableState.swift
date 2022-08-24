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
        // TODO: refactor this
        $current
            .compactMap { $0 }
            .sink { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "TimetableWidget")
            }
            .store(in: &bag)
    }
}
