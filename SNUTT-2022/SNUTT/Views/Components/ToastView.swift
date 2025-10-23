//
//  ToastView.swift
//  SNUTT
//
//  Created by 최유림 on 7/3/25.
//

import SwiftUI

struct ToastViewModifier: ViewModifier {
  
    @Binding var toast: Toast?
    @State private var currentToast: Toast?
    
    func body(content: Content) -> some View {
        content
            .task(id: toast?.id, priority: .high) {
                withAnimation {
                    self.currentToast = nil
                }
                guard let _ = toast?.id else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    withAnimation {
                        self.currentToast = toast
                    }
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    withAnimation {
                        self.toast = nil
                        self.currentToast = nil
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let toast = currentToast {
                    ToastView(toast: toast)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
            }
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastViewModifier(toast: toast))
    }
}

private struct ToastView: View {
    
    let toast: Toast
    
    var body: some View {
        HStack {
            Text(toast.type.message)
                .font(STFont.medium14.font)
                .foregroundStyle(.white)
            Spacer()
            if let action = toast.action {
                Button {
                    action()
                } label: {
                    Text("보기")
                        .font(STFont.medium14.font)
                        .foregroundStyle(STColor.milkMint)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)),
                removal: .opacity.combined(with: .identity)
            )
        )
    }
}
