//
//  FriendMenuSheetModifier.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

extension View {
    func friendMenuSheet(
        isPresented: Binding<Bool>,
        viewModel: FriendsViewModel
    ) -> some View {
        customSheet(
            isPresented: isPresented,
            configuration: .init(
                orientation: .left(maxWidth: 320),
                cornerRadius: 0,
                sheetOpacity: 0.7
            )
        ) {
            FriendMenuContentView(friendsViewModel: viewModel)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    let viewModel = FriendsViewModel()
    let _ = Task {
        try await viewModel.initialLoadFriends()
    }
    ZStack {
        Color.clear.ignoresSafeArea()
        Button("Show Friend Menu: \(isPresented.description)") {
            isPresented.toggle()
        }
        .friendMenuSheet(isPresented: $isPresented, viewModel: viewModel)
    }
    .overlaySheet()
}
