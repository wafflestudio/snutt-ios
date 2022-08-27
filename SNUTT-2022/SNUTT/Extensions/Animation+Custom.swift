//
//  Animation+Custom.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/23.
//

import SwiftUI

extension Animation {
    static var customSpring: Animation {
        spring(response: 0.2, dampingFraction: 1, blendDuration: 0)
    }
}
