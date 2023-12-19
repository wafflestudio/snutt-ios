//
//  InteractiveDismissKeyboardModifier.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/12/18.
//

import SwiftUI

struct InteractiveDismissesKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollDismissesKeyboard(.interactively)
        } else {
            content
        }
    }
}

extension View {
    func scrollDismissesKeyboardInteractively() -> some View {
        modifier(InteractiveDismissesKeyboardModifier())
    }
}
