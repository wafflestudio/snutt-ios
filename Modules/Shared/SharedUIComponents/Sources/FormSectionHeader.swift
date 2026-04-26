//
//  FormSectionHeader.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct FormSectionHeader: View {
    let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.footnote.bold())
            .dynamicTypeSize(.xSmall ... .xLarge)
    }
}
