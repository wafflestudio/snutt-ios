//
//  EvaluationStarRatingInput.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

/// Five stars that set a rating in half-star steps by tapping or dragging, adjustable with VoiceOver.
struct EvaluationStarRatingInput: View {
    @Binding var rating: Double?
    let accessibilityLabel: String
    var starSize: CGFloat = 28

    private static let range = 0.5...5.0
    private static let step = 0.5

    @ScaledMetric private var spacing = 6.0

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...5, id: \.self) { index in
                let fill = EvaluationStarGlyph.Fill(rating: rating ?? 0, position: index)
                EvaluationStarGlyph(fill: fill, size: starSize)
                    .scaleEffect(fill == .empty ? 0.92 : 1)
            }
        }
        .contentShape(.rect)
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .contentShape(.rect)
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                updateRating(at: value.location.x, width: proxy.size.width)
                            }
                    )
                    .modifier(
                        HorizontalScrubModifier { x in
                            updateRating(at: x, width: proxy.size.width)
                        }
                    )
            }
        }
        .animation(.defaultSpring, value: rating)
        .sensoryFeedback(.selection, trigger: rating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(rating.map { EvaluationsStrings.writeStarRatingAccessibility($0.ratingText) } ?? "")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                rating = min(Self.range.upperBound, (rating ?? 0) + Self.step)
            case .decrement:
                // Nothing to lower before a rating is picked.
                guard let rating else { return }
                self.rating = max(Self.range.lowerBound, rating - Self.step)
            @unknown default:
                break
            }
        }
    }

    private func updateRating(at x: CGFloat, width: CGFloat) {
        guard width > 0 else { return }
        let raw = Double(x / width) * Self.range.upperBound
        let stepped = (raw / Self.step).rounded(.up) * Self.step
        let newRating = min(max(stepped, Self.range.lowerBound), Self.range.upperBound)
        if newRating != rating {
            rating = newRating
        }
    }

}

/// Scrubs with horizontal pans only, so vertical pans keep scrolling the enclosing form.
private struct HorizontalScrubModifier: ViewModifier {
    let onScrub: (CGFloat) -> Void

    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.gesture(HorizontalPanGesture(onChange: onScrub))
        } else {
            content
        }
    }
}

@available(iOS 18, *)
private struct HorizontalPanGesture: UIGestureRecognizerRepresentable {
    let onChange: (CGFloat) -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        guard recognizer.state == .began || recognizer.state == .changed else { return }
        onChange(context.converter.localLocation.x)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y)
        }
    }
}

#Preview {
    @Previewable @State var rating: Double? = 3.5
    EvaluationStarRatingInput(rating: $rating, accessibilityLabel: "총점")
        .padding()
}
