//
//  PopupView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/03.
//

import SwiftUI

struct PopupView: View {
    let popup: Popup
    let dismiss: @MainActor (Popup, Bool) -> Void // dismiss(popup:dontShowForWhile:)

    var body: some View {
        AsyncImage(url: URL(string: popup.imageURL)!, transaction: Transaction(animation: .customSpring)) { phase in
            switch phase {
            case let .success(popupImage):
                VStack(spacing: 0) {
                    popupImage
                        .resizable()
                        .scaledToFit()

                    HStack {
                        Spacer()

                        Button {
                            dismiss(popup, true)
                        } label: {
                            Text("당분간 보지 않기")
                                .foregroundColor(.white)
                                .font(STFont.regular14.font)
                        }

                        Spacer()

                        Rectangle()
                            .frame(width: 1, height: 17)
                            .foregroundColor(.white.opacity(0.5))

                        Spacer()

                        Button {
                            dismiss(popup, false)
                        } label: {
                            Text("닫기")
                                .foregroundColor(.white)
                                .font(STFont.regular14.font)
                        }

                        Spacer()
                    }.frame(height: 33)
                }
            default:
                ProgressView()
            }
        }
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(
            popup: .init(
                id: "",
                imageURL: "https://avatars.githubusercontent.com/u/70614553?v=4",
                hiddenDays: 0,
                dismissedAt: nil,
                dontShowForWhile: false
            ),
            dismiss: { _, _ in
            }
        )
        .background(.black.opacity(0.2))
    }
}
