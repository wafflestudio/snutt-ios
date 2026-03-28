//
//  TimetableGeometry.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import CoreGraphics
import SwiftUI

public struct TimetableGeometry: Sendable {
    public let size: CGSize
    public let safeAreaInsets: EdgeInsets

    public init(size: CGSize, safeAreaInsets: EdgeInsets) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
    }

    public init(_ geometry: GeometryProxy) {
        self.size = geometry.size
        self.safeAreaInsets = geometry.safeAreaInsets
    }

    public var extendedContainerSize: CGSize {
        .init(width: size.width, height: size.height + safeAreaInsets.bottom)
    }
}
