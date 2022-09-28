//
//  EllipsisSheetButton.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct EllipsisSheetButton: View {
    let imageName: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 10)
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
        }
        .buttonStyle(RectangleButtonStyle())
    }
}

struct EllipsisSheetButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            EllipsisSheetButton(imageName: "pen", text: "이름 변경") {
                print("tap")
            }
            EllipsisSheetButton(imageName: "trash", text: "시간표 삭제") {
                print("tap")
            }
            EllipsisSheetButton(imageName: "palette", text: "시간표 테마 설정") {
                print("tap")
            }
        }
    }
}
