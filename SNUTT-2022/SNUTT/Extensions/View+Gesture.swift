//
//  View+Gesture.swift
//  SNUTT
//
//  Created by 이채민 on 1/7/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func sheetGesture(_ translation: Binding<CGFloat>, dismiss: @escaping @MainActor () -> Void) -> some View {
        if #available(iOS 18.0, *) {
            gesture(SheetGestureRecognizer(translation: translation, dismiss: dismiss))
        } else {
            highPriorityGesture(DragGesture().onChanged { value in
                translation.wrappedValue = value.translation.width
            }.onEnded { value in
                translation.wrappedValue = 0
                if value.velocity.width < -500 || value.translation.width < -100 {
                    dismiss()
                }
            })
        }
    }
}

@available(iOS 18.0, *)
private struct SheetGestureRecognizer: UIGestureRecognizerRepresentable {
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator(translation: $translation, dismiss: dismiss)
    }
    
    @Binding var translation: CGFloat
    let dismiss: () -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan))
        return recognizer
    }

    final class Coordinator: NSObject {
        @Binding var translation: CGFloat
        let dismiss: () -> Void

        init(translation: Binding<CGFloat>, dismiss: @escaping () -> Void) {
            _translation = translation
            self.dismiss = dismiss
        }

        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            switch recognizer.state {
            case .changed:
                translation = recognizer.translation(in: recognizer.view).x
            case .ended:
                if shouldDismiss(recognizer) {
                    dismiss()
                }
                translation = 0
            default:
                break
            }
        }

        private func shouldDismiss(_ recognizer: UIPanGestureRecognizer) -> Bool {
            let velocity = recognizer.velocity(in: recognizer.view).x
            let translation = recognizer.translation(in: recognizer.view).x
            return velocity < -500 || translation < -100
        }
    }
}
