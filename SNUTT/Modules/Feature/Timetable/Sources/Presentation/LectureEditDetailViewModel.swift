//
//  LectureEditDetailViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation
import TimetableInterface

@MainActor
@Observable
final class LectureEditDetailViewModel {
    @ObservationIgnored
    @Dependency(\.lectureRepository) private var lectureRepository

    let entryLecture: Lecture
    var editableLecture: Lecture

    var buildings: [Building] = []

    var showMapView: Bool {
        !buildings.isEmpty && isGwanak
    }

    var showMapMismatchWarning: Bool {
        !entryLecture.timePlaces.map { $0.place }.allSatisfy { place in
            buildings.contains { place.hasPrefix($0.number) }
        }
    }

    private var isGwanak: Bool {
        buildings.allSatisfy { $0.campus == .GWANAK }
    }

    init(entryLecture: Lecture) {
        self.entryLecture = entryLecture
        editableLecture = entryLecture
    }

    // TODO: supportForMapViewEnabled = appState.system.configs?.disableMapFeature

    func fetchBuildingList() async {
        let lecturePlaces = entryLecture.timePlaces.map { $0.place }
        do {
            buildings = try await lectureRepository.fetchBuildingList(places: lecturePlaces)
        } catch {
            print(error)
        }
    }
}


extension Lecture {
    var quotaDescription: String? {
        get {
            if let quota, let freshmenQuota {
                return "\(quota)(\(freshmenQuota))"
            }
            return nil
        }
        set {}
    }
}
