//
//  PopupViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@Observable
@MainActor
class PopupViewModel {
    @ObservationIgnored
    @Dependency(\.popupUseCase) private var popupUseCase

    private var currentPopupList: [PopupModel] = []
    var currentPopup: PopupModel? {
        currentPopupList.first(where: { $0.shouldShow })
    }

    func dismiss(popup: PopupModel, dontShowForWhile: Bool) {
        guard let index = currentPopupList.firstIndex(where: { $0.id == popup.id }) else { return }
        currentPopupList[index].markAsDismissed(dontShowForWhile: dontShowForWhile)
        popupUseCase.storePopupList(currentPopupList)
    }

    func fetchRecentPopupList() async throws {
        currentPopupList = try await popupUseCase.fetchRecentPopupList()
    }
}
