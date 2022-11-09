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
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .ignoresSafeArea(.all)
            PopupView(popup: viewModel.currentPopup,
                      dismissOnce: viewModel.dismissOnce(popupView:),
                      dismissNdays: viewModel.dismissNdays(popupView:))
        }
    }
}

extension PopupScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published private var _currentIndex = 0
        
        override init(container: DIContainer) {
            super.init(container: container)
            appState.popup.$currentIndex.assign(to: &$_currentIndex)
        }
        
        var currentPopup: Popup {
            appState.popup.currentList[_currentIndex]
        }
        
        func dismissOnce(popupView: PopupView) {
            services.popupService.showNextPopup()
        }
        
        func dismissNdays(popupView: PopupView) {
            services.popupService.saveLastUpdate(popup: popupView.popup)
            services.popupService.showNextPopup()
        }
    }
}
