//
//  DetailLabel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/17.
//

import SwiftUI

struct DetailLabel: View {
    let text: String
    var body: some View {
        VStack {
            Text(text)
                .padding(.trailing, 10)
                .padding(.top, 2.5)
                .font(STFont.regular14.font)
                .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.6)))
                .lineLimit(1)
                .frame(maxWidth: 84, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct DetailLabel_Previews: PreviewProvider {
    static var previews: some View {
        DetailLabel(text: "제목")
    }
}
