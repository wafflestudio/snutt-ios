//
//  PopoverTipModifier.swift
//  SNUTT
//
//  Created by 최유림 on 2/3/25.
//

import SwiftUI
import TipKit

extension View {
    func popoverTipIfAvailable(_ message: String) -> some View {
        modifier(PopoverTipModifier(message: message))
    }
}

private struct PopoverTipModifier: ViewModifier {
    
    let message: String
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .popoverTip(MessageTip(_message: message), arrowEdge: .bottom)
        } else {
            content
        }
    }
}

@available(iOS 17.0, *)
private struct MessageTip: Tip {
    
    static let dismissed: Event = .init(id: "dismissedPopoverTip")
    
    var title: Text { Text("") }
    var message: Text? { Text(_message) }
    var rules: [Rule] {
        #Rule(Self.dismissed) {
            $0.donations.count < 1
        }
    }
    var options: [any Option] {
        IgnoresDisplayFrequency(true)
    }
    
    let _message: String
}
