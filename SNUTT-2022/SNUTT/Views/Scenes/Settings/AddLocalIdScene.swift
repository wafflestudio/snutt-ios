//
//  AddLocalIdScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/12.
//

import SwiftUI

struct AddLocalIdScene: View {
    
    private enum Field {
        case id, password, passwordCheck
    }
    
    let viewModel: AddLocalIdViewModel

    @State var id: String = ""
    @State var password: String = ""
    @State var passwordCheck: String = ""
    @FocusState private var focusedTextField: Field?
    
    var body: some View {
        ZStack {
            VStack(spacing: 72) {
                Spacer()
                VStack(spacing: 32) {
                    UnderlinedTextField(placeholder: "아이디(4자 이상)", text: $id)
                        .focused($focusedTextField, equals: .id)
                    UnderlinedTextField(placeholder: "비밀번호(6자 이상)", text: $password)
                        .focused($focusedTextField, equals: .password)
                    UnderlinedTextField(placeholder: "비밀번호 확인", text: $passwordCheck)
                        .focused($focusedTextField, equals: .passwordCheck)
                }
                VStack(spacing: 32) {
                    Button {
                        viewModel.addLocalId(id: id, password: password, passwordCheck: passwordCheck)
                    } label: {
                        Text("아이디 비번 추가")
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .border(Color(uiColor: .label.withAlphaComponent(0.25)), width: 1)
                    
                    Text("위 버튼을 누르시면 **일반 이용 약관**에 동의하시게 됩니다.".markdown)
                        .font(.caption)
                        .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.5)))
                }
                Spacer()
            }
            .padding(.horizontal, 32)
            .navigationTitle("아이디 비번 추가")
            .navigationBarTitleDisplayMode(.inline)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedTextField = nil
        }
    }
}

struct UnderlinedTextField: View {
    @State var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
                .frame(height: 25)
            Divider()
                .frame(height: 1)
        }
    }
}

struct AddLocalIdScene_Previews: PreviewProvider {
    static var previews: some View {
        AddLocalIdScene(viewModel: AddLocalIdViewModel(container: .preview), id: "", password: "", passwordCheck: "")
    }
}
