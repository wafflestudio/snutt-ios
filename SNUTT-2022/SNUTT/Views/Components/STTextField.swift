//
//  STTextField.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/20.
//

import SwiftUI
import UIKit

struct STTextField: UIViewRepresentable {
    @Binding var isFirstResponder: Bool
    @Binding var text: String
    let placeholder: String

    public var configuration = { (_: UITextField) in }

    public init(_ placeholder: String, text: Binding<String>, focused: Binding<Bool>, configuration: @escaping (UITextField) -> Void = { _ in }) {
        self.configuration = configuration
        _text = text
        _isFirstResponder = focused
        self.placeholder = placeholder
    }

    public func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        view.placeholder = placeholder
        return view
    }

    public func updateUIView(_ uiView: UITextField, context _: Context) {
        uiView.text = text
        configuration(uiView)
        switch isFirstResponder {
        case true: uiView.becomeFirstResponder()
        case false: uiView.resignFirstResponder()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($text, isFirstResponder: $isFirstResponder)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>

        init(_ text: Binding<String>, isFirstResponder: Binding<Bool>) {
            self.text = text
            self.isFirstResponder = isFirstResponder
        }

        @objc public func textViewDidChange(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        public func textFieldDidBeginEditing(_: UITextField) {
            isFirstResponder.wrappedValue = true
        }

        public func textFieldDidEndEditing(_: UITextField) {
            isFirstResponder.wrappedValue = false
        }
    }
}
