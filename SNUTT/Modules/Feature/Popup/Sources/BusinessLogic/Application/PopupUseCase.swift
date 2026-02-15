//
//  PopupUseCase.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies

struct PopupUseCase {
    @Dependency(\.popupLocalRepository) private var localRepository
    @Dependency(\.popupServerRepository) private var serverRepository

    func fetchRecentPopupList() async throws -> [PopupModel] {
        let serverPopups = try await serverRepository.fetchPopups()
        let localPopups = localRepository.fetchPopups()
        return merge(localPopups: localPopups, into: serverPopups)
    }

    func storePopupList(_ popups: [PopupModel]) {
        let localPopups = popups.compactMap { $0.localPopup }
        localRepository.storePopups(localPopups)
    }

    private func merge(localPopups: [LocalPopup], into serverPopups: [ServerPopup]) -> [PopupModel] {
        let localPopupByKey = Dictionary(grouping: localPopups, by: { $0.key })
        return serverPopups.map { serverPopup in
            guard let localPopup = localPopupByKey[serverPopup.key]?.first else {
                return .init(serverPopup: serverPopup)
            }
            if serverPopup.hiddenDays != localPopup.dismissInfo.hiddenDays {
                return .init(serverPopup: serverPopup)
            }
            return .init(serverPopup: serverPopup, localPopup: localPopup)
        }
    }
}

struct PopupUseCaseKey: DependencyKey {
    static let liveValue: PopupUseCase = .init()
}

extension DependencyValues {
    var popupUseCase: PopupUseCase {
        get { self[PopupUseCaseKey.self] }
        set { self[PopupUseCaseKey.self] = newValue }
    }
}
