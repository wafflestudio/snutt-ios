//
//  SettingsMenuItem.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import SwiftUI

struct SettingsTextItem: View {
    let title: String
    var detail: String? = nil
    var detailSystemImage: String? = nil
    var role: ButtonRole? = nil

    @Environment(\.hasNewBadgeClosure) var hasNewBadge: HasNewBadgeClosure?

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .foregroundColor(role == .destructive ? .red : .primary)
            
            if hasNewBadge?(title) == true {
                SettingsNewBadge()
            }
            
            Spacer()
            
            Group {
                Text(detail ?? "")
                
                if let image = detailSystemImage {
                    Image(systemName: image)
                }
            }
            .foregroundColor(Color.gray)
        }
        .contentShape(Rectangle())
    }
}

struct SettingsLinkItem<Destination>: View where Destination: View {
    let title: String
    var detail: String?
    var isActive: Binding<Bool>?
    let destination: () -> Destination

    var body: some View {
        if let isActive {
            NavigationLink(isActive: isActive) {
                destination()
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                SettingsTextItem(title: title, detail: detail)
            }
        } else {
            NavigationLink {
                destination()
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                SettingsTextItem(title: title, detail: detail)
            }
        }
    }
}

struct SettingsButtonItem: View {
    let title: String
    var detail: String? = nil
    var role: ButtonRole? = nil
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            SettingsTextItem(title: title, detail: detail, role: role)
        }
    }
}

struct SettingsNewBadge: View {
    var body: some View {
        Text("NEW!")
            .font(.system(size: 8, weight: .bold))
            .padding(.vertical, 3)
            .padding(.horizontal, 3)
            .background(STColor.cyan)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .padding(.horizontal, 5)
    }
}

typealias HasNewBadgeClosure = (String) -> Bool

private struct SettingsBadgeConfigKey: EnvironmentKey {
    static let defaultValue: HasNewBadgeClosure? = nil
}

extension EnvironmentValues {
    var hasNewBadgeClosure: HasNewBadgeClosure? {
        get { self[SettingsBadgeConfigKey.self] }
        set { self[SettingsBadgeConfigKey.self] = newValue }
    }
}
