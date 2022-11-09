//
//  PopupView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/03.
//

import SwiftUI

struct PopupView: View {
    let popup: Popup
    let dismissOnce: (PopupView) -> Void
    let dismissNdays: (PopupView) -> Void

    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: popup.imageURL)!) { popupImage in
                popupImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 230, height: 280)
                    .clipped()
            } placeholder: {
                ProgressView()
            }

            HStack {
                Spacer()

                Button {
                    dismissNdays(self)
                } label: {
                    Text("당분간 보지 않기")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }.frame(width: 105)

                Spacer()

                Rectangle()
                    .frame(width: 1, height: 17)
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                Button {
                    dismissOnce(self)
                } label: {
                    Text("닫기")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }.frame(width: 60)

                Spacer()
            }.frame(height: 33)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView(
            popup: .init(id: "", imageURL: "https://avatars.githubusercontent.com/u/70614553?v=4", hiddenDays: 0, lastUpdate: nil),
            dismissOnce: { _ in
                print("닫기")
            },
            dismissNdays: { _ in
                print("당분간 보지 않기")
            }
        )
        .background(.black.opacity(0.2))
    }
}
