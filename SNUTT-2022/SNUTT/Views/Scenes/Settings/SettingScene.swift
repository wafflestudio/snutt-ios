//
//  SettingScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import SwiftUI

struct SettingScene: View {
    let viewModel: SettingViewModel
    
    var menuList: [[Menu]] {
        return viewModel.menuList
    }

    var body: some View {
        List(menuList, id: \.self) { section in
            Section {
                ForEach(section, id: \.self) { menu in
                    menu.show()
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)

        let _ = debugChanges()
    }
}

struct SettingScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TabView {
                SettingScene(viewModel: .init(container: .preview))
            }
        }
    }
}
