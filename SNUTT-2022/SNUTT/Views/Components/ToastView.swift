//
//  ToastView.swift
//  SNUTT
//
//  Created by 최유림 on 7/3/25.
//

import SwiftUI

struct ToastViewModifier: ViewModifier {
  
    @Binding var toast: Toast?
    @Binding var buttonAction: (() -> Void)?
    
    @State private var displayToast: Task<Void, Never>?
    @State private var currentToast: Toast?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: toast) { newToast in
                // Remove previous toast
                displayToast?.cancel()
                displayToast = nil
                withAnimation {
                    self.currentToast = nil
                }
                
                guard let newToast else { return }
                
                Task { @MainActor in
                    // Delay 0.05 sec
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    withAnimation {
                        self.currentToast = newToast
                    }
                    displayToast = Task { @MainActor in
                        // Duration 3 sec
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        withAnimation {
                            self.toast = nil
                            self.currentToast = nil
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let toast = currentToast {
                    ToastView(
                        label: toast.type.message,
                        showButton: toast.type.showButton,
                        action: buttonAction
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>, _ buttonAction: Binding<(() -> Void)?>) -> some View {
        modifier(ToastViewModifier(toast: toast, buttonAction: buttonAction))
    }
}

private struct ToastView: View {
    
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
