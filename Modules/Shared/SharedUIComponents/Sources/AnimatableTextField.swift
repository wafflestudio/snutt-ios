//
//  AnimatableTextField.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI
import SwiftUIUtility

@MemberwiseInit(.public)
public struct AnimatableTextField: View {
    public let label: String
    @Init(default: "") public let placeholder: String

    @Init(default: false) public let secure: Bool

    @Init(default: UIKeyboardType.default) public let keyboardType: UIKeyboardType

    @Init(default: SubmitLabel.return) public let submitLabel: SubmitLabel

    @InitWrapper(type: Binding<String>.self)
    @Binding public var text: String

    private enum Design {
        static let label = Font.system(size: 14, weight: .regular)
        static let textFieldHeight: CGFloat = 20
        static let animatedLineHeight: CGFloat = 1
    }

    public var body: some View {
        VStack {
            Text(label)
                .font(Design.label)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Group {
                    if secure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(submitLabel)
                .font(Design.label)
                .frame(height: Design.textFieldHeight)
            }

            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: Design.animatedLineHeight)
                    .foregroundColor(Color(uiColor: .quaternaryLabel))

                Rectangle()
                    .frame(maxWidth: text.isEmpty ? 0 : .infinity, alignment: .leading)
                    .frame(height: Design.animatedLineHeight)
                    .foregroundColor(SharedUIComponentsAsset.cyan.swiftUIColor)
                    .animation(.defaultSpring, value: text.isEmpty)
            }
        }
    }
}

private struct PreviewProvider: View {
    @State private var text: String = ""
    var body: some View {
        AnimatableTextField(label: "로그인", text: $text)
    }
}

#Preview {
    PreviewProvider()
}
