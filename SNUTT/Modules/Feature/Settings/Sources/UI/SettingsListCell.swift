//
//  SettingsListCell.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct SettingsListCell<Menu: MenuItem>: View {
    let menu: Menu
    @Binding var path: [Destination]

    var showNewBadge: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
            if menu.shouldNavigate {
                switch menu {
                case let menu as Settings: path.append(Destination.settings(menu))
                case let menu as MyAccount: path.append(Destination.myAccount(menu))
                default:
                    return
                }
            }
        } label: {
            HStack(spacing: 0) {
                if let leadingImage = menu.leadingImage {
                    leadingImage
                    Spacer().frame(width: 4)
                }
                Text(menu.title)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        menu.destructive
                            ? SharedUIComponentsAsset.red.swiftUIColor
                            : Color.primary
                    )
                if showNewBadge {
                    Spacer().frame(width: 6)
                    NewBadgeView()
                }
                Spacer()
                Group {
                    if let detailImage = menu.detailImage {
                        detailImage
                    }
                    if let detail = menu.detail {
                        Text(detail)
                            .font(.system(size: 16))
                    }
                    if menu.shouldNavigate {
                        Image(systemName: "chevron.right")
                            .padding(.leading, 8)
                    }
                }
                .foregroundStyle(.gray)
            }
        }
        .contentShape(.rect)
        .disabled(!menu.shouldNavigate && onTap == nil)
    }
}
