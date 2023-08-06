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
    var role: ButtonRole? = nil

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(role == .destructive ? .red : .primary)
            Spacer()
            Text(detail ?? "")
                .foregroundColor(Color.gray)
        }
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
