//
//  Menu.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/14.
//

import SwiftUI

struct Menu {
    var title: String
    var destination: AnyView?
    var content: String?
    var destructive: Bool = false
    var action: (() -> ())?
    var shouldNavigate: Bool {
        return destination != nil
    }
    
    /// 탭하면 다른 화면으로 이동하는 메뉴입니다.
    init<Content>(_ menu: MenuType, _ destination: () -> Content) where Content: View {
        self.title = menu.title
        self.destination = AnyView(destination())
    }

    /// 다른 화면으로 이동하지 않고 정보만 보여주거나 탭할 시 Navigation 외의 액션을 하는 메뉴입니다.
    init(_ menu: MenuType, _ content: String? = "", destructive: Bool = false, action: (() -> ())? = nil) {
        self.title = menu.title
        self.content = content
        self.destructive = destructive
        self.action = action
    }
}

extension Menu {
    @ViewBuilder var view: some View {
        if shouldNavigate {
            NavigationLink(destination: destination) {
                bodyView
            }
        } else {
            bodyView
            .contentShape(Rectangle())
            .onTapGesture {
                (action ?? {})()
            }
        }
    }
    
    @ViewBuilder private var bodyView: some View {
        HStack {
            Text(title)
                .foregroundColor(destructive ? .red : .primary)
            Spacer()
            Text(content ?? "")
                .foregroundColor(Color.gray)
        }
    }
}

extension Menu: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(content)
        hasher.combine(shouldNavigate)
    }
    
    static func == (lhs: Menu, rhs: Menu) -> Bool {
        return lhs.title == rhs.title && lhs.shouldNavigate == rhs.shouldNavigate && lhs.content == rhs.content
    }
}
