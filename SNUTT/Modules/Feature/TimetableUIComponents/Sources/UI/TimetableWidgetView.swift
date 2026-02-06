//
//  TimetableWidgetView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

public struct TimetableWidgetView: View {
    let painter: TimetablePainter

    public init(painter: TimetablePainter) {
        self.painter = painter
    }

    public var body: some View {
        GeometryReader { reader in
            let geometry = TimetableGeometry(reader)
            ZStack(alignment: .top) {
                TimetableGridLayer(painter: painter, geometry: geometry)
                    .frame(width: geometry.size.width, height: geometry.extendedContainerSize.height)
                TimetableBlocksLayer(painter: painter, geometry: geometry)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

// MARK: Preview

#Preview {
    TimetableWidgetView(painter: makePreviewPainter())
}
