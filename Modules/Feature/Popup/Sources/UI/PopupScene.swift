//
//  PopupScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

extension View {
    public func overlayADPopup() -> some View {
        overlay {
            PopupScene()
        }
    }
}

private struct PopupScene: View {
    @State private var viewModel: PopupViewModel = .init()
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        GeometryReader { reader in
            if let currentPopup = viewModel.currentPopup {
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .ignoresSafeArea(.all)
                    PopupView(viewModel: viewModel, popup: currentPopup)
                        .padding(.horizontal, reader.size.width * 0.1)
                        .id(currentPopup.id)
                }
            }
        }
        .animation(.defaultSpring, value: viewModel.currentPopup?.id)
        .onLoad {
            errorAlertHandler.withAlert {
                try await viewModel.fetchRecentPopupList()
            }
        }
    }
}

#Preview {
    PopupScene()
}
