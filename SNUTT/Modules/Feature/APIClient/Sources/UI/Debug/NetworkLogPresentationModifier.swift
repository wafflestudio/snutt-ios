//
//  NetworkLogPresentationModifier.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import SwiftUI

    struct NetworkLogPresentationModifier: ViewModifier {
        @State private var isPresented: Bool = false

        func body(content: Content) -> some View {
            if #available(iOS 18.0, *) {
                content
                    .gesture(
                        TwoFingerLongPressGesture {
                            isPresented = true
                        }
                    )
                    .sheet(isPresented: $isPresented) {
                        NavigationStack {
                            NetworkLogsScene()
                        }
                        .presentationDetents([.medium, .large, .fraction(0.4)])
                        .presentationBackgroundInteraction(.enabled)
                        .presentationContentInteraction(.scrolls)
                    }
            } else {
                EmptyView()
            }
        }
    }

    extension View {
        public func observeNetworkLogsGesture() -> some View {
            modifier(NetworkLogPresentationModifier())
        }
    }
#endif
