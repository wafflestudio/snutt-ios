//
//  UITextEditor.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/18.
//

import SwiftUI
import UIKit

/// A bug-free UIKit version of `TextEditor` that supports dynamic height, automatic scrolling, placeholder, etc.
///
/// To implement dynamic height, it is required to set the height of the frame explicitly, where the `height` is bound to `textView.contentSize.height`:
///
/// ```
/// UITextEditor(text: $text) { textView in
///     height = textView.contentSize.height
/// }
/// .frame(height: height)
/// ```
struct UITextEditor: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    let configureView: ((UITextView) -> Void)?
    let textDidChange: (UITextView) -> Void

    let textView = UITextView()
    let placeholderView = UITextView()

    init(text: Binding<String>, configureView: ((UITextView) -> Void)? = nil, onChange: @escaping (UITextView) -> Void) {
        placeholder = ""
        _text = text
        self.configureView = configureView
        textDidChange = onChange
    }

    init(_ placeholder: String, text: Binding<String>, configureView: ((UITextView) -> Void)? = nil, onChange: @escaping (UITextView) -> Void) {
        self.placeholder = placeholder
        _text = text
        self.configureView = configureView
        textDidChange = onChange
    }

    func makeUIView(context: Context) -> UITextView {
        textView.text = text
        textView.autocorrectionType = .no
        textView.delegate = context.coordinator
        configureView?(textView)

        placeholderView.text = placeholder
        placeholderView.isHidden = !text.isEmpty
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.backgroundColor = .clear
        placeholderView.isScrollEnabled = false
        placeholderView.isUserInteractionEnabled = false
        placeholderView.textColor = .placeholderText
        configureView?(placeholderView)

        textView.addSubview(placeholderView)
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: textView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
        ])
        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        Task { @MainActor in
            if !uiView.isFirstResponder {
                // When this uiView is the first responder, `uiView.delegate` takes care of all the view updates.
                // When it's not, manually call delegate method to trigger ui update.
                uiView.text = text
                uiView.delegate?.textViewDidChange?(uiView)
            }
            self.textDidChange(uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, placeholderTextView: placeholderView, textDidChange: textDidChange)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        let textDidChange: (UITextView) -> Void
        private var cursorScrollPositionAnimator: UIViewPropertyAnimator?
        weak var placeholderTextView: UITextView?

        init(text: Binding<String>, placeholderTextView: UITextView, textDidChange: @escaping (UITextView) -> Void) {
            _text = text
            self.placeholderTextView = placeholderTextView
            self.textDidChange = textDidChange
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            placeholderTextView?.isHidden = !textView.text.isEmpty
            textDidChange(textView)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            textView.text = text
            placeholderTextView?.isHidden = !text.isEmpty
        }

        // MARK: Automatic Scrolling

        // Automatically scroll to ensure that the cursor is always visible

        func textViewDidChangeSelection(_ textView: UITextView) {
            if textView.isFirstResponder {
                ensureCursorVisible(textView: textView)
            }
        }

        private func findParentScrollView(of view: UIView) -> UIScrollView? {
            var current = view
            while let superview = current.superview {
                if let scrollView = superview as? UIScrollView {
                    return scrollView
                } else {
                    current = superview
                }
            }
            return nil
        }

        private func ensureCursorVisible(textView: UITextView) {
            guard let scrollView = findParentScrollView(of: textView),
                  let range = textView.selectedTextRange
            else {
                return
            }

            let cursorRect = textView.caretRect(for: range.start)
            var rectToMakeVisible = textView.convert(cursorRect, to: scrollView)

            rectToMakeVisible.origin.y -= cursorRect.height
            rectToMakeVisible.size.height *= 3

            if let existing = cursorScrollPositionAnimator {
                existing.stopAnimation(true)
            }

            let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                scrollView.scrollRectToVisible(rectToMakeVisible, animated: false)
            }
            animator.startAnimation()
            cursorScrollPositionAnimator = animator
        }
    }
}
