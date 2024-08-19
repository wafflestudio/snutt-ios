//
//  EllipsisSheetButton.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct EllipsisSheetButton: View {
    let menu: Menu

    /// An optional property used to fix animation glitch in iOS 16. See this [Pull Request](https://github.com/wafflestudio/snutt-ios/pull/132).
    var isSheetOpen: Bool = false

    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Image(menu.imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 12)

                Spacer().frame(width: 9)

                Text(menu.text)
                    .font(STFont.detailLabel.font)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .animation(.customSpring, value: isSheetOpen)
        }
        .buttonStyle(RectangleButtonStyle())
    }
}

extension EllipsisSheetButton {
    enum Menu {
        case edit
        case primary(isOn: Bool)
        case theme
        case delete

        var imageName: String {
            switch self {
            case .edit: return "sheet.edit"
            case .primary(true): return "sheet.friend.off"
            case .primary(false): return "sheet.friend"
            case .theme: return "sheet.palette"
            case .delete: return "sheet.trash"
            }
        }

        var text: String {
            switch self {
            case .edit: return "이름 변경"
            case .primary(true): return "학기 대표 시간표 해제"
            case .primary(false): return "학기 대표 시간표로 지정"
            case .theme: return "시간표 테마 설정"
            case .delete: return "시간표 삭제"
            }
        }
    }
}

struct EllipsisSheetButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            EllipsisSheetButton(menu: .edit) {
                print("tap")
            }
            EllipsisSheetButton(menu: .primary(isOn: true)) {
                print("tap")
            }
            EllipsisSheetButton(menu: .theme) {
                print("tap")
            }
            EllipsisSheetButton(menu: .delete) {
                print("tap")
            }
        }
    }
}
