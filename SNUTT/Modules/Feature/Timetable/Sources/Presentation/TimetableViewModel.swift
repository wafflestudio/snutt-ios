//
//  TimetableViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import TimetableInterface
import DependenciesAdditions
import SharedUIComponents

@MainActor
class TimetableViewModel: ObservableObject {
    @Dependency(\.timetableUseCase) private var timetableUseCase
    @Published var currentTimetable: (any Timetable)?
    @Published var selectedLecture: (any Lecture)?
    @Published private(set) var configuration: TimetableConfiguration = .init()
    @Published var paths = [TimetableDetailSceneTypes]()

    var totalCredit: Int {
        let credit = currentTimetable?.lectures.reduce(0) { $0 + ($1.credit ?? 0) } ?? 0
        return Int(credit)
    }

    var timetableTitle: String {
        currentTimetable?.title ?? ""
    }

    func loadTimetable() async {
        do {
            currentTimetable = try await timetableUseCase.loadRecentTimetable()
        } catch {
            print(error)
        }
    }
}

enum TimetableDetailSceneTypes {
    case lectureList
}

extension TimetableViewModel: TimetablePainter {}
