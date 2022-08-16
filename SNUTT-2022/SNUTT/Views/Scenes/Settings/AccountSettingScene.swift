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
        List(menuList, id: \.self) { menu in
            Section {
                ForEach(menu, id: \.self) { content in
                    if content.showOnly {
                        HStack {
                            Text(content.title)
                            Spacer()
                            Text(content.content ?? "")
                                .foregroundColor(Color.gray)
                        }
                    } else {
                        NavigationLink(destination: content.view) {
                            Text(content.title)
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle("계정 관리")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct AccountSettingScene_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountSettingScene(viewModel: AccountSettingViewModel())
//    }
//}
