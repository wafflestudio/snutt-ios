//
//  PopupScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/08.
//

import Combine
import SwiftUI

struct PopupScene: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        GeometryReader { reader in
            if let currentPopup = viewModel.currentPopup {
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .ignoresSafeArea(.all)
                    PopupView(popup: currentPopup,
                              dismiss: viewModel.dismiss(popup:dontShowForWhile:))
                        .padding(.horizontal, reader.size.width * 0.1)
                }
            }
        }
        .animation(.customSpring, value: viewModel.currentPopup?.id)
        .onChange(of: viewModel.currentPopup?.id) { newPopupId in
            if newPopupId != nil {
                FirebaseAnalyticsLogger().logScreen(.popup)
            }
        }
        .onLoad {
            await viewModel.getRecentPopupList()
        }
    }
}

extension PopupScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published private var currentPopupList: [Popup] = []

        override init(container: DIContainer) {
            super.init(container: container)
            appState.popup.$currentList.assign(to: &$currentPopupList)
        }

        var currentPopup: Popup? {
            appState.popup.currentList.first { $0.shouldShow }
        }

        func dismiss(popup: Popup, dontShowForWhile: Bool) {
            services.popupService.dismissPopup(popup: popup, dontShowForWhile: dontShowForWhile)
        }

        func getRecentPopupList() async {
            do {
                try await services.popupService.getRecentPopupList()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}
