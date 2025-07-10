//
//  LectureEditDetailViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
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
        lectureID = entryLecture.id
        self.entryLecture = entryLecture
        editableLecture = entryLecture
    }

    // TODO: supportForMapViewEnabled = appState.system.configs?.disableMapFeature

    func fetchBuildingList() async {
        let lecturePlaces = entryLecture.timePlaces.map { $0.place }
        buildings = (try? await lectureRepository.fetchBuildingList(places: lecturePlaces)) ?? []
    }

    func saveEditableLecture(overrideOnConflict: Bool = false) async throws {
        guard let timetableViewModel, let timetableID = timetableViewModel.currentTimetable?.id else { return }
        let lectureID = editableLecture.id
        do {
            let timetable = try await lectureRepository.updateLecture(
                timetableID: timetableID,
                lecture: editableLecture,
                overrideOnConflict: overrideOnConflict
            )
            try timetableViewModel.setCurrentTimetable(timetable)
            guard let updatedLecture = timetable.lectures.first(where: { $0.id == lectureID }) else { return }
            entryLecture = updatedLecture
        } catch {
            throw error
        }
    }

    func addCustomLecture(overrideOnConflict: Bool = false) async throws {
        guard let timetableViewModel, let timetableID = timetableViewModel.currentTimetable?.id else { return }
        do {
            let timetable = try await lectureRepository.addCustomLecture(
                timetableID: timetableID,
                lecture: editableLecture,
                overrideOnConflict: overrideOnConflict
            )
            try timetableViewModel.setCurrentTimetable(timetable)
        } catch {
            throw error
        }
    }

    func addTimePlace() {
        let newTimePlace = TimePlace(
            id: UUID().uuidString,
            day: .mon,
            startTime: Time(hour: 9, minute: 0),
            endTime: Time(hour: 10, minute: 0),
            place: "",
            isCustom: editableLecture.isCustom
        )
        editableLecture.timePlaces.append(newTimePlace)
    }

    func removeTimePlace(at index: Int) {
        guard index < editableLecture.timePlaces.count else { return }
        editableLecture.timePlaces.remove(at: index)
    }

    var canRemoveTimePlace: Bool {
        !editableLecture.timePlaces.isEmpty
    }

    var hasUnsavedChanges: Bool {
        editableLecture != entryLecture
    }

    func cancelEdit() {
        editableLecture = entryLecture
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
