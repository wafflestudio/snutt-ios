//
//  WebErrorView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/24.
//

import SwiftUI

struct WebErrorView: View {
    let viewModel: ReviewViewModel

    var body: some View {
        VStack {
            Image("warning.cat")
            Spacer().frame(height: 20)
            Text("네트워크 연결을 확인해주세요")
                .font(.system(size: 17))
            Spacer().frame(height: 28)
            Button {
                viewModel.connectionState = .success
            } label: {
                Text("다시 불러오기")
                    .bold()
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            .frame(width: 130, height: 38)
            .background(STColor.cyan)
            .cornerRadius(8)
        }
    }
}

// struct WebErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//        WebErrorView()
//    }
// }
