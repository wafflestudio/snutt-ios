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
        modifier(PopoverTipModifier(displayMessage: message))
    }
}

private struct PopoverTipModifier: ViewModifier {
    let displayMessage: String

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .popoverTip(MessageTip(displayMessage: displayMessage), arrowEdge: .bottom)
                .tipViewStyle(MessageTipViewStyle())
        } else {
            content
        }
    }
}

@available(iOS 17.0, *)
private struct MessageTip: Tip {
    static let dismissed: Event = .init(id: "dismissedPopoverTip")

    var title: Text { Text("") }
    var message: Text? { Text(displayMessage) }
    var rules: [Rule] {
        #Rule(Self.dismissed) {
            $0.donations.count < 1
        }
    }

    var options: [any Option] {
        IgnoresDisplayFrequency(true)
    }

    let displayMessage: String
}

@available(iOS 17.0, *)
private struct MessageTipViewStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top) {
            configuration.message?
                .font(.system(size: 14))
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
                .tint(.secondary)
            Spacer()
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .medium))
                .tint(.primary.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .frame(width: 272)
    }
}
