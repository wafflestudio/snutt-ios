//
//  TabScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/25.
//

import SwiftUI

struct TabScene<Content>: View where Content: View {
    var systemState = AppState.of.system
    let tabType: AppState.TabType
    @State var isViewDisplayed = false
    @ViewBuilder var content: () -> Content

    var onImageName: String {
        "tab.\(tabType.rawValue).on"
    }

    var offImageName: String {
        "tab.\(tabType.rawValue).off"
    }

    var body: some View {
        NavigationView {
            self.content()
        }
        .accentColor(Color(UIColor.label))
        .tabItem {
            Image(self.isViewDisplayed ? onImageName : offImageName)
        }
        .onAppear {
            self.isViewDisplayed = true
        }
        .onDisappear {
            self.isViewDisplayed = false
        }
        .tag(tabType)
    }
}
