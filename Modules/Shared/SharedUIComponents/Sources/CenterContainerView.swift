//
//  CenterContainerView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SnapKit
import UIKit

public final class CenterContainerView<ContentView: UIView>: UIView {
    let contentView: ContentView
    private let layoutOptions: LayoutOptions

    public init(contentView: ContentView, layoutOptions: LayoutOptions = .default) {
        self.contentView = contentView
        self.layoutOptions = layoutOptions
        super.init(frame: .zero)
        setupContentView()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupContentView() {
        addSubview(contentView)
        if !layoutOptions.expandsVertically {
            setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
        if !layoutOptions.expandsHorizontally {
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            if layoutOptions.contains(.expandVertically) {
                make.verticalEdges.equalToSuperview()
            }
            if layoutOptions.contains(.expandHorizontally) {
                make.horizontalEdges.equalToSuperview()
            }
        }
    }

    override public var intrinsicContentSize: CGSize {
        let respectsHeight = layoutOptions.contains(.respectIntrinsicHeight)
        let respectsWidth = layoutOptions.contains(.respectIntrinsicWidth)
        return .init(
            width: respectsWidth ? contentView.intrinsicContentSize.width : Self.noIntrinsicMetric,
            height: respectsHeight ? contentView.intrinsicContentSize.height : Self.noIntrinsicMetric
        )
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? contentView : view
    }
}

public struct LayoutOptions: OptionSet, Sendable {
    public let rawValue: Int8

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    public static let expandHorizontally = LayoutOptions(rawValue: 1 << 0)
    public static let expandVertically = LayoutOptions(rawValue: 1 << 1)
    public static let respectIntrinsicHeight = LayoutOptions(rawValue: 1 << 2)
    public static let respectIntrinsicWidth = LayoutOptions(rawValue: 1 << 3)
    public static let `default`: LayoutOptions = [.respectIntrinsicWidth, .respectIntrinsicHeight]

    fileprivate var expandsHorizontally: Bool {
        contains(.expandHorizontally)
    }

    fileprivate var expandsVertically: Bool {
        contains(.expandVertically)
    }
}
