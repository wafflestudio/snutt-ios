//
//  IntegrateAccountScene.swift
//  SNUTT
//
//  Created by 이채민 on 7/3/24.
//

import SwiftUI

struct IntegrateAccountScene: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isDisconnectFBAlertPresented: Bool = false
    
    var body: some View {
        List {
                if let facebookName = viewModel.currentUser?.fbName {
                    SettingsTextItem(title: "페이스북 이름", detail: facebookName)
                    SettingsButtonItem(title: "페이스북 계정 연동 해제", role: .destructive) {
                        isDisconnectFBAlertPresented = true
                    }
                } else {
                    SettingsButtonItem(title: "페이스북 계정 연동") {
                        viewModel.performFacebookSignIn()
                    }
                }
            
        }
        .alert("페이스북 계정 연동 해제", isPresented: $isDisconnectFBAlertPresented) {
            Button("취소", role: .cancel, action: {})
            Button("해제", role: .destructive, action: {
                Task {
                    await viewModel.detachFacebook()
                }
            })
        } message: {
            Text("페이스북 연동을 해제하시겠습니까?")
        }
    }
}

#if DEBUG
    struct IntegrateAccountScene_Previews: PreviewProvider {
        static var previews: some View {
            IntegrateAccountScene(viewModel: .init(container: .preview))
        }
    }
#endif
