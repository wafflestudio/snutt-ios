//
//  ThemeDetailViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility
import Foundation
import Observation
import ThemesInterface
import TimetableInterface

@MainActor
@Observable
final class ThemeDetailViewModel {
    @ObservationIgnored
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository

    @ObservationIgnored
    @Dependency(\.themeRepository) private var themeRepository

    @ObservationIgnored
    @Dependency(\.notificationCenter) private var notificationCenter

    private let entryTheme: Theme
    let isNewTheme: Bool
    var editableTheme: Theme
    private(set) var identifiableColors: [IdentifiableColor] = [] {
        didSet {
            editableTheme.colors = identifiableColors.map { $0.color }
        }
    }

    private(set) var timetable: Timetable?
    private(set) var configuration: TimetableConfiguration = .init()

    init(entryTheme: Theme?) {
        self.entryTheme = entryTheme ?? .newTheme
        self.isNewTheme = entryTheme == nil
        self.editableTheme = self.entryTheme
        self.identifiableColors = self.editableTheme.colors.map { IdentifiableColor(color: $0) }
        self.timetable = try? timetableLocalRepository.loadSelectedTimetable()
        self.configuration = timetableLocalRepository.loadTimetableConfiguration()
    }

    var isThemeEditable: Bool {
        isNewTheme || entryTheme.status == .customPrivate
    }

    func addColor() {
        identifiableColors.append(IdentifiableColor(color: .cyan))
    }

    func duplicateColor(id: UUID) {
        guard let index = identifiableColors.firstIndex(where: { $0.id == id }) else { return }
        let color = identifiableColors[index].color
        identifiableColors.insert(IdentifiableColor(color: color), at: index + 1)
    }

    func deleteColor(id: UUID) {
        let newIdentifiableColors = identifiableColors.filter { $0.id != id }
        guard !newIdentifiableColors.isEmpty else { return }
        identifiableColors = newIdentifiableColors
    }

    func updateColorFg(id: UUID, hex: String) {
        guard let index = identifiableColors.firstIndex(where: { $0.id == id }) else { return }
        identifiableColors[index] = IdentifiableColor(
            color: .init(fgHex: hex, bgHex: identifiableColors[index].color.bgHex)
        )
    }

    func updateColorBg(id: UUID, hex: String) {
        guard let index = identifiableColors.firstIndex(where: { $0.id == id }) else { return }
        identifiableColors[index] = IdentifiableColor(
            color: .init(fgHex: identifiableColors[index].color.fgHex, bgHex: hex)
        )
    }

    func save() async throws {
        if isNewTheme {
            editableTheme = try await themeRepository.createTheme(theme: editableTheme)
        } else {
            editableTheme = try await themeRepository.updateTheme(theme: editableTheme)
        }
        notificationCenter.post(CustomThemeDidUpdateMessage())
    }
}

struct IdentifiableColor: Identifiable, Hashable {
    let id = UUID()
    let color: LectureColor
}

extension Theme {
    fileprivate static var newTheme: Theme {
        .init(
            id: UUID().uuidString,
            name: "새 테마",
            colors: [
                .init(fgHex: "#FFFFFF", bgHex: "#1BD0C8")
            ],
            status: .customPrivate
        )
    }
}
