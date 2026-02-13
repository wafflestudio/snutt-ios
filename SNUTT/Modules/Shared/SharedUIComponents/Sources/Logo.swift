//
//  Logo.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct Logo: View {
    public let orientation: Orientation
    public enum Orientation {
        case vertical, horizontal
    }

    public init(
        orientation: Orientation
    ) {
        self.orientation = orientation
    }

    public var body: some View {
        switch orientation {
        case .vertical:
            VStack(spacing: 16) {
                SharedUIComponentsAsset.logo.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                Text("SNUTT")
                    .font(.system(size: 22, weight: .heavy))
            }
        case .horizontal:
            HStack {
                HStack(spacing: 16) {
                    SharedUIComponentsAsset.logo.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)

                    Text("SNUTT")
                        .font(.system(size: 22, weight: .bold))
                }
            }
        }
    }
}

#Preview {
    VStack {
        Logo(orientation: .horizontal)
    }
}
