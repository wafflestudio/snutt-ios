//
//  SettingScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import SwiftUI

struct SettingScene: View {
    let viewModel: SettingViewModel

    var body: some View {
        Button {
            viewModel.updateCurrentUser(user: User())
        } label: {
            Text("Change current user")
        }

        let _ = debugChanges()
    }
}

struct SettingScene_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        NavigationView {
            TabView {
                SettingScene(viewModel: SettingViewModel(appState: appState))
            }
        }
    }
}