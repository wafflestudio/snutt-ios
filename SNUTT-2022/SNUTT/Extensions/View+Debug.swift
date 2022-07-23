//
//  View+Debug.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import SwiftUI

extension View {
    func debugChanges() {
        #if DEBUG
        if #available(iOS 15.0, *) {
            Self._printChanges()
        }
        #endif
    }
}

