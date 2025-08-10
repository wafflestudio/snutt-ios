//
//  ToastView.swift
//  SNUTT
//
//  Created by 최유림 on 7/3/25.
//

import SwiftUI

struct ToastView: ViewModifier {
  
    @Binding var toast: ToastType?
    @Binding var buttonAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .animation(.linear(duration: 0.5), value: toast)
            .overlay(alignment: .bottom) {
                if let toast = toast {
                    Toast(
                        label: toast.message,
                        showButton: toast.showButton,
                        action: buttonAction
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .transition(.opacity)
                    .onAppear {
                        Task { @MainActor in
                            try await Task.sleep(nanoseconds: 3_000_000_000)
                            withAnimation {
                                self.toast = nil
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func toast(_ toast: Binding<ToastType?>, _ buttonAction: Binding<(() -> Void)?>) -> some View {
        modifier(ToastView(toast: toast, buttonAction: buttonAction))
    }
}

private struct Toast: View {
    
    let label: String
    let showButton: Bool
    let action: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            if showButton {
                Button {
                    action?()
                } label: {
                    Text("보기")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(STColor.milkMint)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.5))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
