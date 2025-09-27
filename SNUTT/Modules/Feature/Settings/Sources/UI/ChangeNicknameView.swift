//
//  ChangeNicknameView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI

struct ChangeNicknameView: View {
    let viewModel: MyAccountViewModel

    @State private var new: String = ""
    @State private var isNicknameChanged: Bool = false

    @FocusState private var isFocused: Bool

    private var isButtonDisabled: Bool {
        new.isEmpty || new.count > 10 || (viewModel.previousNickname == new)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    TextField("", text: $new, prompt: Text(viewModel.previousNickname))
                        .font(.system(size: 16))
                        .focused($isFocused)

                    if isFocused {
                        Button {
                            new = ""
                            isFocused = false
                        } label: {
                            Image("xbutton")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }

                    Spacer().frame(width: 2)

                    Text("#NNNN")
                        .font(.system(size: 16))
                        .foregroundColor(Color(uiColor: UIColor.tertiaryLabel))
                }
            } header: {
                Text("닉네임 (공백 포함 한/영/숫자 10자 이내)")
                    .font(.system(size: 12))
            } footer: {
                VStack(alignment: .leading) {
                    Spacer().frame(height: 8)

                    Text("최초 닉네임은 가입 시 임의 부여된 닉네임으로,\n앞의 이름을 변경할 시 4자리 숫자 태그는 자동 변경됩니다.\n\n변경된 닉네임은 나의 모든 친구에게 반영됩니다.")

                    Spacer().frame(height: 30)

                    Text(
                        "**닉네임 조건**\n\u{2022} 불완전한 한글(예: ㄱ, ㅏ)은 포함될 수 없습니다.\n\u{2022} 영문 대/소문자는 구분됩니다.\n\u{2022} 상대에게 불쾌감을 주는 등 부적절한 닉네임은 관리자에 의해 안내 없이 수정될 수 있습니다."
                            .asMarkdown()
                    )
                    .lineSpacing(4)
                }
                .font(.system(size: 12))
            }
        }
        .navigationTitle(Text("닉네임 변경"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await errorAlertHandler.withAlert {
                            try await viewModel.changeNickname(to: new)
                            isNicknameChanged = true
                        }
                    }
                } label: {
                    Text("저장")
                }
                .disabled(isButtonDisabled)
            }
        }
        .alert("닉네임이 변경되었습니다.", isPresented: $isNicknameChanged) {
            Button("확인") {
                dismiss()
            }
        }
        .animation(.defaultSpring, value: isFocused)
    }
}

extension MyAccountViewModel {
    var previousNickname: String {
        switch loadState {
        case .loaded(let user):
            user.nickname.nickname
        case .loading:
            ""
        }
    }
}
