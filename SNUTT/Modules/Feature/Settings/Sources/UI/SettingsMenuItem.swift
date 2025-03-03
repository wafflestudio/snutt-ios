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
    var leadingImage: Image? = nil
    
    var detail: String? = nil
    var detailImage: Image? = nil
    
    var destructive: Bool = false
    var showNewBadge: Bool = false
    
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 0) {
                if let leadingImage = leadingImage {
                    leadingImage
                    Spacer().frame(width: 4)
                }
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(destructive
                                     ? SharedUIComponentsAsset.red.swiftUIColor
                                     : Color.primary)
                if showNewBadge {
                    Spacer().frame(width: 6)
                    NewBadge()
                }
                Spacer()
                Group {
                    if let detailImage = detailImage {
                        detailImage
                    }
                    if let detail = detail {
                        Text(detail)
                            .font(.system(size: 16))
                    }
                }
                .foregroundStyle(.gray)
            }
        }
        .contentShape(.rect)
        .disabled(onTap == nil)
    }
}

struct SettingsNavigationItem<Destination>: View where Destination: View {
    let title: String
    var leadingImage: Image? = nil
    
    var detail: String? = nil
    var detailImage: Image? = nil
    
    var destructive: Bool = false
    var showNewBadge: Bool = false
    var destination: Destination
    
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            SettingsMenuItem(title: title,
                             leadingImage: leadingImage,
                             detail: detail,
                             detailImage: detailImage,
                             destructive: destructive,
                             showNewBadge: showNewBadge,
                             onTap: onTap)
        }
    }
}
