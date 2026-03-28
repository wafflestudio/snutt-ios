//
//  Sheet+Gesture.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func sheetGesture(
        _ translation: Binding<CGFloat>,
        dismiss: @escaping @MainActor () -> Void
    ) -> some View {
        if #available(iOS 18.0, *) {
            gesture(SheetGestureRecognizer(translation: translation, dismiss: dismiss))
        } else {
            highPriorityGesture(
                DragGesture().onChanged { value in
                    translation.wrappedValue = value.translation.width
                }.onEnded { value in
                    translation.wrappedValue = 0
                    if value.velocity.width < -300 || value.translation.width < -100 {
                        dismiss()
                    }
                }
            )
        }
    }
}

@available(iOS 18.0, *)
private struct SheetGestureRecognizer: UIGestureRecognizerRepresentable {
    @Binding var translation: CGFloat
    let dismiss: () -> Void

    typealias UIGestureRecognizerType = UIPanGestureRecognizer
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func makeCoordinator(converter _: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIGestureRecognizerType, context: Context) {
        switch recognizer.state {
        case .changed:
            translation = context.converter.translation(in: .local)?.x ?? 0
        case .ended:
            translation = 0
            if shouldDismiss(recognizer, context: context) {
                dismiss()
            }
        default:
            break
        }
    }

    private func shouldDismiss(_: UIGestureRecognizerType, context: Context) -> Bool {
        guard let velocity = context.converter.velocity(in: .local),
            let translation = context.converter.translation(in: .local)
        else { return false }
        return velocity.x < -300 || translation.x < -100
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
            true
        }

        func gestureRecognizer(_: UIGestureRecognizer, shouldRequireFailureOf _: UIGestureRecognizer) -> Bool {
            false
        }
    }
}
