//
//  AccountSettingScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct AccountSettingScene: View {
    let viewModel: AccountSettingViewModel
    
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
        .navigationTitle("계정 관리")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccountSettingScene_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingScene(viewModel: .init(container: .preview))
    }
}
