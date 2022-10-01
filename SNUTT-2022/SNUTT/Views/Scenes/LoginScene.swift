//
//  LoginScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import SwiftUI

struct LoginScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var id: String = "snuttiostest123"
    @State private var password: String = "snuttiostest123"

    var body: some View {
        VStack {
            TextField("아이디", text: $id)
            TextField("비밀번호", text: $password)
            Button {
                Task {
                    try! await viewModel.container.services.authService.loginWithId(id: id, password: password)
                }
            } label: {
                Text("로그인")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
    }
}

extension LoginScene {
    class ViewModel: BaseViewModel, ObservableObject {}
}

// struct LoginScene_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginScene()
//    }
// }
