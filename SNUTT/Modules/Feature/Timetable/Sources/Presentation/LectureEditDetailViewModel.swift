//
//  LectureEditDetailViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import FoundationUtility
import Observation
import SwiftUI
import TimetableInterface
import VacancyInterface

@MainActor
@Observable
public final class LectureEditDetailViewModel {
    @ObservationIgnored
    @Dependency(\.lectureRepository) private var lectureRepository

    @ObservationIgnored
    @Dependency(\.vacancyRepository) private var vacancyRepository

    /// Might be `nil` if write operation is not necessary.
    private let timetableViewModel: TimetableViewModel?

    var entryLecture: Lecture
    var editableLecture: Lecture

    var buildings: [Building] = []

    private(set) var isBookmarked = false
    private(set) var isVacancyNotificationEnabled = false
    nonisolated let lectureID: String

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
        self.entryLecture = entryLecture
        editableLecture = entryLecture
        lectureID = entryLecture.id

        Task {
            await fetchBookmarkStatus()
            await fetchVacancyNotificationStatus()
        }
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

    func deleteLecture() async throws {
        guard let timetableViewModel else { return }
        try await timetableViewModel.removeLecture(lecture: entryLecture)
    }

    func resetLecture() async throws {
        guard let timetableViewModel, let timetableID = timetableViewModel.currentTimetable?.id,
            !entryLecture.isCustom
        else { return }

        let timetable = try await lectureRepository.resetLecture(
            timetableID: timetableID,
            lectureID: entryLecture.id
        )
        try timetableViewModel.setCurrentTimetable(timetable)

        guard let resetLecture = timetable.lectures.first(where: { $0.id == entryLecture.id }) else { return }
        entryLecture = resetLecture
        editableLecture = resetLecture
    }

    private func fetchBookmarkStatus() async {
        guard !entryLecture.isCustom else { return }
        isBookmarked = (try? await lectureRepository.isBookmarked(lectureID: entryLecture.id)) ?? false
    }

    private func fetchVacancyNotificationStatus() async {
        guard !entryLecture.isCustom else { return }
        isVacancyNotificationEnabled =
            (try? await vacancyRepository
                .isVacancyNotificationEnabled(lectureID: entryLecture.id)) ?? false
    }

    func toggleBookmark() async throws {
        guard !entryLecture.isCustom else { return }
        if isBookmarked {
            try await lectureRepository.removeBookmark(lectureID: entryLecture.id)
        } else {
            try await lectureRepository.addBookmark(lectureID: entryLecture.id)
        }
        isBookmarked.toggle()
    }

    func toggleVacancyNotification() async throws {
        guard !entryLecture.isCustom else { return }
        if isVacancyNotificationEnabled {
            try await vacancyRepository.deleteVacancyLecture(lectureID: entryLecture.id)
        } else {
            try await vacancyRepository.addVacancyLecture(lectureID: entryLecture.id)
        }
        isVacancyNotificationEnabled.toggle()
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
