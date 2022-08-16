//
//  SettingScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import SwiftUI

struct Menu: Hashable {
    var title: String
    var view: AnyView?
    var showOnly: Bool {
        return view == nil
    }
    var content: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(showOnly)
    }
    
    /// 탭하면 다른 화면으로 navigate되는 메뉴입니다. 메뉴명 title과 이동할 View를 인자로 받습니다.
    init(_ title: String, _ view: AnyView? = nil) {
        self.title = title
        self.view = view
    }
    
    /// 다른 화면으로 이동하지 않고, 정보만 보여주는 메뉴입니다. 메뉴명 title을 필수로 받고, 필요에 따라 추가로 보여줄 정보인 content를 인자로 받습니다.
    init(_ title: String, _ content: String?) {
        self.title = title
        self.content = content
    }
    
    static func == (lhs: Menu, rhs: Menu) -> Bool {
        return lhs.title == rhs.title && lhs.showOnly == rhs.showOnly
    }
}

struct SettingScene: View {
    let viewModel: SettingViewModel
    
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
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)

        let _ = debugChanges()
    }
    
//    @ViewBuilder func singleRow(label: String, destination: some View) -> some View {
//        NavigationLink(destination: destination) {
//            Text(label)
//        }
//    }
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
