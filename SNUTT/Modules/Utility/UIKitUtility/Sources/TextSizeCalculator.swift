//
//  TextSizeCalculator.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import UIKit

public final class TextSizeCalculator: NSObject, @unchecked Sendable {
    let textContentStorage: NSTextContentStorage
    let textLayoutManager: NSTextLayoutManager
    let textContainer: NSTextContainer

    override init() {
        textContentStorage = NSTextContentStorage()
        textLayoutManager = NSTextLayoutManager()
        textContainer = NSTextContainer()
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = textContainer
        textContainer.lineFragmentPadding = 0
        super.init()
        textLayoutManager.textViewportLayoutController.delegate = self
    }

    public nonisolated static func sizeThatFits(
        attributedText: NSAttributedString,
        maxWidth: CGFloat,
        maxHeight: CGFloat? = nil
    ) -> (size: CGSize, isOverflown: Bool) {
        let calculator = TextSizeCalculator()
        calculator.textContainerSize = .init(
            width: maxWidth,
            height: maxHeight ?? .greatestFiniteMagnitude
        )
        calculator.attributedString = attributedText
        calculator.layoutViewport()
        return calculator.sizeThatFits()
    }

    private func layoutViewport() {
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }

    private var textContainerSize: CGSize {
        get { textContainer.size }
        set {
            textContainer.size = newValue
        }
    }

    private var attributedString: NSAttributedString? {
        get {
            textContentStorage.attributedString
        }
        set {
            textContentStorage.textStorage?.setAttributedString(newValue ?? .init())
        }
    }

    private func sizeThatFits() -> (size: CGSize, isOverflown: Bool) {
        let usageBounds = textLayoutManager.usageBoundsForTextContainer
        let fittingSize = CGSize(
            width: ceil(usageBounds.maxX),
            height: ceil(usageBounds.maxY)
        )
        return (fittingSize, hasOverflownLayoutFragment())
    }

    private func hasOverflownLayoutFragment() -> Bool {
        var isOverflown = false
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.endLocation,
            options: [.reverse]
        ) { fragment in
            if fragment.state == .none {
                isOverflown = true
            }
            return false
        }
        return isOverflown
    }
}

extension TextSizeCalculator: NSTextViewportLayoutControllerDelegate {
    public func viewportBounds(for _: NSTextViewportLayoutController) -> CGRect {
        .init(origin: .zero, size: textContainerSize)
    }

    public func textViewportLayoutController(
        _: NSTextViewportLayoutController,
        configureRenderingSurfaceFor _: NSTextLayoutFragment
    ) {}
}
