//
//  TabScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import SwiftUI

struct TabScene<Content>: View where Content: View {
    let tabType: TabType
    @State var isViewVisible = false
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
        // workaround to prevent unintend popping back
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(UIColor.label))
        .tabItem {
            Image(self.isViewVisible ? onImageName : offImageName)
        }
        .onAppear {
            self.isViewVisible = true
        }
        .onDisappear {
            self.isViewVisible = false
        }
        .tag(tabType)
        let _ = debugChanges()
    }
}
