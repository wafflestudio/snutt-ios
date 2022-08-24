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
    @Published var courseBookList: [Quarter]?
    @Published var configuration: TimetableConfiguration = .init()

    private var bag = Set<AnyCancellable>()

    // TODO: refactor this
    init() {
        // sync between current timetable and widget
        $current
            .compactMap { $0 }
            .sink { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "TimetableWidget")
            }
            .store(in: &bag)

        // sync between current timetable and timetable metadata
        $current
            .compactMap { $0 }
            .sink { [weak self] timetable in
                guard let currentMetaIndex = self?.metadataList?.firstIndex(where: { $0.id == timetable.id }) else { return }
                self?.metadataList?[currentMetaIndex].totalCredit = timetable.totalCredit
            }
            .store(in: &bag)
    }
}
