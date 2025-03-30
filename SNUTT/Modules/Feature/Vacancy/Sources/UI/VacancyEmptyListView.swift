//
//  VacancyEmptyListView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility

struct VacancyEmptyListView: View {
    let seeMore: () -> Void

    private enum Design {
        static let buttonForegroundColor = Color.label.opacity(0.6)
    }

    var body: some View {
        VStack(spacing: 15) {
            VacancyAsset.vacancyEmpty.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 260)

            Button {
                seeMore()
            } label: {
                HStack(spacing: 5) {
                    VacancyAsset.vacancyInfo.swiftUIImage
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 14)
                        .foregroundColor(Design.buttonForegroundColor)
                    Text("자세히 보기")
                        .font(.system(size: 13))
                        .underline()
                        .foregroundColor(Design.buttonForegroundColor)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    VacancyEmptyListView(seeMore: {})
}
