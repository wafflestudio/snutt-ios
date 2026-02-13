//
//  TwoFingerLongPressGesture.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import SwiftUI

    struct TwoFingerLongPressGesture: UIGestureRecognizerRepresentable {
        let action: () -> Void
        let minimumDuration: TimeInterval

        init(minimumDuration: TimeInterval = 0.1, action: @escaping () -> Void) {
            self.minimumDuration = minimumDuration
            self.action = action
        }

        func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
            let gesture = UILongPressGestureRecognizer()
            gesture.numberOfTouchesRequired = 2
            gesture.minimumPressDuration = minimumDuration
            gesture.delegate = context.coordinator
            return gesture
        }

        func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
            Coordinator()
        }

        func handleUIGestureRecognizerAction(
            _ recognizer: UILongPressGestureRecognizer,
            context: Context
        ) {
            if recognizer.state == .began {
                action()
            }
        }

        final class Coordinator: NSObject, UIGestureRecognizerDelegate {
            func gestureRecognizer(
                _ gestureRecognizer: UIGestureRecognizer,
                shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
            ) -> Bool {
                true
            }
        }
    }
#endif
