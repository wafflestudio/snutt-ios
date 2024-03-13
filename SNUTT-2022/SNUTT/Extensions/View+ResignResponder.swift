//
//  View+ResignResponder.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/17.
//

import SwiftUI

#if canImport(UIKit)
    extension View {
        func resignFirstResponder() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif
