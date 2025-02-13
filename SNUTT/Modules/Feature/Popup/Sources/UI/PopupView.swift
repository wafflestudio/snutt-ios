//
//  PopupView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct PopupView: View {
    let viewModel: PopupViewModel
    let popup: PopupModel

    private enum Design {
        static let font: Font = .system(size: 14)
    }

    var body: some View {
        AsyncImage(url: popup.imageURL, transaction: Transaction(animation: .defaultSpring)) { phase in
            switch phase {
            case let .success(popupImage):
                VStack(spacing: 0) {
                    popupImage
                        .resizable()
                        .scaledToFit()

                    HStack {
                        Spacer()

                        Button {
                            viewModel.dismiss(popup: popup, dontShowForWhile: true)
                        } label: {
                            Text(PopupStrings.popupDontShowForWhile)
                                .foregroundColor(.white)
                                .font(Design.font)
                        }

                        Spacer()

                        Rectangle()
                            .frame(width: 1, height: 17)
                            .foregroundColor(.white.opacity(0.5))

                        Spacer()

                        Button {
                            viewModel.dismiss(popup: popup, dontShowForWhile: false)
                        } label: {
                            Text(PopupStrings.popupDismiss)
                                .foregroundColor(.white)
                                .font(Design.font)
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
