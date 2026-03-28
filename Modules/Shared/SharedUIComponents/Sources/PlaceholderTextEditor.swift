//
//  PlaceholderTextEditor.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

public struct PlaceholderTextEditor: View {
    let placeholder: String
    @Binding var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(SharedUIComponentsAsset.alternative.swiftUIColor)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .introspect(.textEditor, on: .iOS(.v17, .v18, .v26)) { textView in
                    textView.textContainerInset = .zero
                    textView.textContainer.lineFragmentPadding = 0
                }
        }
    }
}
