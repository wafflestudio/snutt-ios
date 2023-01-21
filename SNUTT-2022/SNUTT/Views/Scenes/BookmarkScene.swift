//
//  BookmarkScene.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import SwiftUI

struct BookmarkScene: View {
    @ObservedObject var viewModel: SearchSceneViewModel
    var navigationBarHeight: CGFloat

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BookmarkScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookmarkScene(viewModel: .init(container: .preview), navigationBarHeight: 80)
        }
    }
}
