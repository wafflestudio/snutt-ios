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
public final class LectureEditDetailViewModel {
    @ObservationIgnored
    @Dependency(\.lectureRepository) private var lectureRepository

    /// Might be `nil` if write operation is not necessary.
    private let timetableViewModel: TimetableViewModel?

    let lectureID: String
    var entryLecture: Lecture
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

    init(timetableViewModel: TimetableViewModel?, entryLecture: Lecture) {
        self.timetableViewModel = timetableViewModel
        self.lectureID = entryLecture.id
        self.entryLecture = entryLecture
        editableLecture = entryLecture
    }

    // TODO: supportForMapViewEnabled = appState.system.configs?.disableMapFeature

    func fetchBuildingList() async {
        let lecturePlaces = entryLecture.timePlaces.map { $0.place }
        buildings = (try? await lectureRepository.fetchBuildingList(places: lecturePlaces)) ?? []
    }

    func saveEditableLecture() async throws {
        guard let timetableViewModel, let timetableID = timetableViewModel.currentTimetable?.id else { return }
        let lectureID = editableLecture.id
        do {
            let timetable = try await lectureRepository.updateLecture(timetableID: timetableID, lecture: editableLecture, overrideOnConflict: false)
            try timetableViewModel.setCurrentTimetable(timetable)
            guard let updatedLecture = timetable.lectures.first(where: { $0.id == lectureID }) else { return }
            entryLecture = updatedLecture
        } catch {
            editableLecture = entryLecture
            throw error
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
