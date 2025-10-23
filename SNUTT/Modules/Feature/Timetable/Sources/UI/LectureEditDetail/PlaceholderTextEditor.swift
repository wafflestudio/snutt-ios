//
//  PlaceholderTextEditor.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct PlaceholderTextEditor: View {
    let label: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .top) {
            if text.isEmpty == true {
                TextField(label, text: .constant(""), prompt: Text(placeholder))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 30, maxHeight: 400)
                .introspect(.textEditor, on: .iOS(.v17, .v18, .v26)) { textView in
                    textView.textContainerInset = .zero
                    textView.textContainer.lineFragmentPadding = 0
                }
        }
    }
}
