//
//  TimetableService.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation
import SwiftUI

protocol TimetableServiceProtocol {
    func fetchRecentTimetable() async throws
    func fetchTimetableList() async throws
    func fetchTimetable(timetableId: String) async throws
    func copyTimetable(timetableId: String) async throws
    func updateTimetableTitle(timetableId: String, title: String) async throws
    func updateTimetableTheme(timetableId: String) async throws
    func deleteTimetable(timetableId: String) async throws
    func selectTimetableTheme(theme: Theme)
}

struct TimetableService: TimetableServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    var timetableRepository: TimetableRepositoryProtocol {
        webRepositories.timetableRepository
    }

    func fetchTimetable(timetableId: String) async throws {
        if appState.timetable.current?.id == timetableId {
            // skip fetching
            return
        }
        let dto = try await timetableRepository.fetchTimetable(timetableId: timetableId)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            withAnimation(.customSpring) {
                appState.timetable.current = timetable
            }
        }
    }

    func fetchRecentTimetable() async throws {
        if let _ = appState.timetable.current {
            // skip fetching
            return
        }
        let dto = try await timetableRepository.fetchRecentTimetable()
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.timetable.current = timetable
        }
    }

    func fetchTimetableList() async throws {
        if let _ = appState.timetable.metadataList {
            // skip fetching
            return
        }
        let dtos = try await timetableRepository.fetchTimetableList()
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        DispatchQueue.main.async {
            withAnimation(.customSpring) {
                appState.timetable.metadataList = timetables
            }
        }
    }

    func copyTimetable(timetableId: String) async throws {
        let dtos = try await timetableRepository.copyTimetable(withTimetableId: timetableId)
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        DispatchQueue.main.async {
            withAnimation(.customSpring) {
                appState.timetable.metadataList = timetables
            }
        }
    }

    func updateTimetableTitle(timetableId: String, title: String) async throws {
        let dtos = try await timetableRepository.updateTimetableTitle(withTimetableId: timetableId, withTitle: title)
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        DispatchQueue.main.async {
            withAnimation(.customSpring) {
                appState.timetable.metadataList = timetables
                if appState.timetable.current?.id == timetableId {
                    appState.timetable.current?.title = title
                }
            }
        }
    }

    func updateTimetableTheme(timetableId: String) async throws {
        guard let theme = appState.timetable.current?.selectedTheme else { return }
        let dto = try await timetableRepository.updateTimetableTheme(withTimetableId: timetableId, withTheme: theme.rawValue)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            withAnimation(.customSpring) {
                if appState.timetable.current?.id == timetableId {
                    appState.timetable.current = timetable
                }
            }
        }
    }

    func deleteTimetable(timetableId: String) async throws {
        if appState.timetable.current?.id == timetableId {
            throw STError.CANT_DELETE_CURRENT_TIMETABLE
        }
        let dtos = try await timetableRepository.deleteTimetable(withTimetableId: timetableId)
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        DispatchQueue.main.async {
            withAnimation(.customSpring) {
                appState.timetable.metadataList = timetables
            }
        }
    }

    func selectTimetableTheme(theme: Theme) {
        withAnimation(.customSpring) {
            appState.timetable.current?.selectedTheme = theme
        }
    }
}

struct FakeTimetableService: TimetableServiceProtocol {
    func fetchRecentTimetable() {}
    func fetchTimetableList() {}
    func fetchTimetable(timetableId _: String) {}
    func copyTimetable(timetableId _: String) {}
    func updateTimetableTitle(timetableId _: String, title _: String) {}
    func updateTimetableTheme(timetableId _: String) async throws {}
    func deleteTimetable(timetableId _: String) async throws {}
    func selectTimetableTheme(theme _: Theme) {}
}
