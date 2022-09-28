//
//  Publisher+SinkWithAnimation.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/16.
//

import Combine
import SwiftUI

extension Publisher where Self.Failure == Never {
    public func sinkWithAnimation(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        return sink { newValue in
            withAnimation(.customSpring) {
                receiveValue(newValue)
            }
        }
    }
}

