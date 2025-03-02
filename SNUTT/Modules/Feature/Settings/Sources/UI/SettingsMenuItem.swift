//
//  SettingsMenuItem.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents

struct SettingsMenuItem: View {
    
    let title: String
    var detail: String? = nil
    var image: Image? = nil
    
    var destructive: Bool = false
    var showNewBadge: Bool = false
    
    var onTap: () -> Void = {}
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                if let image = image {
                    image
                    Spacer().frame(width: 4)
                }
                Text(title)
                    .foregroundStyle(destructive
                                     ? SharedUIComponentsAsset.red.swiftUIColor
                                     : Color.primary)
                if showNewBadge {
                    Spacer().frame(width: 6)
                    NewBadge()
                }
                Spacer()
                if let detail = detail {
                    Text(detail)
                        .foregroundStyle(.gray)
                }
            }
        }
        .contentShape(.rect)
    }
}

struct SettingsNavigationItem<Destination>: View where Destination: View {
    let title: String
    var detail: String? = nil
    var image: Image? = nil
    
    var destructive: Bool = false
    var showNewBadge: Bool = false
    var destination: Destination
    
    var onTap: () -> Void = {}
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            SettingsMenuItem(title: title, detail: detail, image: image, destructive: destructive, showNewBadge: showNewBadge, onTap: onTap)
        }
    }
}
