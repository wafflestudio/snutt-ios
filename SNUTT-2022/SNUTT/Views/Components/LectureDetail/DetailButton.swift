//
//  DetailButton.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/17.
//

import SwiftUI

struct DetailButton: View {
    let text: String
    let role: ButtonRole?
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding()
                .contentShape(Rectangle())
                .foregroundColor(role == .destructive ? .red : Color(uiColor: .label))
        }
        .buttonStyle(RectangleButtonStyle(color: STColor.groupForeground))
    }
}

extension DetailButton {
    init(text: String, action: @escaping () -> Void) {
        self.text = text
        role = nil
        self.action = action
    }
}

struct DetailButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            STColor.groupBackground
            VStack {
                DetailButton(text: "강의평") {}
            }
            .background(STColor.groupForeground)
        }
    }
}
